import { useRef, useState, type ReactNode } from 'react'
import { AlertCircle, Check, Copy, Pencil, Tag, Trash2 } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { fmtDate, fmtDateTime, money, payLabel } from '../lib/format'
import type { CatalogItem, Invoice } from '../types'
import { useFeedback } from './Feedback'
import { InvoiceForm } from './InvoiceForm'
import { ItemPicker } from './ItemPicker'
import { Sheet } from './Sheet'
import { Badge, Button, Money, StoreDot, cx } from './ui'

export function ItemChips({ invoice, max = 2 }: { invoice: Invoice; max?: number }) {
  if (!invoice.lines.length) {
    return (
      <Badge tone="warn">
        <AlertCircle className="size-3.5" /> غير مصنّفة
      </Badge>
    )
  }
  const shown = invoice.lines.slice(0, max)
  return (
    <>
      {shown.map((l) => (
        <Badge key={l.item_id} tone={l.kind === 'service' ? 'primary' : 'success'}>
          {l.name}
        </Badge>
      ))}
      {invoice.lines.length > max && <Badge>+{invoice.lines.length - max}</Badge>}
    </>
  )
}

/** One invoice in a list. Long-press (or tap in select mode) toggles selection. */
export function InvoiceCard({
  invoice,
  onOpen,
  selectMode,
  selected,
  onToggle,
  showStore = true,
}: {
  invoice: Invoice
  onOpen: () => void
  selectMode?: boolean
  selected?: boolean
  onToggle?: () => void
  showStore?: boolean
}) {
  const timer = useRef<number>(undefined)
  const longPressed = useRef(false)
  const start = () => {
    if (!onToggle) return
    longPressed.current = false
    timer.current = window.setTimeout(() => {
      longPressed.current = true
      navigator.vibrate?.(15)
      onToggle()
    }, 450)
  }
  const cancel = () => window.clearTimeout(timer.current)

  return (
    <button
      onClick={() => {
        if (longPressed.current) return
        if (selectMode) onToggle?.()
        else onOpen()
      }}
      onPointerDown={start}
      onPointerUp={cancel}
      onPointerLeave={cancel}
      onPointerCancel={cancel}
      onContextMenu={(e) => onToggle && e.preventDefault()}
      className={cx(
        'flex w-full items-start gap-3 rounded-3xl border bg-surface p-4 text-start shadow-card transition select-none active:scale-[0.99]',
        selected ? 'border-primary ring-2 ring-primary/30' : 'border-line',
      )}
    >
      {selectMode && (
        <span className={cx('mt-1 flex size-6 shrink-0 items-center justify-center rounded-lg border-2', selected ? 'border-primary bg-primary text-primary-fg' : 'border-line')}>
          {selected && <Check className="size-4" strokeWidth={3} />}
        </span>
      )}
      <span className="min-w-0 flex-1">
        <span className="flex items-start justify-between gap-3">
          <span className="min-w-0 truncate text-[17px] font-semibold">{invoice.customer_name || 'بدون اسم'}</span>
          <Money value={invoice.amount} className="shrink-0 text-[17px] font-bold" />
        </span>
        <span className="mt-1 flex items-center gap-2 text-[14px] text-muted">
          {showStore && (
            <span className="flex min-w-0 items-center gap-1.5">
              <StoreDot color={invoice.store_color} />
              <span className="truncate">{invoice.store_name}</span>
            </span>
          )}
          {showStore && <span>·</span>}
          <span className="shrink-0">{fmtDate(invoice.paid_at)}</span>
          {invoice.invoice_no && (
            <>
              <span>·</span>
              <span className="num shrink-0">#{invoice.invoice_no}</span>
            </>
          )}
        </span>
        <span className="mt-2 flex flex-wrap gap-1.5">
          <ItemChips invoice={invoice} />
        </span>
      </span>
    </button>
  )
}

function Row({ label, children, copy }: { label: string; children: ReactNode; copy?: string | null }) {
  const { toast } = useFeedback()
  if (children === null || children === undefined || children === '') return null
  return (
    <div className="flex min-h-12 items-center justify-between gap-4 border-b border-line py-2.5 last:border-0">
      <span className="shrink-0 text-[15px] text-muted">{label}</span>
      <span className="flex min-w-0 items-center gap-1.5 text-end text-[15px] font-medium">
        <span className="min-w-0 break-all">{children}</span>
        {copy && (
          <button
            aria-label="نسخ"
            className="shrink-0 p-1 text-muted"
            onClick={() => {
              navigator.clipboard?.writeText(copy).then(() => toast('تم النسخ'), () => {})
            }}
          >
            <Copy className="size-4" />
          </button>
        )}
      </span>
    </div>
  )
}

/** Invoice details with quick classify, edit and delete. */
export function InvoiceSheet({
  invoice,
  onClose,
  onChanged,
  onDeleted,
}: {
  invoice: Invoice | null
  onClose: () => void
  onChanged: (inv: Invoice) => void
  onDeleted: (id: number) => void
}) {
  const { can } = useApp()
  const { toast, confirm } = useFeedback()
  const [editing, setEditing] = useState(false)
  const [picker, setPicker] = useState(false)
  const [busy, setBusy] = useState(false)

  const close = () => {
    setEditing(false)
    onClose()
  }

  const classify = async (item: CatalogItem) => {
    if (!invoice) return
    if (invoice.lines.some((l) => l.item_id === item.id)) return
    setBusy(true)
    try {
      // The first item takes the whole amount; adding to existing lines keeps their prices.
      const body = invoice.lines.length
        ? {
            items: [
              ...invoice.lines.map((l) => ({ item_id: l.item_id, qty: l.qty, unit_price: l.unit_price })),
              { item_id: item.id, qty: 1, unit_price: item.default_price ?? 0 },
            ],
          }
        : { items: [{ item_id: item.id }] }
      const r = await api<{ invoice: Invoice }>(`invoices/${invoice.id}`, { method: 'PUT', body })
      onChanged(r.invoice)
      toast('تم تحديد الخدمة/المنتج')
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setBusy(false)
    }
  }

  const removeLine = async (itemId: number) => {
    if (!invoice) return
    const rest = invoice.lines.filter((l) => l.item_id !== itemId)
    try {
      const r = await api<{ invoice: Invoice }>(`invoices/${invoice.id}`, {
        method: 'PUT',
        body: { items: rest.length === 1 ? [{ item_id: rest[0].item_id, qty: rest[0].qty }] : rest.map((l) => ({ item_id: l.item_id, qty: l.qty, unit_price: l.unit_price })) },
      })
      onChanged(r.invoice)
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  const remove = async () => {
    if (!invoice) return
    const ok = await confirm({
      title: 'حذف الفاتورة؟',
      text: `سيتم حذف فاتورة ${invoice.customer_name ?? ''} بمبلغ ${money(invoice.amount)} ر.س نهائياً.`,
      confirmLabel: 'حذف',
      danger: true,
    })
    if (!ok) return
    try {
      await api(`invoices/${invoice.id}`, { method: 'DELETE' })
      toast('تم حذف الفاتورة')
      onDeleted(invoice.id)
      close()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  return (
    <Sheet open={!!invoice} onClose={close} title={editing ? 'تعديل الفاتورة' : 'تفاصيل الفاتورة'}>
      {invoice && editing && (
        <InvoiceForm
          initial={invoice}
          onCancel={() => setEditing(false)}
          onSaved={(inv) => {
            onChanged(inv)
            setEditing(false)
          }}
        />
      )}
      {invoice && !editing && (
        <div>
          <div className="mb-4 rounded-3xl bg-surface-2 p-5 text-center">
            <Money value={invoice.amount} className="text-[32px] font-bold" />
            <p className="mt-1 text-[16px] font-semibold">{invoice.customer_name || 'بدون اسم'}</p>
            <p className="mt-1 flex items-center justify-center gap-1.5 text-[14px] text-muted">
              <StoreDot color={invoice.store_color} /> {invoice.store_name} · {fmtDateTime(invoice.paid_at)}
            </p>
          </div>

          <div className="mb-4 rounded-3xl border border-line p-4">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-[16px] font-semibold">الخدمة / المنتج</p>
              {can('editor') && (
                <Button size="sm" variant="soft" loading={busy} icon={<Tag className="size-4" />} onClick={() => setPicker(true)}>
                  {invoice.lines.length ? 'إضافة' : 'تحديد'}
                </Button>
              )}
            </div>
            {!invoice.lines.length && <p className="rounded-2xl bg-warn-soft px-4 py-3 text-[15px] font-medium text-warn">هذه الفاتورة غير مصنّفة بعد</p>}
            <div className="space-y-1.5">
              {invoice.lines.map((l) => (
                <div key={l.item_id} className="flex items-center gap-2 rounded-2xl bg-surface-2 px-3 py-2.5">
                  <Badge tone={l.kind === 'service' ? 'primary' : 'success'}>{l.kind === 'service' ? 'خدمة' : 'منتج'}</Badge>
                  <span className="min-w-0 flex-1 truncate text-[15px] font-semibold">
                    {l.name}
                    {!l.is_active && <span className="ms-1 text-[12px] text-muted">(مؤرشف)</span>}
                  </span>
                  {invoice.lines.length > 1 && (
                    <span className="num text-[14px] text-muted">
                      {l.qty !== 1 && `${l.qty} × `}
                      {money(l.unit_price)}
                    </span>
                  )}
                  {can('editor') && (
                    <button aria-label="إزالة" className="p-1 text-muted hover:text-danger" onClick={() => removeLine(l.item_id)}>
                      <Trash2 className="size-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          {invoice.note && (
            <div className="mb-4 rounded-3xl border border-line p-4">
              <p className="mb-1 text-[14px] text-muted">ملاحظة</p>
              <p className="whitespace-pre-wrap text-[16px]">{invoice.note}</p>
            </div>
          )}

          <div className="rounded-3xl border border-line px-4">
            <Row label="الجوال" copy={invoice.phone}>
              {invoice.phone && <span className="num">{invoice.phone}</span>}
            </Row>
            <Row label="الإيميل" copy={invoice.email}>
              {invoice.email && <span className="num">{invoice.email}</span>}
            </Row>
            <Row label="رقم الفاتورة">{invoice.invoice_no && <span className="num">{invoice.invoice_no}</span>}</Row>
            <Row label="طريقة الدفع">{invoice.pay_method && payLabel(invoice.pay_method)}</Row>
            <Row label="البطاقة">
              {(invoice.card_type || invoice.card_last4) && (
                <span className="num">
                  {invoice.card_type} {invoice.card_last4 && `•••• ${invoice.card_last4}`}
                </span>
              )}
            </Row>
            <Row label="الرقم المرجعي" copy={invoice.reference_no}>
              {invoice.reference_no && <span className="num">{invoice.reference_no}</span>}
            </Row>
            <Row label="رمز التفويض">{invoice.auth_code && <span className="num">{invoice.auth_code}</span>}</Row>
            <Row label="رقم الجهاز">{invoice.terminal_id && <span className="num">{invoice.terminal_id}</span>}</Row>
            <Row label="رقم العملية" copy={invoice.transaction_id}>
              {invoice.transaction_id && <span className="num text-[13px]">{invoice.transaction_id}</span>}
            </Row>
            <Row label="المصدر">{invoice.source === 'import' ? 'استيراد Excel' : 'إدخال يدوي'}</Row>
            <Row label="أضافها">{invoice.created_by_name && `${invoice.created_by_name} · ${fmtDate(invoice.created_at)}`}</Row>
            {invoice.updated_by_name && invoice.updated_at !== invoice.created_at && (
              <Row label="آخر تعديل">{`${invoice.updated_by_name} · ${fmtDate(invoice.updated_at)}`}</Row>
            )}
          </div>

          {can('editor') && (
            <div className="mt-5 flex gap-3">
              <Button block variant="secondary" icon={<Pencil className="size-5" />} onClick={() => setEditing(true)}>
                تعديل
              </Button>
              <Button block variant="danger" icon={<Trash2 className="size-5" />} onClick={remove}>
                حذف
              </Button>
            </div>
          )}
          <ItemPicker open={picker} onClose={() => setPicker(false)} storeId={invoice.store_id} onPick={classify} />
        </div>
      )}
    </Sheet>
  )
}

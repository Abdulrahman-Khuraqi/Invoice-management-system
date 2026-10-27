import { useRef, useState, type ReactNode } from 'react'
import { AlertCircle, Check, Copy, FileDown, ImageDown, Pencil, Tag, Trash2 } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { fmtDate, fmtDateTime, money, payLabel } from '../lib/format'
import type { CatalogItem, Invoice } from '../types'
import { useFeedback } from './Feedback'
import { InvoiceForm } from './InvoiceForm'
import { InvoicePaperPreview, useInvoicePaperExport } from './InvoicePaper'
import { ItemPicker } from './ItemPicker'
import { Sheet } from './Sheet'
import { Badge, Button, Money, Segmented, StoreDot, cx } from './ui'
import { t } from '../lib/i18n'

export function ItemChips({ invoice, max = 2 }: { invoice: Invoice; max?: number }) {
  if (!invoice.lines.length) {
    return (
      <Badge tone="warn">
        <AlertCircle className="size-3.5" />  {t('غير مصنّفة')}
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
          <span className="min-w-0 truncate text-[17px] font-semibold">{invoice.customer_name || t('بدون اسم')}</span>
          <Money value={invoice.amount} className="shrink-0 text-[17px] font-bold" />
        </span>
        <span className="mt-1 flex items-center gap-2 text-[14px] text-muted">
          {showStore && (
            <span className="flex min-w-0 items-center gap-1.5">
              <StoreDot color={invoice.store_color} storeId={invoice.store_id} />
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

/** Desktop list: one row per invoice, columns instead of stacked card text. */
export function InvoiceTable({
  invoices,
  onOpen,
  selectMode,
  selected,
  onToggle,
  onToggleAll,
  showStore = true,
}: {
  invoices: Invoice[]
  onOpen: (inv: Invoice) => void
  selectMode?: boolean
  selected?: Set<number>
  onToggle?: (id: number) => void
  onToggleAll?: () => void
  showStore?: boolean
}) {
  const allSelected = !!selected && invoices.length > 0 && selected.size === invoices.length
  const box = (on: boolean) => (
    <span className={cx('flex size-5 items-center justify-center rounded-md border-2', on ? 'border-primary bg-primary text-primary-fg' : 'border-line')}>
      {on && <Check className="size-3.5" strokeWidth={3} />}
    </span>
  )
  const th = 'px-4 py-3 text-start text-[13px] font-semibold text-muted'
  return (
    <div className="overflow-hidden rounded-2xl border border-line bg-surface shadow-card">
      <table className="w-full border-collapse text-[14px]">
        <thead className="bg-surface-2/60">
          <tr className="border-b border-line">
            {onToggle && (
              <th className="w-12 ps-4">
                <button aria-label={t('تحديد الكل')} onClick={onToggleAll} className="flex items-center">
                  {box(allSelected)}
                </button>
              </th>
            )}
            <th className={th}>{t('العميل')}</th>
            {showStore && <th className={th}>{t('المتجر')}</th>}
            <th className={th}>{t('التاريخ')}</th>
            <th className={th}>{t('الخدمة / المنتج')}</th>
            <th className={th}>{t('الدفع')}</th>
            <th className={cx(th, 'text-end')}>{t('المبلغ')}</th>
          </tr>
        </thead>
        <tbody>
          {invoices.map((inv) => {
            const on = !!selected?.has(inv.id)
            return (
              <tr
                key={inv.id}
                onClick={() => (selectMode ? onToggle?.(inv.id) : onOpen(inv))}
                className={cx('cursor-pointer border-b border-line transition last:border-0 hover:bg-surface-2/70', on && 'bg-primary-soft/60')}
              >
                {onToggle && (
                  <td className="ps-4" onClick={(e) => (e.stopPropagation(), onToggle(inv.id))}>
                    {box(on)}
                  </td>
                )}
                <td className="max-w-[240px] px-4 py-3">
                  <span className="block truncate font-semibold leading-snug">{inv.customer_name || t('بدون اسم')}</span>
                  {inv.invoice_no && <span className="num block text-[12px] leading-snug text-muted">#{inv.invoice_no}</span>}
                </td>
                {showStore && (
                  <td className="px-4 py-3">
                    <span className="flex items-center gap-2">
                      <StoreDot color={inv.store_color} storeId={inv.store_id} />
                      <span className="truncate">{inv.store_name}</span>
                    </span>
                  </td>
                )}
                <td className="whitespace-nowrap px-4 py-3 text-muted">{fmtDate(inv.paid_at)}</td>
                <td className="px-4 py-3">
                  <span className="flex flex-wrap gap-1.5">
                    <ItemChips invoice={inv} />
                  </span>
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-muted">{payLabel(inv.pay_method)}</td>
                <td className="px-4 py-3 text-end">
                  <Money value={inv.amount} className="font-bold" />
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
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
            aria-label={t('نسخ')}
            className="shrink-0 p-1 text-muted"
            onClick={() => {
              navigator.clipboard?.writeText(copy).then(() => toast(t('تم النسخ')), () => {})
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
  const [view, setView] = useState<'paper' | 'details'>('paper')
  const paperExport = useInvoicePaperExport(invoice)

  const close = () => {
    setEditing(false)
    setView('paper')
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
      toast(t('تم تحديد الخدمة/المنتج'))
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
      title: t('حذف الفاتورة؟'),
      text: t('سيتم حذف فاتورة {0} بمبلغ {1} ر.س نهائياً.', invoice.customer_name ?? '', money(invoice.amount)),
      confirmLabel: t('حذف'),
      danger: true,
    })
    if (!ok) return
    try {
      await api(`invoices/${invoice.id}`, { method: 'DELETE' })
      toast(t('تم حذف الفاتورة'))
      onDeleted(invoice.id)
      close()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  return (
    <Sheet
      open={!!invoice}
      onClose={close}
      title={editing ? t('تعديل الفاتورة') : view === 'paper' ? t('الفاتورة') : t('تفاصيل الفاتورة')}
      footer={
        invoice && !editing && view === 'paper' ? (
          <div className="flex gap-3">
            <Button block variant="secondary" loading={paperExport.exporting === 'png'} disabled={!!paperExport.exporting} icon={<ImageDown className="size-5" />} onClick={() => paperExport.exportAs('png')}>
              {t('صورة')}
            </Button>
            <Button block loading={paperExport.exporting === 'pdf'} disabled={!!paperExport.exporting} icon={<FileDown className="size-5" />} onClick={() => paperExport.exportAs('pdf')}>
              PDF
            </Button>
          </div>
        ) : undefined
      }
    >
      {paperExport.host}
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
        <div className="mb-4">
          <Segmented
            value={view}
            onChange={setView}
            options={[
              { value: 'paper', label: t('الفاتورة') },
              { value: 'details', label: t('التفاصيل') },
            ]}
          />
        </div>
      )}
      {invoice && !editing && view === 'paper' && <InvoicePaperPreview invoice={invoice} />}
      {invoice && !editing && view === 'details' && (
        <div>
          <div className="mb-4 rounded-3xl bg-surface-2 p-5 text-center">
            <Money value={invoice.amount} className="text-[32px] font-bold" />
            <p className="mt-1 text-[16px] font-semibold">{invoice.customer_name || t('بدون اسم')}</p>
            <p className="mt-1 flex items-center justify-center gap-1.5 text-[14px] text-muted">
              <StoreDot color={invoice.store_color} storeId={invoice.store_id} /> {invoice.store_name} · {fmtDateTime(invoice.paid_at)}
            </p>
          </div>

          <div className="mb-4 rounded-3xl border border-line p-4">
            <div className="mb-2 flex items-center justify-between">
              <p className="text-[16px] font-semibold">{t('الخدمة / المنتج')}</p>
              {can('editor') && (
                <Button size="sm" variant="soft" loading={busy} icon={<Tag className="size-4" />} onClick={() => setPicker(true)}>
                  {invoice.lines.length ? t('إضافة') : t('تحديد')}
                </Button>
              )}
            </div>
            {!invoice.lines.length && <p className="rounded-2xl bg-warn-soft px-4 py-3 text-[15px] font-medium text-warn">{t('هذه الفاتورة غير مصنّفة بعد')}</p>}
            <div className="space-y-1.5">
              {invoice.lines.map((l) => (
                <div key={l.item_id} className="flex items-center gap-2 rounded-2xl bg-surface-2 px-3 py-2.5">
                  <Badge tone={l.kind === 'service' ? 'primary' : 'success'}>{l.kind === 'service' ? t('خدمة') : t('منتج')}</Badge>
                  <span className="min-w-0 flex-1 truncate text-[15px] font-semibold">
                    {l.name}
                    {!l.is_active && <span className="ms-1 text-[12px] text-muted">{t('(مؤرشف)')}</span>}
                  </span>
                  {invoice.lines.length > 1 && (
                    <span className="num text-[14px] text-muted">
                      {l.qty !== 1 && `${l.qty} × `}
                      {money(l.unit_price)}
                    </span>
                  )}
                  {can('editor') && (
                    <button aria-label={t('إزالة')} className="p-1 text-muted hover:text-danger" onClick={() => removeLine(l.item_id)}>
                      <Trash2 className="size-4" />
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          {invoice.note && (
            <div className="mb-4 rounded-3xl border border-line p-4">
              <p className="mb-1 text-[14px] text-muted">{t('ملاحظة')}</p>
              <p className="whitespace-pre-wrap text-[16px]">{invoice.note}</p>
            </div>
          )}

          <div className="rounded-3xl border border-line px-4">
            <Row label={t('الجوال')} copy={invoice.phone}>
              {invoice.phone && <span className="num">{invoice.phone}</span>}
            </Row>
            <Row label={t('الإيميل')} copy={invoice.email}>
              {invoice.email && <span className="num">{invoice.email}</span>}
            </Row>
            <Row label={t('رقم الفاتورة')}>{invoice.invoice_no && <span className="num">{invoice.invoice_no}</span>}</Row>
            <Row label={t('طريقة الدفع')}>{invoice.pay_method && payLabel(invoice.pay_method)}</Row>
            <Row label={t('البطاقة')}>
              {(invoice.card_type || invoice.card_last4) && (
                <span className="num">
                  {invoice.card_type} {invoice.card_last4 && `•••• ${invoice.card_last4}`}
                </span>
              )}
            </Row>
            <Row label={t('الرقم المرجعي')} copy={invoice.reference_no}>
              {invoice.reference_no && <span className="num">{invoice.reference_no}</span>}
            </Row>
            <Row label={t('رمز التفويض')}>{invoice.auth_code && <span className="num">{invoice.auth_code}</span>}</Row>
            <Row label={t('رقم الجهاز')}>{invoice.terminal_id && <span className="num">{invoice.terminal_id}</span>}</Row>
            <Row label={t('رقم العملية')} copy={invoice.transaction_id}>
              {invoice.transaction_id && <span className="num text-[13px]">{invoice.transaction_id}</span>}
            </Row>
            <Row label={t('المصدر')}>{invoice.source === 'import' ? t('استيراد Excel') : t('إدخال يدوي')}</Row>
            <Row label={t('أضافها')}>{invoice.created_by_name && `${invoice.created_by_name} · ${fmtDate(invoice.created_at)}`}</Row>
            {invoice.updated_by_name && invoice.updated_at !== invoice.created_at && (
              <Row label={t('آخر تعديل')}>{`${invoice.updated_by_name} · ${fmtDate(invoice.updated_at)}`}</Row>
            )}
          </div>

          {can('editor') && (
            <div className="mt-5 flex gap-3">
              <Button block variant="secondary" icon={<Pencil className="size-5" />} onClick={() => setEditing(true)}>
                
                {t('تعديل')}
              </Button>
              <Button block variant="danger" icon={<Trash2 className="size-5" />} onClick={remove}>
                
                {t('حذف')}
              </Button>
            </div>
          )}
          <ItemPicker open={picker} onClose={() => setPicker(false)} storeId={invoice.store_id} onPick={classify} />
        </div>
      )}
    </Sheet>
  )
}

import { useState } from 'react'
import { ChevronDown, Package, Plus, Trash2, Wrench } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { PAY_METHODS, money, toInputDateTime, ymdhm } from '../lib/format'
import type { CatalogItem, Invoice, ItemKind } from '../types'
import { useFeedback } from './Feedback'
import { ItemPicker } from './ItemPicker'
import { Button, Field, IconButton, Input, Select, Textarea, cx } from './ui'
import { t } from '../lib/i18n'
import { fitPrices, toNum } from '../lib/split'

interface Line {
  item_id: number
  name: string
  kind: ItemKind
  qty: string
  /** Empty = follow the invoice amount (single line). */
  unit_price: string
}

/** Add or edit an invoice, including which services/products it is for. */
export function InvoiceForm({ initial, onSaved, onCancel }: { initial?: Invoice; onSaved: (inv: Invoice) => void; onCancel?: () => void }) {
  const { activeStores, currentStore, storeById, items } = useApp()
  const { toast } = useFeedback()
  const defaultStore = initial?.store_id ?? currentStore ?? (activeStores.length === 1 ? activeStores[0].id : null)
  const [f, setF] = useState({
    store_id: defaultStore ? String(defaultStore) : '',
    amount: initial ? String(initial.amount) : '',
    paid_at: initial ? toInputDateTime(initial.paid_at) : ymdhm(new Date()),
    customer_name: initial?.customer_name ?? '',
    phone: initial?.phone ?? '',
    email: initial?.email ?? '',
    invoice_no: initial?.invoice_no ?? '',
    pay_method: initial?.pay_method ?? '',
    card_type: initial?.card_type ?? '',
    card_last4: initial?.card_last4 ?? '',
    reference_no: initial?.reference_no ?? '',
    auth_code: initial?.auth_code ?? '',
    note: initial?.note ?? '',
  })
  const [lines, setLines] = useState<Line[]>(() =>
    (initial?.lines ?? []).map((l, _, arr) => ({
      item_id: l.item_id,
      name: l.name,
      kind: l.kind,
      qty: String(l.qty),
      unit_price: arr.length === 1 && Math.abs(l.unit_price * l.qty - (initial?.amount ?? 0)) < 0.01 ? '' : String(l.unit_price),
    })),
  )
  const [picker, setPicker] = useState(false)
  const [more, setMore] = useState(!!(initial?.card_type || initial?.reference_no || initial?.auth_code || initial?.card_last4))
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }))

  const storeId = f.store_id ? +f.store_id : null
  const amount = toNum(f.amount)
  const linesTotal = lines.reduce((a, l) => a + toNum(l.qty || '1') * (l.unit_price === '' ? (lines.length === 1 ? amount / toNum(l.qty || '1') : 0) : toNum(l.unit_price)), 0)
  const mismatch = lines.length > 1 && Math.abs(linesTotal - amount) > 0.009
  const archivedStore = initial && !storeById(initial.store_id)?.is_active ? storeById(initial.store_id) : undefined

  /** Prices that add up to the invoice amount; a single line just follows the amount. */
  const refit = (ls: Line[]): Line[] => {
    if (ls.length < 2) return ls.map((l) => ({ ...l, unit_price: '' }))
    const prices = fitPrices(amount, ls.map((l) => items.find((i) => i.id === l.item_id)?.default_price))
    return ls.map((l, k) => ({ ...l, unit_price: String(Math.round((prices[k] / (toNum(l.qty || '1') || 1)) * 100) / 100) }))
  }
  const addItems = (picked: CatalogItem[]) =>
    setLines((ls) => refit([...ls, ...picked.filter((p) => !ls.some((l) => l.item_id === p.id)).map((p) => ({ item_id: p.id, name: p.name, kind: p.kind, qty: '1', unit_price: '' }))]))

  const submit = async () => {
    const errs: Record<string, string> = {}
    if (!f.store_id) errs.store_id = t('اختر المتجر')
    if (!f.amount.trim() || amount <= 0) errs.amount = t('أدخل المبلغ')
    if (!f.paid_at) errs.paid_at = t('اختر التاريخ')
    setErrors(errs)
    if (Object.keys(errs).length) return

    setSaving(true)
    try {
      const body = {
        ...f,
        store_id: +f.store_id,
        amount,
        items: lines.map((l) => ({
          item_id: l.item_id,
          qty: toNum(l.qty || '1'),
          unit_price: l.unit_price === '' ? null : toNum(l.unit_price),
        })),
      }
      const r = initial
        ? await api<{ invoice: Invoice }>(`invoices/${initial.id}`, { method: 'PUT', body })
        : await api<{ invoice: Invoice }>('invoices', { method: 'POST', body })
      toast(initial ? t('تم حفظ التعديلات') : t('تمت إضافة الفاتورة'))
      onSaved(r.invoice)
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }

  // Container queries: roomy cards (desktop Add page) get two columns; the phone layout and the narrow edit dialog stay single-column.
  return (
    <div className="@container">
    <div className="space-y-4 @2xl:grid @2xl:grid-cols-2 @2xl:gap-x-5 @2xl:gap-y-4 @2xl:space-y-0">
      <Field label={t('المتجر')} required error={errors.store_id} className="@2xl:order-1">
        <Select value={f.store_id} onChange={set('store_id')}>
          <option value="">{t('اختر المتجر…')}</option>
          {archivedStore && <option value={archivedStore.id}>{archivedStore.name}  {t('(مؤرشف)')}</option>}
          {activeStores.map((s) => (
            <option key={s.id} value={s.id}>
              {s.name}
            </option>
          ))}
        </Select>
      </Field>

      <Field label={t('المبلغ (ر.س)')} required error={errors.amount} className="@2xl:order-2">
        <Input inputMode="decimal" value={f.amount} onChange={set('amount')} placeholder="0.00" className="num text-end text-[20px] font-semibold" />
      </Field>
      <Field label={t('التاريخ والوقت')} required error={errors.paid_at} className="@2xl:order-3">
        <Input type="datetime-local" value={f.paid_at} onChange={set('paid_at')} className="num text-end" />
      </Field>

      {/* What is this invoice for */}
      <div className="rounded-3xl border border-line bg-surface-2/50 p-4 @2xl:order-5 @2xl:col-span-2">
        <div className="mb-3 flex items-center justify-between">
          <div>
            <p className="text-[16px] font-semibold">{t('الخدمة / المنتج')}</p>
            <p className="text-[13px] text-muted">{t('لماذا هذه الفاتورة؟')}</p>
          </div>
          <Button size="sm" variant="soft" icon={<Plus className="size-4" />} onClick={() => setPicker(true)}>
            
            {t('إضافة')}
          </Button>
        </div>
        {lines.length === 0 && (
          <button onClick={() => setPicker(true)} className="w-full rounded-2xl border border-dashed border-warn/50 bg-warn-soft px-4 py-3.5 text-[15px] font-medium text-warn">
            
            {t('لم تُحدد بعد — اضغط لاختيار خدمة أو منتج')}
          </button>
        )}
        <div className="space-y-2">
          {lines.map((l, idx) => (
            <div key={idx} className="rounded-2xl bg-surface p-3">
              <div className="flex items-center gap-2">
                <span className={cx('flex size-8 shrink-0 items-center justify-center rounded-lg', l.kind === 'service' ? 'bg-primary-soft text-primary' : 'bg-success-soft text-success')}>
                  {l.kind === 'service' ? <Wrench className="size-4" /> : <Package className="size-4" />}
                </span>
                <span className="min-w-0 flex-1 truncate text-[16px] font-semibold">{l.name}</span>
                <IconButton label={t('حذف البند')} onClick={() => setLines((ls) => refit(ls.filter((_, i) => i !== idx)))} className="size-9 text-danger">
                  <Trash2 className="size-5" />
                </IconButton>
              </div>
              {lines.length > 1 && (
                <div className="mt-2 grid grid-cols-2 gap-2">
                  <Input
                    inputMode="decimal"
                    aria-label={t('الكمية')}
                    value={l.qty}
                    onChange={(e) => setLines((ls) => ls.map((x, i) => (i === idx ? { ...x, qty: e.target.value } : x)))}
                    placeholder={t('الكمية')}
                    className="num h-11 text-end"
                  />
                  <Input
                    inputMode="decimal"
                    aria-label={t('السعر')}
                    value={l.unit_price}
                    onChange={(e) => setLines((ls) => ls.map((x, i) => (i === idx ? { ...x, unit_price: e.target.value } : x)))}
                    placeholder={t('السعر')}
                    className="num h-11 text-end"
                  />
                </div>
              )}
            </div>
          ))}
        </div>
        {mismatch && (
          <div className="mt-2 flex items-center justify-between gap-2 text-[13px] text-warn">
            <span>{t('مجموع البنود {0} لا يساوي مبلغ الفاتورة {1}', money(linesTotal), money(amount))}</span>
            {amount > 0 && (
              <button type="button" className="shrink-0 font-bold underline" onClick={() => setLines(refit)}>
                {t('ضبط')}
              </button>
            )}
          </div>
        )}
      </div>

      <Field label={t('اسم العميل')} className="@2xl:order-6 @2xl:col-span-2">
        <Input value={f.customer_name} onChange={set('customer_name')} autoComplete="off" />
      </Field>
      <div className="grid grid-cols-2 gap-3 @2xl:contents">
        <Field label={t('الجوال')} className="@2xl:order-7">
          <Input type="tel" inputMode="tel" value={f.phone} onChange={set('phone')} className="num text-end" />
        </Field>
        <Field label={t('رقم الفاتورة')} className="@2xl:order-8">
          <Input value={f.invoice_no} onChange={set('invoice_no')} className="num text-end" />
        </Field>
      </div>
      <Field label={t('طريقة الدفع')} className="@2xl:order-4">
        <Select value={f.pay_method} onChange={set('pay_method')}>
          <option value="">—</option>
          {Object.entries(PAY_METHODS).map(([v, l]) => (
            <option key={v} value={v}>
              {l}
            </option>
          ))}
        </Select>
      </Field>
      <Field label={t('ملاحظة')} className="@2xl:order-9 @2xl:col-span-2">
        <Textarea value={f.note} onChange={set('note')} placeholder={t('ملاحظات للمتابعة لاحقاً…')} />
      </Field>

      <button type="button" onClick={() => setMore((m) => !m)} className="flex h-11 items-center gap-1 text-[15px] font-semibold text-primary @2xl:order-10 @2xl:col-span-2 @2xl:justify-self-start">
        <ChevronDown className={cx('size-5 transition', more && 'rotate-180')} />
        
        {t('تفاصيل إضافية')}
      </button>
      {more && (
        <div className="space-y-4 @2xl:order-10 @2xl:col-span-2">
          <Field label={t('الإيميل')}>
            <Input type="email" value={f.email} onChange={set('email')} className="num text-end" />
          </Field>
          <div className="grid grid-cols-2 gap-3">
            <Field label={t('نوع البطاقة')}>
              <Input value={f.card_type} onChange={set('card_type')} placeholder="Visa / Mada" />
            </Field>
            <Field label={t('آخر 4 أرقام')}>
              <Input inputMode="numeric" maxLength={4} value={f.card_last4} onChange={set('card_last4')} className="num text-end" />
            </Field>
            <Field label={t('الرقم المرجعي')}>
              <Input value={f.reference_no} onChange={set('reference_no')} className="num text-end" />
            </Field>
            <Field label={t('رمز التفويض')}>
              <Input value={f.auth_code} onChange={set('auth_code')} className="num text-end" />
            </Field>
          </div>
        </div>
      )}

      <div className="flex gap-3 pt-2 @2xl:order-last @2xl:col-span-2 @2xl:justify-start [&>button]:@2xl:w-56 [&>button]:@2xl:flex-none">
        <Button size="lg" block loading={saving} onClick={submit}>
          {initial ? t('حفظ التعديلات') : t('حفظ الفاتورة')}
        </Button>
        {onCancel && (
          <Button size="lg" variant="secondary" onClick={onCancel}>
            
            {t('إلغاء')}
          </Button>
        )}
      </div>

      <ItemPicker
        open={picker}
        onClose={() => setPicker(false)}
        storeId={storeId}
        exclude={lines.map((l) => l.item_id)}
        onPickMany={addItems}
      />
    </div>
    </div>
  )
}

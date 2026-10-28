import type { CatalogItem, Invoice } from '../types'
import type { ParsedRow } from './excel'
import { money, payLabel } from './format'
import { isEn, t } from './i18n'

export interface Change {
  field: string
  label: string
  from: string
  to: string
}

/** One existing invoice that an edited Excel file would change. */
export interface RowUpdate {
  invoice: Invoice
  changes: Change[]
  /** Body for `import/update` (the invoice id plus only the changed fields). */
  payload: Record<string, unknown>
  /** Things in the row that can't be applied (e.g. unknown service name); the rest still updates. */
  warnings: string[]
}

const TEXT_FIELDS = [
  ['customer_name', t('اسم العميل')],
  ['phone', t('الجوال')],
  ['email', t('الإيميل')],
  ['invoice_no', t('رقم الفاتورة')],
  ['pay_method', t('طريقة الدفع')],
  ['note', t('ملاحظة')],
  ['card_type', t('نوع البطاقة')],
  ['card_last4', t('آخر 4 أرقام')],
  ['reference_no', t('الرقم المرجعي')],
  ['auth_code', t('رمز التفويض')],
] as const

const clean = (v: string | null | undefined) => (v ?? '').trim()

/** Fields a gateway file fills in on an invoice that is already stored, where that invoice has them empty. */
const FILL_FIELDS = [...TEXT_FIELDS.filter(([f]) => f !== 'note'), ['terminal_id', t('رقم الجهاز')]] as const

/** Labels of the fields the file row has and the stored invoice is missing (the import fills them in). */
export function missingFields(row: ParsedRow, inv: Invoice): string[] {
  return FILL_FIELDS.filter(([f]) => clean(row[f]) && !clean(inv[f])).map(([, label]) => label)
}

/** Spreadsheets drop leading zeros of numbers-as-text ("0551…" -> 551…), so those don't count as edits. */
function sameText(a: string | null | undefined, b: string | null | undefined) {
  const x = clean(a)
  const y = clean(b)
  if (x === y) return true
  return /^\d+$/.test(x) && /^\d+$/.test(y) && x.replace(/^0+/, '') === y.replace(/^0+/, '')
}

const norm = (s: string) => s.trim().toLowerCase()
const splitItems = (s: string | null | undefined) => (s ?? '').split(/\s*[،|\n]\s*/).map((x) => x.trim()).filter(Boolean)
const show = (v: string | null | undefined) => (clean(v) === '' ? '—' : clean(v))

/**
 * Compares a row of an edited file with the invoice it belongs to. Only columns that exist in the file are compared.
 * `newStoreId` is the store named in the row (null if the row names none or an unknown one).
 */
export function planUpdate(
  row: ParsedRow,
  inv: Invoice,
  columns: string[],
  ctx: { newStoreId: number | null; storeName: (id: number) => string; items: CatalogItem[] },
): RowUpdate | null {
  const has = (f: string) => columns.includes(f)
  const changes: Change[] = []
  const patch: Record<string, unknown> = {}
  const warnings: string[] = []
  const add = (field: string, label: string, from: string, to: string, value: unknown) => {
    changes.push({ field, label, from, to })
    patch[field] = value
  }

  if (has('store_id') && ctx.newStoreId && ctx.newStoreId !== inv.store_id) {
    add('store_id', t('المتجر'), inv.store_name, ctx.storeName(ctx.newStoreId), ctx.newStoreId)
  }
  if (has('paid_at') && row.paid_at && row.paid_at.slice(0, 16) !== (inv.paid_at ?? '').slice(0, 16)) {
    add('paid_at', t('التاريخ'), (inv.paid_at ?? '—').slice(0, 16), row.paid_at.slice(0, 16), row.paid_at)
  }
  const amountChanged = has('amount') && Math.abs(row.amount - inv.amount) > 0.004
  if (amountChanged) add('amount', t('المبلغ'), money(inv.amount), money(row.amount), row.amount)

  for (const [f, label] of TEXT_FIELDS) {
    if (!has(f)) continue
    const next = row[f]
    const cur = inv[f]
    if (!sameText(next, cur)) {
      const fmt = f === 'pay_method' ? (v: string | null) => (v ? payLabel(v) : '—') : show
      add(f, label, fmt(cur), fmt(next), clean(next) === '' ? null : clean(next))
    }
  }

  // Service/product: compared as a set of names; only touched when the cell really differs.
  if (has('item')) {
    const wanted = splitItems(row.item_raw)
    const current = inv.lines.map((l) => l.name)
    const same = wanted.length === current.length && wanted.every((w) => current.some((c) => norm(c) === norm(w)))
    if (!same) {
      const storeId = patch.store_id ? (patch.store_id as number) : inv.store_id
      const resolved = wanted.map((w) => ctx.items.find((i) => i.is_active && norm(i.name) === norm(w) && (i.store_id === null || i.store_id === storeId)))
      const missing = wanted.filter((_, k) => !resolved[k])
      if (missing.length) {
        warnings.push(t('الخدمة/المنتج «{0}» غير موجود في القائمة، لن تتغير الخدمة', missing.join(isEn ? ', ' : '، ')))
      } else {
        patch.items = resolved.map((it) => {
          const keep = inv.lines.find((l) => l.item_id === it!.id)
          return keep ? { item_id: it!.id, qty: keep.qty, unit_price: keep.unit_price } : { item_id: it!.id }
        })
        changes.push({ field: 'item', label: t('الخدمة/المنتج'), from: current.join(isEn ? ', ' : '، ') || '—', to: wanted.join(isEn ? ', ' : '، ') || '—' })
      }
    }
  }
  // A single line follows the invoice amount, so changing the amount re-prices it.
  if (amountChanged && !('items' in patch) && inv.lines.length === 1) {
    const l = inv.lines[0]
    if (Math.abs(l.qty * l.unit_price - inv.amount) < 0.01) patch.items = [{ item_id: l.item_id, qty: l.qty }]
  }

  if (!changes.length && !warnings.length) return null
  return { invoice: inv, changes, payload: { id: inv.id, ...patch }, warnings }
}

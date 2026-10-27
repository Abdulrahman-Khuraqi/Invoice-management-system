import type { Invoice } from '../types'
import { parseDate } from './format'

/**
 * Per-store look of the printable invoice paper. The paper itself is always English / LTR
 * (like the original ARVO purchase invoice), whatever the app language is.
 *
 * To add a store: add a template below and a matcher in TEMPLATES. Stores without a
 * template fall back to a plain one that uses the store name.
 */
export interface PaperTemplate {
  id: string
  /** Printed above the title and as the heading of the company block. */
  company: string
  email?: string
  /** Document title, e.g. "PURCHASE INVOICE". */
  title: string
  currency: string
  /** Files under web/public/, e.g. "invoice/arvo/logo.png". Hidden if missing. */
  logo?: string
  seal?: string
  accent: string
  /** Row shown when the invoice has no service/product lines. */
  fallbackItem: string
}

const ARVO: PaperTemplate = {
  id: 'arvo',
  company: 'ARVO',
  email: 'info@arvo-sa.com',
  title: 'PURCHASE INVOICE',
  currency: 'SAR',
  logo: 'invoice/arvo/logo.png',
  seal: 'invoice/arvo/seal.png',
  accent: '#111827',
  fallbackItem: 'Purchase',
}

const TEMPLATES: { match: RegExp; template: PaperTemplate }[] = [{ match: /arvo|أرفو|ارفو/i, template: ARVO }]

export function templateFor(storeName: string): PaperTemplate {
  const hit = TEMPLATES.find((t) => t.match.test(storeName))
  if (hit) return hit.template
  return { id: 'default', company: storeName, title: 'PURCHASE INVOICE', currency: 'SAR', accent: '#111827', fallbackItem: 'Purchase' }
}

export interface PaperRow {
  description: string
  note: string | null
  unitPrice: number
  qty: number
  amount: number
}

export interface PaperData {
  number: string
  date: string
  customer: string
  email: string
  rows: PaperRow[]
  subTotal: number
  discount: number
  total: number
}

const pad = (n: number) => String(n).padStart(2, '0')
const cents = (n: number) => Math.round(n * 100) / 100

/** "2026-10-12 20:59:11" → "12/10/2026 – 20:59" */
export function paperDate(s: string | null | undefined) {
  const d = parseDate(s)
  return d ? `${pad(d.getDate())}/${pad(d.getMonth() + 1)}/${d.getFullYear()} – ${pad(d.getHours())}:${pad(d.getMinutes())}` : '—'
}

const moneyFmt = new Intl.NumberFormat('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
export const paperMoney = (n: number) => moneyFmt.format(n)

/**
 * The invoice's amount is what was actually paid, so it is always the Total. Lines that add up to
 * more than that show the difference as a Discount.
 */
export function buildPaperData(invoice: Invoice, template: PaperTemplate): PaperData {
  const rows: PaperRow[] = invoice.lines.length
    ? invoice.lines.map((l) => ({
        description: l.name,
        note: l.line_note,
        unitPrice: l.unit_price,
        qty: l.qty,
        amount: cents(l.unit_price * l.qty),
      }))
    : [{ description: template.fallbackItem, note: null, unitPrice: invoice.amount, qty: 1, amount: invoice.amount }]

  const linesSum = cents(rows.reduce((s, r) => s + r.amount, 0))
  const total = cents(invoice.amount)
  // Per-unit rounding of a single line can drift by a cent or two; that isn't a discount.
  const subTotal = linesSum - total < 0.02 ? total : linesSum
  return {
    number: invoice.invoice_no || invoice.transaction_id || `#${invoice.id}`,
    date: paperDate(invoice.paid_at ?? invoice.created_at_src ?? invoice.created_at),
    customer: invoice.customer_name || '—',
    email: invoice.email || '—',
    rows,
    subTotal,
    discount: cents(subTotal - total),
    total,
  }
}

/** File-system friendly name for downloads: "ARVO-AG-2026-10-001". */
export function paperFileName(template: PaperTemplate, data: PaperData) {
  const slug = `${template.company}-${data.number}`.replace(/[^\p{L}\p{N}._-]+/gu, '-').replace(/^-+|-+$/g, '')
  return slug || 'invoice'
}

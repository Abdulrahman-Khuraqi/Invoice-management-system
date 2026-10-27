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
  /** More lines under the email in the company block (phone, licence number ...). */
  lines?: string[]
  /** Document title, e.g. "PURCHASE INVOICE". */
  title: string
  currency: string
  /** Files under web/public/, e.g. "invoice/arvo/logo.png". Hidden if missing. */
  logo?: string
  seal?: string
  /** Color of the company name at the top. */
  color: string
  /** Max logo height / seal width in px on the paper (defaults 52 / 250); tune per image. */
  logoHeight?: number
  sealWidth?: number
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
  color: '#0f2942',
  fallbackItem: 'Purchase',
}

const XRUN: PaperTemplate = {
  id: 'xrun',
  company: 'XRUN STUDIO',
  email: 'aans21420@gmail.com',
  title: 'PURCHASE INVOICE',
  currency: 'SAR',
  // The original logo has white lettering; web/public/invoice/xrun/logo.png is a copy with dark lettering so it shows on white.
  logo: 'invoice/xrun/logo.png',
  seal: 'invoice/xrun/seal.png',
  color: '#0230b7',
  logoHeight: 38,
  sealWidth: 210,
  fallbackItem: 'Purchase',
}

const ANAS_FL = 'FL-216314344' // also printed on the stamp: web/public/invoice/anas/seal.svg

const ANAS: PaperTemplate = {
  id: 'anas',
  company: 'ANAS',
  email: 'anas707.707aa@gmail.com',
  lines: ['Phone: 0551728288', `Freelance Document: ${ANAS_FL}`],
  title: 'PURCHASE INVOICE',
  currency: 'SAR',
  logo: 'invoice/anas/logo.png',
  seal: 'invoice/anas/seal.png',
  color: '#021a4d',
  logoHeight: 40,
  sealWidth: 210,
  fallbackItem: 'Purchase',
}

const TEMPLATES: { match: RegExp; template: PaperTemplate }[] = [
  { match: /arvo|أرفو|ارفو/i, template: ARVO },
  { match: /x\s*run|اكس\s*ران|إكس\s*ران/i, template: XRUN },
  // The anas store; it may also be named after its field (game design and development).
  { match: /\banas\b|أنس|تصميم\s*و\s*تطوير\s*ال[اأ]لعاب/i, template: ANAS },
]

export function templateFor(storeName: string): PaperTemplate {
  const hit = TEMPLATES.find((t) => t.match.test(storeName))
  if (hit) return hit.template
  return { id: 'default', company: storeName, title: 'PURCHASE INVOICE', currency: 'SAR', color: '#0f2942', fallbackItem: 'Purchase' }
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
  /** Same date with dashes, safe for file names. */
  fileDate: string
  customer: string
  email: string
  rows: PaperRow[]
  subTotal: number
  discount: number
  total: number
}

const pad = (n: number) => String(n).padStart(2, '0')
const cents = (n: number) => Math.round(n * 100) / 100

/** "2026-10-12 20:59:11" → "12/10/2026" */
export function paperDate(s: string | null | undefined, sep = '/') {
  const d = parseDate(s)
  return d ? [pad(d.getDate()), pad(d.getMonth() + 1), d.getFullYear()].join(sep) : '—'
}

/** 1500 → "1500.00" (no thousands separator, like the original invoices). */
export const paperMoney = (n: number) => n.toFixed(2)

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
    number: invoice.doc_no || invoice.invoice_no || `#${invoice.id}`,
    date: paperDate(invoice.paid_at ?? invoice.created_at_src ?? invoice.created_at),
    fileDate: paperDate(invoice.paid_at ?? invoice.created_at_src ?? invoice.created_at, '-'),
    customer: invoice.customer_name || '—',
    email: invoice.email || '—',
    rows,
    subTotal,
    discount: cents(subTotal - total),
    total,
  }
}

/**
 * "Purchase_Invoice_ARVO-ARV-261012-0007_12-10-2026_1350": title, company, number, date, total.
 * ASCII only: browsers drop download names that contain Arabic, so an Arabic store name is left out.
 */
export function paperFileName(template: PaperTemplate, data: PaperData) {
  const ascii = (s: string) => s.replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '')
  const title = template.title
    .toLowerCase()
    .split(' ')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join('_')
  const head = [ascii(title), ascii(template.company)].filter(Boolean).join('_')
  return [head ? `${head}-${ascii(data.number)}` : ascii(data.number), data.fileDate, Math.round(data.total)].join('_')
}

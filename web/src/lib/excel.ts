import * as XLSX from 'xlsx'
import type { Invoice } from '../types'
import { payLabel, KIND_LABELS } from './format'
import { EN } from './en'
import { isEn, t } from './i18n'

/** One invoice row read from an Excel file, before it's assigned to a store. */
export interface ParsedRow {
  transaction_id: string
  invoice_no: string | null
  customer_name: string | null
  email: string | null
  phone: string | null
  amount: number
  status: string | null
  pay_method: string | null
  card_type: string | null
  card_last4: string | null
  terminal_id: string | null
  reference_no: string | null
  auth_code: string | null
  created_at_src: string | null
  paid_at: string | null
  /** Template/export files only: */
  store_name: string | null
  item_name: string | null
  /** The whole service/product cell (exports join several names with "، "). */
  item_raw: string | null
  note: string | null
  /** System id from an exported file; lets a re-uploaded file update that invoice. */
  invoice_id: number | null
}

export interface ParsedFile {
  fileName: string
  format: 'gateway' | 'template'
  rows: ParsedRow[]
  errors: string[]
  /** Columns present in a template/export file (as ParsedRow field names, plus 'item'): only these may update invoices. */
  columns: string[]
}

// Column headers of the app's own template/export (Arabic) and the payment gateway export.
const TEMPLATE_COLUMNS = {
  store: 'المتجر',
  date: 'التاريخ',
  amount: 'المبلغ',
  customer: 'اسم العميل',
  phone: 'الجوال',
  email: 'الإيميل',
  invoiceNo: 'رقم الفاتورة',
  payMethod: 'طريقة الدفع',
  item: 'الخدمة/المنتج',
  note: 'ملاحظة',
  cardType: 'نوع البطاقة',
  last4: 'آخر 4 أرقام',
  txn: 'رقم العملية',
  ref: 'الرقم المرجعي',
  auth: 'رمز التفويض',
  terminal: 'رقم الجهاز',
  id: 'معرّف النظام',
} as const

/** Template column -> the invoice field it edits. */
const COLUMN_FIELDS: [keyof typeof TEMPLATE_COLUMNS, string][] = [
  ['store', 'store_id'], ['date', 'paid_at'], ['amount', 'amount'], ['customer', 'customer_name'], ['phone', 'phone'],
  ['email', 'email'], ['invoiceNo', 'invoice_no'], ['payMethod', 'pay_method'], ['item', 'item'], ['note', 'note'],
  ['cardType', 'card_type'], ['last4', 'card_last4'], ['ref', 'reference_no'], ['auth', 'auth_code'],
]

/** English header -> canonical column name, so files exported in either language can be uploaded. */
const HEADER_ALIASES = new Map(Object.values(TEMPLATE_COLUMNS).flatMap((ar) => (EN[ar] ? [[EN[ar], ar] as [string, string]] : [])))

/** Separates several service names inside one cell. */
const SEP = isEn ? ' | ' : '، '
const SPLIT = /\s*[،|\n]\s*/

const pad = (n: number) => String(n).padStart(2, '0')

function cellDate(v: unknown): string | null {
  if (v instanceof Date && !isNaN(v.getTime())) {
    return `${v.getFullYear()}-${pad(v.getMonth() + 1)}-${pad(v.getDate())} ${pad(v.getHours())}:${pad(v.getMinutes())}:${pad(v.getSeconds())}`
  }
  if (typeof v === 'string') {
    const s = toLatinDigits(v.trim())
    let m = s.match(/^(\d{4})[-/](\d{1,2})[-/](\d{1,2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?/)
    if (m) return `${m[1]}-${pad(+m[2])}-${pad(+m[3])} ${pad(+(m[4] ?? 0))}:${m[5] ?? '00'}:${m[6] ?? '00'}`
    // Day-first dates as typed in Saudi Arabia: 20/10/2026
    m = s.match(/^(\d{1,2})[-/](\d{1,2})[-/](\d{4})(?:\s+(\d{1,2}):(\d{2}))?/)
    if (m) return `${m[3]}-${pad(+m[2])}-${pad(+m[1])} ${pad(+(m[4] ?? 0))}:${m[5] ?? '00'}:00`
  }
  return null
}

function toLatinDigits(s: string) {
  return s.replace(/[٠-٩]/g, (d) => String('٠١٢٣٤٥٦٧٨٩'.indexOf(d))).replace(/٫/g, '.').replace(/٬/g, ',')
}

function cellMoney(v: unknown): number | null {
  if (typeof v === 'number') return Math.round(v * 100) / 100
  if (typeof v === 'string') {
    const n = parseFloat(toLatinDigits(v).replace(/[^\d.\-]/g, ''))
    return isNaN(n) ? null : Math.round(n * 100) / 100
  }
  return null
}

function cellId(v: unknown): number | null {
  const n = typeof v === 'number' ? v : parseInt(toLatinDigits(String(v ?? '')).trim(), 10)
  return Number.isInteger(n) && n > 0 ? n : null
}

function cellStr(v: unknown): string | null {
  if (v === null || v === undefined) return null
  if (v instanceof Date) return cellDate(v)
  const s = String(v).trim()
  return s === '' ? null : s
}

/** Stable id for template rows that have no gateway TransactionID, so re-importing the same file adds nothing. */
function rowFingerprint(parts: (string | number | null)[]): string {
  const str = parts.map((p) => String(p ?? '')).join('|')
  let h1 = 0xdeadbeef ^ str.length
  let h2 = 0x41c6ce57 ^ str.length
  for (let i = 0; i < str.length; i++) {
    const c = str.charCodeAt(i)
    h1 = Math.imul(h1 ^ c, 2654435761)
    h2 = Math.imul(h2 ^ c, 1597334677)
  }
  h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909)
  h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909)
  return 'tpl-' + (h2 >>> 0).toString(16).padStart(8, '0') + (h1 >>> 0).toString(16).padStart(8, '0')
}

export async function parseExcelFile(file: File): Promise<ParsedFile> {
  return parseWorkbook(await file.arrayBuffer(), file.name)
}

export function parseWorkbook(data: ArrayBuffer | Uint8Array, fileName: string): ParsedFile {
  const wb = XLSX.read(data, { type: 'array', cellDates: true })
  const sheet = wb.Sheets[wb.SheetNames[0]]
  if (!sheet) return { fileName, format: 'gateway', rows: [], errors: [t('الملف فارغ')], columns: [] }
  // Exports made in English carry English headers; map them back to the canonical (Arabic) names used below.
  const records = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, { defval: null, raw: true }).map((r) =>
    Object.fromEntries(Object.entries(r).map(([k, v]) => [HEADER_ALIASES.get(k.trim()) ?? k.trim(), v])),
  )
  const headers = Object.keys(records[0] ?? {})

  if (headers.includes('TransactionID') && headers.includes('TotalAmount')) {
    return parseGateway(records, fileName)
  }
  if (headers.includes(TEMPLATE_COLUMNS.amount) && headers.includes(TEMPLATE_COLUMNS.date)) {
    return parseTemplate(records, fileName, headers)
  }
  return {
    fileName,
    format: 'gateway',
    rows: [],
    errors: [t('صيغة الملف غير معروفة. استخدم ملف بوابة الدفع (Checkouts) أو قالب Excel الخاص بالنظام')],
    columns: [],
  }
}

function parseGateway(records: Record<string, unknown>[], fileName: string): ParsedFile {
  const rows: ParsedRow[] = []
  const errors: string[] = []
  records.forEach((r, i) => {
    const txn = cellStr(r.TransactionID)
    const amount = cellMoney(r.TotalAmount)
    if (!txn || amount === null) {
      if (Object.values(r).some((v) => v !== null)) errors.push(t('الصف {0}: لا يوجد رقم عملية أو مبلغ', i + 2))
      return
    }
    rows.push({
      transaction_id: txn,
      invoice_no: cellStr(r.InvoiceNo),
      customer_name: cellStr(r.Name),
      email: cellStr(r.Email),
      phone: cellStr(r.Phone),
      amount,
      status: cellStr(r.StatusTitle),
      pay_method: cellStr(r.PayMethodTitle),
      card_type: cellStr(r.CardTypeTitle),
      card_last4: cellStr(r.CardLast4),
      terminal_id: cellStr(r.TerminalID),
      reference_no: cellStr(r.TransactionReferenceNumber),
      auth_code: cellStr(r.AuthCode),
      created_at_src: cellDate(r.CreateDate),
      paid_at: cellDate(r.PaidDate) ?? cellDate(r.CreateDate),
      store_name: null,
      item_name: null,
      item_raw: null,
      note: null,
      invoice_id: null,
    })
  })
  return { fileName, format: 'gateway', rows, errors, columns: [] }
}

function parseTemplate(records: Record<string, unknown>[], fileName: string, headers: string[]): ParsedFile {
  const C = TEMPLATE_COLUMNS
  const rows: ParsedRow[] = []
  const errors: string[] = []
  const payByLabel = new Map([
    ['بطاقة', 'Card'], ['Card', 'Card'], ['Apple Pay', 'ApplePay'], ['Samsung Pay', 'SamsungPay'], ['مدى', 'Mada'], ['Mada', 'Mada'],
    ['نقدي', 'Cash'], ['Cash', 'Cash'], ['تحويل بنكي', 'Transfer'], ['Bank transfer', 'Transfer'], ['أخرى', 'Other'], ['Other', 'Other'],
  ])
  records.forEach((r, i) => {
    if (!Object.values(r).some((v) => v !== null && String(v).trim() !== '')) return
    const amount = cellMoney(r[C.amount])
    const paid = cellDate(r[C.date])
    if (amount === null || !paid) {
      errors.push(t('الصف {0}: المبلغ والتاريخ مطلوبان', i + 2))
      return
    }
    const store = cellStr(r[C.store])
    const customer = cellStr(r[C.customer])
    const phone = cellStr(r[C.phone])
    const invoiceNo = cellStr(r[C.invoiceNo])
    const pay = cellStr(r[C.payMethod])
    rows.push({
      transaction_id: cellStr(r[C.txn]) ?? rowFingerprint([store, paid, amount, customer, phone, invoiceNo]),
      invoice_no: invoiceNo,
      customer_name: customer,
      email: cellStr(r[C.email]),
      phone,
      amount,
      status: 'Paid',
      pay_method: pay ? payByLabel.get(pay) ?? pay : null,
      card_type: cellStr(r[C.cardType]),
      card_last4: cellStr(r[C.last4]),
      terminal_id: cellStr(r[C.terminal]),
      reference_no: cellStr(r[C.ref]),
      auth_code: cellStr(r[C.auth]),
      created_at_src: null,
      paid_at: paid,
      store_name: store,
      // Exports list several items joined with "، "; only the first is matched on import.
      item_name: cellStr(r[C.item])?.split(SPLIT)[0] ?? null,
      item_raw: cellStr(r[C.item]),
      note: cellStr(r[C.note]),
      invoice_id: cellId(r[C.id]),
    })
  })
  const columns = COLUMN_FIELDS.filter(([k]) => headers.includes(C[k])).map(([, f]) => f)
  return { fileName, format: 'template', rows, errors, columns }
}

function saveWorkbook(wb: XLSX.WorkBook, fileName: string) {
  wb.Workbook = { Views: [{ RTL: !isEn }] }
  XLSX.writeFile(wb, fileName, { compression: true })
}

function sheetFrom(rows: Record<string, unknown>[], widths: number[]) {
  const ws = XLSX.utils.json_to_sheet(rows)
  ws['!cols'] = widths.map((wch) => ({ wch }))
  return ws
}

export interface ExportColumn {
  key: string
  label: string
  width: number
  value: (inv: Invoice) => string | number
}

/** Every column the invoice export can contain, in file order. */
export const EXPORT_COLUMNS: ExportColumn[] = [
  { key: 'store', label: t(TEMPLATE_COLUMNS.store), width: 16, value: (i) => i.store_name },
  { key: 'date', label: t(TEMPLATE_COLUMNS.date), width: 20, value: (i) => i.paid_at ?? i.created_at },
  { key: 'amount', label: t(TEMPLATE_COLUMNS.amount), width: 12, value: (i) => i.amount },
  { key: 'customer', label: t(TEMPLATE_COLUMNS.customer), width: 24, value: (i) => i.customer_name ?? '' },
  { key: 'phone', label: t(TEMPLATE_COLUMNS.phone), width: 16, value: (i) => i.phone ?? '' },
  { key: 'email', label: t(TEMPLATE_COLUMNS.email), width: 24, value: (i) => i.email ?? '' },
  { key: 'invoiceNo', label: t(TEMPLATE_COLUMNS.invoiceNo), width: 12, value: (i) => i.invoice_no ?? '' },
  { key: 'payMethod', label: t(TEMPLATE_COLUMNS.payMethod), width: 12, value: (i) => (i.pay_method ? payLabel(i.pay_method) : '') },
  { key: 'item', label: t(TEMPLATE_COLUMNS.item), width: 24, value: (i) => i.lines.map((l) => l.name).join(SEP) },
  { key: 'kind', label: t('النوع'), width: 10, value: (i) => [...new Set(i.lines.map((l) => KIND_LABELS[l.kind]))].join(SEP) },
  { key: 'category', label: t('التصنيف'), width: 14, value: (i) => [...new Set(i.lines.map((l) => l.category_name).filter(Boolean))].join(SEP) },
  { key: 'note', label: t(TEMPLATE_COLUMNS.note), width: 30, value: (i) => i.note ?? '' },
  { key: 'cardType', label: t(TEMPLATE_COLUMNS.cardType), width: 12, value: (i) => i.card_type ?? '' },
  { key: 'last4', label: t(TEMPLATE_COLUMNS.last4), width: 10, value: (i) => i.card_last4 ?? '' },
  { key: 'txn', label: t(TEMPLATE_COLUMNS.txn), width: 34, value: (i) => i.transaction_id ?? '' },
  { key: 'ref', label: t(TEMPLATE_COLUMNS.ref), width: 16, value: (i) => i.reference_no ?? '' },
  { key: 'auth', label: t(TEMPLATE_COLUMNS.auth), width: 12, value: (i) => i.auth_code ?? '' },
  { key: 'terminal', label: t(TEMPLATE_COLUMNS.terminal), width: 16, value: (i) => i.terminal_id ?? '' },
  { key: 'source', label: t('المصدر'), width: 8, value: (i) => (i.source === 'import' ? t('استيراد') : t('يدوي')) },
  // Lets the file be edited and uploaded again to update these invoices.
  { key: 'id', label: t(TEMPLATE_COLUMNS.id), width: 12, value: (i) => i.id },
]

export const ALL_EXPORT_KEYS = EXPORT_COLUMNS.map((c) => c.key)

/**
 * Exports invoices. With no `keys` every column is written (the file can be edited and uploaded again to update
 * the invoices); otherwise only the chosen columns, optionally with a totals row.
 */
export function exportInvoices(invoices: Invoice[], fileName: string, opts: { keys?: string[]; totalRow?: boolean } = {}) {
  const cols = EXPORT_COLUMNS.filter((c) => !opts.keys || opts.keys.includes(c.key))
  const rows: Record<string, unknown>[] = invoices.map((inv) => Object.fromEntries(cols.map((c) => [c.label, c.value(inv)])))
  const amountCol = cols.find((c) => c.key === 'amount')
  if (opts.totalRow && amountCol && cols.length > 0) {
    const total: Record<string, unknown> = Object.fromEntries(cols.map((c) => [c.label, '']))
    const first = cols.find((c) => c.key !== 'amount')
    if (first) total[first.label] = t('المجموع ({0})', invoices.length)
    total[amountCol.label] = Math.round(invoices.reduce((a, i) => a + i.amount, 0) * 100) / 100
    rows.push(total)
  }
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, sheetFrom(rows, cols.map((c) => c.width)), t('الفواتير'))
  saveWorkbook(wb, fileName)
}

/** Empty template with example rows for adding many invoices at once from Excel. */
export function downloadTemplate(storeNames: string[]) {
  const L = (k: keyof typeof TEMPLATE_COLUMNS) => t(TEMPLATE_COLUMNS[k])
  const example = (store: string, date: string, amount: number, customer: string, phone: string, item: string) => ({
    [L('store')]: store, [L('date')]: date, [L('amount')]: amount, [L('customer')]: customer, [L('phone')]: phone,
    [L('email')]: '', [L('invoiceNo')]: '', [L('payMethod')]: t('بطاقة'), [L('item')]: item, [L('note')]: '',
  })
  const rows = [
    example(storeNames[0] ?? t('اسم المتجر'), '2026-10-20 14:30', 1500, t('مثال: أحمد علي'), '0551234567', t('اسم الخدمة أو المنتج')),
    example(storeNames[1] ?? storeNames[0] ?? t('اسم المتجر'), '2026-10-21', 250, t('مثال: سارة'), '', ''),
  ]
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, sheetFrom(rows, [16, 20, 12, 24, 16, 24, 12, 12, 24, 30]), t('الفواتير'))
  const help = [
    [t('طريقة الاستخدام')],
    [t('• احذف صفوف المثال واكتب فواتيرك، فاتورة في كل صف.')],
    [t('• المبلغ والتاريخ مطلوبان. التاريخ بصيغة 2026-10-20 أو 20/10/2026، ويمكن إضافة الوقت.')],
    [t('• المتجر: اكتب اسم المتجر كما هو في النظام: ') + storeNames.join(SEP)],
    [t('• طريقة الدفع: بطاقة، مدى، Apple Pay، Samsung Pay، نقدي، تحويل بنكي، أخرى.')],
    [t('• الخدمة/المنتج: اكتب الاسم كما هو في قائمة الخدمات والمنتجات حتى تُربط تلقائياً.')],
    [t('• استيراد نفس الملف مرة ثانية لا يكرر الفواتير.')],
  ]
  const ws = XLSX.utils.aoa_to_sheet(help)
  ws['!cols'] = [{ wch: 90 }]
  XLSX.utils.book_append_sheet(wb, ws, t('تعليمات'))
  saveWorkbook(wb, t('قالب-الفواتير.xlsx'))
}

/** Multi-sheet report export. */
export function exportReport(sheets: { name: string; rows: Record<string, unknown>[] }[], fileName: string) {
  const wb = XLSX.utils.book_new()
  for (const s of sheets) {
    const ws = XLSX.utils.json_to_sheet(s.rows)
    ws['!cols'] = Object.keys(s.rows[0] ?? {}).map(() => ({ wch: 22 }))
    XLSX.utils.book_append_sheet(wb, ws, s.name.slice(0, 31))
  }
  saveWorkbook(wb, fileName)
}

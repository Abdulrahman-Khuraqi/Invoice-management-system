import * as XLSX from 'xlsx'
import type { Invoice } from '../types'
import { payLabel, KIND_LABELS } from './format'

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
  note: string | null
}

export interface ParsedFile {
  fileName: string
  format: 'gateway' | 'template'
  rows: ParsedRow[]
  errors: string[]
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
} as const

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
  if (!sheet) return { fileName, format: 'gateway', rows: [], errors: ['الملف فارغ'] }
  const records = XLSX.utils.sheet_to_json<Record<string, unknown>>(sheet, { defval: null, raw: true })
  const headers = Object.keys(records[0] ?? {})

  if (headers.includes('TransactionID') && headers.includes('TotalAmount')) {
    return parseGateway(records, fileName)
  }
  if (headers.includes(TEMPLATE_COLUMNS.amount) && headers.includes(TEMPLATE_COLUMNS.date)) {
    return parseTemplate(records, fileName)
  }
  return {
    fileName,
    format: 'gateway',
    rows: [],
    errors: ['صيغة الملف غير معروفة. استخدم ملف بوابة الدفع (Checkouts) أو قالب Excel الخاص بالنظام'],
  }
}

function parseGateway(records: Record<string, unknown>[], fileName: string): ParsedFile {
  const rows: ParsedRow[] = []
  const errors: string[] = []
  records.forEach((r, i) => {
    const txn = cellStr(r.TransactionID)
    const amount = cellMoney(r.TotalAmount)
    if (!txn || amount === null) {
      if (Object.values(r).some((v) => v !== null)) errors.push(`الصف ${i + 2}: لا يوجد رقم عملية أو مبلغ`)
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
      note: null,
    })
  })
  return { fileName, format: 'gateway', rows, errors }
}

function parseTemplate(records: Record<string, unknown>[], fileName: string): ParsedFile {
  const C = TEMPLATE_COLUMNS
  const rows: ParsedRow[] = []
  const errors: string[] = []
  const payByLabel = new Map([
    ['بطاقة', 'Card'], ['Apple Pay', 'ApplePay'], ['Samsung Pay', 'SamsungPay'], ['مدى', 'Mada'],
    ['نقدي', 'Cash'], ['تحويل بنكي', 'Transfer'], ['أخرى', 'Other'],
  ])
  records.forEach((r, i) => {
    if (!Object.values(r).some((v) => v !== null && String(v).trim() !== '')) return
    const amount = cellMoney(r[C.amount])
    const paid = cellDate(r[C.date])
    if (amount === null || !paid) {
      errors.push(`الصف ${i + 2}: المبلغ والتاريخ مطلوبان`)
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
      item_name: cellStr(r[C.item])?.split('، ')[0] ?? null,
      note: cellStr(r[C.note]),
    })
  })
  return { fileName, format: 'template', rows, errors }
}

function saveWorkbook(wb: XLSX.WorkBook, fileName: string) {
  wb.Workbook = { Views: [{ RTL: true }] }
  XLSX.writeFile(wb, fileName, { compression: true })
}

function sheetFrom(rows: Record<string, unknown>[], widths: number[]) {
  const ws = XLSX.utils.json_to_sheet(rows)
  ws['!cols'] = widths.map((wch) => ({ wch }))
  return ws
}

/** Exports invoices with the template's columns, so the file can be edited and re-imported. */
export function exportInvoices(invoices: Invoice[], fileName: string) {
  const C = TEMPLATE_COLUMNS
  const rows = invoices.map((inv) => ({
    [C.store]: inv.store_name,
    [C.date]: inv.paid_at ?? inv.created_at,
    [C.amount]: inv.amount,
    [C.customer]: inv.customer_name ?? '',
    [C.phone]: inv.phone ?? '',
    [C.email]: inv.email ?? '',
    [C.invoiceNo]: inv.invoice_no ?? '',
    [C.payMethod]: inv.pay_method ? payLabel(inv.pay_method) : '',
    [C.item]: inv.lines.map((l) => l.name).join('، '),
    'النوع': [...new Set(inv.lines.map((l) => KIND_LABELS[l.kind]))].join('، '),
    'التصنيف': [...new Set(inv.lines.map((l) => l.category_name).filter(Boolean))].join('، '),
    [C.note]: inv.note ?? '',
    [C.cardType]: inv.card_type ?? '',
    [C.last4]: inv.card_last4 ?? '',
    [C.txn]: inv.transaction_id ?? '',
    [C.ref]: inv.reference_no ?? '',
    [C.auth]: inv.auth_code ?? '',
    [C.terminal]: inv.terminal_id ?? '',
    'المصدر': inv.source === 'import' ? 'استيراد' : 'يدوي',
  }))
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, sheetFrom(rows, [16, 20, 12, 24, 16, 24, 12, 12, 24, 10, 14, 30, 12, 10, 34, 16, 12, 16, 8]), 'الفواتير')
  saveWorkbook(wb, fileName)
}

/** Empty template with example rows for adding many invoices at once from Excel. */
export function downloadTemplate(storeNames: string[]) {
  const C = TEMPLATE_COLUMNS
  const example = (store: string, date: string, amount: number, customer: string, phone: string, item: string) => ({
    [C.store]: store, [C.date]: date, [C.amount]: amount, [C.customer]: customer, [C.phone]: phone,
    [C.email]: '', [C.invoiceNo]: '', [C.payMethod]: 'بطاقة', [C.item]: item, [C.note]: '',
  })
  const rows = [
    example(storeNames[0] ?? 'اسم المتجر', '2026-10-20 14:30', 1500, 'مثال: أحمد علي', '0551234567', 'اسم الخدمة أو المنتج'),
    example(storeNames[1] ?? storeNames[0] ?? 'اسم المتجر', '2026-10-21', 250, 'مثال: سارة', '', ''),
  ]
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, sheetFrom(rows, [16, 20, 12, 24, 16, 24, 12, 12, 24, 30]), 'الفواتير')
  const help = [
    ['طريقة الاستخدام'],
    ['• احذف صفوف المثال واكتب فواتيرك، فاتورة في كل صف.'],
    ['• المبلغ والتاريخ مطلوبان. التاريخ بصيغة 2026-10-20 أو 20/10/2026، ويمكن إضافة الوقت.'],
    ['• المتجر: اكتب اسم المتجر كما هو في النظام: ' + storeNames.join('، ')],
    ['• طريقة الدفع: بطاقة، مدى، Apple Pay، Samsung Pay، نقدي، تحويل بنكي، أخرى.'],
    ['• الخدمة/المنتج: اكتب الاسم كما هو في قائمة الخدمات والمنتجات حتى تُربط تلقائياً.'],
    ['• استيراد نفس الملف مرة ثانية لا يكرر الفواتير.'],
  ]
  const ws = XLSX.utils.aoa_to_sheet(help)
  ws['!cols'] = [{ wch: 90 }]
  XLSX.utils.book_append_sheet(wb, ws, 'تعليمات')
  saveWorkbook(wb, 'قالب-الفواتير.xlsx')
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

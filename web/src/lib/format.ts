import { LOCALE, LOCALE_GREG, t } from './i18n'
const wholeFmt = new Intl.NumberFormat(LOCALE, { maximumFractionDigits: 0 })
const centsFmt = new Intl.NumberFormat(LOCALE, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const compactFmt = new Intl.NumberFormat(LOCALE, { notation: 'compact', maximumFractionDigits: 1 })

/** 1500 → "1,500", 1500.5 → "1,500.50" */
export function money(n: number | null | undefined) {
  const v = Math.round(Number(n ?? 0) * 100) / 100
  return Number.isInteger(v) ? wholeFmt.format(v) : centsFmt.format(v)
}
/** "1,900 – 6,000", a single amount when min = max, or null when the item has no range. */
export function priceRange(min: number | null | undefined, max: number | null | undefined) {
  if (min == null || max == null) return null
  return min === max ? money(min) : `${money(min)} – ${money(max)}`
}
export const compact =(n: number) => (Math.abs(n) >= 100000 ? compactFmt.format(n) : money(n))

/** "2026-10-12 20:59:11" (server, KSA time) → Date without timezone shifting. */
export function parseDate(s: string | null | undefined): Date | null {
  if (!s) return null
  const m = s.match(/^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?/)
  if (!m) return null
  return new Date(+m[1], +m[2] - 1, +m[3], +(m[4] ?? 0), +(m[5] ?? 0), +(m[6] ?? 0))
}

const dateFmt = new Intl.DateTimeFormat(LOCALE_GREG, { day: 'numeric', month: 'short', year: 'numeric' })
const timeFmt = new Intl.DateTimeFormat(LOCALE_GREG, { hour: 'numeric', minute: '2-digit' })
const dayMonthFmt = new Intl.DateTimeFormat(LOCALE_GREG, { day: 'numeric', month: 'short' })

/** Clock time of a Date, e.g. "10:42 ص". */
export const fmtTime = (d: Date) => timeFmt.format(d)

export function fmtDate(s: string | null | undefined) {
  const d = parseDate(s)
  return d ? dateFmt.format(d) : '—'
}
export function fmtDateTime(s: string | null | undefined) {
  const d = parseDate(s)
  return d ? `${dateFmt.format(d)} · ${timeFmt.format(d)}` : '—'
}
export function fmtDayMonth(s: string | null | undefined) {
  const d = parseDate(s)
  return d ? dayMonthFmt.format(d) : ''
}

const pad = (n: number) => String(n).padStart(2, '0')
export const ymd = (d: Date) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
export const ymdhm = (d: Date) => `${ymd(d)}T${pad(d.getHours())}:${pad(d.getMinutes())}`
export const toInputDateTime = (s: string | null | undefined) => {
  const d = parseDate(s)
  return d ? ymdhm(d) : ''
}

export type RangeKey = 'today' | 'week' | 'month' | 'last_month' | 'year' | 'all'
export const RANGE_LABELS: Record<RangeKey, string> = {
  today: t('اليوم'),
  week: t('آخر 7 أيام'),
  month: t('هذا الشهر'),
  last_month: t('الشهر الماضي'),
  year: t('هذه السنة'),
  all: t('كل الفترات'),
}
export function rangeDates(key: RangeKey): { from?: string; to?: string } {
  const now = new Date()
  const today = ymd(now)
  switch (key) {
    case 'today':
      return { from: today, to: today }
    case 'week':
      return { from: ymd(new Date(now.getFullYear(), now.getMonth(), now.getDate() - 6)), to: today }
    case 'month':
      return { from: ymd(new Date(now.getFullYear(), now.getMonth(), 1)), to: today }
    case 'last_month':
      return {
        from: ymd(new Date(now.getFullYear(), now.getMonth() - 1, 1)),
        to: ymd(new Date(now.getFullYear(), now.getMonth(), 0)),
      }
    case 'year':
      return { from: ymd(new Date(now.getFullYear(), 0, 1)), to: today }
    default:
      return {}
  }
}

export const PAY_METHODS: Record<string, string> = {
  Card: t('بطاقة'),
  ApplePay: 'Apple Pay',
  SamsungPay: 'Samsung Pay',
  Mada: t('مدى'),
  Cash: t('نقدي'),
  Transfer: t('تحويل بنكي'),
  Other: t('أخرى'),
}
export const payLabel = (p: string | null | undefined) => (p ? PAY_METHODS[p] ?? p : '—')

export const ROLE_LABELS = { admin: t('مدير'), editor: t('محرر'), viewer: t('مشاهد') } as const
export const KIND_LABELS = { service: t('خدمة'), product: t('منتج') } as const

export const PALETTE = ['#4f46e5', '#7c3aed', '#db2777', '#dc2626', '#ea580c', '#f59e0b', '#16a34a', '#059669', '#0891b2', '#0ea5e9', '#2563eb', '#64748b']

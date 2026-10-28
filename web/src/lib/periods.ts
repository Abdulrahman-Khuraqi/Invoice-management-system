import type { StatRow } from '../types'
import { fmtDayMonth, fmtMonthYear, fmtYear, parseDate, ymd } from './format'

export type Grain = 'day' | 'week' | 'month' | 'year'

/** How many periods the chart shows at most. */
const WINDOW: Record<Grain, number> = { day: 30, week: 12, month: 12, year: 5 }

const startOf = (g: Grain, d: Date) => {
  if (g === 'day') return new Date(d.getFullYear(), d.getMonth(), d.getDate())
  if (g === 'week') return new Date(d.getFullYear(), d.getMonth(), d.getDate() - d.getDay()) // weeks start on Sunday
  if (g === 'month') return new Date(d.getFullYear(), d.getMonth(), 1)
  return new Date(d.getFullYear(), 0, 1)
}
const step = (g: Grain, d: Date, by: number) => {
  if (g === 'day') return new Date(d.getFullYear(), d.getMonth(), d.getDate() + by)
  if (g === 'week') return new Date(d.getFullYear(), d.getMonth(), d.getDate() + 7 * by)
  if (g === 'month') return new Date(d.getFullYear(), d.getMonth() + by, 1)
  return new Date(d.getFullYear() + by, 0, 1)
}

export const periodLabel = (g: Grain, d: Date) => (g === 'month' ? fmtMonthYear(d) : g === 'year' ? fmtYear(d) : fmtDayMonth(ymd(d)))

export interface Period {
  key: string
  date: Date
  n: number
  /** Revenue of the period. */
  total: number
}

/**
 * The latest periods ending at `to`, without gaps: a period with no payments is shown as 0 rather than skipped.
 * Never starts before `from` (the start of the chosen range), so a range that began recently isn't padded
 * with empty periods from before it.
 */
export function fillPeriods(rows: StatRow[], g: Grain, from: string | null, to: string | null): Period[] {
  const end = parseDate(to)
  if (!end || !rows.length) return []
  const found = new Map(rows.map((r) => [r.day!, r]))
  const last = startOf(g, end)
  let first = step(g, last, -(WINDOW[g] - 1))
  const rangeStart = parseDate(from)
  if (rangeStart && startOf(g, rangeStart) > first) first = startOf(g, rangeStart)
  const out: Period[] = []
  for (let d = first; d <= last; d = step(g, d, 1)) {
    const key = ymd(d)
    out.push({ key, date: d, n: found.get(key)?.n ?? 0, total: found.get(key)?.total ?? 0 })
  }
  return out
}

/** Whole days from a to b, counting both ends (at least 1). */
export function daysBetween(a: string | null, b: string | null) {
  const x = parseDate(a)
  const y = parseDate(b)
  if (!x || !y) return 1
  return Math.max(1, Math.round((y.getTime() - x.getTime()) / 86_400_000) + 1)
}

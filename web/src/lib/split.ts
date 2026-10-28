/** Splits an amount into `n` parts in whole halalas; the last part takes the rounding remainder. */
export function splitAmount(amount: number, n: number): number[] {
  if (n <= 0) return []
  const cents = Math.round(amount * 100)
  const base = Math.trunc(cents / n)
  return Array.from({ length: n }, (_, i) => (i === n - 1 ? cents - base * (n - 1) : base) / 100)
}

/**
 * Prices for several items that together make up `amount`: default prices are kept when they fit and the items
 * without one share the rest; otherwise the amount is split equally. Mirrors fit_prices() in the API.
 */
export function fitPrices(amount: number, defaults: (number | null | undefined)[]): number[] {
  const open = defaults.flatMap((d, i) => (d == null || d <= 0 ? [i] : []))
  const fixed = defaults.reduce<number>((a, d) => a + (d == null || d <= 0 ? 0 : d), 0)
  if (open.length && fixed <= amount + 0.004) {
    const out = defaults.map((d) => (d == null || d <= 0 ? 0 : d))
    splitAmount(amount - fixed, open.length).forEach((share, k) => (out[open[k]] = share))
    return out
  }
  if (!open.length && Math.abs(fixed - amount) < 0.005) return defaults.map((d) => d ?? 0)
  return splitAmount(amount, defaults.length)
}

/** Parses a typed price (Arabic digits and thousands separators allowed); empty or invalid is 0. */
export function toNum(s: string) {
  const n = parseFloat(s.replace(/[٠-٩]/g, (d) => String('٠١٢٣٤٥٦٧٨٩'.indexOf(d))).replace(/٫/g, '.').replace(/[,٬]/g, ''))
  return isNaN(n) ? 0 : n
}

export const round2 = (n: number) => Math.round(n * 100) / 100

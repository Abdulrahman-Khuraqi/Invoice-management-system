import type { CatalogItem } from '../types'

/** Why an item is suggested for an invoice, strongest first. */
export type SuggestReason = 'remembered' | 'exact' | 'range' | 'popular'

export interface Suggestion {
  item: CatalogItem
  reason: SuggestReason
}

/** "storeId:amount" → item id the user picked last time for that store and amount. */
export type AmountMemory = Record<string, number>

export const memoryKey = (storeId: number, amount: number) => `${storeId}:${amount.toFixed(2)}`

const same = (a: number, b: number) => Math.abs(a - b) < 0.005
const MAX = 4

/**
 * Items worth offering for one invoice, best first:
 *  1. what was chosen last time for the same store and amount,
 *  2. items whose price is exactly the amount,
 *  3. items whose price range contains the amount (the narrower the range, the more specific the match),
 *  4. the store's most used items, only to fill up the list when little else matched.
 * Only active items of this store (or shared ones) are offered.
 */
export function suggestItems(items: CatalogItem[], inv: { store_id: number; amount: number }, memory: AmountMemory = {}): Suggestion[] {
  const pool = items.filter((i) => i.is_active && (i.store_id === null || i.store_id === inv.store_id))
  const out: Suggestion[] = []
  const add = (item: CatalogItem | undefined, reason: SuggestReason) => {
    if (item && out.length < MAX && !out.some((s) => s.item.id === item.id)) out.push({ item, reason })
  }

  const remembered = memory[memoryKey(inv.store_id, inv.amount)]
  if (remembered !== undefined) add(pool.find((i) => i.id === remembered), 'remembered')

  const byUse = (a: CatalogItem, b: CatalogItem) => b.usage_count - a.usage_count || a.name.localeCompare(b.name)
  pool
    .filter((i) => (i.default_price !== null && same(i.default_price, inv.amount)) || (i.price_min !== null && i.price_max !== null && same(i.price_min, inv.amount) && same(i.price_max, inv.amount)))
    .sort(byUse)
    .forEach((i) => add(i, 'exact'))

  pool
    .filter((i) => i.price_min !== null && i.price_max !== null && inv.amount >= i.price_min - 0.005 && inv.amount <= i.price_max + 0.005)
    .sort((a, b) => a.price_max! - a.price_min! - (b.price_max! - b.price_min!) || byUse(a, b))
    .forEach((i) => add(i, 'range'))

  if (out.length < 3) {
    pool
      .filter((i) => i.usage_count > 0)
      .sort(byUse)
      .forEach((i) => out.length < 3 && add(i, 'popular'))
  }
  return out
}

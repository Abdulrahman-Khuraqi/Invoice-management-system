import { Check, Divide, X } from 'lucide-react'
import { money } from '../lib/format'
import { t } from '../lib/i18n'
import { fitPrices, round2, splitAmount, toNum } from '../lib/split'
import type { ItemKind } from '../types'
import { Badge, cx } from './ui'

export interface SplitLine {
  item_id: number
  name: string
  kind: ItemKind
}

/** Typed prices -> final prices: the last line always takes what is left of the invoice amount. */
export function resolvePrices(amount: number, prices: string[]): number[] {
  const head = prices.slice(0, -1).map(toNum)
  return prices.length ? [...head, round2(amount - head.reduce((a, p) => a + p, 0))] : []
}

/** Starting prices (as typed text) for these items, adding up to the amount. */
export function initialPrices(amount: number, defaults: (number | null | undefined)[]): string[] {
  return fitPrices(amount, defaults).map(String)
}

/**
 * Several services/products sharing one invoice amount. Every line but the last has a price field; the last
 * line takes the rest, so the lines always add up to the invoice. `prices` holds the typed text of every line.
 */
export function LineSplit({
  amount,
  lines,
  prices,
  onChange,
  onRemove,
}: {
  amount: number
  lines: SplitLine[]
  prices: string[]
  onChange: (prices: string[]) => void
  onRemove?: (index: number) => void
}) {
  const final = resolvePrices(amount, prices)
  const rest = final[final.length - 1] ?? 0
  return (
    <div className="space-y-2">
      {lines.map((l, i) => {
        const last = i === lines.length - 1
        return (
          <div key={l.item_id} className="flex items-center gap-2 rounded-2xl bg-surface-2 py-2 pe-2 ps-3">
            <Badge tone={l.kind === 'service' ? 'primary' : 'success'}>{l.kind === 'service' ? t('خدمة') : t('منتج')}</Badge>
            <span className="min-w-0 flex-1 truncate text-[15px] font-semibold">{l.name}</span>
            {lines.length > 1 && !last && (
              <input
                inputMode="decimal"
                aria-label={t('سعر {0}', l.name)}
                value={prices[i] ?? ''}
                onChange={(e) => onChange(prices.map((p, k) => (k === i ? e.target.value : p)))}
                onFocus={(e) => e.target.select()}
                className="num h-10 w-28 shrink-0 rounded-xl border border-line bg-surface px-3 text-end text-[16px] font-semibold text-fg outline-none transition focus:border-primary focus:ring-4 focus:ring-primary/15"
              />
            )}
            {(lines.length === 1 || last) && (
              <span className={cx('num w-28 shrink-0 px-3 text-end text-[15px] font-semibold', rest < 0 && 'text-danger')} title={lines.length > 1 ? t('الباقي من مبلغ الفاتورة') : undefined}>
                {money(lines.length === 1 ? amount : rest)}
              </span>
            )}
            {onRemove && (
              <button aria-label={t('إزالة')} className="shrink-0 p-1 text-muted hover:text-danger" onClick={() => onRemove(i)}>
                <X className="size-4" />
              </button>
            )}
          </div>
        )
      })}
      {lines.length > 1 && (
        <div className="flex items-center justify-between gap-2 px-1 text-[13px]">
          <button className="flex items-center gap-1 font-semibold text-primary" onClick={() => onChange(splitAmount(amount, lines.length).map(String))}>
            <Divide className="size-4" /> {t('تقسيم بالتساوي')}
          </button>
          {rest < 0 ? (
            <span className="font-medium text-danger">{t('الأسعار أكبر من مبلغ الفاتورة')}</span>
          ) : (
            <span className="flex items-center gap-1 text-success">
              <Check className="size-4" /> {t('المجموع = مبلغ الفاتورة')} <span className="num font-semibold">{money(amount)}</span>
            </span>
          )}
        </div>
      )}
    </div>
  )
}

/** True when the split can be saved (no line ends up below zero). */
export const splitValid = (amount: number, prices: string[]) => resolvePrices(amount, prices).every((p) => p >= 0)

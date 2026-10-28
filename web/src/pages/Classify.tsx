import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useNavigate } from '../lib/nav'
import { Check, CheckCircle2, Layers, Plus, RefreshCw, SkipForward, Sparkles, Tag, Undo2, WifiOff, X } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { ItemPicker } from '../components/ItemPicker'
import { LineSplit, initialPrices, resolvePrices, splitValid } from '../components/LineSplit'
import { Page, TopBar } from '../components/Layout'
import { Button, EmptyState, Money, PageLoader, StoreDot, cx } from '../components/ui'
import { fmtDate, payLabel, priceRange, rangeDates, type RangeKey } from '../lib/format'
import { t } from '../lib/i18n'
import { load, save } from '../lib/storage'
import { memoryKey, suggestItems, type AmountMemory, type SuggestReason } from '../lib/suggest'
import type { CatalogItem, Invoice, InvoiceList } from '../types'

const BATCH = 500
const MEMORY_LIMIT = 300

const REASON_LABEL: Record<SuggestReason, () => string> = {
  remembered: () => t('اخترتها لنفس المبلغ سابقاً'),
  exact: () => t('السعر يطابق المبلغ'),
  range: () => t('المبلغ ضمن نطاق السعر'),
  popular: () => t('الأكثر استخداماً'),
}

/**
 * Quick classify: the unclassified invoices one at a time, each with suggested services/products
 * based on its amount. One tap picks one, saves in the background and shows the next invoice.
 * The "+" next to a suggestion (or several picks from the list) collects more than one service instead;
 * the invoice amount is then split between them and the split can be adjusted before saving.
 */
export default function Classify() {
  const { currentStore, items } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const [queue, setQueue] = useState<Invoice[] | null>(null)
  /** Invoices that match but are not loaded yet (the queue is loaded in batches). */
  const [more, setMore] = useState(0)
  const [done, setDone] = useState(0)
  const [last, setLast] = useState<{ inv: Invoice; names: string } | null>(null)
  /** Services collected for the current invoice (several at once), with their typed prices. */
  const [basket, setBasket] = useState<CatalogItem[]>([])
  const [prices, setPrices] = useState<string[]>([])
  const [error, setError] = useState<string | null>(null)
  const [picker, setPicker] = useState(false)
  const [undoing, setUndoing] = useState(false)
  const memory = useRef<AmountMemory>(load<AmountMemory>('qcMemory', {}))
  /** Saves that have not finished yet, by invoice id. */
  const inflight = useRef(new Map<number, Promise<unknown>>())

  const range = params.get('range') as RangeKey | null
  const from = params.get('from')
  const to = params.get('to')
  const fetchBatch = useCallback(async () => {
    const dates = range && range !== 'all' ? rangeDates(range) : { from: from ?? undefined, to: to ?? undefined }
    const r = await api<InvoiceList>('invoices', { query: { store: currentStore, unclassified: 1, sort: 'paid_asc', per_page: BATCH, ...dates } })
    // Anything still being saved is already classified, even if the server has not caught up yet.
    const rows = r.invoices.filter((i) => !inflight.current.has(i.id))
    return { rows, more: Math.max(0, r.total - r.invoices.length) }
  }, [currentStore, range, from, to])

  const start = useCallback(() => {
    setError(null)
    setQueue(null)
    setDone(0)
    setLast(null)
    fetchBatch().then(
      (b) => (setQueue(b.rows), setMore(b.more)),
      (e) => setError(errorMessage(e)),
    )
  }, [fetchBatch])
  useEffect(start, [start])

  // The batch is used up but there are more: load the next one.
  useEffect(() => {
    if (queue?.length !== 0 || more === 0) return
    let live = true
    fetchBatch().then(
      (b) => live && (setQueue(b.rows), setMore(b.more)),
      (e) => live && setError(errorMessage(e)),
    )
    return () => {
      live = false
    }
  }, [queue?.length, more, fetchBatch])

  const cur = queue?.[0]
  const suggestions = useMemo(() => (cur ? suggestItems(items, cur, memory.current) : []), [items, cur])

  // A new invoice on screen starts with an empty selection.
  const [basketFor, setBasketFor] = useState<number | undefined>(undefined)
  if (cur?.id !== basketFor) {
    setBasketFor(cur?.id)
    setBasket([])
    setPrices([])
  }
  const setBasketItems = (next: CatalogItem[]) => {
    setBasket(next)
    setPrices(initialPrices(cur?.amount ?? 0, next.map((i) => i.default_price)))
  }
  const toggleBasket = (item: CatalogItem) =>
    setBasketItems(basket.some((b) => b.id === item.id) ? basket.filter((b) => b.id !== item.id) : [...basket, item])

  const remember = (inv: Invoice, item: CatalogItem) => {
    const key = memoryKey(inv.store_id, inv.amount)
    const m = memory.current
    delete m[key] // re-insert so the newest entries are kept when trimming
    m[key] = item.id
    for (const old of Object.keys(m).slice(0, Math.max(0, Object.keys(m).length - MEMORY_LIMIT))) delete m[old]
    save('qcMemory', m)
  }

  /** Saves the invoice with one service (takes the whole amount) or several with their split prices. */
  const classify = (picked: CatalogItem[], split?: number[]) => {
    if (!cur || !picked.length) return
    const inv = cur
    setQueue((q) => q?.slice(1) ?? q)
    setDone((d) => d + 1)
    setLast({ inv, names: picked.map((i) => i.name).join(t('، ')) })
    const body = { items: picked.map((i, k) => ({ item_id: i.id, qty: 1, unit_price: picked.length > 1 ? split?.[k] : undefined })) }
    const p = api(`invoices/${inv.id}`, { method: 'PUT', body })
      .then(() => picked.length === 1 && remember(inv, picked[0]))
      .catch((e) => {
        toast(errorMessage(e), 'error')
        // Put it back right after the invoice being looked at, so the screen doesn't jump.
        setQueue((q) => (q?.length ? [q[0], inv, ...q.slice(1)] : [inv]))
        setDone((d) => d - 1)
        setLast((l) => (l?.inv.id === inv.id ? null : l))
      })
      .finally(() => inflight.current.delete(inv.id))
    inflight.current.set(inv.id, p)
  }

  const skip = () => setQueue((q) => (q && q.length > 1 ? [...q.slice(1), q[0]] : q))

  const undo = async () => {
    if (!last || undoing) return
    const { inv } = last
    setUndoing(true)
    try {
      await inflight.current.get(inv.id) // never race the save we are undoing
      await api(`invoices/${inv.id}`, { method: 'PUT', body: { items: [] } })
      setQueue((q) => [inv, ...(q ?? [])])
      setDone((d) => d - 1)
      setLast(null)
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setUndoing(false)
    }
  }

  const saveBasket = () => {
    if (!cur || !splitValid(cur.amount, prices)) return
    classify(basket, resolvePrices(cur.amount, prices))
  }

  // Keyboard: 1-4 pick a suggestion (or add it to the selection), Enter confirms, S skips, Z undoes.
  const keys = useRef<(e: KeyboardEvent) => void>(undefined)
  keys.current = (e) => {
    const target = e.target as HTMLElement
    if (picker || e.metaKey || e.ctrlKey || e.altKey || /^(INPUT|TEXTAREA|SELECT)$/.test(target.tagName)) return
    const n = Number(e.key)
    if (n >= 1 && n <= suggestions.length) (basket.length ? toggleBasket(suggestions[n - 1].item) : classify([suggestions[n - 1].item]))
    else if (e.key === 'Enter' && basket.length) saveBasket()
    else if (e.key === 'Enter' && suggestions[0]) classify([suggestions[0].item])
    else if (e.key.toLowerCase() === 's') skip()
    else if (e.key.toLowerCase() === 'z') void undo()
    else return
    e.preventDefault()
  }
  useEffect(() => {
    const on = (e: KeyboardEvent) => keys.current?.(e)
    window.addEventListener('keydown', on)
    return () => window.removeEventListener('keydown', on)
  }, [])

  const remaining = (queue?.length ?? 0) + more
  const total = done + remaining
  const finished = queue !== null && queue.length === 0 && more === 0

  return (
    <>
      <TopBar title={t('التصنيف السريع')} back />
      <Page width="narrow">
        {error && !queue && (
          <EmptyState
            icon={<WifiOff className="size-8" />}
            title={t('تعذّر تحميل الفواتير')}
            text={error}
            action={
              <Button icon={<RefreshCw className="size-5" />} onClick={start}>
                {t('إعادة المحاولة')}
              </Button>
            }
          />
        )}
        {!error && (!queue || (queue.length === 0 && more > 0)) && <PageLoader />}

        {finished && (
          <EmptyState
            icon={<CheckCircle2 className="size-8 text-success" />}
            title={t('تم تصنيف كل الفواتير')}
            text={done > 0 ? t('صنّفت {0} فاتورة في هذه الجلسة', done) : undefined}
            action={<Button onClick={() => navigate('/')}>{t('العودة للرئيسية')}</Button>}
          />
        )}

        {cur && (
          <>
            <div className="mb-1 flex items-center justify-between px-1 text-[14px] text-muted">
              <span className="num">{t('الفاتورة {0} من {1}', done + 1, total)}</span>
              <span className="num">{Math.round((done / total) * 100)}%</span>
            </div>
            <div className="mb-4 h-2 overflow-hidden rounded-full bg-surface-2">
              <div className="h-full rounded-full bg-primary transition-all duration-300" style={{ width: `${(done / total) * 100}%` }} />
            </div>

            <div key={cur.id} className="animate-rise rounded-3xl border border-line bg-surface p-5 shadow-card">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="truncate text-[19px] font-semibold">{cur.customer_name || t('بدون اسم')}</p>
                  <p className="mt-1 flex items-center gap-1.5 text-[14px] text-muted">
                    <StoreDot color={cur.store_color} storeId={cur.store_id} />
                    <span className="truncate">{cur.store_name}</span>
                    <span>·</span>
                    <span className="shrink-0">{fmtDate(cur.paid_at)}</span>
                  </p>
                </div>
                <Money value={cur.amount} className="text-[28px] font-bold leading-tight" />
              </div>
              <p className="num mt-3 flex flex-wrap gap-x-3 gap-y-1 text-[13px] text-muted">
                {cur.doc_no && <span>{cur.doc_no}</span>}
                {cur.pay_method && <span>{payLabel(cur.pay_method)}</span>}
                {cur.phone && <span>{cur.phone}</span>}
                {cur.email && <span className="break-all">{cur.email}</span>}
              </p>
              {cur.note && <p className="mt-2 line-clamp-2 rounded-2xl bg-surface-2 px-3 py-2 text-[14px]">{cur.note}</p>}
            </div>

            <div className="mt-4 space-y-2.5">
              {suggestions.length === 0 && (
                <p className="rounded-2xl bg-warn-soft px-4 py-3 text-[15px] font-medium text-warn">{t('لا يوجد اقتراح مناسب لهذا المبلغ. اختر من القائمة.')}</p>
              )}
              {suggestions.map((s, i) => {
                const range = priceRange(s.item.price_min, s.item.price_max)
                const inBasket = basket.some((b) => b.id === s.item.id)
                // The first suggestion stands out as the one-tap answer, until several are being collected.
                const lead = i === 0 && !basket.length
                return (
                  <div key={s.item.id} className="flex items-stretch gap-2">
                    <button
                      onClick={() => (basket.length ? toggleBasket(s.item) : classify([s.item]))}
                      className={cx(
                        'flex min-w-0 flex-1 items-center gap-3 rounded-3xl p-4 text-start transition active:scale-[0.98]',
                        lead
                          ? 'bg-primary text-primary-fg shadow-lg shadow-primary/25'
                          : inBasket
                            ? 'border border-primary bg-primary-soft/60 ring-2 ring-primary/25'
                            : 'border border-line bg-surface hover:bg-surface-2',
                      )}
                    >
                      <span
                        className={cx(
                          'flex size-11 shrink-0 items-center justify-center rounded-2xl',
                          lead ? 'bg-white/20' : inBasket ? 'bg-primary text-primary-fg' : 'bg-primary-soft text-primary',
                        )}
                      >
                        {lead || inBasket ? <Check className="size-6" strokeWidth={3} /> : <span className="num text-[16px] font-bold">{i + 1}</span>}
                      </span>
                      <span className="min-w-0 flex-1">
                        <span className="block text-[17px] font-bold leading-snug">{s.item.name}</span>
                        <span className={cx('flex items-center gap-1.5 text-[13px]', lead ? 'opacity-85' : 'text-muted')}>
                          {lead && <Sparkles className="size-3.5 shrink-0" />}
                          <span className="truncate">{REASON_LABEL[s.reason]()}</span>
                          {range && (
                            <>
                              <span>·</span>
                              <span className="num shrink-0">{range}</span>
                            </>
                          )}
                        </span>
                      </span>
                    </button>
                    <button
                      aria-label={inBasket ? t('إزالة «{0}» من الاختيار', s.item.name) : t('إضافة «{0}» مع خدمات أخرى', s.item.name)}
                      title={inBasket ? t('إزالة من الاختيار') : t('اختيار أكثر من خدمة')}
                      aria-pressed={inBasket}
                      onClick={() => toggleBasket(s.item)}
                      className={cx(
                        'flex w-14 shrink-0 items-center justify-center rounded-3xl border transition active:scale-95',
                        inBasket ? 'border-primary bg-primary text-primary-fg' : 'border-line bg-surface text-primary hover:bg-surface-2',
                      )}
                    >
                      {inBasket ? <X className="size-5" /> : <Plus className="size-6" />}
                    </button>
                  </div>
                )
              })}
            </div>

            {basket.length > 0 && (
              <div className="animate-rise mt-4 rounded-3xl border border-primary/40 bg-surface p-4 shadow-card">
                <div className="mb-3 flex items-center gap-2">
                  <Layers className="size-5 shrink-0 text-primary" />
                  <p className="min-w-0 flex-1 text-[16px] font-semibold">{t('{0} خدمة لهذه الفاتورة', basket.length)}</p>
                  <button className="shrink-0 text-[14px] font-semibold text-muted" onClick={() => setBasketItems([])}>
                    {t('إلغاء')}
                  </button>
                </div>
                <LineSplit
                  amount={cur.amount}
                  lines={basket.map((b) => ({ item_id: b.id, name: b.name, kind: b.kind }))}
                  prices={prices}
                  onChange={setPrices}
                  onRemove={(k) => setBasketItems(basket.filter((_, i) => i !== k))}
                />
                <Button block size="lg" className="mt-3" icon={<Check className="size-5" strokeWidth={3} />} disabled={!splitValid(cur.amount, prices)} onClick={saveBasket}>
                  {basket.length === 1 ? t('حفظ «{0}»', basket[0].name) : t('حفظ {0} خدمات', basket.length)}
                </Button>
              </div>
            )}

            <div className="mt-3 flex gap-3">
              <Button block variant="secondary" icon={<Tag className="size-5" />} onClick={() => setPicker(true)}>
                {basket.length ? t('إضافة من القائمة') : t('اختيار آخر')}
              </Button>
              <Button block variant="ghost" icon={<SkipForward className="size-5 rtl:rotate-180" />} disabled={queue!.length < 2} onClick={skip}>
                {t('تخطي')}
              </Button>
            </div>
            <p className="mt-3 text-center text-[13px] text-muted">{t('لأكثر من خدمة في نفس الفاتورة اضغط + بجانب كل خدمة، ويُقسَّم المبلغ عليها.')}</p>
            <p className="mt-2 hidden text-center text-[13px] text-muted lg:block">{t('اختصارات: 1–4 للاختيار، Enter للتأكيد، S للتخطي، Z للتراجع')}</p>
          </>
        )}

        {last && (
          <div className="animate-rise mt-4 flex items-center gap-3 rounded-2xl bg-success-soft px-4 py-3 text-success">
            <Check className="size-5 shrink-0" strokeWidth={3} />
            <span className="min-w-0 flex-1 truncate text-[15px] font-medium">{t('تم تصنيف «{0}»', last.names)}</span>
            <button onClick={undo} disabled={undoing} className="flex shrink-0 items-center gap-1 rounded-xl px-2 py-1 text-[15px] font-bold disabled:opacity-50">
              <Undo2 className="size-4" /> {t('تراجع')}
            </button>
          </div>
        )}
      </Page>

      <ItemPicker
        open={picker}
        onClose={() => setPicker(false)}
        storeId={cur?.store_id ?? null}
        exclude={basket.map((b) => b.id)}
        onPickMany={(picked) => (basket.length || picked.length > 1 ? setBasketItems([...basket, ...picked]) : classify(picked))}
      />
    </>
  )
}

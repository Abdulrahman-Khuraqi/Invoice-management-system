import { useCallback, useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AlertCircle, ChevronLeft, FileSpreadsheet, Plus, RefreshCw, WifiOff } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { InvoiceCard, InvoiceSheet } from '../components/InvoiceViews'
import { Page, TopBar } from '../components/Layout'
import { Button, Card, Chip, EmptyState, IconButton, Money, PageLoader, SectionTitle, StoreDot, cx } from '../components/ui'
import { RANGE_LABELS, fmtTime, money, rangeDates, type RangeKey } from '../lib/format'
import { load, save } from '../lib/storage'
import type { Invoice, InvoiceList, Stats } from '../types'
import { t } from '../lib/i18n'

const HOME_RANGES: RangeKey[] = ['month', 'last_month', 'year', 'all']
/** The home page stays open all day: refresh it in the background while it is on screen. */
const AUTO_REFRESH_MS = 60_000
/** Coming back to the app refreshes, unless the last fetch was this recent. */
const FRESH_MS = 15_000
/** A request that hangs on a bad connection is given up after this, so the page never stays "updating" forever. */
const TIMEOUT_MS = 20_000

interface HomeData {
  stats: Stats
  /** null when only the stats came from the saved copy (recent invoices aren't stored on the device). */
  recent: Invoice[] | null
  at: number
}

// Last data per user/store/range: in memory for moving between pages, and the totals (no customer
// details) in localStorage so the numbers show at once when the app is reopened, even offline.
const memory = new Map<string, HomeData>()
function readCached(key: string): HomeData | null {
  const hit = memory.get(key)
  if (hit) return hit
  const saved = load<{ stats: Stats; at: number } | null>(key, null)
  return saved?.stats ? { stats: saved.stats, at: saved.at, recent: null } : null
}

export default function Home() {
  const { user, currentStore, setCurrentStore, can } = useApp()
  const navigate = useNavigate()
  const [range, setRange] = useState<RangeKey>(() => load<RangeKey>('homeRange', 'month'))
  const key = `home:${user.id}:${currentStore ?? 'all'}:${range}`
  const [data, setData] = useState<HomeData | null>(() => readCached(key))
  const [error, setError] = useState<string | null>(null)
  const [refreshing, setRefreshing] = useState(false)
  const [open, setOpen] = useState<Invoice | null>(null)
  const reqId = useRef(0)
  const lastFetch = useRef(0)

  const refresh = useCallback(async () => {
    // Only the latest request may update the page, so a slow answer for a range the user already left is ignored.
    const id = ++reqId.current
    lastFetch.current = Date.now()
    setRefreshing(true)
    const ctrl = new AbortController()
    const timer = window.setTimeout(() => ctrl.abort(), TIMEOUT_MS)
    try {
      const [stats, recent] = await Promise.all([
        api<Stats>('stats', { query: { store: currentStore, ...rangeDates(range) }, signal: ctrl.signal }),
        api<InvoiceList>('invoices', { query: { store: currentStore, per_page: 5, sort: 'added_desc' }, signal: ctrl.signal }),
      ])
      if (id !== reqId.current) return
      const next = { stats, recent: recent.invoices, at: Date.now() }
      memory.set(key, next)
      save(key, { stats, at: next.at })
      setData(next)
      setError(null)
    } catch (e) {
      if (id === reqId.current) setError(errorMessage(e))
    } finally {
      window.clearTimeout(timer)
      if (id === reqId.current) setRefreshing(false)
    }
  }, [key, currentStore, range])

  // New store or range: show what we last had for it right away, then fetch.
  useEffect(() => {
    setData(readCached(key))
    setError(null)
    void refresh()
  }, [key, refresh])

  useEffect(() => {
    const visible = () => document.visibilityState === 'visible'
    const onReturn = () => visible() && Date.now() - lastFetch.current > FRESH_MS && void refresh()
    const onOnline = () => void refresh()
    const timer = window.setInterval(() => visible() && void refresh(), AUTO_REFRESH_MS)
    document.addEventListener('visibilitychange', onReturn)
    window.addEventListener('focus', onReturn)
    window.addEventListener('online', onOnline)
    return () => {
      window.clearInterval(timer)
      document.removeEventListener('visibilitychange', onReturn)
      window.removeEventListener('focus', onReturn)
      window.removeEventListener('online', onOnline)
    }
  }, [refresh])

  const rangeQuery = () => (range === 'all' ? '' : `&range=${range}`)
  const stats = data?.stats
  const recent = data?.recent

  return (
    <>
      <TopBar
        title={t('الرئيسية')}
        switcher
        actions={
          <IconButton label={t('تحديث')} onClick={() => void refresh()}>
            <RefreshCw className={cx('size-6', refreshing && 'animate-spin')} />
          </IconButton>
        }
      />
      <Page>
        <div className="no-scrollbar -mx-4 mb-2 flex gap-2 overflow-x-auto px-4">
          {HOME_RANGES.map((k) => (
            <Chip
              key={k}
              active={range === k}
              onClick={() => {
                setRange(k)
                save('homeRange', k)
              }}
            >
              {RANGE_LABELS[k]}
            </Chip>
          ))}
        </div>

        {data && error && (
          <div className="mb-3 flex items-center gap-3 rounded-2xl border border-warn/30 bg-warn-soft px-4 py-3">
            <WifiOff className="size-5 shrink-0 text-warn" />
            <span className="min-w-0 flex-1 text-[14px] font-medium text-warn">
              {t('تعذّر التحديث. هذه آخر بيانات من الساعة {0}', fmtTime(new Date(data.at)))}
            </span>
            <Button size="sm" variant="secondary" loading={refreshing} onClick={() => void refresh()}>
              {t('إعادة المحاولة')}
            </Button>
          </div>
        )}
        {data && !error && (
          <p className="mb-3 px-1 text-[13px] text-muted" aria-live="polite">
            {refreshing ? t('جارٍ التحديث…') : t('آخر تحديث {0}', fmtTime(new Date(data.at)))}
          </p>
        )}

        {!data && !error && <PageLoader />}
        {!data && error && (
          <EmptyState
            icon={<WifiOff className="size-8" />}
            title={t('تعذّر تحميل البيانات')}
            text={error}
            action={
              <Button loading={refreshing} icon={<RefreshCw className="size-5" />} onClick={() => void refresh()}>
                {t('إعادة المحاولة')}
              </Button>
            }
          />
        )}

        {stats && (
          <>
            <div className="lg:grid lg:grid-cols-3 lg:gap-4">
              <div className={`rounded-[28px] bg-primary p-5 text-primary-fg shadow-lg shadow-primary/25 lg:p-7 ${stats.unclassified > 0 ? 'lg:col-span-2' : 'lg:col-span-3'}`}>
                <p className="text-[15px] opacity-85">{t('إجمالي المبيعات · {0}', RANGE_LABELS[range])}</p>
                <p className="mt-1 text-[34px] font-bold leading-tight lg:text-[44px]">
                  <span className="num">{money(stats.sum)}</span>
                  <span className="ms-1.5 text-[18px] font-medium opacity-80">{t('ر.س')}</span>
                </p>
                <p className="mt-1 text-[15px] opacity-85">
                  <span className="num">{t('{0} فاتورة', stats.count)}</span>
                </p>
              </div>

              {stats.unclassified > 0 && (
                <button
                  onClick={() => navigate(can('editor') ? `/classify?${rangeQuery().slice(1)}` : `/invoices?unclassified=1${rangeQuery()}`)}
                  className="mt-3 flex w-full items-center gap-3 rounded-3xl border border-warn/30 bg-warn-soft p-4 text-start transition hover:brightness-95 active:scale-[0.99] lg:mt-0 lg:flex-col lg:items-start lg:justify-center lg:gap-4 lg:p-6"
                >
                  <span className="flex size-11 shrink-0 items-center justify-center rounded-2xl bg-warn text-white">
                    <AlertCircle className="size-6" />
                  </span>
                  <span className="flex-1">
                    <span className="block text-[17px] font-bold text-warn">
                      <span className="num">{t('{0} فاتورة غير مصنّفة', stats.unclassified)}</span>
                    </span>
                    <span className="text-[14px] text-warn/80">{can('editor') ? t('ابدأ التصنيف السريع') : t('حدد الخدمة أو المنتج لكل فاتورة')}</span>
                  </span>
                  <ChevronLeft className="size-6 text-warn lg:hidden ltr:rotate-180" />
                </button>
              )}
            </div>

            {stats.count === 0 && (
              <EmptyState
                icon={<FileSpreadsheet className="size-8" />}
                title={t('لا توجد فواتير في هذه الفترة')}
                text={t('ابدأ باستيراد ملفات Excel من بوابة الدفع أو أضف فاتورة يدوياً')}
                action={
                  can('editor') && (
                    <Button icon={<Plus className="size-5" />} onClick={() => navigate('/add')}>
                      {t('إضافة فواتير')}
                    </Button>
                  )
                }
              />
            )}

            {!currentStore && stats.by_store.length > 0 && (
              <>
                <SectionTitle>{t('المتاجر')}</SectionTitle>
                <div className="stagger grid grid-cols-2 gap-3 lg:grid-cols-[repeat(auto-fit,minmax(220px,1fr))] lg:gap-4">
                  {stats.by_store.map((s) => (
                    <Card key={s.id} className="p-4" onClick={() => (setCurrentStore(s.id!), navigate(`/invoices?${rangeQuery().slice(1)}`))}>
                      <span className="flex items-center gap-2 text-[15px] font-semibold">
                        <StoreDot color={s.color!} className="size-3" storeId={s.id} />
                        <span className="truncate">{s.name}</span>
                      </span>
                      <Money value={s.total} className="mt-2 block text-[19px] font-bold" />
                      <span className="text-[13px] text-muted">
                        <span className="num">{t('{0} فاتورة', s.n)}</span>
                      </span>
                    </Card>
                  ))}
                </div>
              </>
            )}

            {recent === null && <PageLoader />}
            {recent && recent.length > 0 && (
              <>
                <SectionTitle
                  action={
                    <button className="text-[14px] font-semibold text-primary" onClick={() => navigate('/invoices?sort=added_desc')}>
                      {t('عرض الكل')}
                    </button>
                  }
                >
                  {t('آخر ما أُضيف')}
                </SectionTitle>
                <div className="stagger space-y-2.5 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">
                  {recent.map((inv) => (
                    <InvoiceCard key={inv.id} invoice={inv} showStore={!currentStore} onOpen={() => setOpen(inv)} />
                  ))}
                </div>
              </>
            )}
          </>
        )}
      </Page>
      <InvoiceSheet
        invoice={open}
        onClose={() => setOpen(null)}
        onChanged={(inv) => {
          setData((d) => d && { ...d, recent: d.recent?.map((x) => (x.id === inv.id ? inv : x)) ?? null })
          setOpen(inv)
          // Classifying or editing changes the totals and the unclassified count.
          void refresh()
        }}
        onDeleted={(id) => {
          setData((d) => d && { ...d, recent: d.recent?.filter((x) => x.id !== id) ?? null })
          void refresh()
        }}
      />
    </>
  )
}

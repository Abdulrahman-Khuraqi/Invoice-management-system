import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { useNavigate } from '../lib/nav'
import { BarChart3, CalendarDays, Download } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Card, Chip, EmptyState, IconButton, Money, PageLoader, SectionTitle, Segmented, cx } from '../components/ui'
import { KIND_LABELS, RANGE_LABELS, fmtDayMonth, money, rangeDates, shortMoney, weekdayName, ymd, type RangeKey } from '../lib/format'
import { daysBetween, fillPeriods, periodLabel, type Grain, type Period } from '../lib/periods'
import { load, save } from '../lib/storage'
import type { Stats } from '../types'
import { RangePicker } from './Invoices'
import { ARROW, LOCALE, t } from '../lib/i18n'

const GRAINS: Grain[] = ['day', 'week', 'month', 'year']
const GRAIN_LABEL: Record<Grain, () => string> = {
  day: () => t('يومي'),
  week: () => t('أسبوعي'),
  month: () => t('شهري'),
  year: () => t('سنوي'),
}
const GRAIN_TITLE: Record<Grain, () => string> = {
  day: () => t('اليوم بيوم'),
  week: () => t('أسبوعاً بأسبوع'),
  month: () => t('شهراً بشهر'),
  year: () => t('سنة بسنة'),
}

/** What the charts and bars show: how much money came in, or how many payments there were. */
type Metric = 'amount' | 'count'
const valueOf = (m: Metric, r: { n: number; total: number }) => (m === 'amount' ? r.total : r.n)

/** Revenue and number of payments, per day / week / month / year and per store, service and category. */
export default function Reports() {
  const { currentStore, storeById } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const [range, setRange] = useState<RangeKey | null>(() => load<RangeKey | null>('reportRange', 'month'))
  const [custom, setCustom] = useState<{ from?: string; to?: string }>({})
  const [grain, setGrain] = useState<Grain>(() => load<Grain>('reportGrain', 'day'))
  const [metric, setMetric] = useState<Metric>(() => load<Metric>('reportMetric', 'amount'))
  const [stats, setStats] = useState<Stats | null>(null)
  const [picker, setPicker] = useState(false)

  const dates = range ? rangeDates(range) : custom
  useEffect(() => {
    setStats(null)
    api<Stats>('stats', { query: { store: currentStore, ...dates } })
      .then(setStats)
      .catch((e) => toast(errorMessage(e), 'error'))
  }, [currentStore, range, custom.from, custom.to, toast])

  const label = range ? RANGE_LABELS[range] : `${custom.from ?? '…'} ${ARROW} ${custom.to ?? '…'}`
  const linkQuery = range && range !== 'all' ? `range=${range}` : new URLSearchParams(Object.entries(custom).filter(([, v]) => v) as [string, string][]).toString()

  const from = dates.from ?? stats?.first_day ?? null
  const to = dates.to ?? stats?.last_day ?? null
  const perDay = stats ? stats.count / daysBetween(from, to) : 0
  // The year switch only makes sense once there is more than one year of payments.
  const grains = GRAINS.filter((g) => g !== 'year' || (stats?.yearly.length ?? 0) > 1)
  const activeGrain = grains.includes(grain) ? grain : 'day'
  const series = useMemo(() => {
    if (!stats) return []
    const rows = { day: stats.daily, week: stats.weekly, month: stats.monthly, year: stats.yearly }[activeGrain]
    return fillPeriods(rows, activeGrain, from, to)
  }, [stats, activeGrain, from, to])
  const weekdays = useMemo(
    () =>
      [1, 2, 3, 4, 5, 6, 7].map((dow) => {
        const r = stats?.by_weekday.find((x) => x.dow === dow)
        return { name: weekdayName(dow), n: r?.n ?? 0, total: r?.total ?? 0 }
      }),
    [stats],
  )

  const doExport = async () => {
    if (!stats) return
    const { exportReport } = await import('../lib/excel')
    const storeName = storeById(currentStore)?.name ?? t('كل المتاجر')
    const N = t('عدد المدفوعات')
    const R = t('الإيرادات')
    const A = t('متوسط الدفعة')
    const avg = (r: { n: number; total: number }) => (r.n ? Number((r.total / r.n).toFixed(2)) : 0)
    exportReport(
      [
        {
          name: t('ملخص'),
          rows: [
            {
              [t('المتجر')]: storeName,
              [t('الفترة')]: label,
              [R]: stats.sum,
              [N]: stats.count,
              [A]: avg({ n: stats.count, total: stats.sum }),
              [t('متوسط الإيراد اليومي')]: Number((stats.sum / daysBetween(from, to)).toFixed(2)),
              [t('المتوسط اليومي')]: Number(perDay.toFixed(2)),
              [t('غير مصنّفة')]: stats.unclassified,
            },
          ],
        },
        { name: t('حسب المتجر'), rows: stats.by_store.map((r) => ({ [t('المتجر')]: r.name, [R]: r.total, [N]: r.n, [A]: avg(r) })) },
        { name: t('حسب الخدمة والمنتج'), rows: stats.by_item.map((r) => ({ [t('الخدمة/المنتج')]: r.name, [t('النوع')]: r.kind ? KIND_LABELS[r.kind] : '', [R]: r.total, [N]: r.n })) },
        { name: t('حسب التصنيف'), rows: stats.by_category.map((r) => ({ [t('التصنيف')]: r.name, [R]: r.total, [N]: r.n })) },
        { name: t('حسب أيام الأسبوع'), rows: weekdays.map((r) => ({ [t('اليوم')]: r.name, [R]: r.total, [N]: r.n, [A]: avg(r) })) },
        { name: t('يومي'), rows: stats.daily.map((r) => ({ [t('اليوم')]: r.day, [R]: r.total, [N]: r.n, [A]: avg(r) })) },
        { name: t('أسبوعي'), rows: stats.weekly.map((r) => ({ [t('بداية الأسبوع')]: r.day, [R]: r.total, [N]: r.n, [A]: avg(r) })) },
        { name: t('شهري'), rows: stats.monthly.map((r) => ({ [t('الشهر')]: r.day?.slice(0, 7), [R]: r.total, [N]: r.n, [A]: avg(r) })) },
      ],
      t('تقرير-{0}-{1}.xlsx', storeName, ymd(new Date())),
    )
  }

  return (
    <>
      <TopBar
        title={t('التقارير')}
        switcher
        actions={
          <IconButton label={t('تصدير التقرير')} onClick={doExport} disabled={!stats}>
            <Download className="size-6" />
          </IconButton>
        }
      />
      <Page>
        <div className="no-scrollbar -mx-4 mb-4 flex gap-2 overflow-x-auto px-4 lg:mx-0 lg:flex-wrap lg:px-0">
          {(['month', 'last_month', 'year', 'all'] as RangeKey[]).map((k) => (
            <Chip
              key={k}
              active={range === k}
              onClick={() => {
                setRange(k)
                save('reportRange', k)
              }}
            >
              {RANGE_LABELS[k]}
            </Chip>
          ))}
          <Chip active={!range || !['month', 'last_month', 'year', 'all'].includes(range)} onClick={() => setPicker(true)}>
            <CalendarDays className="size-4" /> {range && ['month', 'last_month', 'year', 'all'].includes(range) ? t('فترة أخرى') : label}
          </Chip>
        </div>

        {!stats && <PageLoader />}
        {stats && stats.count === 0 && <EmptyState icon={<BarChart3 className="size-8" />} title={t('لا توجد بيانات في هذه الفترة')} />}
        {stats && stats.count > 0 && (
          <>
            <div className="grid grid-cols-2 gap-3 lg:grid-cols-3 lg:gap-4">
              <Kpi label={t('إجمالي الإيرادات')} value={money(stats.sum)} unit={t('ر.س')} big wide />
              <Kpi label={t('عدد المدفوعات')} value={String(stats.count)} hint={t('{0} في اليوم', perDay.toLocaleString(LOCALE, { maximumFractionDigits: 1 }))} />
              <Kpi label={t('متوسط الدفعة')} value={money(stats.count ? stats.sum / stats.count : 0)} unit={t('ر.س')} />
              <Kpi label={t('متوسط الإيراد اليومي')} value={money(stats.sum / daysBetween(from, to))} unit={t('ر.س')} />
              <Kpi
                label={t('أعلى يوم إيراداً')}
                value={money(stats.richest?.total ?? 0)}
                unit={t('ر.س')}
                hint={stats.richest ? fmtDayMonth(stats.richest.day) : undefined}
              />
              <Kpi
                label={t('غير مصنّفة')}
                value={String(stats.unclassified)}
                hint={stats.unclassified > 0 ? `${money(stats.unclassified_sum)} ${t('ر.س')}` : undefined}
                warn={stats.unclassified > 0}
                wide
                onClick={() => navigate(`/invoices?unclassified=1${linkQuery ? '&' + linkQuery : ''}`)}
              />
            </div>

            <div className="mt-5 lg:max-w-md">
              <Segmented<Metric>
                value={metric}
                onChange={(m) => {
                  setMetric(m)
                  save('reportMetric', m)
                }}
                options={[
                  { value: 'amount', label: t('المبالغ') },
                  { value: 'count', label: t('عدد المدفوعات') },
                ]}
              />
            </div>

            <SectionTitle>{GRAIN_TITLE[activeGrain]()}</SectionTitle>
            {grains.length > 1 && (
              <div className="mb-3 lg:max-w-md">
                <Segmented<Grain>
                  value={activeGrain}
                  onChange={(g) => {
                    setGrain(g)
                    save('reportGrain', g)
                  }}
                  options={grains.map((g) => ({ value: g, label: GRAIN_LABEL[g]() }))}
                />
              </div>
            )}
            <PaymentsChart periods={series} grain={activeGrain} metric={metric} />
            <PeriodTable periods={series} grain={activeGrain} />

            {/* Columns, not grid rows: each section takes only the height it needs, so there are no gaps under shorter ones. */}
            <div className="mt-6 lg:columns-2 lg:gap-x-8">
              <Section title={t('حسب أيام الأسبوع')}>
                <Bars rows={weekdays} metric={metric} stats={stats} />
              </Section>

              {!currentStore && stats.by_store.length > 0 && (
                <Section title={t('حسب المتجر')}>
                  <Bars rows={stats.by_store.map((r) => ({ name: r.name ?? '', n: r.n, total: r.total, color: r.color }))} metric={metric} stats={stats} />
                </Section>
              )}

              {stats.by_category.length > 0 && (
                <Section title={t('حسب التصنيف')}>
                  <Bars
                    rows={stats.by_category.map((r) => ({ id: r.id, name: r.name ?? '', n: r.n, total: r.total, color: r.color }))}
                    metric={metric}
                    stats={stats}
                    onClick={(r) => r.id && navigate(`/invoices?category=${r.id}${linkQuery ? '&' + linkQuery : ''}`)}
                  />
                </Section>
              )}

              {stats.by_item.length > 0 && (
                <Section title={t('حسب الخدمة والمنتج')}>
                  <Bars
                    rows={[...stats.by_item].sort((a, b) => valueOf(metric, b) - valueOf(metric, a)).map((r) => ({ id: r.id, name: r.name ?? '', n: r.n, total: r.total, color: r.kind === 'service' ? 'var(--primary)' : 'var(--success)' }))}
                    metric={metric}
                    stats={stats}
                    onClick={(r) => navigate(`/invoices?item=${r.id}${linkQuery ? '&' + linkQuery : ''}`)}
                  />
                </Section>
              )}
            </div>
            {stats.unclassified > 0 && <p className="px-1 text-[13px] text-muted">{t('التقارير حسب الخدمة والتصنيف لا تشمل {0} دفعة غير مصنّفة.', stats.unclassified)}</p>}
          </>
        )}
      </Page>
      <Sheet open={picker} onClose={() => setPicker(false)} title={t('الفترة')}>
        <RangePicker
          range={range}
          from={custom.from ?? ''}
          to={custom.to ?? ''}
          onChange={(u) => {
            if (u.range) {
              setRange(u.range as RangeKey)
            } else if (u.from || u.to) {
              setRange(null)
              setCustom({ from: u.from ?? undefined, to: u.to ?? undefined })
            } else {
              setRange('all')
            }
            setPicker(false)
          }}
        />
      </Sheet>
    </>
  )
}

function Kpi({ label, value, unit, hint, big, wide, warn, onClick }: { label: string; value: string; unit?: string; hint?: string; big?: boolean; wide?: boolean; warn?: boolean; onClick?: () => void }) {
  return (
    <Card onClick={onClick} className={cx('flex min-h-[92px] flex-col justify-between', wide && 'col-span-2 lg:col-span-1', warn && 'border-warn/40 bg-warn-soft')}>
      <p className={cx('text-[14px]', warn ? 'text-warn' : 'text-muted')}>{label}</p>
      <p className={cx('num mt-1 font-bold leading-tight', big ? 'text-[30px]' : 'text-[24px]', warn && 'text-warn')}>
        {value}
        {unit && <span className="ms-1.5 text-[14px] font-normal text-muted">{unit}</span>}
      </p>
      {hint && <p className="num mt-0.5 text-[13px] font-medium text-muted">{hint}</p>}
    </Card>
  )
}

/** A report section inside the columns: never split across columns, spaced by its own bottom margin. */
function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section className="mb-6 break-inside-avoid">
      <SectionTitle flush>{title}</SectionTitle>
      {children}
    </section>
  )
}

interface BarRow {
  id?: number
  name: string
  n: number
  total: number
  color?: string
}

const BARS_SHOWN = 8

/**
 * Horizontal bars of the chosen metric (revenue or payment count), the other one printed small beside it.
 * The longest bar is full width; the percentage is the share of the whole period.
 * Long lists show the top ones and a button for the rest, so sections stay short and balanced.
 */
function Bars({ rows, metric, stats, onClick }: { rows: BarRow[]; metric: Metric; stats: Stats; onClick?: (r: BarRow) => void }) {
  const [all, setAll] = useState(false)
  const base = metric === 'amount' ? stats.sum : stats.count
  const max = Math.max(...rows.map((r) => valueOf(metric, r)), 1)
  const shown = all ? rows : rows.slice(0, BARS_SHOWN)
  return (
    <Card className="space-y-0.5 p-2">
      {shown.map((r, i) => {
        const v = valueOf(metric, r)
        const pct = base ? (v / base) * 100 : 0
        return (
          <button key={`${r.id ?? r.name}-${i}`} onClick={() => onClick?.(r)} disabled={!onClick} className={cx('block w-full rounded-2xl px-3 py-2 text-start', onClick && 'hover:bg-surface-2')}>
            <span className="flex items-center justify-between gap-3">
              <span className="min-w-0 truncate text-[15px] font-semibold">{r.name}</span>
              <span className="flex shrink-0 items-baseline gap-2">
                <span className="num text-[13px] text-muted">{pct.toFixed(0)}%</span>
                {metric === 'amount' ? <Money value={r.total} className="text-[16px] font-bold" /> : <span className="num text-[16px] font-bold">{r.n}</span>}
              </span>
            </span>
            <span className="mt-0.5 block text-[12px] text-muted">
              {metric === 'amount' ? t('{0} دفعة', r.n) : <><span className="num">{money(r.total)}</span> {t('ر.س')}</>}
            </span>
            <span className="mt-1 block h-2 overflow-hidden rounded-full bg-surface-2">
              <span className="block h-full rounded-full" style={{ width: `${v ? Math.max((v / max) * 100, 2) : 0}%`, background: r.color ?? 'var(--primary)' }} />
            </span>
          </button>
        )
      })}
      {rows.length > BARS_SHOWN && (
        <button onClick={() => setAll(!all)} className="block w-full rounded-2xl px-3 py-2.5 text-center text-[14px] font-semibold text-primary hover:bg-surface-2">
          {all ? t('عرض أقل') : t('عرض الكل ({0})', rows.length)}
        </button>
      )}
    </Card>
  )
}

/** Bar chart per period of the chosen metric (the best period is highlighted). */
function PaymentsChart({ periods, grain, metric }: { periods: Period[]; grain: Grain; metric: Metric }) {
  if (periods.length < 2) {
    return (
      <Card>
        <p className="text-[15px] text-muted">
          {periods.length ? (
            <>
              <span className="num font-semibold text-fg">{money(periods[0].total)}</span> {t('ر.س')} · {t('{0} دفعة', periods[0].n)}
            </>
          ) : (
            t('لا توجد بيانات في هذه الفترة')
          )}
        </p>
      </Card>
    )
  }
  const val = (p: Period) => valueOf(metric, p)
  const text = (p: Period) => (metric === 'amount' ? shortMoney(p.total) : String(p.n))
  const max = Math.max(...periods.map(val), 1)
  const best = periods.reduce((a, b) => (val(b) > val(a) ? b : a))
  const labelled = periods.length <= (metric === 'amount' ? 8 : 14) // few bars: print each value above its bar
  const everyLabel = periods.length <= 7
  return (
    <Card>
      <div className="mb-3 flex items-baseline justify-between gap-2 text-[13px] text-muted">
        <span>
          {t('الأعلى:')} <span className="font-semibold text-fg">{periodLabel(grain, best.date)}</span>
        </span>
        <span className="num font-semibold text-fg">
          {metric === 'amount' ? `${money(best.total)} ${t('ر.س')}` : t('{0} دفعة', best.n)}
        </span>
      </div>
      <div className={cx('flex h-40 items-end lg:h-56', labelled ? 'gap-1.5' : 'gap-[3px] lg:gap-1')} dir="ltr">
        {periods.map((p) => (
          <div
            key={p.key}
            className="group flex h-full min-w-0 flex-1 flex-col justify-end"
            title={`${periodLabel(grain, p.date)}: ${money(p.total)} ${t('ر.س')} · ${t('{0} دفعة', p.n)}`}
          >
            {labelled && <span className={cx('num mb-1 text-center text-[11px] font-semibold', val(p) ? 'text-fg' : 'text-muted/60')}>{text(p)}</span>}
            <div
              className={cx('w-full rounded-t-md transition', p === best ? 'bg-primary' : 'bg-primary/55 group-hover:bg-primary/80')}
              style={{ height: val(p) ? `${Math.max((val(p) / max) * (labelled ? 86 : 100), 3)}%` : '2px', background: val(p) ? undefined : 'var(--line)' }}
            />
          </div>
        ))}
      </div>
      <div className={cx('mt-1.5 text-[12px] text-muted', everyLabel ? 'flex gap-1.5' : 'flex justify-between')} dir="ltr">
        {everyLabel ? (
          periods.map((p) => (
            <span key={p.key} className="min-w-0 flex-1 truncate text-center">
              {periodLabel(grain, p.date)}
            </span>
          ))
        ) : (
          <>
            <span>{periodLabel(grain, periods[0].date)}</span>
            <span>{periodLabel(grain, periods[Math.floor(periods.length / 2)].date)}</span>
            <span>{periodLabel(grain, periods[periods.length - 1].date)}</span>
          </>
        )}
      </div>
    </Card>
  )
}

const PERIODS_SHOWN = 7

/** Every period of the chart as a row — revenue and number of payments side by side, newest first. */
function PeriodTable({ periods, grain }: { periods: Period[]; grain: Grain }) {
  const [all, setAll] = useState(false)
  const rows = useMemo(() => [...periods].reverse(), [periods])
  if (rows.length < 2) return null
  const shown = all ? rows : rows.slice(0, PERIODS_SHOWN)
  const total = periods.reduce((a, p) => a + p.total, 0)
  const count = periods.reduce((a, p) => a + p.n, 0)
  return (
    <Card className="mt-3 p-2">
      <div className="flex items-center gap-3 px-3 pb-1.5 pt-1 text-[12px] font-semibold text-muted">
        <span className="min-w-0 flex-1">{GRAIN_LABEL[grain]()}</span>
        <span className="w-12 text-end">{t('الدفعات')}</span>
        <span className="w-28 text-end">{t('الإيراد')}</span>
      </div>
      {shown.map((p) => (
        <div key={p.key} className="flex items-center gap-3 rounded-2xl px-3 py-2 text-[15px] odd:bg-surface-2/50">
          <span className="min-w-0 flex-1 truncate font-medium">{periodLabel(grain, p.date)}</span>
          <span className={cx('num w-12 text-end', !p.n && 'text-muted/60')}>{p.n}</span>
          <Money value={p.total} className={cx('w-28 text-end font-bold', !p.total && 'font-normal text-muted/60')} />
        </div>
      ))}
      {rows.length > PERIODS_SHOWN && (
        <button onClick={() => setAll(!all)} className="block w-full rounded-2xl px-3 py-2.5 text-center text-[14px] font-semibold text-primary hover:bg-surface-2">
          {all ? t('عرض أقل') : t('عرض الكل ({0})', rows.length)}
        </button>
      )}
      <div className="mt-1 flex items-center gap-3 border-t border-line px-3 pb-1 pt-2.5 text-[15px] font-bold">
        <span className="min-w-0 flex-1">{t('المجموع')}</span>
        <span className="num w-12 text-end">{count}</span>
        <Money value={total} className="w-28 text-end" />
      </div>
    </Card>
  )
}

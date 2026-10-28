import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { useNavigate } from '../lib/nav'
import { BarChart3, CalendarDays, Download } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Card, Chip, EmptyState, IconButton, PageLoader, SectionTitle, Segmented, cx } from '../components/ui'
import { KIND_LABELS, RANGE_LABELS, fmtDayMonth, rangeDates, weekdayName, ymd, type RangeKey } from '../lib/format'
import { daysBetween, fillPeriods, periodLabel, type Grain } from '../lib/periods'
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
  day: () => t('المدفوعات اليومية'),
  week: () => t('المدفوعات الأسبوعية'),
  month: () => t('المدفوعات الشهرية'),
  year: () => t('المدفوعات السنوية'),
}

/** The reports are about how many payments were made, not how much they were worth. */
export default function Reports() {
  const { currentStore, storeById } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const [range, setRange] = useState<RangeKey | null>(() => load<RangeKey | null>('reportRange', 'month'))
  const [custom, setCustom] = useState<{ from?: string; to?: string }>({})
  const [grain, setGrain] = useState<Grain>(() => load<Grain>('reportGrain', 'day'))
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
      [1, 2, 3, 4, 5, 6, 7].map((dow) => ({ name: weekdayName(dow), n: stats?.by_weekday.find((r) => r.dow === dow)?.n ?? 0 })),
    [stats],
  )

  const doExport = async () => {
    if (!stats) return
    const { exportReport } = await import('../lib/excel')
    const storeName = storeById(currentStore)?.name ?? t('كل المتاجر')
    const N = t('عدد المدفوعات')
    exportReport(
      [
        { name: t('ملخص'), rows: [{ [t('المتجر')]: storeName, [t('الفترة')]: label, [N]: stats.count, [t('المتوسط اليومي')]: Number(perDay.toFixed(2)), [t('غير مصنّفة')]: stats.unclassified }] },
        { name: t('حسب المتجر'), rows: stats.by_store.map((r) => ({ [t('المتجر')]: r.name, [N]: r.n })) },
        { name: t('حسب الخدمة والمنتج'), rows: stats.by_item.map((r) => ({ [t('الخدمة/المنتج')]: r.name, [t('النوع')]: r.kind ? KIND_LABELS[r.kind] : '', [N]: r.n })) },
        { name: t('حسب التصنيف'), rows: stats.by_category.map((r) => ({ [t('التصنيف')]: r.name, [N]: r.n })) },
        { name: t('حسب أيام الأسبوع'), rows: weekdays.map((r) => ({ [t('اليوم')]: r.name, [N]: r.n })) },
        { name: t('يومي'), rows: stats.daily.map((r) => ({ [t('اليوم')]: r.day, [N]: r.n })) },
        { name: t('أسبوعي'), rows: stats.weekly.map((r) => ({ [t('بداية الأسبوع')]: r.day, [N]: r.n })) },
        { name: t('شهري'), rows: stats.monthly.map((r) => ({ [t('الشهر')]: r.day?.slice(0, 7), [N]: r.n })) },
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
            <div className="grid grid-cols-2 gap-3 lg:grid-cols-4 lg:gap-4">
              <Kpi label={t('عدد المدفوعات')} value={String(stats.count)} big />
              <Kpi label={t('المتوسط اليومي')} value={perDay.toLocaleString(LOCALE, { maximumFractionDigits: 1 })} hint={t('دفعة في اليوم')} />
              <Kpi label={t('أكثر يوم')} value={String(stats.busiest?.n ?? 0)} hint={stats.busiest ? fmtDayMonth(stats.busiest.day) : undefined} />
              <Kpi
                label={t('غير مصنّفة')}
                value={String(stats.unclassified)}
                warn={stats.unclassified > 0}
                onClick={() => navigate(`/invoices?unclassified=1${linkQuery ? '&' + linkQuery : ''}`)}
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
            <PaymentsChart periods={series} grain={activeGrain} />

            {/* Columns, not grid rows: each section takes only the height it needs, so there are no gaps under shorter ones. */}
            <div className="mt-6 lg:columns-2 lg:gap-x-8">
              <Section title={t('المدفوعات حسب أيام الأسبوع')}>
                <Bars rows={weekdays} base={stats.count} />
              </Section>

              {!currentStore && stats.by_store.length > 0 && (
                <Section title={t('حسب المتجر')}>
                  <Bars rows={stats.by_store.map((r) => ({ name: r.name ?? '', n: r.n, color: r.color }))} base={stats.count} />
                </Section>
              )}

              {stats.by_kind.length > 0 && (
                <Section title={t('خدمات مقابل منتجات')}>
                  <Bars
                    rows={stats.by_kind.map((k) => ({ name: k.kind ? KIND_LABELS[k.kind] : '', n: k.n, color: k.kind === 'service' ? 'var(--primary)' : 'var(--success)' }))}
                    base={stats.count}
                  />
                </Section>
              )}

              {stats.by_category.length > 0 && (
                <Section title={t('حسب التصنيف')}>
                  <Bars
                    rows={stats.by_category.map((r) => ({ id: r.id, name: r.name ?? '', n: r.n, color: r.color }))}
                    base={stats.count}
                    onClick={(r) => r.id && navigate(`/invoices?category=${r.id}${linkQuery ? '&' + linkQuery : ''}`)}
                  />
                </Section>
              )}

              {stats.by_item.length > 0 && (
                <Section title={t('حسب الخدمة والمنتج')}>
                  <Bars
                    rows={[...stats.by_item].sort((a, b) => b.n - a.n).map((r) => ({ id: r.id, name: r.name ?? '', n: r.n, color: r.kind === 'service' ? 'var(--primary)' : 'var(--success)' }))}
                    base={stats.count}
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

function Kpi({ label, value, hint, big, warn, onClick }: { label: string; value: string; hint?: string; big?: boolean; warn?: boolean; onClick?: () => void }) {
  return (
    <Card onClick={onClick} className={cx('flex min-h-[92px] flex-col justify-between', warn && 'border-warn/40 bg-warn-soft')}>
      <p className={cx('text-[14px]', warn ? 'text-warn' : 'text-muted')}>{label}</p>
      <p className={cx('num mt-1 font-bold leading-tight', big ? 'text-[28px]' : 'text-[24px]', warn && 'text-warn')}>
        {value}
        {hint && <span className="ms-1.5 text-[13px] font-medium text-muted"> {hint}</span>}
      </p>
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
  color?: string
}

/** Horizontal bars of payment counts. The longest bar is full width; the percentage is the share of all payments. */
const BARS_SHOWN = 8

/** Long lists show the top ones and a button for the rest, so sections stay short and balanced. */
function Bars({ rows, base, onClick }: { rows: BarRow[]; base: number; onClick?: (r: BarRow) => void }) {
  const [all, setAll] = useState(false)
  const max = Math.max(...rows.map((r) => r.n), 1)
  const shown = all ? rows : rows.slice(0, BARS_SHOWN)
  return (
    <Card className="space-y-0.5 p-2">
      {shown.map((r, i) => {
        const pct = base ? (r.n / base) * 100 : 0
        return (
          <button key={`${r.id ?? r.name}-${i}`} onClick={() => onClick?.(r)} disabled={!onClick} className={cx('block w-full rounded-2xl px-3 py-2 text-start', onClick && 'hover:bg-surface-2')}>
            <span className="flex items-center justify-between gap-3">
              <span className="min-w-0 truncate text-[15px] font-semibold">{r.name}</span>
              <span className="flex shrink-0 items-baseline gap-2">
                <span className="num text-[13px] text-muted">{pct.toFixed(0)}%</span>
                <span className="num text-[16px] font-bold">{r.n}</span>
              </span>
            </span>
            <span className="mt-1.5 block h-2 overflow-hidden rounded-full bg-surface-2">
              <span className="block h-full rounded-full" style={{ width: `${r.n ? Math.max((r.n / max) * 100, 2) : 0}%`, background: r.color ?? 'var(--primary)' }} />
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

/** Bar chart of payment counts per period (the busiest period is highlighted). */
function PaymentsChart({ periods, grain }: { periods: { key: string; date: Date; n: number }[]; grain: Grain }) {
  if (periods.length < 2) {
    return (
      <Card>
        <p className="text-[15px] text-muted">{periods.length ? t('{0} دفعة', periods[0].n) : t('لا توجد بيانات في هذه الفترة')}</p>
      </Card>
    )
  }
  const max = Math.max(...periods.map((p) => p.n), 1)
  const best = periods.reduce((a, b) => (b.n > a.n ? b : a))
  const labelled = periods.length <= 14 // few bars: print each count above its bar
  const everyLabel = periods.length <= 7
  return (
    <Card>
      <div className="mb-3 flex items-baseline justify-between text-[13px] text-muted">
        <span>
          {t('الأعلى:')} <span className="font-semibold text-fg">{periodLabel(grain, best.date)}</span>
        </span>
        <span className="num font-semibold text-fg">{t('{0} دفعة', best.n)}</span>
      </div>
      <div className={cx('flex h-40 items-end lg:h-56', labelled ? 'gap-1.5' : 'gap-[3px] lg:gap-1')} dir="ltr">
        {periods.map((p) => (
          <div key={p.key} className="group flex h-full min-w-0 flex-1 flex-col justify-end" title={`${periodLabel(grain, p.date)}: ${p.n}`}>
            {labelled && <span className={cx('num mb-1 text-center text-[11px] font-semibold', p.n ? 'text-fg' : 'text-muted/60')}>{p.n}</span>}
            <div
              className={cx('w-full rounded-t-md transition', p === best ? 'bg-primary' : 'bg-primary/55 group-hover:bg-primary/80')}
              style={{ height: p.n ? `${Math.max((p.n / max) * (labelled ? 86 : 100), 3)}%` : '2px', background: p.n ? undefined : 'var(--line)' }}
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

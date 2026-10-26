import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { BarChart3, CalendarDays, Download } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Card, Chip, EmptyState, IconButton, Money, PageLoader, SectionTitle, cx } from '../components/ui'
import { KIND_LABELS, RANGE_LABELS, compact, fmtDayMonth, rangeDates, ymd, type RangeKey } from '../lib/format'
import { load, save } from '../lib/storage'
import type { Stats, StatRow } from '../types'
import { RangePicker } from './Invoices'

export default function Reports() {
  const { currentStore, storeById } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const [range, setRange] = useState<RangeKey | null>(() => load<RangeKey | null>('reportRange', 'month'))
  const [custom, setCustom] = useState<{ from?: string; to?: string }>({})
  const [stats, setStats] = useState<Stats | null>(null)
  const [picker, setPicker] = useState(false)

  const dates = range ? rangeDates(range) : custom
  useEffect(() => {
    setStats(null)
    api<Stats>('stats', { query: { store: currentStore, ...dates } })
      .then(setStats)
      .catch((e) => toast(errorMessage(e), 'error'))
  }, [currentStore, range, custom.from, custom.to, toast])

  const label = range ? RANGE_LABELS[range] : `${custom.from ?? '…'} ← ${custom.to ?? '…'}`
  const linkQuery = range && range !== 'all' ? `range=${range}` : new URLSearchParams(Object.entries(custom).filter(([, v]) => v) as [string, string][]).toString()

  const doExport = async () => {
    if (!stats) return
    const { exportReport } = await import('../lib/excel')
    const storeName = storeById(currentStore)?.name ?? 'كل المتاجر'
    exportReport(
      [
        { name: 'ملخص', rows: [{ 'المتجر': storeName, 'الفترة': label, 'عدد الفواتير': stats.count, 'المجموع': stats.sum, 'غير مصنّفة': stats.unclassified, 'مبلغ غير المصنّفة': stats.unclassified_sum }] },
        { name: 'حسب المتجر', rows: stats.by_store.map((r) => ({ 'المتجر': r.name, 'عدد الفواتير': r.n, 'المجموع': r.total })) },
        { name: 'حسب الخدمة والمنتج', rows: stats.by_item.map((r) => ({ 'الخدمة/المنتج': r.name, 'النوع': r.kind ? KIND_LABELS[r.kind] : '', 'عدد الفواتير': r.n, 'المجموع': r.total })) },
        { name: 'حسب التصنيف', rows: stats.by_category.map((r) => ({ 'التصنيف': r.name, 'عدد الفواتير': r.n, 'المجموع': r.total })) },
        { name: 'يومي', rows: stats.daily.map((r) => ({ 'اليوم': r.day, 'عدد الفواتير': r.n, 'المجموع': r.total })) },
      ],
      `تقرير-${storeName}-${ymd(new Date())}.xlsx`,
    )
  }

  return (
    <>
      <TopBar
        title="التقارير"
        switcher
        actions={
          <IconButton label="تصدير التقرير" onClick={doExport} disabled={!stats}>
            <Download className="size-6" />
          </IconButton>
        }
      />
      <Page>
        <div className="no-scrollbar -mx-4 mb-4 flex gap-2 overflow-x-auto px-4">
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
            <CalendarDays className="size-4" /> {range && ['month', 'last_month', 'year', 'all'].includes(range) ? 'فترة أخرى' : label}
          </Chip>
        </div>

        {!stats && <PageLoader />}
        {stats && stats.count === 0 && <EmptyState icon={<BarChart3 className="size-8" />} title="لا توجد بيانات في هذه الفترة" />}
        {stats && stats.count > 0 && (
          <>
            <div className="grid grid-cols-2 gap-3">
              <Card>
                <p className="text-[14px] text-muted">المجموع</p>
                <Money value={stats.sum} className="mt-1 block text-[22px] font-bold" />
              </Card>
              <Card>
                <p className="text-[14px] text-muted">عدد الفواتير</p>
                <p className="num mt-1 text-[22px] font-bold">{stats.count}</p>
              </Card>
              <Card>
                <p className="text-[14px] text-muted">متوسط الفاتورة</p>
                <Money value={stats.sum / stats.count} className="mt-1 block text-[20px] font-bold" />
              </Card>
              <Card onClick={() => navigate(`/invoices?unclassified=1${linkQuery ? '&' + linkQuery : ''}`)} className={cx(stats.unclassified > 0 && 'border-warn/40 bg-warn-soft')}>
                <p className={cx('text-[14px]', stats.unclassified ? 'text-warn' : 'text-muted')}>غير مصنّفة</p>
                <p className={cx('num mt-1 text-[22px] font-bold', stats.unclassified > 0 && 'text-warn')}>{stats.unclassified}</p>
              </Card>
            </div>

            <DailyChart rows={stats.daily} />

            {!currentStore && stats.by_store.length > 0 && (
              <>
                <SectionTitle>حسب المتجر</SectionTitle>
                <Bars rows={stats.by_store} total={stats.sum} />
              </>
            )}

            {stats.by_kind.length > 0 && (
              <>
                <SectionTitle>خدمات مقابل منتجات</SectionTitle>
                <Bars
                  rows={stats.by_kind.map((k) => ({ ...k, name: k.kind ? KIND_LABELS[k.kind] : '', color: k.kind === 'service' ? 'var(--primary)' : 'var(--success)' }))}
                  total={stats.by_kind.reduce((a, k) => a + k.total, 0)}
                />
              </>
            )}

            {stats.by_category.length > 0 && (
              <>
                <SectionTitle>حسب التصنيف</SectionTitle>
                <Bars rows={stats.by_category} total={stats.by_category.reduce((a, k) => a + k.total, 0)} onClick={(r) => r.id && navigate(`/invoices?category=${r.id}${linkQuery ? '&' + linkQuery : ''}`)} />
              </>
            )}

            {stats.by_item.length > 0 && (
              <>
                <SectionTitle>حسب الخدمة والمنتج</SectionTitle>
                <Bars
                  rows={stats.by_item.map((r) => ({ ...r, color: r.kind === 'service' ? 'var(--primary)' : 'var(--success)' }))}
                  total={stats.by_item.reduce((a, k) => a + k.total, 0)}
                  onClick={(r) => navigate(`/invoices?item=${r.id}${linkQuery ? '&' + linkQuery : ''}`)}
                />
              </>
            )}
            {stats.unclassified > 0 && (
              <p className="mt-3 px-1 text-[13px] text-muted">
                التقارير حسب الخدمة والتصنيف لا تشمل <span className="num">{stats.unclassified}</span> فاتورة غير مصنّفة (<Money value={stats.unclassified_sum} />).
              </p>
            )}
          </>
        )}
      </Page>
      <Sheet open={picker} onClose={() => setPicker(false)} title="الفترة">
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

function Bars({ rows, total, onClick }: { rows: StatRow[]; total: number; onClick?: (r: StatRow) => void }) {
  return (
    <Card className="space-y-1 p-2">
      {rows.map((r, i) => {
        const pct = total ? (r.total / total) * 100 : 0
        return (
          <button key={`${r.id ?? r.name}-${i}`} onClick={() => onClick?.(r)} className="block w-full rounded-2xl px-3 py-2.5 text-start hover:bg-surface-2">
            <span className="flex items-center justify-between gap-3">
              <span className="min-w-0 truncate text-[15px] font-semibold">{r.name}</span>
              <span className="flex shrink-0 items-baseline gap-2">
                <span className="num text-[13px] text-muted">{pct.toFixed(0)}%</span>
                <Money value={r.total} className="text-[15px] font-bold" />
              </span>
            </span>
            <span className="mt-1.5 block h-2 overflow-hidden rounded-full bg-surface-2">
              <span className="block h-full rounded-full" style={{ width: `${Math.max(pct, 1.5)}%`, background: r.color ?? 'var(--primary)' }} />
            </span>
            <span className="mt-1 block text-[12px] text-muted">
              <span className="num">{r.n}</span> فاتورة
            </span>
          </button>
        )
      })}
    </Card>
  )
}

/** Simple bar chart of daily totals (latest 30 days in the range). */
function DailyChart({ rows }: { rows: StatRow[] }) {
  const data = rows.slice(-30)
  if (data.length < 2) return null
  const max = Math.max(...data.map((d) => d.total), 1)
  const best = data.reduce((a, b) => (b.total > a.total ? b : a))
  return (
    <>
      <SectionTitle>المبيعات اليومية</SectionTitle>
      <Card>
        <div className="mb-2 flex items-baseline justify-between text-[13px] text-muted">
          <span>
            أعلى يوم: <span className="font-semibold text-fg">{fmtDayMonth(best.day)}</span>
          </span>
          <span className="num font-semibold text-fg">{compact(best.total)} ر.س</span>
        </div>
        <div className="flex h-36 items-end gap-[3px]" dir="ltr">
          {data.map((d) => (
            <div key={d.day} className="group relative flex h-full flex-1 items-end" title={`${d.day}: ${d.total}`}>
              <div className="w-full rounded-t-md bg-primary/80 transition group-hover:bg-primary" style={{ height: `${Math.max((d.total / max) * 100, 2)}%` }} />
            </div>
          ))}
        </div>
        <div className="mt-1.5 flex justify-between text-[12px] text-muted" dir="ltr">
          <span>{fmtDayMonth(data[0].day)}</span>
          <span>{fmtDayMonth(data[data.length - 1].day)}</span>
        </div>
      </Card>
    </>
  )
}

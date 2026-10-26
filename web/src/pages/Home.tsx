import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { AlertCircle, ChevronLeft, FileSpreadsheet, Plus } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { InvoiceCard, InvoiceSheet } from '../components/InvoiceViews'
import { Page, TopBar } from '../components/Layout'
import { StoreInfoCard, hasInfo } from '../components/StoreInfo'
import { Button, Card, Chip, EmptyState, Money, PageLoader, SectionTitle, StoreDot } from '../components/ui'
import { RANGE_LABELS, money, rangeDates, type RangeKey } from '../lib/format'
import { load, save } from '../lib/storage'
import type { Invoice, InvoiceList, Stats } from '../types'

const HOME_RANGES: RangeKey[] = ['month', 'last_month', 'year', 'all']

export default function Home() {
  const { currentStore, setCurrentStore, can, storeById } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const [range, setRange] = useState<RangeKey>(() => load<RangeKey>('homeRange', 'month'))
  const [stats, setStats] = useState<Stats | null>(null)
  const [recent, setRecent] = useState<Invoice[]>([])
  const [open, setOpen] = useState<Invoice | null>(null)

  useEffect(() => {
    setStats(null)
    const q = { store: currentStore, ...rangeDates(range) }
    Promise.all([
      api<Stats>('stats', { query: q }),
      api<InvoiceList>('invoices', { query: { store: currentStore, per_page: 5, sort: 'added_desc' } }),
    ])
      .then(([s, r]) => {
        setStats(s)
        setRecent(r.invoices)
      })
      .catch((e) => toast(errorMessage(e), 'error'))
  }, [currentStore, range, toast])

  const rangeQuery = () => (range === 'all' ? '' : `&range=${range}`)

  return (
    <>
      <TopBar title="الرئيسية" switcher />
      <Page>
        <div className="no-scrollbar -mx-4 mb-4 flex gap-2 overflow-x-auto px-4">
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

        {!stats && <PageLoader />}
        {stats && (
          <>
            <div className="lg:grid lg:grid-cols-3 lg:gap-4">
            <div className={`rounded-[28px] bg-primary p-5 text-primary-fg shadow-lg shadow-primary/25 lg:p-7 ${stats.unclassified > 0 ? 'lg:col-span-2' : 'lg:col-span-3'}`}>
              <p className="text-[15px] opacity-85">إجمالي المبيعات · {RANGE_LABELS[range]}</p>
              <p className="mt-1 text-[34px] font-bold leading-tight lg:text-[44px]">
                <span className="num">{money(stats.sum)}</span>
                <span className="ms-1.5 text-[18px] font-medium opacity-80">ر.س</span>
              </p>
              <p className="mt-1 text-[15px] opacity-85">
                <span className="num">{stats.count}</span> فاتورة
              </p>
            </div>

            {stats.unclassified > 0 && (
              <button
                onClick={() => navigate(`/invoices?unclassified=1${rangeQuery()}`)}
                className="mt-3 flex w-full items-center gap-3 rounded-3xl border border-warn/30 bg-warn-soft p-4 text-start transition hover:brightness-95 active:scale-[0.99] lg:mt-0 lg:flex-col lg:items-start lg:justify-center lg:gap-4 lg:p-6"
              >
                <span className="flex size-11 shrink-0 items-center justify-center rounded-2xl bg-warn text-white">
                  <AlertCircle className="size-6" />
                </span>
                <span className="flex-1">
                  <span className="block text-[17px] font-bold text-warn">
                    <span className="num">{stats.unclassified}</span> فاتورة غير مصنّفة
                  </span>
                  <span className="text-[14px] text-warn/80">حدد الخدمة أو المنتج لكل فاتورة</span>
                </span>
                <ChevronLeft className="size-6 text-warn lg:hidden" />
              </button>
            )}
            </div>

            {(() => {
              const st = storeById(currentStore)
              return st && hasInfo(st.info) ? <StoreInfoCard store={st} /> : null
            })()}

            {stats.count === 0 && (
              <EmptyState
                icon={<FileSpreadsheet className="size-8" />}
                title="لا توجد فواتير في هذه الفترة"
                text="ابدأ باستيراد ملفات Excel من بوابة الدفع أو أضف فاتورة يدوياً"
                action={
                  can('editor') && (
                    <Button icon={<Plus className="size-5" />} onClick={() => navigate('/add')}>
                      إضافة فواتير
                    </Button>
                  )
                }
              />
            )}

            {!currentStore && stats.by_store.length > 0 && (
              <>
                <SectionTitle>المتاجر</SectionTitle>
                <div className="grid grid-cols-2 gap-3 lg:grid-cols-[repeat(auto-fit,minmax(220px,1fr))] lg:gap-4">
                  {stats.by_store.map((s) => (
                    <Card key={s.id} className="p-4" onClick={() => (setCurrentStore(s.id!), navigate(`/invoices?${rangeQuery().slice(1)}`))}>
                      <span className="flex items-center gap-2 text-[15px] font-semibold">
                        <StoreDot color={s.color!} className="size-3" storeId={s.id} />
                        <span className="truncate">{s.name}</span>
                      </span>
                      <Money value={s.total} className="mt-2 block text-[19px] font-bold" />
                      <span className="text-[13px] text-muted">
                        <span className="num">{s.n}</span> فاتورة
                      </span>
                    </Card>
                  ))}
                </div>
              </>
            )}

            <div className="lg:grid lg:grid-cols-2 lg:items-start lg:gap-8">
            {stats.by_item.length > 0 && (
              <div>
                <SectionTitle
                  action={
                    <button className="text-[14px] font-semibold text-primary" onClick={() => navigate('/reports')}>
                      التقارير
                    </button>
                  }
                >
                  الأكثر مبيعاً
                </SectionTitle>
                <Card className="p-2">
                  {stats.by_item.slice(0, 5).map((it) => (
                    <button
                      key={it.id}
                      onClick={() => navigate(`/invoices?item=${it.id}${rangeQuery()}`)}
                      className="flex w-full items-center gap-3 rounded-2xl px-3 py-3 text-start hover:bg-surface-2"
                    >
                      <span className="min-w-0 flex-1">
                        <span className="block truncate text-[16px] font-semibold">{it.name}</span>
                        <span className="text-[13px] text-muted">
                          <span className="num">{it.n}</span> فاتورة
                        </span>
                      </span>
                      <Money value={it.total} className="text-[16px] font-bold" />
                    </button>
                  ))}
                </Card>
              </div>
            )}

            {recent.length > 0 && (
              <div>
                <SectionTitle
                  action={
                    <button className="text-[14px] font-semibold text-primary" onClick={() => navigate('/invoices?sort=added_desc')}>
                      عرض الكل
                    </button>
                  }
                >
                  آخر ما أُضيف
                </SectionTitle>
                <div className="space-y-2.5">
                  {recent.map((inv) => (
                    <InvoiceCard key={inv.id} invoice={inv} showStore={!currentStore} onOpen={() => setOpen(inv)} />
                  ))}
                </div>
              </div>
            )}
            </div>
          </>
        )}
      </Page>
      <InvoiceSheet
        invoice={open}
        onClose={() => setOpen(null)}
        onChanged={(inv) => {
          setRecent((r) => r.map((x) => (x.id === inv.id ? inv : x)))
          setOpen(inv)
        }}
        onDeleted={(id) => setRecent((r) => r.filter((x) => x.id !== id))}
      />
    </>
  )
}

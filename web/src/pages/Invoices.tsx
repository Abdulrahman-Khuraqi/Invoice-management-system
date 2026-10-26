import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useSearchParams } from 'react-router-dom'
import { ArrowLeftRight, CalendarDays, CheckSquare, Download, FileText, SlidersHorizontal, Tag, Trash2, X, Search } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { InvoiceCard, InvoiceSheet, InvoiceTable } from '../components/InvoiceViews'
import { ItemPicker } from '../components/ItemPicker'
import { Page, TopBar, useIsDesktop } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Button, Chip, EmptyState, Field, IconButton, Input, Money, PageLoader, Segmented, Select, Spinner, StoreDot, cx } from '../components/ui'
import { PAY_METHODS, RANGE_LABELS, rangeDates, ymd, type RangeKey } from '../lib/format'
import type { Invoice, InvoiceList } from '../types'

const PER_PAGE = 30
const FILTER_KEYS = ['unclassified', 'item', 'kind', 'category', 'range', 'from', 'to', 'pay_method', 'source', 'min', 'max', 'sort'] as const

export default function Invoices() {
  const { currentStore, items, categories, can, activeStores, storeById } = useApp()
  const { toast, confirm } = useFeedback()
  const [params, setParams] = useSearchParams()
  const [q, setQ] = useState(params.get('q') ?? '')
  const [debouncedQ, setDebouncedQ] = useState(q)
  const [data, setData] = useState<InvoiceList | null>(null)
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [open, setOpen] = useState<Invoice | null>(null)
  const [selected, setSelected] = useState<Set<number>>(new Set())
  const [selectMode, setSelectMode] = useState(false)
  const [sheet, setSheet] = useState<null | 'range' | 'filters' | 'item' | 'bulkItem' | 'bulkMove'>(null)
  const [exporting, setExporting] = useState(false)
  const desktop = useIsDesktop()
  const reqId = useRef(0)
  const sentinel = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const t = window.setTimeout(() => setDebouncedQ(q.trim()), 300)
    return () => window.clearTimeout(t)
  }, [q])

  const range = (params.get('range') as RangeKey | null) ?? null
  const query = useMemo(() => {
    const dates = range && range !== 'all' ? rangeDates(range) : { from: params.get('from') ?? undefined, to: params.get('to') ?? undefined }
    return {
      q: debouncedQ,
      store: currentStore,
      unclassified: params.get('unclassified') === '1',
      item: params.get('item'),
      kind: params.get('kind'),
      category: params.get('category'),
      pay_method: params.get('pay_method'),
      source: params.get('source'),
      min: params.get('min'),
      max: params.get('max'),
      sort: params.get('sort'),
      ...dates,
    }
  }, [debouncedQ, currentStore, params, range])

  const fetchPage = useCallback(
    async (page: number) => {
      const id = ++reqId.current
      const r = await api<InvoiceList>('invoices', { query: { ...query, page, per_page: PER_PAGE } })
      return id === reqId.current ? r : null
    },
    [query],
  )

  useEffect(() => {
    setLoading(true)
    setSelected(new Set())
    fetchPage(1)
      .then((r) => r && setData(r))
      .catch((e) => toast(errorMessage(e), 'error'))
      .finally(() => setLoading(false))
  }, [fetchPage, toast])

  const hasMore = !!data && data.invoices.length < data.total
  const loadMore = useCallback(async () => {
    if (!data || loadingMore || !hasMore) return
    setLoadingMore(true)
    try {
      const r = await fetchPage(data.page + 1)
      if (r) setData((d) => d && { ...r, invoices: [...d.invoices, ...r.invoices] })
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setLoadingMore(false)
    }
  }, [data, loadingMore, hasMore, fetchPage, toast])

  useEffect(() => {
    const el = sentinel.current
    if (!el) return
    const io = new IntersectionObserver((entries) => entries[0].isIntersecting && loadMore(), { rootMargin: '400px' })
    io.observe(el)
    return () => io.disconnect()
  }, [loadMore])

  const setParam = (updates: Record<string, string | null>) => {
    const next = new URLSearchParams(params)
    for (const [k, v] of Object.entries(updates)) {
      if (v === null || v === '') next.delete(k)
      else next.set(k, v)
    }
    setParams(next, { replace: true })
  }

  const replaceInvoice = (inv: Invoice) => {
    setData((d) => d && { ...d, invoices: d.invoices.map((x) => (x.id === inv.id ? inv : x)) })
    setOpen(inv)
  }
  const reload = () => {
    setSelected(new Set())
    setSelectMode(false)
    fetchPage(1).then((r) => r && setData(r))
  }

  const toggle = (id: number) => {
    setSelectMode(true)
    setSelected((s) => {
      const n = new Set(s)
      if (n.has(id)) n.delete(id)
      else n.add(id)
      return n
    })
  }

  const bulk = async (body: Record<string, unknown>, msg: string) => {
    try {
      const r = await api<{ affected: number }>('invoices/bulk', { method: 'POST', body: { ids: [...selected], ...body } })
      toast(`${msg} (${r.affected})`)
      reload()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  const bulkDelete = async () => {
    const ok = await confirm({ title: `حذف ${selected.size} فاتورة؟`, text: 'لا يمكن التراجع عن الحذف.', confirmLabel: 'حذف', danger: true })
    if (ok) bulk({ action: 'delete' }, 'تم الحذف')
  }

  const doExport = async () => {
    if (!data?.total) return
    setExporting(true)
    try {
      const all: Invoice[] = []
      for (let page = 1; all.length < data.total; page++) {
        const r = await api<InvoiceList>('invoices', { query: { ...query, page, per_page: 1000 } })
        all.push(...r.invoices)
        if (!r.invoices.length) break
      }
      const storeName = storeById(currentStore)?.name
      const { exportInvoices } = await import('../lib/excel')
      exportInvoices(all, `فواتير${storeName ? '-' + storeName : ''}-${ymd(new Date())}.xlsx`)
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setExporting(false)
    }
  }

  const itemFilter = items.find((i) => String(i.id) === params.get('item'))
  const extraFilters = ['kind', 'category', 'pay_method', 'source', 'min', 'max', 'sort'].filter((k) => params.get(k)).length
  const rangeLabel = range ? RANGE_LABELS[range] : params.get('from') || params.get('to') ? `${params.get('from') ?? '…'} ← ${params.get('to') ?? '…'}` : 'الفترة'
  const anyFilter = FILTER_KEYS.some((k) => params.get(k)) || !!debouncedQ
  const selectedInvoices = data?.invoices.filter((i) => selected.has(i.id)) ?? []
  const commonStore = selectedInvoices.length && selectedInvoices.every((i) => i.store_id === selectedInvoices[0].store_id) ? selectedInvoices[0].store_id : null

  return (
    <>
      <TopBar
        title="الفواتير"
        switcher
        actions={
          <IconButton label="تصدير Excel" onClick={doExport} disabled={exporting || !data?.total}>
            {exporting ? <Spinner className="size-5" /> : <Download className="size-6" />}
          </IconButton>
        }
      />
      <Page>
        <div className="sticky top-[calc(64px+env(safe-area-inset-top))] z-20 -mx-4 bg-bg/90 px-4 pb-2 backdrop-blur-md lg:top-[72px] lg:-mx-8 lg:flex lg:items-center lg:gap-3 lg:px-8 lg:pb-3 lg:pt-1">
          <div className="relative lg:w-96 lg:shrink-0">
            <Search className="pointer-events-none absolute start-4 top-1/2 size-5 -translate-y-1/2 text-muted" />
            <Input
              type="search"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="ابحث بالاسم، الجوال، رقم الفاتورة، الخدمة…"
              className="ps-12 pe-11 lg:h-11"
              enterKeyHint="search"
            />
            {q && (
              <button aria-label="مسح البحث" onClick={() => setQ('')} className="absolute end-2 top-1/2 flex size-9 -translate-y-1/2 items-center justify-center rounded-full text-muted">
                <X className="size-5" />
              </button>
            )}
          </div>
          <div className="no-scrollbar -mx-4 mt-2.5 flex gap-2 overflow-x-auto px-4 pb-1 lg:m-0 lg:flex-wrap lg:overflow-visible lg:p-0">
            <Chip active={params.get('unclassified') === '1'} onClick={() => setParam({ unclassified: params.get('unclassified') === '1' ? null : '1' })}>
              غير مصنّفة
            </Chip>
            <Chip active={!!range || !!params.get('from') || !!params.get('to')} onClick={() => setSheet('range')}>
              <CalendarDays className="size-4" /> {rangeLabel}
            </Chip>
            <Chip active={!!itemFilter} onClick={() => (itemFilter ? setParam({ item: null }) : setSheet('item'))}>
              <Tag className="size-4" /> {itemFilter ? itemFilter.name : 'الخدمة/المنتج'}
              {itemFilter && <X className="size-4" />}
            </Chip>
            <Chip active={extraFilters > 0} onClick={() => setSheet('filters')}>
              <SlidersHorizontal className="size-4" /> فلاتر{extraFilters ? ` (${extraFilters})` : ''}
            </Chip>
            {can('editor') && (
              <Chip active={selectMode} onClick={() => (selectMode ? (setSelectMode(false), setSelected(new Set())) : setSelectMode(true))}>
                <CheckSquare className="size-4" /> تحديد
              </Chip>
            )}
          </div>
        </div>

        {data && !loading && (
          <div className="mb-3 mt-1 flex items-center justify-between px-1 text-[15px]">
            <span className="text-muted">
              <span className="num font-semibold text-fg">{data.total}</span> فاتورة
            </span>
            <span className="text-muted">
              المجموع <Money value={data.sum} className="font-bold text-fg" />
            </span>
          </div>
        )}

        {loading && <PageLoader />}
        {!loading && data && !data.invoices.length && (
          <EmptyState
            icon={<FileText className="size-8" />}
            title={anyFilter ? 'لا توجد نتائج' : 'لا توجد فواتير بعد'}
            text={anyFilter ? 'جرّب تغيير البحث أو الفلاتر' : 'أضف فاتورة أو استورد ملف Excel من صفحة «إضافة»'}
            action={
              anyFilter && (
                <Button variant="secondary" onClick={() => (setQ(''), setParams(new URLSearchParams(), { replace: true }))}>
                  مسح الفلاتر
                </Button>
              )
            }
          />
        )}
        {!loading && desktop && !!data?.invoices.length && (
          <InvoiceTable
            invoices={data.invoices}
            showStore={!currentStore}
            onOpen={setOpen}
            selectMode={selectMode}
            selected={selected}
            onToggle={can('editor') ? toggle : undefined}
            onToggleAll={() => setSelected((s) => (s.size === data.invoices.length ? new Set() : new Set(data.invoices.map((i) => i.id))))}
          />
        )}
        {!loading && !desktop && (
          <div className="space-y-2.5">
            {data?.invoices.map((inv) => (
              <InvoiceCard
                key={inv.id}
                invoice={inv}
                showStore={!currentStore}
                onOpen={() => setOpen(inv)}
                selectMode={selectMode}
                selected={selected.has(inv.id)}
                onToggle={can('editor') ? () => toggle(inv.id) : undefined}
              />
            ))}
          </div>
        )}
        <div ref={sentinel} className="h-10" />
        {loadingMore && <PageLoader />}
      </Page>

      {/* Bulk actions bar */}
      {selectMode && (
        <div className="fixed inset-x-0 bottom-[calc(100px+env(safe-area-inset-bottom))] z-40 px-3 lg:bottom-6 lg:ps-64">
          <div className="mx-auto flex max-w-2xl items-center gap-1 rounded-3xl border border-line bg-surface p-2 shadow-2xl">
            <button
              className="flex h-12 min-w-0 flex-1 items-center gap-2 rounded-2xl px-3 text-[15px] font-semibold"
              onClick={() => setSelected((s) => (s.size === data?.invoices.length ? new Set() : new Set(data?.invoices.map((i) => i.id))))}
            >
              <span className="num text-primary">{selected.size}</span> محددة
              <span className="text-[13px] font-normal text-muted">{selected.size === data?.invoices.length ? 'إلغاء الكل' : 'تحديد الكل'}</span>
            </button>
            <BulkBtn label="تصنيف" disabled={!selected.size} onClick={() => setSheet('bulkItem')}>
              <Tag className="size-5" />
            </BulkBtn>
            <BulkBtn label="نقل" disabled={!selected.size} onClick={() => setSheet('bulkMove')}>
              <ArrowLeftRight className="size-5" />
            </BulkBtn>
            <BulkBtn label="حذف" danger disabled={!selected.size} onClick={bulkDelete}>
              <Trash2 className="size-5" />
            </BulkBtn>
            <BulkBtn label="إغلاق" onClick={() => (setSelectMode(false), setSelected(new Set()))}>
              <X className="size-5" />
            </BulkBtn>
          </div>
        </div>
      )}

      <InvoiceSheet
        invoice={open}
        onClose={() => setOpen(null)}
        onChanged={replaceInvoice}
        onDeleted={(id) => setData((d) => d && { ...d, total: d.total - 1, invoices: d.invoices.filter((x) => x.id !== id) })}
      />

      <ItemPicker open={sheet === 'item'} onClose={() => setSheet(null)} storeId={currentStore} title="فلترة حسب الخدمة/المنتج" onPick={(i) => setParam({ item: String(i.id) })} />
      <ItemPicker
        open={sheet === 'bulkItem'}
        onClose={() => setSheet(null)}
        storeId={commonStore}
        title={`تحديد الخدمة/المنتج لـ ${selected.size} فاتورة`}
        onPick={(i) => bulk({ action: 'assign_item', item_id: i.id }, `تم تحديد «${i.name}»`)}
      />

      <Sheet open={sheet === 'bulkMove'} onClose={() => setSheet(null)} title={`نقل ${selected.size} فاتورة إلى متجر`}>
        <div className="space-y-1.5">
          {activeStores.map((s) => (
            <button
              key={s.id}
              onClick={() => {
                setSheet(null)
                bulk({ action: 'move_store', store_id: s.id }, `تم النقل إلى ${s.name}`)
              }}
              className="flex h-14 w-full items-center gap-3 rounded-2xl px-4 text-[17px] font-medium hover:bg-surface-2"
            >
              <StoreDot color={s.color} className="size-3.5" /> {s.name}
            </button>
          ))}
        </div>
      </Sheet>

      <Sheet open={sheet === 'range'} onClose={() => setSheet(null)} title="الفترة">
        <RangePicker
          range={range}
          from={params.get('from') ?? ''}
          to={params.get('to') ?? ''}
          onChange={(u) => {
            setParam(u)
            setSheet(null)
          }}
        />
      </Sheet>

      <Sheet open={sheet === 'filters'} onClose={() => setSheet(null)} title="فلاتر إضافية">
        <div className="space-y-4">
          <Field label="النوع">
            <Segmented
              value={params.get('kind') ?? ''}
              onChange={(v) => setParam({ kind: v || null })}
              options={[
                { value: '', label: 'الكل' },
                { value: 'service', label: 'خدمات' },
                { value: 'product', label: 'منتجات' },
              ]}
            />
          </Field>
          <Field label="التصنيف">
            <Select value={params.get('category') ?? ''} onChange={(e) => setParam({ category: e.target.value || null })}>
              <option value="">الكل</option>
              {categories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </Select>
          </Field>
          <Field label="طريقة الدفع">
            <Select value={params.get('pay_method') ?? ''} onChange={(e) => setParam({ pay_method: e.target.value || null })}>
              <option value="">الكل</option>
              {Object.entries(PAY_METHODS).map(([v, l]) => (
                <option key={v} value={v}>
                  {l}
                </option>
              ))}
            </Select>
          </Field>
          <div className="grid grid-cols-2 gap-3">
            <Field label="من مبلغ">
              <Input inputMode="decimal" defaultValue={params.get('min') ?? ''} onBlur={(e) => setParam({ min: e.target.value || null })} className="num text-end" />
            </Field>
            <Field label="إلى مبلغ">
              <Input inputMode="decimal" defaultValue={params.get('max') ?? ''} onBlur={(e) => setParam({ max: e.target.value || null })} className="num text-end" />
            </Field>
          </div>
          <Field label="المصدر">
            <Segmented
              value={params.get('source') ?? ''}
              onChange={(v) => setParam({ source: v || null })}
              options={[
                { value: '', label: 'الكل' },
                { value: 'import', label: 'استيراد' },
                { value: 'manual', label: 'يدوي' },
              ]}
            />
          </Field>
          <Field label="الترتيب">
            <Select value={params.get('sort') ?? ''} onChange={(e) => setParam({ sort: e.target.value || null })}>
              <option value="">الأحدث أولاً</option>
              <option value="paid_asc">الأقدم أولاً</option>
              <option value="amount_desc">الأعلى مبلغاً</option>
              <option value="amount_asc">الأقل مبلغاً</option>
              <option value="added_desc">آخر ما أُضيف</option>
            </Select>
          </Field>
          <div className="flex gap-3 pt-1">
            <Button block onClick={() => setSheet(null)}>
              عرض النتائج
            </Button>
            <Button block variant="secondary" onClick={() => setParam({ kind: null, category: null, pay_method: null, source: null, min: null, max: null, sort: null })}>
              مسح
            </Button>
          </div>
        </div>
      </Sheet>
    </>
  )
}

function BulkBtn({ label, onClick, children, danger, disabled }: { label: string; onClick: () => void; children: ReactNode; danger?: boolean; disabled?: boolean }) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={cx('flex h-12 w-14 flex-col items-center justify-center rounded-2xl text-[11px] font-semibold disabled:opacity-40', danger ? 'text-danger' : 'text-fg', 'hover:bg-surface-2')}
    >
      {children}
      {label}
    </button>
  )
}

export function RangePicker({
  range,
  from,
  to,
  onChange,
}: {
  range: RangeKey | null
  from: string
  to: string
  onChange: (u: Record<string, string | null>) => void
}) {
  const [f, setF] = useState(from)
  const [t, setT] = useState(to)
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 gap-2">
        {(Object.keys(RANGE_LABELS) as RangeKey[]).map((k) => (
          <Chip
            key={k}
            active={range === k || (k === 'all' && !range && !from && !to)}
            className="h-12 justify-center"
            onClick={() => onChange({ range: k === 'all' ? null : k, from: null, to: null })}
          >
            {RANGE_LABELS[k]}
          </Chip>
        ))}
      </div>
      <p className="pt-2 text-[15px] font-semibold">فترة مخصصة</p>
      <div className="grid grid-cols-2 gap-3">
        <Field label="من">
          <Input type="date" value={f} onChange={(e) => setF(e.target.value)} className="num px-3" />
        </Field>
        <Field label="إلى">
          <Input type="date" value={t} onChange={(e) => setT(e.target.value)} className="num px-3" />
        </Field>
      </div>
      <Button block disabled={!f && !t} onClick={() => onChange({ range: null, from: f || null, to: t || null })}>
        تطبيق
      </Button>
    </div>
  )
}

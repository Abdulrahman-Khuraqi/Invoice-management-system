import { useMemo, useRef, useState } from 'react'
import { useNavigate } from '../lib/nav'
import { AlertTriangle, CheckCircle2, FileSpreadsheet, FileDown, Pencil, Plus, Upload, X } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { InvoiceForm } from '../components/InvoiceForm'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { LogoPicker } from '../components/StoreLogo'
import { Badge, Button, Card, ColorPicker, Field, Input, Money, Segmented, Select, StoreDot, Switch, cx } from '../components/ui'
import type { ParsedFile, ParsedRow } from '../lib/excel'
import { missingFields, planUpdate, type RowUpdate } from '../lib/importDiff'
import type { Invoice } from '../types'
import { PALETTE } from '../lib/format'
import type { LogoImage } from '../lib/image'
import { load, save } from '../lib/storage'
import { ARROW, t, tServer } from '../lib/i18n'

type Tab = 'manual' | 'import'

export default function Add() {
  const [tab, setTab] = useState<Tab>(() => load<Tab>('addTab', 'manual'))
  const [formKey, setFormKey] = useState(0)
  const navigate = useNavigate()
  const choose = (t: Tab) => {
    setTab(t)
    save('addTab', t)
  }
  return (
    <>
      <TopBar title={t('إضافة فواتير')} />
      <Page width="medium">
        <Segmented
          className="lg:max-w-md"
          value={tab}
          onChange={choose}
          options={[
            { value: 'manual', label: <><Plus className="size-5" />  {t('إدخال يدوي')}</> },
            { value: 'import', label: <><FileSpreadsheet className="size-5" />  {t('استيراد Excel')}</> },
          ]}
        />
        <div className="mt-5">
          {tab === 'manual' ? (
            <Card>
              <InvoiceForm
                key={formKey}
                onSaved={(inv) => {
                  setFormKey((k) => k + 1)
                  window.scrollTo({ top: 0, behavior: 'smooth' })
                  if (!inv.lines.length) navigate('/invoices?unclassified=1')
                }}
              />
            </Card>
          ) : (
            <ImportPanel />
          )}
        </div>
      </Page>
    </>
  )
}

interface ResolvedRow extends ParsedRow {
  store_id: number | null
  item_id: number | null
  file: string
  /** Only app-made files (export/template) can update existing invoices; gateway files just skip duplicates. */
  format: ParsedFile['format']
  columns: string[]
}

const BATCH = 200
const norm = (s: string) => s.trim().toLowerCase()

function ImportPanel() {
  const { stores, activeStores, items, currentStore, reloadStores, reloadCatalog, can, user } = useApp()
  const { toast } = useFeedback()
  const navigate = useNavigate()
  const inputRef = useRef<HTMLInputElement>(null)
  const [files, setFiles] = useState<ParsedFile[]>([])
  const [parsing, setParsing] = useState(false)
  /** User's choice of store for an unknown terminal id ("t:<id>") or unknown store name ("n:<name>"). */
  const [mapping, setMapping] = useState<Record<string, string>>({})
  const [fallbackStore, setFallbackStore] = useState(currentStore ? String(currentStore) : '')
  const [existing, setExisting] = useState<Set<string> | null>(null)
  /** Current data of the invoices that rows of an edited file point to (by system id or TransactionID). */
  const [known, setKnown] = useState<Invoice[]>([])
  const [applyUpdates, setApplyUpdates] = useState(true)
  const [showAllUpdates, setShowAllUpdates] = useState(false)
  const [stage, setStage] = useState<'pick' | 'review' | 'importing' | 'done'>('pick')
  const [progress, setProgress] = useState({ done: 0, total: 0 })
  const [result, setResult] = useState<{ inserted: number; filled: number; skipped: number; updated: number; failed: { id: number; message: string }[] }>({ inserted: 0, filled: 0, skipped: 0, updated: 0, failed: [] })
  const [newStoreFor, setNewStoreFor] = useState<string | null>(null)
  const [creatingItems, setCreatingItems] = useState(false)

  const terminalStore = useMemo(() => {
    const m = new Map<string, number>()
    for (const s of stores) for (const t of s.terminals) m.set(t.terminal_id, s.id)
    return m
  }, [stores])
  const storeByName = useMemo(() => new Map(stores.map((s) => [norm(s.name), s.id])), [stores])

  const allRows = useMemo(() => files.flatMap((f) => f.rows.map((r) => ({ ...r, file: f.fileName, format: f.format, columns: f.columns }))), [files])

  // Rows of an edited export/template that point to an invoice we already have.
  const matchOf = useMemo(() => {
    const byId = new Map(known.map((i) => [i.id, i]))
    const byTxn = new Map(known.filter((i) => i.transaction_id).map((i) => [i.transaction_id!, i]))
    const m = new Map<(typeof allRows)[number], Invoice>()
    for (const r of allRows) {
      if (r.format !== 'template') continue
      const inv = (r.invoice_id ? byId.get(r.invoice_id) : undefined) ?? byTxn.get(r.transaction_id)
      if (inv) m.set(r, inv)
    }
    return m
  }, [allRows, known])

  // Keys that need the user to pick a store.
  const unknownKeys = useMemo(() => {
    const keys = new Map<string, { label: string; count: number }>()
    for (const r of allRows) {
      if (matchOf.has(r)) continue
      let key: string | null = null
      if (r.store_name && !storeByName.has(norm(r.store_name))) key = `n:${r.store_name.trim()}`
      else if (!r.store_name && r.terminal_id && !terminalStore.has(r.terminal_id)) key = `t:${r.terminal_id}`
      if (key) {
        const e = keys.get(key) ?? { label: key.startsWith('t:') ? t('جهاز رقم {0}', r.terminal_id) : t('متجر «{0}»', r.store_name), count: 0 }
        e.count++
        keys.set(key, e)
      }
    }
    return keys
  }, [allRows, storeByName, terminalStore, matchOf])

  const resolved: ResolvedRow[] = useMemo(
    () =>
      allRows.map((r) => {
        let storeId: number | null = null
        if (r.store_name) storeId = storeByName.get(norm(r.store_name)) ?? (+mapping[`n:${r.store_name.trim()}`] || null)
        else if (r.terminal_id) storeId = terminalStore.get(r.terminal_id) ?? (+mapping[`t:${r.terminal_id}`] || null)
        if (!storeId) storeId = +fallbackStore || null
        let itemId: number | null = null
        if (r.item_name) {
          const n = norm(r.item_name)
          itemId = items.find((i) => i.is_active && norm(i.name) === n && (i.store_id === null || i.store_id === storeId))?.id ?? null
        }
        return { ...r, store_id: storeId, item_id: itemId }
      }),
    [allRows, storeByName, terminalStore, mapping, fallbackStore, items],
  )

  // Rows that would become new invoices (not a duplicate, not an edit of an existing invoice).
  const newRows = useMemo(() => resolved.filter((r, i) => !matchOf.has(allRows[i]) && !existing?.has(r.transaction_id)), [resolved, allRows, matchOf, existing])
  const needsFallback = newRows.some((r) => !r.store_id) || allRows.some((r) => !matchOf.has(r) && !r.store_name && !r.terminal_id)
  const missingStore = newRows.filter((r) => !r.store_id).length
  const unmatchedItems = useMemo(
    () => [...new Set(newRows.filter((r) => r.item_name && !r.item_id).map((r) => r.item_name!.trim()))],
    [newRows],
  )

  // Gateway rows of invoices we already have, where the stored invoice is missing something the file has
  // (e.g. the email). They are sent with the import; the server fills only the empty fields.
  const fills = useMemo(() => {
    const byTxn = new Map(known.filter((i) => i.transaction_id).map((i) => [i.transaction_id!, i]))
    return resolved.flatMap((r) => {
      const inv = r.format === 'gateway' && existing?.has(r.transaction_id) ? byTxn.get(r.transaction_id) : undefined
      const fields = inv ? missingFields(r, inv) : []
      return inv && fields.length ? [{ row: { ...r, store_id: inv.store_id }, fields }] : []
    })
  }, [resolved, known, existing])
  const fillLabels = useMemo(() => [...new Set(fills.flatMap((f) => f.fields))], [fills])

  /** Changes an edited file would make to invoices we already have. */
  const plans = useMemo(() => {
    const out: RowUpdate[] = []
    const warned: RowUpdate[] = []
    let unchanged = 0
    allRows.forEach((r) => {
      const inv = matchOf.get(r)
      if (!inv) return
      const newStoreId = r.store_name ? storeByName.get(norm(r.store_name)) ?? null : null
      const p = planUpdate(r, inv, r.columns, { newStoreId, storeName: (id) => stores.find((s) => s.id === id)?.name ?? '', items })
      if (p && p.changes.length) out.push(p)
      else {
        unchanged++
        if (p) warned.push(p)
      }
    })
    return { updates: out, unchanged, warned }
  }, [allRows, matchOf, storeByName, stores, items])
  const updates = applyUpdates ? plans.updates : []

  const summary = useMemo(() => {
    const per = new Map<number, { n: number; dup: number; sum: number }>()
    let dup = 0
    let fresh = 0
    resolved.forEach((r, i) => {
      if (matchOf.has(allRows[i])) return
      if (existing?.has(r.transaction_id)) {
        dup++
        if (r.store_id) per.set(r.store_id, { ...(per.get(r.store_id) ?? { n: 0, dup: 0, sum: 0 }), dup: (per.get(r.store_id)?.dup ?? 0) + 1 })
        return
      }
      if (!r.store_id) return
      const e = per.get(r.store_id) ?? { n: 0, dup: 0, sum: 0 }
      e.n++
      e.sum += r.amount
      per.set(r.store_id, e)
      fresh++
    })
    return { per, dup, fresh, sum: [...per.values()].reduce((a, e) => a + e.sum, 0) }
  }, [resolved, allRows, matchOf, existing])

  const pick = async (list: FileList | null) => {
    if (!list?.length) return
    setParsing(true)
    try {
      const { parseExcelFile } = await import('../lib/excel')
      const parsed = await Promise.all([...list].map((f) => parseExcelFile(f).catch(() => ({ fileName: f.name, format: 'gateway' as const, rows: [], errors: [t('تعذّرت قراءة الملف')], columns: [] }))))
      const merged = [...files, ...parsed.filter((p) => !files.some((f) => f.fileName === p.fileName))]
      setFiles(merged)
      const ids = merged.flatMap((f) => f.rows.map((r) => r.transaction_id))
      const invIds = merged.flatMap((f) => f.rows.map((r) => r.invoice_id).filter((v): v is number => !!v))
      const r = await api<{ existing: string[]; invoices: Invoice[] }>('import/check', { method: 'POST', body: { transaction_ids: ids, ids: invIds } })
      setExisting(new Set(r.existing))
      setKnown(r.invoices)
      setStage('review')
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setParsing(false)
      if (inputRef.current) inputRef.current.value = ''
    }
  }

  const reset = () => {
    setFiles([])
    setMapping({})
    setExisting(null)
    setKnown([])
    setStage('pick')
  }

  const createMissingItems = async () => {
    setCreatingItems(true)
    try {
      for (const name of unmatchedItems) {
        // Shared by all stores unless the user is limited to specific stores.
        const storeId = user.role !== 'admin' && user.store_ids.length ? resolved.find((r) => r.item_name?.trim() === name)?.store_id : null
        await api('catalog/items', { method: 'POST', body: { name, kind: 'service', store_id: storeId ?? null } })
      }
      await reloadCatalog()
      toast(t('تمت إضافة {0} خدمة/منتج', unmatchedItems.length))
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setCreatingItems(false)
    }
  }

  const run = async () => {
    const rows = [...newRows.filter((r) => r.store_id), ...fills.map((f) => f.row)]
    const toUpdate = updates
    const fileName = files.map((f) => f.fileName).join('، ').slice(0, 120)
    setStage('importing')
    setProgress({ done: 0, total: rows.length + toUpdate.length })
    const terminals = Object.entries(mapping)
      .filter(([k, v]) => k.startsWith('t:') && v)
      .map(([k, v]) => ({ terminal_id: k.slice(2), store_id: +v }))
    let inserted = 0
    let filled = 0
    let skipped = 0
    let updated = 0
    const failed: { id: number; message: string }[] = []
    try {
      for (let i = 0; i < rows.length; i += BATCH) {
        const batch = rows.slice(i, i + BATCH).map(({ file: _f, format: _fm, columns: _c, store_name: _s, item_name: _i, item_raw: _ir, invoice_id: _id, ...r }) => r)
        const r = await api<{ inserted: number; filled?: number; skipped: number }>('import', {
          method: 'POST',
          body: { rows: batch, terminals: i === 0 ? terminals : [], file_name: fileName },
        })
        inserted += r.inserted
        filled += r.filled ?? 0
        skipped += r.skipped
        setProgress({ done: Math.min(i + BATCH, rows.length), total: rows.length + toUpdate.length })
      }
      for (let i = 0; i < toUpdate.length; i += BATCH) {
        const r = await api<{ updated: number; errors: { id: number; message: string }[] }>('import/update', {
          method: 'POST',
          body: { rows: toUpdate.slice(i, i + BATCH).map((u) => u.payload), file_name: fileName },
        })
        updated += r.updated
        failed.push(...r.errors)
        setProgress({ done: rows.length + Math.min(i + BATCH, toUpdate.length), total: rows.length + toUpdate.length })
      }
      // Rows sent only to fill missing fields are among the duplicates already counted in summary.dup.
      setResult({ inserted, filled, skipped: skipped + summary.dup - fills.length, updated, failed })
      setStage('done')
      if (terminals.length) reloadStores()
    } catch (e) {
      toast(errorMessage(e), 'error')
      setResult({ inserted, filled, skipped, updated, failed })
      setStage('review')
    }
  }

  if (stage === 'done') {
    return (
      <Card className="text-center">
        <CheckCircle2 className="mx-auto size-14 text-success" />
        <p className="mt-3 text-[20px] font-bold">{t('تم الاستيراد')}</p>
        <p className="mt-1 text-[16px] text-muted">
          {result.inserted > 0 && (
            <>
              
              <span className="font-semibold text-fg">{t('أُضيفت {0} فاتورة', result.inserted)}</span>
            </>
          )}
          {result.inserted > 0 && result.updated > 0 && ' · '}
          {result.updated > 0 && (
            <>
              
              <span className="font-semibold text-fg">{t('تم تحديث {0} فاتورة', result.updated)}</span>
            </>
          )}
          {result.filled > 0 && (
            <>
              {(result.inserted > 0 || result.updated > 0) && ' · '}
              <span className="font-semibold text-fg">{t('اكتملت بيانات {0} فاتورة', result.filled)}</span>
            </>
          )}
          {result.inserted === 0 && result.updated === 0 && result.filled === 0 && t('لا توجد تغييرات')}
          {result.skipped > 0 && (
            <>
              {' · '}{t('تم تجاهل {0} مكررة', result.skipped)}
            </>
          )}
        </p>
        {result.failed.length > 0 && (
          <div className="mt-4 rounded-2xl bg-danger-soft p-3 text-start text-[14px] text-danger">
            <p className="font-semibold">{t('تعذّر تحديث {0} فاتورة:', result.failed.length)}</p>
            <ul className="mt-1 list-disc space-y-0.5 ps-5">
              {result.failed.slice(0, 8).map((f) => (
                <li key={f.id}>
                  #<span className="num">{f.id}</span>: {tServer(f.message)}
                </li>
              ))}
            </ul>
          </div>
        )}
        <div className="mt-6 space-y-3">
          {result.inserted > 0 && (
            <Button block size="lg" onClick={() => navigate('/invoices?unclassified=1&source=import')}>
              
              {t('حدد الخدمة/المنتج للفواتير الجديدة')}
            </Button>
          )}
          {result.inserted === 0 && (
            <Button block size="lg" onClick={() => navigate('/invoices')}>
              
              {t('عرض الفواتير')}
            </Button>
          )}
          <Button block variant="secondary" onClick={reset}>
            
            {t('استيراد ملف آخر')}
          </Button>
        </div>
      </Card>
    )
  }

  return (
    <div className="space-y-4">
      <input ref={inputRef} type="file" accept=".xlsx,.xls,.csv" multiple hidden onChange={(e) => pick(e.target.files)} />

      {stage === 'pick' && (
        <>
          <button
            onClick={() => inputRef.current?.click()}
            onDragOver={(e) => e.preventDefault()}
            onDrop={(e) => {
              e.preventDefault()
              pick(e.dataTransfer.files)
            }}
            disabled={parsing}
            className="flex w-full flex-col items-center rounded-3xl border-2 border-dashed border-primary/40 bg-primary-soft/40 px-6 py-12 text-center transition active:scale-[0.99]"
          >
            <span className="flex size-16 items-center justify-center rounded-3xl bg-primary text-primary-fg">
              <Upload className="size-8" />
            </span>
            <span className="mt-4 text-[18px] font-bold">{parsing ? t('جاري قراءة الملفات…') : t('اختر ملفات Excel')}</span>
            <span className="mt-1 max-w-xs text-[15px] text-muted">{t('ملفات بوابة الدفع (Checkouts Paid) أو قالب النظام. لتعديل فواتير موجودة: صدّر الفواتير، عدّل الخلايا، ثم ارفع الملف هنا')}</span>
          </button>
          <Card>
            <div className="flex items-start gap-3">
              <FileDown className="mt-0.5 size-6 shrink-0 text-primary" />
              <div className="flex-1">
                <p className="text-[16px] font-semibold">{t('إضافة فواتير كثيرة من Excel')}</p>
                <p className="mt-0.5 text-[14px] text-muted">{t('حمّل القالب، اكتب الفواتير فيه، ثم ارفعه هنا. الفواتير المكررة لا تُضاف مرتين.')}</p>
                <Button size="sm" variant="soft" className="mt-3" onClick={async () => (await import('../lib/excel')).downloadTemplate(activeStores.map((s) => s.name))}>
                  
                  {t('تحميل القالب')}
                </Button>
              </div>
            </div>
          </Card>
        </>
      )}

      {stage !== 'pick' && (
        <>
          <div className="space-y-2">
            {files.map((f) => (
              <div key={f.fileName} className="flex items-center gap-3 rounded-2xl border border-line bg-surface px-4 py-3">
                <FileSpreadsheet className="size-6 shrink-0 text-success" />
                <div className="min-w-0 flex-1">
                  <p className="truncate text-[15px] font-semibold" dir="auto">
                    {f.fileName}
                  </p>
                  <p className="text-[13px] text-muted">
                    {t('{0} فاتورة', f.rows.length)} · {f.format === 'gateway' ? t('ملف بوابة الدفع') : t('قالب النظام')}
                  </p>
                  {f.errors.slice(0, 3).map((e) => (
                    <p key={e} className="text-[13px] text-danger">
                      {e}
                    </p>
                  ))}
                </div>
                {stage === 'review' && (
                  <button aria-label={t('إزالة')} className="p-1 text-muted" onClick={() => (files.length === 1 ? reset() : setFiles(files.filter((x) => x !== f)))}>
                    <X className="size-5" />
                  </button>
                )}
              </div>
            ))}
            {stage === 'review' && (
              <Button variant="ghost" size="sm" icon={<Plus className="size-4" />} onClick={() => inputRef.current?.click()}>
                
                {t('إضافة ملف آخر')}
              </Button>
            )}
          </div>

          {unknownKeys.size > 0 && (
            <Card>
              <p className="mb-1 text-[16px] font-semibold">{t('لأي متجر تتبع هذه الفواتير؟')}</p>
              <p className="mb-3 text-[14px] text-muted">{can('admin') ? t('سيتذكر النظام اختيارك للأجهزة في المرات القادمة.') : t('اختر المتجر لكل مجموعة.')}</p>
              <div className="space-y-3">
                {[...unknownKeys].map(([key, info]) => (
                  <Field key={key} label={t('{0} — {1} فاتورة', info.label, info.count)}>
                    <Select
                      value={mapping[key] ?? ''}
                      onChange={(e) => (e.target.value === 'new' ? setNewStoreFor(key) : setMapping((m) => ({ ...m, [key]: e.target.value })))}
                    >
                      <option value="">{t('اختر المتجر…')}</option>
                      {activeStores.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.name}
                        </option>
                      ))}
                      {can('admin') && <option value="new">{t('+ متجر جديد…')}</option>}
                    </Select>
                  </Field>
                ))}
              </div>
            </Card>
          )}

          {needsFallback && (
            <Card>
              <Field label={t('المتجر الافتراضي')} hint={t('للفواتير التي لا يُعرف متجرها من الملف')}>
                <Select value={fallbackStore} onChange={(e) => setFallbackStore(e.target.value)}>
                  <option value="">{t('اختر المتجر…')}</option>
                  {activeStores.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </Select>
              </Field>
            </Card>
          )}

          {unmatchedItems.length > 0 && (
            <Card>
              <div className="flex items-start gap-3">
                <AlertTriangle className="mt-0.5 size-5 shrink-0 text-warn" />
                <div className="flex-1">
                  <p className="text-[15px] font-semibold">{t('خدمات/منتجات غير موجودة في القائمة')}</p>
                  <div className="mt-2 flex flex-wrap gap-1.5">
                    {unmatchedItems.slice(0, 12).map((n) => (
                      <Badge key={n}>{n}</Badge>
                    ))}
                  </div>
                  <p className="mt-2 text-[13px] text-muted">{t('إذا لم تُضفها، ستُستورد فواتيرها «غير مصنّفة».')}</p>
                  {can('editor') && (
                    <Button size="sm" variant="soft" className="mt-3" loading={creatingItems} onClick={createMissingItems}>
                      
                      {t('إضافتها للقائمة')}
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          )}

          <Card>
            <p className="mb-3 text-[16px] font-semibold">{t('ملخص الاستيراد')}</p>
            <div className={cx('grid gap-2 text-center', plans.updates.length ? 'grid-cols-2 sm:grid-cols-4' : 'grid-cols-3')}>
              <Stat label={t('جديدة')} value={summary.fresh} tone="success" />
              {plans.updates.length > 0 && <Stat label={t('ستُحدَّث')} value={updates.length} tone="primary" />}
              <Stat label={plans.updates.length || plans.unchanged ? t('بدون تغيير / مكررة') : t('مكررة (تُتجاهل)')} value={summary.dup + plans.unchanged + (applyUpdates ? 0 : plans.updates.length)} />
              <Stat label={t('بدون متجر')} value={missingStore} tone={missingStore ? 'warn' : undefined} />
            </div>
            <div className="mt-3 space-y-1.5">
              {[...summary.per].map(([sid, e]) => {
                const s = stores.find((x) => x.id === sid)
                return (
                  <div key={sid} className="flex items-center gap-2 rounded-2xl bg-surface-2 px-3 py-2.5 text-[15px]">
                    <StoreDot color={s?.color ?? '#999'} storeId={s?.id} />
                    <span className="flex-1 font-medium">{s?.name}</span>
                    <span className="num text-muted">{e.n}</span>
                    <Money value={e.sum} className="font-semibold" />
                  </div>
                )
              })}
            </div>
            <div className="mt-3 flex items-center justify-between border-t border-line pt-3 text-[16px]">
              <span className="text-muted">{t('المجموع')}</span>
              <Money value={summary.sum} className="text-[18px] font-bold" />
            </div>
          </Card>

          {fills.length > 0 && (
            <Card>
              <div className="flex items-start gap-3">
                <CheckCircle2 className="mt-0.5 size-5 shrink-0 text-success" />
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold">{t('إكمال بيانات ناقصة في {0} فاتورة موجودة', fills.length)}</p>
                  <p className="mt-0.5 text-[13px] text-muted">{t('هذه الفواتير مستوردة من قبل وينقصها ما يوجد في الملف. تُكمَل الحقول الفارغة فقط ولا يتغير شيء آخر.')}</p>
                  <div className="mt-2 flex flex-wrap gap-1.5">
                    {fillLabels.map((l) => (
                      <Badge key={l} tone="success">
                        {l}
                      </Badge>
                    ))}
                  </div>
                </div>
              </div>
            </Card>
          )}

          {plans.warned.length > 0 && (
            <Card>
              <div className="flex items-start gap-3">
                <AlertTriangle className="mt-0.5 size-5 shrink-0 text-warn" />
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold">
                    {t('{0} فاتورة بها خلايا لا يمكن تطبيقها', plans.warned.length)}
                  </p>
                  <div className="mt-2 space-y-2">
                    {plans.warned.slice(0, 5).map((u) => (
                      <UpdateRow key={u.invoice.id} update={u} />
                    ))}
                  </div>
                </div>
              </div>
            </Card>
          )}

          {plans.updates.length > 0 && (
            <Card>
              <div className="flex items-start gap-3">
                <Pencil className="mt-0.5 size-5 shrink-0 text-primary" />
                <div className="min-w-0 flex-1">
                  <p className="text-[16px] font-semibold">
                    
                    {t('تعديلات على {0} فاتورة موجودة', plans.updates.length)}
                  </p>
                  <p className="text-[13px] text-muted">{t('الخلايا التي تغيّرت في الملف مقارنةً بالبيانات الحالية. الفواتير بدون تغيير لا تُلمس.')}</p>
                </div>
              </div>
              <div className="mt-3 space-y-2">
                {plans.updates.slice(0, 5).map((u) => (
                  <UpdateRow key={u.invoice.id} update={u} />
                ))}
              </div>
              {plans.updates.length > 5 && (
                <Button variant="ghost" size="sm" className="mt-2" onClick={() => setShowAllUpdates(true)}>
                  
                  {t('عرض كل التعديلات ({0})', plans.updates.length)}
                </Button>
              )}
              <div className="mt-2 border-t border-line pt-1">
                <Switch checked={applyUpdates} onChange={setApplyUpdates} label={t('تطبيق هذه التعديلات')} />
              </div>
            </Card>
          )}

          {stage === 'importing' ? (
            <Card>
              <p className="mb-2 text-[15px] font-semibold">
                
                {t('جاري الاستيراد…')} <span className="num">{progress.done}</span> / <span className="num">{progress.total}</span>
              </p>
              <div className="h-3 overflow-hidden rounded-full bg-surface-2">
                <div className="h-full rounded-full bg-primary transition-all" style={{ width: `${progress.total ? (progress.done / progress.total) * 100 : 0}%` }} />
              </div>
            </Card>
          ) : (
            <div className="flex gap-3">
              <Button size="lg" block disabled={!summary.fresh && !updates.length && !fills.length} onClick={run}>
                {[
                  summary.fresh > 0 && t('استيراد {0} فاتورة', summary.fresh),
                  updates.length > 0 && t('تحديث {0} فاتورة', updates.length),
                  fills.length > 0 && t('إكمال {0} فاتورة', fills.length),
                ]
                  .filter(Boolean)
                  .join(t(' و')) || t('لا توجد تغييرات للاستيراد')}
              </Button>
              <Button size="lg" variant="secondary" onClick={reset}>
                
                {t('إلغاء')}
              </Button>
            </div>
          )}
        </>
      )}

      <Sheet open={showAllUpdates} onClose={() => setShowAllUpdates(false)} title={t('التعديلات ({0})', plans.updates.length)}>
        <div className="space-y-2">
          {plans.updates.map((u) => (
            <UpdateRow key={u.invoice.id} update={u} />
          ))}
        </div>
      </Sheet>

      <NewStoreSheet
        open={!!newStoreFor}
        defaultName={newStoreFor?.startsWith('n:') ? newStoreFor.slice(2) : ''}
        onClose={() => setNewStoreFor(null)}
        onCreated={async (id) => {
          await reloadStores()
          if (newStoreFor) setMapping((m) => ({ ...m, [newStoreFor]: String(id) }))
          setNewStoreFor(null)
        }}
      />
    </div>
  )
}

/** One invoice with the cells that changed: old value struck through, new value next to it. */
function UpdateRow({ update }: { update: RowUpdate }) {
  const { invoice, changes, warnings } = update
  return (
    <div className="rounded-2xl bg-surface-2 px-3 py-2.5 text-[14px]">
      <p className="font-semibold">
        {invoice.customer_name || t('بدون اسم')} <span className="num font-normal text-muted">· {invoice.doc_no ?? (invoice.invoice_no ? `#${invoice.invoice_no}` : t('معرّف {0}', invoice.id))}</span>
      </p>
      <ul className="mt-1 space-y-0.5">
        {changes.map((c) => (
          <li key={c.field} className="flex flex-wrap items-baseline gap-x-1.5">
            <span className="text-muted">{c.label}:</span>
            <span className="text-muted line-through">{c.from}</span>
            <span className="text-muted">{ARROW}</span>
            <span className="font-medium text-primary">{c.to}</span>
          </li>
        ))}
        {warnings.map((w) => (
          <li key={w} className="text-[13px] text-warn">
            {w}
          </li>
        ))}
      </ul>
    </div>
  )
}

function Stat({ label, value, tone }: { label: string; value: number; tone?: 'success' | 'warn' | 'primary' }) {
  return (
    <div className={cx('rounded-2xl px-2 py-3', tone === 'success' ? 'bg-success-soft' : tone === 'warn' ? 'bg-warn-soft' : tone === 'primary' ? 'bg-primary-soft' : 'bg-surface-2')}>
      <p className={cx('num text-[22px] font-bold', tone === 'success' && 'text-success', tone === 'warn' && 'text-warn', tone === 'primary' && 'text-primary')}>{value}</p>
      <p className="text-[12px] text-muted">{label}</p>
    </div>
  )
}

export function NewStoreSheet({ open, onClose, onCreated, defaultName = '' }: { open: boolean; onClose: () => void; onCreated: (id: number) => void; defaultName?: string }) {
  const { toast } = useFeedback()
  const [name, setName] = useState(defaultName)
  const [color, setColor] = useState(PALETTE[Math.floor(Math.random() * PALETTE.length)])
  const [logo, setLogo] = useState<LogoImage | null>(null)
  const [saving, setSaving] = useState(false)
  const [lastDefault, setLastDefault] = useState(defaultName)
  if (defaultName !== lastDefault) {
    setLastDefault(defaultName)
    setName(defaultName)
  }
  const save = async () => {
    setSaving(true)
    try {
      const r = await api<{ id: number }>('stores', { method: 'POST', body: { name, color } })
      toast(t('تمت إضافة متجر {0}', name))
      if (logo) {
        try {
          await api(`stores/${r.id}/logo`, { method: 'POST', body: { data: logo.dataUrl, bg: logo.bg } })
        } catch (e) {
          toast(t('تمت إضافة المتجر لكن تعذّر رفع الشعار: {0}', errorMessage(e)), 'error')
        }
      }
      setName('')
      setLogo(null)
      onCreated(r.id)
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }
  return (
    <Sheet
      open={open}
      onClose={onClose}
      title={t('متجر جديد')}
      footer={
        <Button block size="lg" loading={saving} disabled={!name.trim()} onClick={save}>
          
          {t('إضافة المتجر')}
        </Button>
      }
    >
      <div className="space-y-4">
        <Field label={t('اسم المتجر')} required>
          <Input autoFocus value={name} onChange={(e) => setName(e.target.value)} />
        </Field>
        <Field label={t('الشعار (اختياري)')}>
          <LogoPicker name={name} color={color} src={logo?.dataUrl ?? null} bg={logo?.bg} onPick={setLogo} onRemove={() => setLogo(null)} />
        </Field>
        <Field label={t('اللون')}>
          <ColorPicker value={color} onChange={setColor} />
        </Field>
      </div>
    </Sheet>
  )
}

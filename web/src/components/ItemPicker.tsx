import { useMemo, useState } from 'react'
import { Package, Plus, Search, Wrench } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { KIND_LABELS, money } from '../lib/format'
import type { CatalogItem, ItemKind } from '../types'
import { useFeedback } from './Feedback'
import { Sheet } from './Sheet'
import { Badge, Button, Field, Input, Segmented, Select, cx } from './ui'

/**
 * Pick a service/product from the catalog. Shows items of the given store plus shared ones,
 * and lets editors create a new item without leaving the flow.
 */
export function ItemPicker({
  open,
  onClose,
  onPick,
  storeId,
  title = 'اختر الخدمة أو المنتج',
}: {
  open: boolean
  onClose: () => void
  onPick: (item: CatalogItem) => void
  storeId: number | null
  title?: string
}) {
  const { items, can } = useApp()
  const [q, setQ] = useState('')
  const [kind, setKind] = useState<'all' | ItemKind>('all')
  const [creating, setCreating] = useState(false)

  const list = useMemo(() => {
    const term = q.trim().toLowerCase()
    return items.filter(
      (i) =>
        i.is_active &&
        (i.store_id === null || storeId === null || i.store_id === storeId) &&
        (kind === 'all' || i.kind === kind) &&
        (!term || i.name.toLowerCase().includes(term) || (i.sku ?? '').toLowerCase().includes(term)),
    )
  }, [items, q, kind, storeId])

  const close = () => {
    setQ('')
    setCreating(false)
    onClose()
  }

  return (
    <Sheet open={open} onClose={close} title={creating ? 'خدمة أو منتج جديد' : title}>
      {creating ? (
        <NewItemForm
          defaultName={q}
          storeId={storeId}
          onCancel={() => setCreating(false)}
          onCreated={(item) => {
            onPick(item)
            close()
          }}
        />
      ) : (
        <div className="space-y-3">
          <div className="relative">
            <Search className="pointer-events-none absolute start-4 top-1/2 size-5 -translate-y-1/2 text-muted" />
            <Input autoFocus value={q} onChange={(e) => setQ(e.target.value)} placeholder="ابحث بالاسم…" className="ps-12" />
          </div>
          <Segmented
            value={kind}
            onChange={setKind}
            options={[
              { value: 'all', label: 'الكل' },
              { value: 'service', label: 'خدمات' },
              { value: 'product', label: 'منتجات' },
            ]}
          />
          <div className="space-y-2">
            {list.map((i) => (
              <button
                key={i.id}
                onClick={() => {
                  onPick(i)
                  close()
                }}
                className="flex min-h-16 w-full items-center gap-3 rounded-2xl border border-line bg-surface px-4 py-3 text-start transition active:scale-[0.99] hover:bg-surface-2"
              >
                <span className={cx('flex size-10 shrink-0 items-center justify-center rounded-xl', i.kind === 'service' ? 'bg-primary-soft text-primary' : 'bg-success-soft text-success')}>
                  {i.kind === 'service' ? <Wrench className="size-5" /> : <Package className="size-5" />}
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block truncate text-[16px] font-semibold">{i.name}</span>
                  <span className="mt-0.5 flex flex-wrap items-center gap-1.5 text-[13px] text-muted">
                    {KIND_LABELS[i.kind]}
                    {i.category_name && <Badge color={i.category_color ?? undefined}>{i.category_name}</Badge>}
                    {i.store_name ? <span>· {i.store_name}</span> : <span>· كل المتاجر</span>}
                  </span>
                </span>
                {i.default_price !== null && <span className="num shrink-0 text-[15px] font-semibold">{money(i.default_price)}</span>}
              </button>
            ))}
            {!list.length && <p className="py-6 text-center text-[15px] text-muted">{q ? 'لا توجد نتائج' : 'لا توجد خدمات أو منتجات بعد'}</p>}
          </div>
          {can('editor') && (
            <Button variant="soft" block icon={<Plus className="size-5" />} onClick={() => setCreating(true)}>
              {q ? `إضافة «${q}»` : 'إضافة خدمة أو منتج جديد'}
            </Button>
          )}
        </div>
      )}
    </Sheet>
  )
}

export function NewItemForm({
  defaultName = '',
  storeId,
  onCreated,
  onCancel,
}: {
  defaultName?: string
  storeId: number | null
  onCreated: (item: CatalogItem) => void
  onCancel: () => void
}) {
  const { categories, activeStores, reloadCatalog, user } = useApp()
  const { toast } = useFeedback()
  const restricted = user.role !== 'admin' && user.store_ids.length > 0
  const [form, setForm] = useState({
    name: defaultName,
    kind: 'service' as ItemKind,
    category_id: '',
    store_id: restricted && storeId ? String(storeId) : '',
    default_price: '',
  })
  const [saving, setSaving] = useState(false)
  const set = (k: keyof typeof form) => (v: string) => setForm((f) => ({ ...f, [k]: v }))

  const save = async () => {
    setSaving(true)
    try {
      const r = await api<{ id: number }>('catalog/items', {
        method: 'POST',
        body: {
          ...form,
          category_id: form.category_id || null,
          store_id: form.store_id || null,
          default_price: form.default_price || null,
        },
      })
      await reloadCatalog()
      const item: CatalogItem = {
        id: r.id,
        kind: form.kind,
        name: form.name.trim(),
        description: null,
        category_id: form.category_id ? +form.category_id : null,
        store_id: form.store_id ? +form.store_id : null,
        default_price: form.default_price ? +form.default_price : null,
        sku: null,
        is_active: true,
        category_name: categories.find((c) => c.id === +form.category_id)?.name ?? null,
        category_color: null,
        store_name: null,
        usage_count: 0,
      }
      toast('تمت الإضافة')
      onCreated(item)
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="space-y-4">
      <Segmented
        value={form.kind}
        onChange={set('kind')}
        options={[
          { value: 'service', label: 'خدمة' },
          { value: 'product', label: 'منتج' },
        ]}
      />
      <Field label="الاسم" required>
        <Input autoFocus value={form.name} onChange={(e) => set('name')(e.target.value)} placeholder="مثال: باقة تدريب شهرية" />
      </Field>
      <Field label="التصنيف">
        <Select value={form.category_id} onChange={(e) => set('category_id')(e.target.value)}>
          <option value="">بدون تصنيف</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>
              {c.name}
            </option>
          ))}
        </Select>
      </Field>
      <Field label="المتجر" hint="«كل المتاجر» يجعلها متاحة لجميع المتاجر">
        <Select value={form.store_id} onChange={(e) => set('store_id')(e.target.value)}>
          {!restricted && <option value="">كل المتاجر</option>}
          {activeStores.map((s) => (
            <option key={s.id} value={s.id}>
              {s.name}
            </option>
          ))}
        </Select>
      </Field>
      <Field label="السعر الافتراضي (اختياري)">
        <Input inputMode="decimal" value={form.default_price} onChange={(e) => set('default_price')(e.target.value)} placeholder="0" className="num text-end" />
      </Field>
      <div className="flex gap-3 pt-1">
        <Button block loading={saving} disabled={!form.name.trim()} onClick={save}>
          حفظ
        </Button>
        <Button block variant="secondary" onClick={onCancel}>
          رجوع
        </Button>
      </div>
    </div>
  )
}

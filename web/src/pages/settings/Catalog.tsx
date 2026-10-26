import { useEffect, useMemo, useState } from 'react'
import { Package, Plus, Search, Trash2, Wrench } from 'lucide-react'
import { api, errorMessage } from '../../api'
import { useApp } from '../../context'
import { useFeedback } from '../../components/Feedback'
import { Page, TopBar } from '../../components/Layout'
import { Sheet } from '../../components/Sheet'
import { Badge, Button, ColorPicker, EmptyState, Field, Input, Segmented, Select, StoreDot, Switch, Textarea, cx } from '../../components/ui'
import { KIND_LABELS, money } from '../../lib/format'
import type { CatalogItem, Category, ItemKind } from '../../types'

export default function CatalogSettings() {
  const { items, categories, can, currentStore, storeById } = useApp()
  const [tab, setTab] = useState<'items' | 'categories'>('items')
  const [q, setQ] = useState('')
  const [kind, setKind] = useState<'all' | ItemKind>('all')
  const [showArchived, setShowArchived] = useState(false)
  const [editItem, setEditItem] = useState<CatalogItem | 'new' | null>(null)
  const [editCat, setEditCat] = useState<Category | 'new' | null>(null)

  // Default view: the store picked in the top switcher. "كل المتاجر" shows everything.
  const store = storeById(currentStore)
  const [scope, setScope] = useState<'store' | 'all'>('store')
  useEffect(() => setScope('store'), [currentStore])
  const byStore = !!store && scope === 'store'

  const list = useMemo(() => {
    const t = q.trim().toLowerCase()
    return items.filter(
      (i) =>
        (showArchived || i.is_active) &&
        (kind === 'all' || i.kind === kind) &&
        // Items without a store are shared by every store, so they belong to this store's list too.
        (!byStore || i.store_id === null || i.store_id === currentStore) &&
        (!t || i.name.toLowerCase().includes(t)),
    )
  }, [items, q, kind, showArchived, byStore, currentStore])

  return (
    <>
      <TopBar
        title="الخدمات والمنتجات"
        back
        actions={
          can('editor') && (
            <Button size="sm" icon={<Plus className="size-5" />} onClick={() => (tab === 'items' ? setEditItem('new') : setEditCat('new'))}>
              إضافة
            </Button>
          )
        }
      />
      <Page width="medium">
        <Segmented
          className="lg:max-w-md"
          value={tab}
          onChange={setTab}
          options={[
            { value: 'items', label: 'الخدمات والمنتجات' },
            { value: 'categories', label: 'التصنيفات' },
          ]}
        />
        {tab === 'items' ? (
          <div className="mt-4 space-y-3">
            {store && (
              <div>
                <Segmented
                  className="lg:max-w-md"
                  value={scope}
                  onChange={setScope}
                  options={[
                    { value: 'store', label: <><StoreDot color={store.color} storeId={store.id} /> <span className="truncate">{store.name}</span></> },
                    { value: 'all', label: 'كل المتاجر' },
                  ]}
                />
                {byStore && <p className="mt-1.5 px-1 text-[13px] text-muted">خدمات ومنتجات هذا المتجر، مع المشتركة بين كل المتاجر.</p>}
              </div>
            )}
            <div className="relative">
              <Search className="pointer-events-none absolute start-4 top-1/2 size-5 -translate-y-1/2 text-muted" />
              <Input value={q} onChange={(e) => setQ(e.target.value)} placeholder="ابحث…" className="ps-12" />
            </div>
            <Segmented
              className="lg:max-w-md"
              value={kind}
              onChange={setKind}
              options={[
                { value: 'all', label: 'الكل' },
                { value: 'service', label: 'خدمات' },
                { value: 'product', label: 'منتجات' },
              ]}
            />
            <Switch checked={showArchived} onChange={setShowArchived} label="عرض المؤرشفة" />
            {!list.length && (
              <EmptyState
                icon={<Package className="size-8" />}
                title="لا توجد خدمات أو منتجات"
                text="أضف ما تبيعه في متاجرك، ثم اربط كل فاتورة بخدمتها أو منتجها"
                action={
                  <div className="flex flex-wrap justify-center gap-2">
                    {can('editor') && <Button onClick={() => setEditItem('new')}>إضافة {byStore ? 'عنصر لهذا المتجر' : 'أول عنصر'}</Button>}
                    {byStore && (
                      <Button variant="secondary" onClick={() => setScope('all')}>
                        عرض كل المتاجر
                      </Button>
                    )}
                  </div>
                }
              />
            )}
            <div className="space-y-2 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">
              {list.map((i) => (
                <button
                  key={i.id}
                  onClick={() => can('editor') && setEditItem(i)}
                  className={cx('flex min-h-16 w-full items-center gap-3 rounded-3xl border border-line bg-surface px-4 py-3 text-start shadow-card', !i.is_active && 'opacity-60')}
                >
                  <span className={cx('flex size-11 shrink-0 items-center justify-center rounded-2xl', i.kind === 'service' ? 'bg-primary-soft text-primary' : 'bg-success-soft text-success')}>
                    {i.kind === 'service' ? <Wrench className="size-5" /> : <Package className="size-5" />}
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block truncate text-[16px] font-semibold">{i.name}</span>
                    <span className="mt-0.5 flex flex-wrap items-center gap-1.5 text-[13px] text-muted">
                      {KIND_LABELS[i.kind]} · {i.store_name ?? 'كل المتاجر'}
                      {i.category_name && <Badge color={i.category_color ?? undefined}>{i.category_name}</Badge>}
                      {!i.is_active && <Badge>مؤرشف</Badge>}
                    </span>
                  </span>
                  <span className="shrink-0 text-end">
                    {i.default_price !== null && <span className="num block text-[15px] font-semibold">{money(i.default_price)}</span>}
                    <span className="text-[12px] text-muted">
                      <span className="num">{i.usage_count}</span> فاتورة
                    </span>
                  </span>
                </button>
              ))}
            </div>
          </div>
        ) : (
          <div className="mt-4 space-y-2 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">
            <p className="px-1 lg:col-span-2 text-[14px] text-muted">التصنيفات تجمع الخدمات والمنتجات (مثل: باقات، استشارات، ملابس) لتظهر في التقارير.</p>
            {categories.map((c) => (
              <button
                key={c.id}
                onClick={() => can('editor') && setEditCat(c)}
                className="flex min-h-15 w-full items-center gap-3 rounded-3xl border border-line bg-surface px-4 py-3 text-start shadow-card"
              >
                <span className="size-4 rounded-full" style={{ background: c.color }} />
                <span className="flex-1 text-[16px] font-semibold">{c.name}</span>
                <span className="text-[13px] text-muted">
                  <span className="num">{c.item_count}</span> عنصر
                </span>
              </button>
            ))}
          </div>
        )}
      </Page>
      {editItem && <ItemSheet item={editItem === 'new' ? null : editItem} defaultStoreId={byStore ? currentStore : null} onClose={() => setEditItem(null)} />}
      {editCat && <CategorySheet category={editCat === 'new' ? null : editCat} onClose={() => setEditCat(null)} />}
    </>
  )
}

function ItemSheet({ item, defaultStoreId, onClose }: { item: CatalogItem | null; defaultStoreId?: number | null; onClose: () => void }) {
  const { categories, activeStores, reloadCatalog, user } = useApp()
  const { toast, confirm } = useFeedback()
  const restricted = user.role !== 'admin' && user.store_ids.length > 0
  const [f, setF] = useState({
    kind: item?.kind ?? ('service' as ItemKind),
    name: item?.name ?? '',
    category_id: item?.category_id ? String(item.category_id) : '',
    store_id: item?.store_id ? String(item.store_id) : !item && defaultStoreId ? String(defaultStoreId) : restricted ? String(user.store_ids[0]) : '',
    default_price: item?.default_price !== null && item?.default_price !== undefined ? String(item.default_price) : '',
    sku: item?.sku ?? '',
    description: item?.description ?? '',
    is_active: item?.is_active ?? true,
  })
  const [saving, setSaving] = useState(false)

  const save = async () => {
    setSaving(true)
    try {
      const body = { ...f, category_id: f.category_id || null, store_id: f.store_id || null, default_price: f.default_price || null }
      if (item) await api(`catalog/items/${item.id}`, { method: 'PUT', body })
      else await api('catalog/items', { method: 'POST', body })
      await reloadCatalog()
      toast('تم الحفظ')
      onClose()
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }

  const remove = async () => {
    if (!item) return
    const used = item.usage_count > 0
    const ok = await confirm({
      title: used ? `أرشفة «${item.name}»؟` : `حذف «${item.name}»؟`,
      text: used ? `مستخدم في ${item.usage_count} فاتورة، لذلك سيُؤرشف بدل الحذف ويبقى ظاهراً في الفواتير القديمة.` : 'سيتم حذفه نهائياً.',
      confirmLabel: used ? 'أرشفة' : 'حذف',
      danger: !used,
    })
    if (!ok) return
    try {
      await api(`catalog/items/${item.id}`, { method: 'DELETE' })
      await reloadCatalog()
      toast(used ? 'تمت الأرشفة' : 'تم الحذف')
      onClose()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  return (
    <Sheet
      open
      onClose={onClose}
      title={item ? 'تعديل' : 'خدمة أو منتج جديد'}
      footer={
        <div className="flex gap-3">
          <Button block size="lg" loading={saving} disabled={!f.name.trim()} onClick={save}>
            حفظ
          </Button>
          {item && (
            <Button size="lg" variant="danger" onClick={remove} aria-label="حذف">
              <Trash2 className="size-5" />
            </Button>
          )}
        </div>
      }
    >
      <div className="space-y-4">
        <Segmented
          value={f.kind}
          onChange={(kind) => setF({ ...f, kind })}
          options={[
            { value: 'service', label: 'خدمة' },
            { value: 'product', label: 'منتج' },
          ]}
        />
        <Field label="الاسم" required>
          <Input value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} />
        </Field>
        <Field label="التصنيف">
          <Select value={f.category_id} onChange={(e) => setF({ ...f, category_id: e.target.value })}>
            <option value="">بدون تصنيف</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </Select>
        </Field>
        <Field label="المتجر" hint="«كل المتاجر» = متاح لجميع المتاجر">
          <Select value={f.store_id} onChange={(e) => setF({ ...f, store_id: e.target.value })}>
            {!restricted && <option value="">كل المتاجر</option>}
            {activeStores.map((s) => (
              <option key={s.id} value={s.id}>
                {s.name}
              </option>
            ))}
          </Select>
        </Field>
        <div className="grid grid-cols-2 gap-3">
          <Field label="السعر الافتراضي">
            <Input inputMode="decimal" value={f.default_price} onChange={(e) => setF({ ...f, default_price: e.target.value })} className="num text-end" />
          </Field>
          <Field label="الرمز (SKU)">
            <Input value={f.sku} onChange={(e) => setF({ ...f, sku: e.target.value })} className="num" />
          </Field>
        </div>
        <Field label="الوصف">
          <Textarea value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })} />
        </Field>
        {item && <Switch checked={f.is_active} onChange={(is_active) => setF({ ...f, is_active })} label="نشط (يظهر عند اختيار الخدمة/المنتج)" />}
      </div>
    </Sheet>
  )
}

function CategorySheet({ category, onClose }: { category: Category | null; onClose: () => void }) {
  const { reloadCatalog, can } = useApp()
  const { toast, confirm } = useFeedback()
  const [name, setName] = useState(category?.name ?? '')
  const [color, setColor] = useState(category?.color ?? '#0ea5e9')
  const [saving, setSaving] = useState(false)
  const save = async () => {
    setSaving(true)
    try {
      if (category) await api(`catalog/categories/${category.id}`, { method: 'PUT', body: { name, color } })
      else await api('catalog/categories', { method: 'POST', body: { name, color } })
      await reloadCatalog()
      toast('تم الحفظ')
      onClose()
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }
  const remove = async () => {
    if (!category) return
    const ok = await confirm({
      title: `حذف تصنيف «${category.name}»؟`,
      text: category.item_count ? `${category.item_count} عنصر سيصبح بدون تصنيف (لن يُحذف).` : undefined,
      confirmLabel: 'حذف',
      danger: true,
    })
    if (!ok) return
    try {
      await api(`catalog/categories/${category.id}`, { method: 'DELETE' })
      await reloadCatalog()
      onClose()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }
  return (
    <Sheet
      open
      onClose={onClose}
      title={category ? 'تعديل التصنيف' : 'تصنيف جديد'}
      footer={
        <div className="flex gap-3">
          <Button block size="lg" loading={saving} disabled={!name.trim()} onClick={save}>
            حفظ
          </Button>
          {category && can('admin') && (
            <Button size="lg" variant="danger" onClick={remove} aria-label="حذف">
              <Trash2 className="size-5" />
            </Button>
          )}
        </div>
      }
    >
      <div className="space-y-4">
        <Field label="الاسم" required>
          <Input autoFocus value={name} onChange={(e) => setName(e.target.value)} />
        </Field>
        <Field label="اللون">
          <ColorPicker value={color} onChange={setColor} />
        </Field>
      </div>
    </Sheet>
  )
}

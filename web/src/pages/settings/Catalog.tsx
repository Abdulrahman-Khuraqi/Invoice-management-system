import { useEffect, useMemo, useState } from 'react'
import { ChevronDown, Package, Plus, Search, Tags, Trash2, Wrench } from 'lucide-react'
import { api, errorMessage } from '../../api'
import { useApp } from '../../context'
import { useFeedback } from '../../components/Feedback'
import { Page, TopBar } from '../../components/Layout'
import { Sheet } from '../../components/Sheet'
import { Button, Chip, ColorPicker, EmptyState, Field, Input, Segmented, Select, StoreDot, Switch, Textarea, cx } from '../../components/ui'
import { KIND_LABELS, money, priceRange } from '../../lib/format'
import type { CatalogItem, Category, ItemKind } from '../../types'

export default function CatalogSettings() {
  const { items, categories, can, currentStore, storeById } = useApp()
  const [q, setQ] = useState('')
  const [kind, setKind] = useState<'all' | ItemKind>('all')
  const [showArchived, setShowArchived] = useState(false)
  const [editItem, setEditItem] = useState<CatalogItem | 'new' | null>(null)
  const [editCat, setEditCat] = useState<Category | 'new' | null>(null)
  const [catsOpen, setCatsOpen] = useState(false)

  // Default view: the store picked in the top switcher. "كل المتاجر" shows everything.
  const store = storeById(currentStore)
  const [scope, setScope] = useState<'store' | 'all'>('store')
  useEffect(() => setScope('store'), [currentStore])
  const byStore = !!store && scope === 'store'

  // Items without a store are shared by every store, so they belong to this store's list too.
  const inScope = useMemo(() => items.filter((i) => !byStore || i.store_id === null || i.store_id === currentStore), [items, byStore, currentStore])
  const archivedCount = inScope.filter((i) => !i.is_active).length

  const groups = useMemo(() => {
    const t = q.trim().toLowerCase()
    const shown = inScope.filter(
      (i) =>
        (showArchived || i.is_active) &&
        (kind === 'all' || i.kind === kind) &&
        (!t || i.name.toLowerCase().includes(t) || (i.category_name ?? '').toLowerCase().includes(t)),
    )
    const out: { key: number; name: string | null; color: string | null; items: CatalogItem[] }[] = categories
      .map((c) => ({ key: c.id, name: c.name, color: c.color, items: shown.filter((i) => i.category_id === c.id) }))
      .filter((g) => g.items.length)
    const rest = shown.filter((i) => !i.category_id || !categories.some((c) => c.id === i.category_id))
    if (rest.length) out.push({ key: 0, name: out.length ? 'بدون تصنيف' : null, color: null, items: rest })
    return out
  }, [inScope, categories, q, kind, showArchived])
  const total = groups.reduce((n, g) => n + g.items.length, 0)

  return (
    <>
      <TopBar
        title="الخدمات والمنتجات"
        back
        actions={
          can('editor') && (
            <Button size="sm" icon={<Plus className="size-5" />} onClick={() => setEditItem('new')}>
              إضافة
            </Button>
          )
        }
      />
      <Page width="medium">
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <div className="relative min-w-0 flex-1">
              <Search className="pointer-events-none absolute start-4 top-1/2 size-5 -translate-y-1/2 text-muted" />
              <Input value={q} onChange={(e) => setQ(e.target.value)} placeholder="ابحث بالاسم أو التصنيف…" className="ps-12 lg:h-11" />
            </div>
            <button
              onClick={() => setCatsOpen(true)}
              aria-label="التصنيفات"
              title="التصنيفات"
              className="flex size-12 shrink-0 items-center justify-center rounded-2xl border border-line bg-surface text-muted transition hover:bg-surface-2 hover:text-fg lg:size-11"
            >
              <Tags className="size-5" />
            </button>
          </div>
          <div className="no-scrollbar -mx-4 flex gap-2 overflow-x-auto px-4 lg:mx-0 lg:flex-wrap lg:px-0">
            {store && (
              <>
                <Chip active={byStore} onClick={() => setScope('store')} className="max-w-[45%] px-3.5">
                  <StoreDot color={store.color} storeId={store.id} />
                  <span className="truncate">{store.name}</span>
                </Chip>
                <Chip active={!byStore} onClick={() => setScope('all')}>
                  كل المتاجر
                </Chip>
                <span className="mx-1 w-px shrink-0 self-stretch bg-line" aria-hidden />
              </>
            )}
            <Chip active={kind === 'service'} onClick={() => setKind(kind === 'service' ? 'all' : 'service')}>
              خدمات
            </Chip>
            <Chip active={kind === 'product'} onClick={() => setKind(kind === 'product' ? 'all' : 'product')}>
              منتجات
            </Chip>
            {archivedCount > 0 && (
              <Chip active={showArchived} onClick={() => setShowArchived(!showArchived)}>
                المؤرشفة <span className="num">{archivedCount}</span>
              </Chip>
            )}
          </div>
        </div>

        {total === 0 ? (
          <EmptyState
            icon={<Package className="size-8" />}
            title={q || kind !== 'all' ? 'لا توجد نتائج' : byStore ? 'لا توجد خدمات لهذا المتجر بعد' : 'لا توجد خدمات أو منتجات'}
            text={q || kind !== 'all' ? 'جرّب تغيير البحث أو الفلتر' : 'أضف ما تبيعه، ثم اربط كل فاتورة بخدمتها أو منتجها'}
            action={
              <div className="flex flex-wrap justify-center gap-2">
                {can('editor') && !q && kind === 'all' && <Button onClick={() => setEditItem('new')}>إضافة {byStore ? 'عنصر لهذا المتجر' : 'أول عنصر'}</Button>}
                {byStore && (
                  <Button variant="secondary" onClick={() => setScope('all')}>
                    عرض كل المتاجر
                  </Button>
                )}
              </div>
            }
          />
        ) : (
          <div className="mt-2 space-y-5">
            {groups.map((g) => (
              <section key={g.key}>
                {g.name && (
                  <h2 className="mb-2 mt-4 flex items-center gap-2 px-1 text-[14px] font-semibold text-muted">
                    {g.color && <span className="size-2.5 rounded-full" style={{ background: g.color }} />}
                    {g.name}
                    <span className="num font-normal">{g.items.length}</span>
                  </h2>
                )}
                <div className="divide-y divide-line overflow-hidden rounded-2xl border border-line bg-surface shadow-card">
                  {g.items.map((i) => (
                    <ItemRow key={i.id} item={i} showStore={!byStore} onClick={can('editor') ? () => setEditItem(i) : undefined} />
                  ))}
                </div>
              </section>
            ))}
          </div>
        )}
      </Page>

      <Sheet
        open={catsOpen}
        onClose={() => setCatsOpen(false)}
        title="التصنيفات"
        footer={
          can('editor') && (
            <Button block size="lg" icon={<Plus className="size-5" />} onClick={() => (setCatsOpen(false), setEditCat('new'))}>
              تصنيف جديد
            </Button>
          )
        }
      >
        <p className="mb-3 text-[14px] text-muted">التصنيفات تجمع الخدمات والمنتجات (مثل: باقات، استشارات، ملابس) وتظهر في التقارير.</p>
        {!categories.length && <p className="py-6 text-center text-[15px] text-muted">لا توجد تصنيفات بعد</p>}
        <div className="divide-y divide-line overflow-hidden rounded-2xl border border-line">
          {categories.map((c) => (
            <button
              key={c.id}
              onClick={() => can('editor') && (setCatsOpen(false), setEditCat(c))}
              className="flex min-h-14 w-full items-center gap-3 px-4 py-3 text-start hover:bg-surface-2"
            >
              <span className="size-3.5 shrink-0 rounded-full" style={{ background: c.color }} />
              <span className="flex-1 text-[16px] font-medium">{c.name}</span>
              <span className="text-[13px] text-muted">
                <span className="num">{c.item_count}</span> عنصر
              </span>
            </button>
          ))}
        </div>
      </Sheet>

      {editItem && <ItemSheet item={editItem === 'new' ? null : editItem} defaultStoreId={byStore ? currentStore : null} onClose={() => setEditItem(null)} />}
      {editCat && <CategorySheet category={editCat === 'new' ? null : editCat} onClose={() => setEditCat(null)} />}
    </>
  )
}

/** One line per item: name (and store when viewing all stores) on the start side, price on the end side. */
function ItemRow({ item: i, showStore, onClick }: { item: CatalogItem; showStore: boolean; onClick?: () => void }) {
  const price = priceRange(i.price_min, i.price_max) ?? (i.default_price !== null ? money(i.default_price) : null)
  const sub = [showStore ? i.store_name ?? 'كل المتاجر' : null, !i.is_active ? 'مؤرشف' : null].filter(Boolean).join(' · ')
  return (
    <button
      onClick={onClick}
      disabled={!onClick}
      className={cx('flex min-h-14 w-full items-center gap-3 px-4 py-2.5 text-start transition', onClick && 'hover:bg-surface-2 active:bg-surface-2', !i.is_active && 'opacity-60')}
    >
      <span className={cx('flex size-9 shrink-0 items-center justify-center rounded-xl', i.kind === 'service' ? 'bg-primary-soft text-primary' : 'bg-success-soft text-success')} title={KIND_LABELS[i.kind]}>
        {i.kind === 'service' ? <Wrench className="size-4" /> : <Package className="size-4" />}
      </span>
      <span className="min-w-0 flex-1">
        <span className="line-clamp-2 break-words text-[16px] font-medium leading-snug">{i.name}</span>
        {sub && <span className="block truncate text-[13px] text-muted">{sub}</span>}
      </span>
      {price && (
        <span className="shrink-0 whitespace-nowrap text-[15px] font-semibold">
          <span className="num">{price}</span>
          <span className="ms-1 text-[12px] font-normal text-muted">ر.س</span>
        </span>
      )}
    </button>
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
    price_min: item?.price_min != null ? String(item.price_min) : '',
    price_max: item?.price_max != null ? String(item.price_max) : '',
    sku: item?.sku ?? '',
    description: item?.description ?? '',
    is_active: item?.is_active ?? true,
  })
  const [saving, setSaving] = useState(false)
  // Rarely used parts stay folded unless the item already uses them.
  const [showRange, setShowRange] = useState(item?.price_min != null || item?.price_max != null)
  const [more, setMore] = useState(!!(item && (item.sku || item.description || !item.is_active)))

  const save = async () => {
    setSaving(true)
    try {
      const body = { ...f, category_id: f.category_id || null, store_id: f.store_id || null, default_price: f.default_price || null, price_min: f.price_min || null, price_max: f.price_max || null }
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
        <Field label="الاسم" required hint={item && item.usage_count > 0 ? `مستخدم في ${item.usage_count} فاتورة` : undefined}>
          <Input autoFocus={!item} value={f.name} onChange={(e) => setF({ ...f, name: e.target.value })} />
        </Field>

        <div>
          <Field label="السعر (ر.س)" hint={showRange ? undefined : 'يُملأ تلقائياً عند اختيار هذا العنصر في فاتورة'}>
            <Input inputMode="decimal" value={f.default_price} onChange={(e) => setF({ ...f, default_price: e.target.value })} className="num text-end text-[18px] font-semibold" />
          </Field>
          {showRange ? (
            <div className="mt-3 grid grid-cols-2 gap-3">
              <Field label="من">
                <Input inputMode="decimal" value={f.price_min} onChange={(e) => setF({ ...f, price_min: e.target.value })} className="num text-end" />
              </Field>
              <Field label="إلى">
                <Input inputMode="decimal" value={f.price_max} onChange={(e) => setF({ ...f, price_max: e.target.value })} className="num text-end" />
              </Field>
            </div>
          ) : (
            <button type="button" onClick={() => setShowRange(true)} className="mt-1 flex h-10 items-center gap-1 text-[14px] font-semibold text-primary">
              <Plus className="size-4" /> نطاق سعر (من – إلى)
            </button>
          )}
        </div>

        <div className="grid gap-4 sm:grid-cols-2">
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
          <Field label="المتجر">
            <Select value={f.store_id} onChange={(e) => setF({ ...f, store_id: e.target.value })}>
              {!restricted && <option value="">كل المتاجر</option>}
              {activeStores.map((s) => (
                <option key={s.id} value={s.id}>
                  {s.name}
                </option>
              ))}
            </Select>
          </Field>
        </div>

        <button type="button" onClick={() => setMore((m) => !m)} className="flex h-10 items-center gap-1 text-[15px] font-semibold text-primary">
          <ChevronDown className={cx('size-5 transition', more && 'rotate-180')} />
          تفاصيل إضافية
        </button>
        {more && (
          <div className="space-y-4">
            <Field label="الوصف">
              <Textarea value={f.description} onChange={(e) => setF({ ...f, description: e.target.value })} />
            </Field>
            <Field label="الرمز (SKU)">
              <Input value={f.sku} onChange={(e) => setF({ ...f, sku: e.target.value })} className="num" />
            </Field>
            {item && <Switch checked={f.is_active} onChange={(is_active) => setF({ ...f, is_active })} label="نشط (يظهر عند اختيار الخدمة/المنتج)" />}
          </div>
        )}
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

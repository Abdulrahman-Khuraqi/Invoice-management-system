import { useState } from 'react'
import { Archive, ArchiveRestore, Cpu, Plus, Trash2 } from 'lucide-react'
import { api, errorMessage } from '../../api'
import { useApp } from '../../context'
import { useFeedback } from '../../components/Feedback'
import { Page, TopBar } from '../../components/Layout'
import { Sheet } from '../../components/Sheet'
import { Badge, Button, Card, ColorPicker, Field, IconButton, Input, SectionTitle, Select, StoreDot } from '../../components/ui'
import type { Store } from '../../types'
import { NewStoreSheet } from '../Add'

export default function StoresSettings() {
  const { stores, reloadStores } = useApp()
  const [adding, setAdding] = useState(false)
  const [editing, setEditing] = useState<Store | null>(null)
  const active = stores.filter((s) => s.is_active)
  const archived = stores.filter((s) => !s.is_active)

  const row = (s: Store) => (
    <Card key={s.id} onClick={() => setEditing(s)} className="flex items-center gap-3">
      <span className="flex size-12 shrink-0 items-center justify-center rounded-2xl text-[20px] font-bold text-white" style={{ background: s.color }}>
        {s.name.slice(0, 1).toUpperCase()}
      </span>
      <span className="min-w-0 flex-1">
        <span className="block truncate text-[17px] font-semibold">{s.name}</span>
        <span className="text-[14px] text-muted">
          <span className="num">{s.invoice_count}</span> فاتورة · <span className="num">{s.terminals.length}</span> جهاز
        </span>
      </span>
      {!s.is_active && <Badge>مؤرشف</Badge>}
    </Card>
  )

  return (
    <>
      <TopBar
        title="المتاجر"
        back
        actions={
          <Button size="sm" icon={<Plus className="size-5" />} onClick={() => setAdding(true)}>
            متجر جديد
          </Button>
        }
      />
      <Page width="medium">
        <p className="mb-4 px-1 text-[14px] text-muted">أضف أي عدد من المتاجر. ربط «رقم الجهاز» (TerminalID) بالمتجر يجعل استيراد ملفات بوابة الدفع يتعرف على المتجر تلقائياً.</p>
        <div className="space-y-2.5 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">{active.map(row)}</div>
        {archived.length > 0 && (
          <>
            <SectionTitle>المتاجر المؤرشفة</SectionTitle>
            <div className="space-y-2.5 opacity-75 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">{archived.map(row)}</div>
          </>
        )}
      </Page>
      <NewStoreSheet
        open={adding}
        onClose={() => setAdding(false)}
        onCreated={async () => {
          setAdding(false)
          await reloadStores()
        }}
      />
      {editing && (
        <EditStoreSheet
          store={stores.find((s) => s.id === editing.id) ?? editing}
          onClose={() => setEditing(null)}
        />
      )}
    </>
  )
}

function EditStoreSheet({ store, onClose }: { store: Store; onClose: () => void }) {
  const { stores, reloadStores } = useApp()
  const { toast, confirm } = useFeedback()
  const [name, setName] = useState(store.name)
  const [color, setColor] = useState(store.color)
  const [terminal, setTerminal] = useState('')
  const [moveTo, setMoveTo] = useState('')
  const [saving, setSaving] = useState(false)
  const others = stores.filter((s) => s.id !== store.id)

  const call = async (fn: () => Promise<unknown>, msg: string) => {
    try {
      await fn()
      await reloadStores()
      toast(msg)
      return true
    } catch (e) {
      toast(errorMessage(e), 'error')
      return false
    }
  }

  const save = async () => {
    setSaving(true)
    if (await call(() => api(`stores/${store.id}`, { method: 'PUT', body: { name, color } }), 'تم الحفظ')) onClose()
    setSaving(false)
  }

  const toggleArchive = async () => {
    if (store.is_active) {
      const ok = await confirm({
        title: `أرشفة ${store.name}؟`,
        text: 'سيختفي المتجر من القوائم ولن تُضاف له فواتير جديدة. تبقى فواتيره القديمة محفوظة ويمكنك استعادته في أي وقت.',
        confirmLabel: 'أرشفة',
      })
      if (!ok) return
    }
    if (await call(() => api(`stores/${store.id}`, { method: 'PUT', body: { is_active: !store.is_active } }), store.is_active ? 'تمت الأرشفة' : 'تمت الاستعادة')) onClose()
  }

  const moveInvoices = async () => {
    const target = stores.find((s) => s.id === +moveTo)
    if (!target) return
    const ok = await confirm({ title: `نقل ${store.invoice_count} فاتورة إلى ${target.name}؟`, confirmLabel: 'نقل' })
    if (ok) await call(() => api(`stores/${store.id}/move-invoices`, { method: 'POST', body: { to_store_id: target.id } }), 'تم نقل الفواتير')
  }

  const remove = async () => {
    const ok = await confirm({ title: `حذف ${store.name} نهائياً؟`, text: 'سيتم حذف المتجر وأجهزته. لا يمكن التراجع.', confirmLabel: 'حذف', danger: true })
    if (ok && (await call(() => api(`stores/${store.id}`, { method: 'DELETE' }), 'تم حذف المتجر'))) onClose()
  }

  return (
    <Sheet
      open
      onClose={onClose}
      title={store.name}
      footer={
        <Button block size="lg" loading={saving} disabled={!name.trim()} onClick={save}>
          حفظ
        </Button>
      }
    >
      <div className="space-y-5">
        <Field label="اسم المتجر" required>
          <Input value={name} onChange={(e) => setName(e.target.value)} />
        </Field>
        <Field label="اللون">
          <ColorPicker value={color} onChange={setColor} />
        </Field>

        <div>
          <p className="mb-1 text-[15px] font-medium">أرقام الأجهزة (TerminalID)</p>
          <p className="mb-2 text-[13px] text-muted">موجودة في عمود TerminalID في ملفات بوابة الدفع.</p>
          <div className="space-y-1.5">
            {store.terminals.map((t) => (
              <div key={t.terminal_id} className="flex items-center gap-2 rounded-2xl bg-surface-2 py-1 pe-1 ps-3">
                <Cpu className="size-4 text-muted" />
                <span className="num flex-1 text-[15px]">{t.terminal_id}</span>
                <IconButton
                  label="إلغاء الربط"
                  className="size-10 text-danger"
                  onClick={() => call(() => api(`terminals/${encodeURIComponent(t.terminal_id)}`, { method: 'DELETE' }), 'تم إلغاء الربط')}
                >
                  <Trash2 className="size-4" />
                </IconButton>
              </div>
            ))}
          </div>
          <div className="mt-2 flex gap-2">
            <Input value={terminal} onChange={(e) => setTerminal(e.target.value)} placeholder="مثال: 900000005043" inputMode="numeric" className="num h-12 flex-1" />
            <Button
              variant="soft"
              disabled={!terminal.trim()}
              onClick={async () => {
                if (await call(() => api('terminals', { method: 'POST', body: { terminal_id: terminal.trim(), store_id: store.id } }), 'تم ربط الجهاز')) setTerminal('')
              }}
            >
              ربط
            </Button>
          </div>
        </div>

        <div className="space-y-3 rounded-3xl border border-line p-4">
          <Button block variant="secondary" icon={store.is_active ? <Archive className="size-5" /> : <ArchiveRestore className="size-5" />} onClick={toggleArchive}>
            {store.is_active ? 'أرشفة المتجر' : 'استعادة المتجر'}
          </Button>
          {store.invoice_count > 0 ? (
            <>
              <p className="text-[14px] text-muted">
                للحذف النهائي انقل أولاً <span className="num">{store.invoice_count}</span> فاتورة إلى متجر آخر:
              </p>
              <div className="flex gap-2">
                <Select value={moveTo} onChange={(e) => setMoveTo(e.target.value)} className="h-12 flex-1">
                  <option value="">اختر المتجر…</option>
                  {others.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </Select>
                <Button variant="secondary" disabled={!moveTo} onClick={moveInvoices}>
                  نقل
                </Button>
              </div>
            </>
          ) : (
            <Button block variant="danger" icon={<Trash2 className="size-5" />} onClick={remove}>
              حذف المتجر نهائياً
            </Button>
          )}
        </div>
        <p className="flex items-center gap-2 text-[13px] text-muted">
          <StoreDot color={color} /> الفواتير: <span className="num">{store.invoice_count}</span>
        </p>
      </div>
    </Sheet>
  )
}

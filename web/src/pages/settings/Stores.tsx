import { useState } from 'react'
import { Archive, ArchiveRestore, Cpu, Plus, Trash2 } from 'lucide-react'
import { api, errorMessage, storeLogoUrl } from '../../api'
import { useApp } from '../../context'
import { useFeedback } from '../../components/Feedback'
import { Page, TopBar } from '../../components/Layout'
import { Sheet } from '../../components/Sheet'
import { EMPTY_INFO, StoreInfoFields } from '../../components/StoreInfo'
import { LogoPicker, StoreAvatar } from '../../components/StoreLogo'
import { Badge, Button, Card, ColorPicker, Field, IconButton, Input, SectionTitle, Select, StoreDot } from '../../components/ui'
import type { Store } from '../../types'
import { NewStoreSheet } from '../Add'
import { t } from '../../lib/i18n'

export default function StoresSettings() {
  const { stores, reloadStores } = useApp()
  const [adding, setAdding] = useState(false)
  const [editing, setEditing] = useState<Store | null>(null)
  const active = stores.filter((s) => s.is_active)
  const archived = stores.filter((s) => !s.is_active)

  const row = (s: Store) => (
    <Card key={s.id} onClick={() => setEditing(s)} className="flex items-center gap-3">
      <StoreAvatar name={s.name} color={s.color} src={storeLogoUrl(s)} bg={s.logo_bg} />
      <span className="min-w-0 flex-1">
        <span className="block truncate text-[17px] font-semibold">{s.name}</span>
        <span className="text-[14px] text-muted">
          {t('{0} فاتورة', s.invoice_count)} · {t('{0} جهاز', s.terminals.length)}
        </span>
      </span>
      {!s.is_active && <Badge>{t('مؤرشف')}</Badge>}
    </Card>
  )

  return (
    <>
      <TopBar
        title={t('المتاجر')}
        back
        actions={
          <Button size="sm" icon={<Plus className="size-5" />} onClick={() => setAdding(true)}>
            
            {t('متجر جديد')}
          </Button>
        }
      />
      <Page width="medium">
        <p className="mb-4 px-1 text-[14px] text-muted">{t('أضف أي عدد من المتاجر. ربط «رقم الجهاز» (TerminalID) بالمتجر يجعل استيراد ملفات بوابة الدفع يتعرف على المتجر تلقائياً.')}</p>
        <div className="space-y-2.5 lg:grid lg:grid-cols-2 lg:gap-3 lg:space-y-0">{active.map(row)}</div>
        {archived.length > 0 && (
          <>
            <SectionTitle>{t('المتاجر المؤرشفة')}</SectionTitle>
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
  const [info, setInfo] = useState(store.info ?? EMPTY_INFO)
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
    if (await call(() => api(`stores/${store.id}`, { method: 'PUT', body: { name, color, info } }), t('تم الحفظ'))) onClose()
    setSaving(false)
  }

  const toggleArchive = async () => {
    if (store.is_active) {
      const ok = await confirm({
        title: t('أرشفة {0}؟', store.name),
        text: t('سيختفي المتجر من القوائم ولن تُضاف له فواتير جديدة. تبقى فواتيره القديمة محفوظة ويمكنك استعادته في أي وقت.'),
        confirmLabel: t('أرشفة'),
      })
      if (!ok) return
    }
    if (await call(() => api(`stores/${store.id}`, { method: 'PUT', body: { is_active: !store.is_active } }), store.is_active ? t('تمت الأرشفة') : t('تمت الاستعادة'))) onClose()
  }

  const moveInvoices = async () => {
    const target = stores.find((s) => s.id === +moveTo)
    if (!target) return
    const ok = await confirm({ title: t('نقل {0} فاتورة إلى {1}؟', store.invoice_count, target.name), confirmLabel: t('نقل') })
    if (ok) await call(() => api(`stores/${store.id}/move-invoices`, { method: 'POST', body: { to_store_id: target.id } }), t('تم نقل الفواتير'))
  }

  const remove = async () => {
    const ok = await confirm({ title: t('حذف {0} نهائياً؟', store.name), text: t('سيتم حذف المتجر وأجهزته. لا يمكن التراجع.'), confirmLabel: t('حذف'), danger: true })
    if (ok && (await call(() => api(`stores/${store.id}`, { method: 'DELETE' }), t('تم حذف المتجر')))) onClose()
  }

  return (
    <Sheet
      open
      onClose={onClose}
      title={store.name}
      footer={
        <Button block size="lg" loading={saving} disabled={!name.trim()} onClick={save}>
          
          {t('حفظ')}
        </Button>
      }
    >
      <div className="space-y-5">
        <Field label={t('اسم المتجر')} required>
          <Input value={name} onChange={(e) => setName(e.target.value)} />
        </Field>
        <Field label={t('الشعار')}>
          <LogoPicker
            name={name}
            color={color}
            src={storeLogoUrl(store)}
            bg={store.logo_bg}
            onPick={async ({ dataUrl, bg }) => {
              await api(`stores/${store.id}/logo`, { method: 'POST', body: { data: dataUrl, bg } })
              await reloadStores()
              toast(t('تم تحديث الشعار'))
            }}
            onRemove={() => call(() => api(`stores/${store.id}/logo`, { method: 'DELETE' }), t('تم حذف الشعار'))}
          />
        </Field>
        <Field label={t('اللون')}>
          <ColorPicker value={color} onChange={setColor} />
        </Field>

        <div>
          <p className="mb-2 text-[15px] font-medium">{t('معلومات المتجر')}</p>
          <StoreInfoFields value={info} onChange={setInfo} />
        </div>

        <div>
          <p className="mb-1 text-[15px] font-medium">{t('أرقام الأجهزة (TerminalID)')}</p>
          <p className="mb-2 text-[13px] text-muted">{t('موجودة في عمود TerminalID في ملفات بوابة الدفع.')}</p>
          <div className="space-y-1.5">
            {store.terminals.map((term) => (
              <div key={term.terminal_id} className="flex items-center gap-2 rounded-2xl bg-surface-2 py-1 pe-1 ps-3">
                <Cpu className="size-4 text-muted" />
                <span className="num flex-1 text-[15px]">{term.terminal_id}</span>
                <IconButton
                  label={t('إلغاء الربط')}
                  className="size-10 text-danger"
                  onClick={() => call(() => api(`terminals/${encodeURIComponent(term.terminal_id)}`, { method: 'DELETE' }), t('تم إلغاء الربط'))}
                >
                  <Trash2 className="size-4" />
                </IconButton>
              </div>
            ))}
          </div>
          <div className="mt-2 flex gap-2">
            <Input value={terminal} onChange={(e) => setTerminal(e.target.value)} placeholder={t('مثال: 900000005043')} inputMode="numeric" className="num h-12 flex-1" />
            <Button
              variant="soft"
              disabled={!terminal.trim()}
              onClick={async () => {
                if (await call(() => api('terminals', { method: 'POST', body: { terminal_id: terminal.trim(), store_id: store.id } }), t('تم ربط الجهاز'))) setTerminal('')
              }}
            >
              
              {t('ربط')}
            </Button>
          </div>
        </div>

        <div className="space-y-3 rounded-3xl border border-line p-4">
          <Button block variant="secondary" icon={store.is_active ? <Archive className="size-5" /> : <ArchiveRestore className="size-5" />} onClick={toggleArchive}>
            {store.is_active ? t('أرشفة المتجر') : t('استعادة المتجر')}
          </Button>
          {store.invoice_count > 0 ? (
            <>
              <p className="text-[14px] text-muted">
                
                {t('للحذف النهائي انقل أولاً {0} فاتورة إلى متجر آخر:', store.invoice_count)}
              </p>
              <div className="flex gap-2">
                <Select value={moveTo} onChange={(e) => setMoveTo(e.target.value)} className="h-12 flex-1">
                  <option value="">{t('اختر المتجر…')}</option>
                  {others.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </Select>
                <Button variant="secondary" disabled={!moveTo} onClick={moveInvoices}>
                  
                  {t('نقل')}
                </Button>
              </div>
            </>
          ) : (
            <Button block variant="danger" icon={<Trash2 className="size-5" />} onClick={remove}>
              
              {t('حذف المتجر نهائياً')}
            </Button>
          )}
        </div>
        <p className="flex items-center gap-2 text-[13px] text-muted">
          <StoreDot color={color} />  {t('الفواتير: {0}', store.invoice_count)}
        </p>
      </div>
    </Sheet>
  )
}

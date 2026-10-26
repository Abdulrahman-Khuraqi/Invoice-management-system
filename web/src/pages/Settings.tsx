import { useEffect, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, History, KeyRound, LogOut, Monitor, Moon, Package, Smartphone, Store as StoreIcon, Sun, Users } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Button, Field, Input, Segmented, SectionTitle } from '../components/ui'
import { ROLE_LABELS } from '../lib/format'
import { getThemePref, setThemePref, type ThemePref } from '../lib/theme'

export default function Settings() {
  const { user, setUser, can, stores, items } = useApp()
  const { confirm, toast } = useFeedback()
  const navigate = useNavigate()
  const [theme, setTheme] = useState<ThemePref>(getThemePref)
  const [pwOpen, setPwOpen] = useState(false)

  const logout = async () => {
    if (!(await confirm({ title: 'تسجيل الخروج؟', confirmLabel: 'خروج' }))) return
    try {
      await api('auth/logout', { method: 'POST', body: {} })
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
    setUser(null)
  }

  return (
    <>
      <TopBar title="الإعدادات" />
      <Page>
        <div className="flex items-center gap-4 rounded-3xl border border-line bg-surface p-4 shadow-card">
          <span className="flex size-14 items-center justify-center rounded-full bg-primary-soft text-[22px] font-bold text-primary">{user.display_name.slice(0, 1)}</span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[18px] font-bold">{user.display_name}</p>
            <p className="text-[14px] text-muted">
              <span className="num">@{user.username}</span> · {ROLE_LABELS[user.role]}
            </p>
          </div>
        </div>

        <SectionTitle>المظهر</SectionTitle>
        <Segmented
          value={theme}
          onChange={(t) => {
            setTheme(t)
            setThemePref(t)
          }}
          options={[
            { value: 'light', label: <><Sun className="size-5" /> فاتح</> },
            { value: 'dark', label: <><Moon className="size-5" /> داكن</> },
            { value: 'system', label: <><Monitor className="size-5" /> تلقائي</> },
          ]}
        />

        <SectionTitle>إدارة النظام</SectionTitle>
        <Group>
          {can('admin') && <Item icon={<StoreIcon />} label="المتاجر" value={String(stores.filter((s) => s.is_active).length)} onClick={() => navigate('/settings/stores')} />}
          <Item icon={<Package />} label="الخدمات والمنتجات" value={String(items.filter((i) => i.is_active).length)} onClick={() => navigate('/settings/catalog')} />
          {can('admin') && <Item icon={<Users />} label="المستخدمون والصلاحيات" onClick={() => navigate('/settings/users')} />}
          {can('admin') && <Item icon={<History />} label="سجل النشاط" onClick={() => navigate('/settings/activity')} />}
        </Group>

        <SectionTitle>الحساب</SectionTitle>
        <Group>
          <Item icon={<KeyRound />} label="تغيير كلمة المرور" onClick={() => setPwOpen(true)} />
          <InstallItem />
          <Item icon={<LogOut />} label="تسجيل الخروج" danger onClick={logout} />
        </Group>
        <p className="mt-6 text-center text-[13px] text-muted">إدارة الفواتير · الإصدار 1.0</p>
      </Page>
      <PasswordSheet open={pwOpen} onClose={() => setPwOpen(false)} />
    </>
  )
}

export function Group({ children }: { children: ReactNode }) {
  return <div className="divide-y divide-line overflow-hidden rounded-3xl border border-line bg-surface shadow-card">{children}</div>
}

export function Item({ icon, label, value, onClick, danger }: { icon: ReactNode; label: string; value?: string; onClick: () => void; danger?: boolean }) {
  return (
    <button onClick={onClick} className="flex min-h-15 w-full items-center gap-3 px-4 py-3 text-start transition hover:bg-surface-2 active:bg-surface-2">
      <span className={`flex size-10 items-center justify-center rounded-xl [&>svg]:size-5 ${danger ? 'bg-danger-soft text-danger' : 'bg-surface-2 text-fg'}`}>{icon}</span>
      <span className={`flex-1 text-[16px] font-medium ${danger ? 'text-danger' : ''}`}>{label}</span>
      {value && <span className="num text-[15px] text-muted">{value}</span>}
      {!danger && <ChevronLeft className="size-5 text-muted" />}
    </button>
  )
}

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>
}

/** "Install app": native prompt on Android/Chrome, instructions on iOS. */
function InstallItem() {
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(null)
  const [help, setHelp] = useState(false)
  const standalone = window.matchMedia('(display-mode: standalone)').matches || (navigator as unknown as { standalone?: boolean }).standalone
  useEffect(() => {
    const h = (e: Event) => {
      e.preventDefault()
      setDeferred(e as BeforeInstallPromptEvent)
    }
    window.addEventListener('beforeinstallprompt', h)
    return () => window.removeEventListener('beforeinstallprompt', h)
  }, [])
  if (standalone) return null
  return (
    <>
      <Item icon={<Smartphone />} label="تثبيت التطبيق على الجوال" onClick={() => (deferred ? deferred.prompt() : setHelp(true))} />
      <Sheet open={help} onClose={() => setHelp(false)} title="تثبيت التطبيق">
        <div className="space-y-4 text-[16px] leading-relaxed">
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">آيفون (Safari)</p>
            <p className="text-muted">اضغط زر المشاركة ⬆️ أسفل الشاشة ثم اختر «إضافة إلى الشاشة الرئيسية».</p>
          </div>
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">أندرويد (Chrome)</p>
            <p className="text-muted">اضغط على القائمة ⋮ أعلى الشاشة ثم اختر «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية».</p>
          </div>
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">الكمبيوتر</p>
            <p className="text-muted">في Chrome أو Edge اضغط أيقونة التثبيت في شريط العنوان.</p>
          </div>
        </div>
      </Sheet>
    </>
  )
}

function PasswordSheet({ open, onClose }: { open: boolean; onClose: () => void }) {
  const { toast } = useFeedback()
  const [cur, setCur] = useState('')
  const [next, setNext] = useState('')
  const [saving, setSaving] = useState(false)
  const save = async () => {
    setSaving(true)
    try {
      await api('auth/password', { method: 'POST', body: { current_password: cur, new_password: next } })
      toast('تم تغيير كلمة المرور')
      setCur('')
      setNext('')
      onClose()
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
      title="تغيير كلمة المرور"
      footer={
        <Button block size="lg" loading={saving} disabled={!cur || next.length < 8} onClick={save}>
          حفظ
        </Button>
      }
    >
      <div className="space-y-4">
        <Field label="كلمة المرور الحالية">
          <Input type="password" autoComplete="current-password" value={cur} onChange={(e) => setCur(e.target.value)} />
        </Field>
        <Field label="كلمة المرور الجديدة" hint="8 أحرف على الأقل">
          <Input type="password" autoComplete="new-password" value={next} onChange={(e) => setNext(e.target.value)} />
        </Field>
      </div>
    </Sheet>
  )
}

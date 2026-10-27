import { useEffect, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, History, Info, KeyRound, LogOut, Monitor, Moon, Package, Smartphone, Store as StoreIcon, Sun, Users } from 'lucide-react'
import { api, errorMessage } from '../api'
import { useApp } from '../context'
import { useFeedback } from '../components/Feedback'
import { Page, TopBar } from '../components/Layout'
import { Sheet } from '../components/Sheet'
import { Button, Field, Input, Segmented, SectionTitle } from '../components/ui'
import { ROLE_LABELS } from '../lib/format'
import { getThemePref, setThemePref, type ThemePref } from '../lib/theme'
import { lang, setLang, t, type Lang } from '../lib/i18n'

export default function Settings() {
  const { user, setUser, can, stores, items } = useApp()
  const { confirm, toast } = useFeedback()
  const navigate = useNavigate()
  const [theme, setTheme] = useState<ThemePref>(getThemePref)
  const [pwOpen, setPwOpen] = useState(false)

  const logout = async () => {
    if (!(await confirm({ title: t('تسجيل الخروج؟'), confirmLabel: t('خروج') }))) return
    try {
      await api('auth/logout', { method: 'POST', body: {} })
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
    setUser(null)
  }

  return (
    <>
      <TopBar title={t('الإعدادات')} />
      <Page width="medium">
        <div className="lg:grid lg:grid-cols-2 lg:items-start lg:gap-x-8">
        <div>
        <SectionTitle className="hidden lg:mb-2 lg:mt-0 lg:flex">{t('الملف الشخصي')}</SectionTitle>
        <div className="flex items-center gap-4 rounded-3xl border border-line bg-surface p-4 shadow-card">
          <span className="flex size-14 items-center justify-center rounded-full bg-primary-soft text-[22px] font-bold text-primary">{user.display_name.slice(0, 1)}</span>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[18px] font-bold">{user.display_name}</p>
            <p className="text-[14px] text-muted">
              <span className="num">@{user.username}</span> · {ROLE_LABELS[user.role]}
            </p>
          </div>
        </div>

        <SectionTitle>{t('المظهر')}</SectionTitle>
        <Segmented
          value={theme}
          onChange={(next) => {
            setTheme(next)
            setThemePref(next)
          }}
          options={[
            { value: 'light', label: <><Sun className="size-5" />  {t('فاتح')}</> },
            { value: 'dark', label: <><Moon className="size-5" />  {t('داكن')}</> },
            { value: 'system', label: <><Monitor className="size-5" />  {t('تلقائي')}</> },
          ]}
        />
        <SectionTitle>{t('اللغة')}</SectionTitle>
        <Segmented<Lang>
          value={lang}
          onChange={setLang}
          options={[
            { value: 'ar', label: 'العربية' },
            { value: 'en', label: 'English' },
          ]}
        />
        </div>

        <div>
        <SectionTitle className="lg:mt-0">{t('إدارة النظام')}</SectionTitle>
        <Group>
          {can('admin') && <Item icon={<StoreIcon />} label={t('المتاجر')} value={String(stores.filter((s) => s.is_active).length)} onClick={() => navigate('/settings/stores')} />}
          <Item icon={<Info />} label={t('معلومات المتاجر')} onClick={() => navigate('/settings/store-info')} />
          <Item icon={<Package />} label={t('الخدمات والمنتجات')} value={String(items.filter((i) => i.is_active).length)} onClick={() => navigate('/settings/catalog')} />
          {can('admin') && <Item icon={<Users />} label={t('المستخدمون والصلاحيات')} onClick={() => navigate('/settings/users')} />}
          {can('admin') && <Item icon={<History />} label={t('سجل النشاط')} onClick={() => navigate('/settings/activity')} />}
        </Group>

        <SectionTitle>{t('الحساب')}</SectionTitle>
        <Group>
          <Item icon={<KeyRound />} label={t('تغيير كلمة المرور')} onClick={() => setPwOpen(true)} />
          <InstallItem />
          <Item icon={<LogOut />} label={t('تسجيل الخروج')} danger onClick={logout} />
        </Group>
        </div>
        </div>
        <p className="mt-6 text-center text-[13px] text-muted">{t('إدارة الفواتير · الإصدار 1.0')}</p>
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
      {!danger && <ChevronLeft className="size-5 text-muted ltr:rotate-180" />}
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
      <Item icon={<Smartphone />} label={t('تثبيت التطبيق على الجوال')} onClick={() => (deferred ? deferred.prompt() : setHelp(true))} />
      <Sheet open={help} onClose={() => setHelp(false)} title={t('تثبيت التطبيق')}>
        <div className="space-y-4 text-[16px] leading-relaxed">
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">{t('آيفون (Safari)')}</p>
            <p className="text-muted">{t('اضغط زر المشاركة ⬆️ أسفل الشاشة ثم اختر «إضافة إلى الشاشة الرئيسية».')}</p>
          </div>
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">{t('أندرويد (Chrome)')}</p>
            <p className="text-muted">{t('اضغط على القائمة ⋮ أعلى الشاشة ثم اختر «تثبيت التطبيق» أو «إضافة إلى الشاشة الرئيسية».')}</p>
          </div>
          <div className="rounded-2xl bg-surface-2 p-4">
            <p className="font-semibold">{t('الكمبيوتر')}</p>
            <p className="text-muted">{t('في Chrome أو Edge اضغط أيقونة التثبيت في شريط العنوان.')}</p>
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
      toast(t('تم تغيير كلمة المرور'))
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
      title={t('تغيير كلمة المرور')}
      footer={
        <Button block size="lg" loading={saving} disabled={!cur || next.length < 8} onClick={save}>
          
          {t('حفظ')}
        </Button>
      }
    >
      <div className="space-y-4">
        <Field label={t('كلمة المرور الحالية')}>
          <Input type="password" autoComplete="current-password" value={cur} onChange={(e) => setCur(e.target.value)} />
        </Field>
        <Field label={t('كلمة المرور الجديدة')} hint={t('8 أحرف على الأقل')}>
          <Input type="password" autoComplete="new-password" value={next} onChange={(e) => setNext(e.target.value)} />
        </Field>
      </div>
    </Sheet>
  )
}

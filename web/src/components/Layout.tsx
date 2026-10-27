import { useEffect, useState, type ReactNode } from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import { BarChart3, Check, ChevronDown, ChevronRight, FileText, Home, Plus, Settings, Store as StoreIcon, WifiOff } from 'lucide-react'
import { ROLE_LABELS } from '../lib/format'
import { useApp } from '../context'
import { Sheet } from './Sheet'
import { IconButton, StoreDot, cx } from './ui'
import { t } from '../lib/i18n'

const NAV = [
  { to: '/', label: t('الرئيسية'), icon: Home, end: true },
  { to: '/invoices', label: t('الفواتير'), icon: FileText },
  { to: '/add', label: t('إضافة'), icon: Plus, center: true },
  { to: '/reports', label: t('التقارير'), icon: BarChart3 },
  { to: '/settings', label: t('الإعدادات'), icon: Settings },
]

export function BottomNav() {
  const { can } = useApp()
  return (
    <nav className="safe-bottom fixed inset-x-0 bottom-0 z-40 border-t border-line bg-surface/95 backdrop-blur-md lg:hidden">
      <div className="mx-auto flex max-w-2xl items-end justify-around px-2">
        {NAV.filter((n) => !n.center || can('editor')).map((n) =>
          n.center ? (
            <NavLink key={n.to} to={n.to} className="flex flex-1 flex-col items-center pb-2" aria-label={n.label}>
              {({ isActive }) => (
                <>
                  <span
                    className={cx(
                      '-mt-5 flex size-14 items-center justify-center rounded-full bg-primary text-primary-fg shadow-lg shadow-primary/30 ring-4 ring-bg transition active:scale-90',
                      isActive && 'scale-105',
                    )}
                  >
                    <n.icon className="size-7" strokeWidth={2.5} />
                  </span>
                  <span className={cx('mt-1 text-[13px] font-semibold', isActive ? 'text-primary' : 'text-muted')}>{n.label}</span>
                </>
              )}
            </NavLink>
          ) : (
            <NavLink
              key={n.to}
              to={n.to}
              end={n.end}
              className={({ isActive }) =>
                cx('flex h-[68px] flex-1 flex-col items-center justify-center gap-1 transition', isActive ? 'text-primary' : 'text-muted')
              }
            >
              {({ isActive }) => (
                <>
                  <span className={cx('flex h-8 w-14 items-center justify-center rounded-full transition active:scale-90', isActive && 'nav-pop bg-primary-soft')}>
                    <n.icon className="size-6" strokeWidth={isActive ? 2.4 : 2} />
                  </span>
                  <span className="text-[13px] font-semibold">{n.label}</span>
                </>
              )}
            </NavLink>
          ),
        )}
      </div>
    </nav>
  )
}

/** Desktop-only: persistent side navigation (replaces the bottom bar from 1024px up). */
export function Sidebar() {
  const { can, user } = useApp()
  return (
    <aside className="fixed inset-y-0 start-0 z-40 hidden w-64 flex-col border-e border-line bg-surface lg:flex">
      <div className="flex h-18 items-center gap-3 px-5">
        <span className="flex size-10 items-center justify-center rounded-xl bg-primary text-primary-fg shadow-md shadow-primary/25">
          <FileText className="size-5" />
        </span>
        <span className="text-[18px] font-bold">{t('إدارة الفواتير')}</span>
      </div>

      {can('editor') && (
        <div className="px-4 pb-2 pt-1">
          <NavLink
            to="/add"
            className={({ isActive }) =>
              cx(
                'flex h-11 items-center justify-center gap-2 rounded-xl bg-primary text-[15px] font-semibold text-primary-fg shadow-md shadow-primary/20 transition hover:opacity-90',
                isActive && 'ring-4 ring-primary/20',
              )
            }
          >
            <Plus className="size-5" strokeWidth={2.5} />  {t('إضافة فواتير')}
          </NavLink>
        </div>
      )}

      <nav className="flex-1 space-y-1 overflow-y-auto px-4 py-3">
        {NAV.filter((n) => !n.center).map((n) => (
          <NavLink
            key={n.to}
            to={n.to}
            end={n.end}
            className={({ isActive }) =>
              cx(
                'flex h-11 items-center gap-3 rounded-xl px-3.5 text-[15px] font-medium transition',
                isActive ? 'bg-primary-soft font-semibold text-primary' : 'text-muted hover:bg-surface-2 hover:text-fg',
              )
            }
          >
            <n.icon className="size-5" />
            {n.label}
          </NavLink>
        ))}
      </nav>

      <div className="border-t border-line p-4">
        <div className="flex items-center gap-3">
          <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary-soft text-[16px] font-bold text-primary">
            {user.display_name.slice(0, 1)}
          </span>
          <div className="min-w-0">
            <p className="truncate text-[14px] font-semibold">{user.display_name}</p>
            <p className="text-[12px] text-muted">{ROLE_LABELS[user.role]}</p>
          </div>
        </div>
      </div>
    </aside>
  )
}

/** Wraps the signed-in app: sidebar on desktop, bottom bar on phones. */
export function Shell({ children }: { children: ReactNode }) {
  return (
    <>
      <Sidebar />
      <div className="lg:ps-64">{children}</div>
      <BottomNav />
    </>
  )
}

/** True from the `lg` breakpoint up (1024px). */
export function useIsDesktop() {
  const query = '(min-width: 1024px)'
  const [match, setMatch] = useState(() => window.matchMedia(query).matches)
  useEffect(() => {
    const m = window.matchMedia(query)
    const on = () => setMatch(m.matches)
    m.addEventListener('change', on)
    return () => m.removeEventListener('change', on)
  }, [])
  return match
}

/** Page header with optional back button and the store switcher. */
export function TopBar({ title, back, switcher, actions }: { title: string; back?: boolean; switcher?: boolean; actions?: ReactNode }) {
  const navigate = useNavigate()
  return (
    <header className="safe-top sticky top-0 z-30 bg-bg/90 backdrop-blur-md">
      <div className="mx-auto flex min-h-16 max-w-2xl items-center gap-2 px-4 lg:min-h-[72px] lg:max-w-6xl lg:px-8">
        {back && (
          <IconButton label={t('رجوع')} onClick={() => navigate(-1)} className="-ms-2">
            <ChevronRight className="size-7 ltr:rotate-180" />
          </IconButton>
        )}
        <h1 key={title} className="title-enter min-w-0 flex-1 truncate text-[24px] font-bold lg:text-[26px]">{title}</h1>
        {actions}
        {switcher && <StoreSwitcher />}
      </div>
    </header>
  )
}

function StoreSwitcher() {
  const { activeStores, currentStore, setCurrentStore, storeById } = useApp()
  const [open, setOpen] = useState(false)
  const current = storeById(currentStore)
  if (activeStores.length < 2 && !current) return null
  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="flex h-11 max-w-[50%] items-center gap-2 rounded-full border border-line bg-surface px-3.5 text-[15px] font-semibold shadow-card hover:bg-surface-2 active:scale-95 lg:max-w-xs"
      >
        {current ? <StoreDot color={current.color} storeId={current.id} /> : <StoreIcon className="size-4 text-muted" />}
        <span className="truncate">{current?.name ?? t('كل المتاجر')}</span>
        <ChevronDown className="size-4 shrink-0 text-muted" />
      </button>
      <Sheet open={open} onClose={() => setOpen(false)} title={t('اختر المتجر')}>
        <div className="space-y-1.5">
          {[{ id: null as number | null, name: t('كل المتاجر'), color: '' }, ...activeStores].map((s) => (
            <button
              key={s.id ?? 'all'}
              onClick={() => {
                setCurrentStore(s.id)
                setOpen(false)
              }}
              className={cx(
                'flex h-14 w-full items-center gap-3 rounded-2xl px-4 text-[17px] font-medium',
                currentStore === s.id ? 'bg-primary-soft text-primary' : 'hover:bg-surface-2',
              )}
            >
              {s.color ? <StoreDot color={s.color} className="size-3.5" storeId={s.id} logoClassName="size-9 rounded-lg" /> : <StoreIcon className="size-5 text-muted" />}
              <span className="flex-1 text-start">{s.name}</span>
              {currentStore === s.id && <Check className="size-5" />}
            </button>
          ))}
        </div>
      </Sheet>
    </>
  )
}

// Inner width cap; the cap sits at the start edge so it lines up with the page title.
const PAGE_WIDTH = { wide: '', medium: 'lg:max-w-4xl', narrow: 'lg:max-w-3xl' } as const

/** Phone: single column. Desktop: wider container (`width` picks how wide). */
export function Page({ children, className, width = 'wide' }: { children: ReactNode; className?: string; width?: keyof typeof PAGE_WIDTH }) {
  return (
    <main className={cx('page-enter pb-nav mx-auto max-w-2xl px-4 lg:max-w-6xl lg:px-8 lg:pb-12', className)}>
      <div className={PAGE_WIDTH[width]}>{children}</div>
    </main>
  )
}

export function OfflineBanner() {
  const [online, setOnline] = useState(navigator.onLine)
  useEffect(() => {
    const on = () => setOnline(true)
    const off = () => setOnline(false)
    window.addEventListener('online', on)
    window.addEventListener('offline', off)
    return () => {
      window.removeEventListener('online', on)
      window.removeEventListener('offline', off)
    }
  }, [])
  if (online) return null
  return (
    <div className="safe-top fixed inset-x-0 top-0 z-[55] flex items-center justify-center gap-2 bg-warn px-4 py-2 text-[14px] font-semibold text-white">
      <WifiOff className="size-4" />  {t('لا يوجد اتصال بالإنترنت — البيانات تحتاج اتصالاً')}
    </div>
  )
}

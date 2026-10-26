import { useEffect, useState, type ReactNode } from 'react'
import { NavLink, useNavigate } from 'react-router-dom'
import { BarChart3, Check, ChevronDown, ChevronRight, FileText, Home, Plus, Settings, Store as StoreIcon, WifiOff } from 'lucide-react'
import { useApp } from '../context'
import { Sheet } from './Sheet'
import { IconButton, StoreDot, cx } from './ui'

const NAV = [
  { to: '/', label: 'الرئيسية', icon: Home, end: true },
  { to: '/invoices', label: 'الفواتير', icon: FileText },
  { to: '/add', label: 'إضافة', icon: Plus, center: true },
  { to: '/reports', label: 'التقارير', icon: BarChart3 },
  { to: '/settings', label: 'الإعدادات', icon: Settings },
]

export function BottomNav() {
  const { can } = useApp()
  return (
    <nav className="safe-bottom fixed inset-x-0 bottom-0 z-40 border-t border-line bg-surface/95 backdrop-blur-md">
      <div className="mx-auto flex max-w-2xl items-end justify-around px-2">
        {NAV.filter((n) => !n.center || can('editor')).map((n) =>
          n.center ? (
            <NavLink key={n.to} to={n.to} className="flex flex-1 flex-col items-center pb-2" aria-label={n.label}>
              {({ isActive }) => (
                <>
                  <span
                    className={cx(
                      '-mt-5 flex size-14 items-center justify-center rounded-full bg-primary text-primary-fg shadow-lg shadow-primary/30 ring-4 ring-bg transition active:scale-95',
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
                  <span className={cx('flex h-8 w-14 items-center justify-center rounded-full transition', isActive && 'bg-primary-soft')}>
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

/** Page header with optional back button and the store switcher. */
export function TopBar({ title, back, switcher, actions }: { title: string; back?: boolean; switcher?: boolean; actions?: ReactNode }) {
  const navigate = useNavigate()
  return (
    <header className="safe-top sticky top-0 z-30 bg-bg/90 backdrop-blur-md">
      <div className="mx-auto flex min-h-16 max-w-2xl items-center gap-2 px-4">
        {back && (
          <IconButton label="رجوع" onClick={() => navigate(-1)} className="-ms-2">
            <ChevronRight className="size-7" />
          </IconButton>
        )}
        <h1 className="min-w-0 flex-1 truncate text-[24px] font-bold">{title}</h1>
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
        className="flex h-11 max-w-[50%] items-center gap-2 rounded-full border border-line bg-surface px-3.5 text-[15px] font-semibold shadow-card active:scale-95"
      >
        {current ? <StoreDot color={current.color} /> : <StoreIcon className="size-4 text-muted" />}
        <span className="truncate">{current?.name ?? 'كل المتاجر'}</span>
        <ChevronDown className="size-4 shrink-0 text-muted" />
      </button>
      <Sheet open={open} onClose={() => setOpen(false)} title="اختر المتجر">
        <div className="space-y-1.5">
          {[{ id: null as number | null, name: 'كل المتاجر', color: '' }, ...activeStores].map((s) => (
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
              {s.color ? <StoreDot color={s.color} className="size-3.5" /> : <StoreIcon className="size-5 text-muted" />}
              <span className="flex-1 text-start">{s.name}</span>
              {currentStore === s.id && <Check className="size-5" />}
            </button>
          ))}
        </div>
      </Sheet>
    </>
  )
}

export function Page({ children, className }: { children: ReactNode; className?: string }) {
  return <main className={cx('pb-nav mx-auto max-w-2xl px-4', className)}>{children}</main>
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
      <WifiOff className="size-4" /> لا يوجد اتصال بالإنترنت — البيانات تحتاج اتصالاً
    </div>
  )
}

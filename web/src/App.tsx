import { useEffect, useState } from 'react'
import { useLayoutEffect, useRef } from 'react'
import { transitionPending, transitionReady } from './lib/nav'
import { Navigate, Route, Routes, useLocation, useNavigationType } from 'react-router-dom'
import { api } from './api'
import { AppProvider, useApp } from './context'
import { OfflineBanner, Shell } from './components/Layout'
import { Button, PageLoader } from './components/ui'
import Add from './pages/Add'
import Classify from './pages/Classify'
import Home from './pages/Home'
import Invoices from './pages/Invoices'
import { Login, Setup } from './pages/Login'
import Reports from './pages/Reports'
import Settings from './pages/Settings'
import CatalogSettings from './pages/settings/Catalog'
import StoreInfoPage from './pages/settings/StoreInfoPage'
import StoresSettings from './pages/settings/Stores'
import { ActivityPage, UsersSettings } from './pages/settings/Users'
import type { User } from './types'
import { t } from './lib/i18n'

type Boot = { state: 'loading' } | { state: 'setup' } | { state: 'login' } | { state: 'ready'; user: User } | { state: 'error'; message: string }

export default function App() {
  const [boot, setBoot] = useState<Boot>({ state: 'loading' })

  const start = () => {
    setBoot({ state: 'loading' })
    api<{ needsSetup: boolean }>('setup-status')
      .then(async (s) => {
        if (s.needsSetup) return setBoot({ state: 'setup' })
        try {
          const r = await api<{ user: User }>('auth/me')
          setBoot({ state: 'ready', user: r.user })
        } catch {
          setBoot({ state: 'login' })
        }
      })
      .catch((e) => setBoot({ state: 'error', message: e.message }))
  }

  useEffect(start, [])
  useEffect(() => {
    const expired = () => setBoot({ state: 'login' })
    window.addEventListener('auth:expired', expired)
    return () => window.removeEventListener('auth:expired', expired)
  }, [])

  const setUser = (u: User | null) => setBoot(u ? { state: 'ready', user: u } : { state: 'login' })

  return (
    <>
      <OfflineBanner />
      {boot.state === 'loading' && (
        <div className="flex min-h-dvh items-center justify-center">
          <PageLoader />
        </div>
      )}
      {boot.state === 'error' && (
        <div className="flex min-h-dvh flex-col items-center justify-center gap-4 px-6 text-center">
          <p className="text-[18px] font-semibold">{t('تعذّر الاتصال بالسيرفر')}</p>
          <p className="text-[15px] text-muted">{boot.message}</p>
          <Button onClick={start}>{t('إعادة المحاولة')}</Button>
        </div>
      )}
      {boot.state === 'setup' && <Setup onDone={setUser} />}
      {boot.state === 'login' && <Login onLogin={setUser} />}
      {boot.state === 'ready' && (
        <AppProvider user={boot.user} setUser={setUser}>
          <Shell>
            <AppRoutes />
          </Shell>
        </AppProvider>
      )}
    </>
  )
}

const TABS = ['/', '/invoices', '/add', '/reports', '/settings']
const depth = (p: string) => (p === '/' ? 0 : p.split('/').filter(Boolean).length)

/** Tells the page transition (see index.css) which way the user is going, and starts every new page at the top. */
function RouteEffects() {
  const { pathname } = useLocation()
  const type = useNavigationType()
  const prev = useRef(pathname)
  useLayoutEffect(() => {
    const from = prev.current
    prev.current = pathname
    if (from === pathname) return
    const a = TABS.indexOf(from)
    const b = TABS.indexOf(pathname)
    const nav = a >= 0 && b >= 0 ? (b > a ? 'tab-next' : 'tab-prev') : type === 'POP' || depth(pathname) < depth(from) ? 'back' : 'forward'
    const root = document.documentElement
    root.dataset.nav = nav
    // While a view transition animates the page, the CSS entrance animations must stay off (they would be
    // captured in their "invisible" first frame). A navigation without one (e.g. browser back) uses them.
    if (transitionPending()) root.dataset.vt = '1'
    else delete root.dataset.vt
    if (type !== 'POP') window.scrollTo(0, 0)
    transitionReady()
  }, [pathname, type])
  return null
}

function AppRoutes() {
  const { can } = useApp()
  return (
    <>
    <RouteEffects />
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/invoices" element={<Invoices />} />
      <Route path="/add" element={can('editor') ? <Add /> : <Navigate to="/" replace />} />
      <Route path="/classify" element={can('editor') ? <Classify /> : <Navigate to="/" replace />} />
      <Route path="/reports" element={<Reports />} />
      <Route path="/settings" element={<Settings />} />
      <Route path="/settings/catalog" element={<CatalogSettings />} />
      <Route path="/settings/store-info" element={<StoreInfoPage />} />
      {can('admin') && (
        <>
          <Route path="/settings/stores" element={<StoresSettings />} />
          <Route path="/settings/users" element={<UsersSettings />} />
          <Route path="/settings/activity" element={<ActivityPage />} />
        </>
      )}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
    </>
  )
}

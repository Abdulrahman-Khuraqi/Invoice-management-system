import { useEffect, useState } from 'react'
import { Navigate, Route, Routes } from 'react-router-dom'
import { api } from './api'
import { AppProvider, useApp } from './context'
import { OfflineBanner, Shell } from './components/Layout'
import { Button, PageLoader } from './components/ui'
import Add from './pages/Add'
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

function AppRoutes() {
  const { can } = useApp()
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/invoices" element={<Invoices />} />
      <Route path="/add" element={can('editor') ? <Add /> : <Navigate to="/" replace />} />
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
  )
}

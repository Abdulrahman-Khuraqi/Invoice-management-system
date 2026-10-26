import { useState, type FormEvent, type ReactNode } from 'react'
import { FileText } from 'lucide-react'
import { api, errorMessage } from '../api'
import { Button, Field, Input } from '../components/ui'
import type { User } from '../types'

function AuthShell({ title, subtitle, children }: { title: string; subtitle: string; children: ReactNode }) {
  return (
    <div className="safe-top flex min-h-dvh flex-col items-center justify-center px-5 py-10">
      <div className="w-full max-w-sm">
        <div className="mb-8 text-center">
          <span className="mx-auto flex size-18 items-center justify-center rounded-[26px] bg-primary text-primary-fg shadow-lg shadow-primary/30">
            <FileText className="size-9" />
          </span>
          <h1 className="mt-5 text-[26px] font-bold">{title}</h1>
          <p className="mt-1 text-[16px] text-muted">{subtitle}</p>
        </div>
        <div className="rounded-[28px] border border-line bg-surface p-5 shadow-card">{children}</div>
      </div>
    </div>
  )
}

export function Login({ onLogin }: { onLogin: (u: User) => void }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const submit = async (e: FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const r = await api<{ user: User }>('auth/login', { method: 'POST', body: { username, password } })
      onLogin(r.user)
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setLoading(false)
    }
  }
  return (
    <AuthShell title="إدارة الفواتير" subtitle="سجّل الدخول للمتابعة">
      <form onSubmit={submit} className="space-y-4">
        <Field label="اسم المستخدم">
          <Input value={username} onChange={(e) => setUsername(e.target.value)} autoComplete="username" autoCapitalize="none" autoCorrect="off" dir="ltr" required />
        </Field>
        <Field label="كلمة المرور">
          <Input type="password" value={password} onChange={(e) => setPassword(e.target.value)} autoComplete="current-password" dir="ltr" required />
        </Field>
        {error && <p className="rounded-2xl bg-danger-soft px-4 py-3 text-[15px] text-danger">{error}</p>}
        <Button type="submit" size="lg" block loading={loading}>
          دخول
        </Button>
      </form>
    </AuthShell>
  )
}

/** First run: create the admin account. */
export function Setup({ onDone }: { onDone: (u: User) => void }) {
  const [f, setF] = useState({ display_name: '', username: '', password: '', confirm: '' })
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const submit = async (e: FormEvent) => {
    e.preventDefault()
    if (f.password !== f.confirm) return setError('كلمتا المرور غير متطابقتين')
    setLoading(true)
    setError('')
    try {
      const r = await api<{ user: User }>('setup', { method: 'POST', body: f })
      onDone(r.user)
    } catch (err) {
      setError(errorMessage(err))
    } finally {
      setLoading(false)
    }
  }
  return (
    <AuthShell title="مرحباً بك 👋" subtitle="أنشئ حساب المدير لبدء استخدام النظام">
      <form onSubmit={submit} className="space-y-4">
        <Field label="اسمك">
          <Input value={f.display_name} onChange={(e) => setF({ ...f, display_name: e.target.value })} required />
        </Field>
        <Field label="اسم المستخدم" hint="أحرف إنجليزية أو أرقام، 3 على الأقل">
          <Input value={f.username} onChange={(e) => setF({ ...f, username: e.target.value })} autoCapitalize="none" autoCorrect="off" dir="ltr" required />
        </Field>
        <Field label="كلمة المرور" hint="8 أحرف على الأقل">
          <Input type="password" value={f.password} onChange={(e) => setF({ ...f, password: e.target.value })} autoComplete="new-password" dir="ltr" required minLength={8} />
        </Field>
        <Field label="تأكيد كلمة المرور">
          <Input type="password" value={f.confirm} onChange={(e) => setF({ ...f, confirm: e.target.value })} autoComplete="new-password" dir="ltr" required />
        </Field>
        {error && <p className="rounded-2xl bg-danger-soft px-4 py-3 text-[15px] text-danger">{error}</p>}
        <Button type="submit" size="lg" block loading={loading}>
          إنشاء الحساب
        </Button>
      </form>
    </AuthShell>
  )
}

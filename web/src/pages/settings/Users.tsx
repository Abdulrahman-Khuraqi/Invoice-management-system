import { useCallback, useEffect, useState } from 'react'
import { History, Plus, Trash2, UserRound } from 'lucide-react'
import { api, errorMessage } from '../../api'
import { useApp } from '../../context'
import { useFeedback } from '../../components/Feedback'
import { Page, TopBar } from '../../components/Layout'
import { Sheet } from '../../components/Sheet'
import { Badge, Button, Card, EmptyState, Field, Input, PageLoader, Segmented, Switch } from '../../components/ui'
import { ROLE_LABELS, fmtDateTime } from '../../lib/format'
import type { Activity, Role, User } from '../../types'

const ROLE_HELP: Record<Role, string> = {
  admin: 'كل الصلاحيات: المتاجر، المستخدمون، الحذف، والإعدادات',
  editor: 'إضافة واستيراد وتعديل وحذف الفواتير وتصنيفها',
  viewer: 'بحث وعرض وتقارير وتصدير فقط',
}

export function UsersSettings() {
  const { user: me } = useApp()
  const { toast } = useFeedback()
  const [users, setUsers] = useState<User[] | null>(null)
  const [edit, setEdit] = useState<User | 'new' | null>(null)
  const load = useCallback(() => {
    api<{ users: User[] }>('users')
      .then((r) => setUsers(r.users))
      .catch((e) => toast(errorMessage(e), 'error'))
  }, [toast])
  useEffect(load, [load])

  return (
    <>
      <TopBar
        title="المستخدمون"
        back
        actions={
          <Button size="sm" icon={<Plus className="size-5" />} onClick={() => setEdit('new')}>
            مستخدم
          </Button>
        }
      />
      <Page>
        {!users && <PageLoader />}
        <div className="space-y-2.5">
          {users?.map((u) => (
            <Card key={u.id} onClick={() => setEdit(u)} className={`flex items-center gap-3 ${u.is_active ? '' : 'opacity-60'}`}>
              <span className="flex size-12 items-center justify-center rounded-full bg-primary-soft text-[18px] font-bold text-primary">{u.display_name.slice(0, 1)}</span>
              <span className="min-w-0 flex-1">
                <span className="block truncate text-[16px] font-semibold">
                  {u.display_name} {u.id === me.id && <span className="text-[13px] text-muted">(أنت)</span>}
                </span>
                <span className="num block text-[13px] text-muted">@{u.username}</span>
              </span>
              <span className="flex flex-col items-end gap-1">
                <Badge tone={u.role === 'admin' ? 'primary' : 'neutral'}>{ROLE_LABELS[u.role]}</Badge>
                {!u.is_active && <Badge tone="warn">موقوف</Badge>}
              </span>
            </Card>
          ))}
        </div>
      </Page>
      {edit && (
        <UserSheet
          target={edit === 'new' ? null : edit}
          onClose={() => setEdit(null)}
          onSaved={() => {
            setEdit(null)
            load()
          }}
        />
      )}
    </>
  )
}

function UserSheet({ target, onClose, onSaved }: { target: User | null; onClose: () => void; onSaved: () => void }) {
  const { activeStores, user: me } = useApp()
  const { toast, confirm } = useFeedback()
  const [f, setF] = useState({
    username: target?.username ?? '',
    display_name: target?.display_name ?? '',
    password: '',
    role: target?.role ?? ('editor' as Role),
    is_active: target?.is_active ?? true,
    store_ids: target?.store_ids ?? [],
  })
  const [saving, setSaving] = useState(false)
  const self = target?.id === me.id

  const save = async () => {
    setSaving(true)
    try {
      if (target) await api(`users/${target.id}`, { method: 'PUT', body: f })
      else await api('users', { method: 'POST', body: f })
      toast('تم الحفظ')
      onSaved()
    } catch (e) {
      toast(errorMessage(e), 'error')
    } finally {
      setSaving(false)
    }
  }

  const remove = async () => {
    if (!target) return
    const ok = await confirm({ title: `حذف ${target.display_name}؟`, text: 'إذا كان له نشاط سابق سيتم إيقاف الحساب بدل حذفه للحفاظ على السجل.', confirmLabel: 'حذف', danger: true })
    if (!ok) return
    try {
      const r = await api<{ deactivated?: boolean }>(`users/${target.id}`, { method: 'DELETE' })
      toast(r.deactivated ? 'تم إيقاف الحساب' : 'تم الحذف')
      onSaved()
    } catch (e) {
      toast(errorMessage(e), 'error')
    }
  }

  const toggleStore = (id: number) => setF((s) => ({ ...s, store_ids: s.store_ids.includes(id) ? s.store_ids.filter((x) => x !== id) : [...s.store_ids, id] }))
  const valid = f.display_name.trim() && f.username.trim().length >= 3 && (target ? !f.password || f.password.length >= 8 : f.password.length >= 8)

  return (
    <Sheet
      open
      onClose={onClose}
      title={target ? target.display_name : 'مستخدم جديد'}
      footer={
        <div className="flex gap-3">
          <Button block size="lg" loading={saving} disabled={!valid} onClick={save}>
            حفظ
          </Button>
          {target && !self && (
            <Button size="lg" variant="danger" onClick={remove} aria-label="حذف">
              <Trash2 className="size-5" />
            </Button>
          )}
        </div>
      }
    >
      <div className="space-y-4">
        <Field label="الاسم" required>
          <Input value={f.display_name} onChange={(e) => setF({ ...f, display_name: e.target.value })} />
        </Field>
        <Field label="اسم المستخدم (للدخول)" required hint="أحرف إنجليزية أو أرقام">
          <Input
            value={f.username}
            disabled={!!target}
            onChange={(e) => setF({ ...f, username: e.target.value })}
            autoCapitalize="none"
            autoCorrect="off"
            dir="ltr"
            className="num"
          />
        </Field>
        <Field label={target ? 'كلمة مرور جديدة (اتركها فارغة بدون تغيير)' : 'كلمة المرور'} required={!target} hint="8 أحرف على الأقل">
          <Input type="password" autoComplete="new-password" value={f.password} onChange={(e) => setF({ ...f, password: e.target.value })} />
        </Field>
        {!self && (
          <Field label="الصلاحية" hint={ROLE_HELP[f.role]}>
            <Segmented
              value={f.role}
              onChange={(role) => setF({ ...f, role })}
              options={(['admin', 'editor', 'viewer'] as Role[]).map((r) => ({ value: r, label: ROLE_LABELS[r] }))}
            />
          </Field>
        )}
        {f.role !== 'admin' && (
          <div>
            <p className="mb-1 text-[15px] font-medium">المتاجر المسموحة</p>
            <p className="mb-2 text-[13px] text-muted">بدون اختيار = كل المتاجر</p>
            <div className="divide-y divide-line rounded-2xl border border-line px-4">
              {activeStores.map((s) => (
                <Switch key={s.id} checked={f.store_ids.includes(s.id)} onChange={() => toggleStore(s.id)} label={s.name} />
              ))}
            </div>
          </div>
        )}
        {target && !self && <Switch checked={f.is_active} onChange={(is_active) => setF({ ...f, is_active })} label="الحساب نشط" />}
        {target?.last_login_at && <p className="text-[13px] text-muted">آخر دخول: {fmtDateTime(target.last_login_at)}</p>}
      </div>
    </Sheet>
  )
}

export function ActivityPage() {
  const { toast } = useFeedback()
  const [rows, setRows] = useState<Activity[]>([])
  const [page, setPage] = useState(1)
  const [done, setDone] = useState(false)
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    setLoading(true)
    api<{ activity: Activity[] }>('activity', { query: { page } })
      .then((r) => {
        setRows((x) => (page === 1 ? r.activity : [...x, ...r.activity]))
        if (r.activity.length < 50) setDone(true)
      })
      .catch((e) => toast(errorMessage(e), 'error'))
      .finally(() => setLoading(false))
  }, [page, toast])
  return (
    <>
      <TopBar title="سجل النشاط" back />
      <Page>
        {!loading && !rows.length && <EmptyState icon={<History className="size-8" />} title="لا يوجد نشاط بعد" />}
        <div className="space-y-2">
          {rows.map((a) => (
            <div key={a.id} className="flex gap-3 rounded-2xl border border-line bg-surface p-3.5">
              <UserRound className="mt-0.5 size-5 shrink-0 text-muted" />
              <div className="min-w-0 flex-1">
                <p className="text-[15px] font-medium">{a.summary}</p>
                <p className="mt-0.5 text-[13px] text-muted">
                  {a.user_name ?? '—'} · {fmtDateTime(a.created_at)}
                </p>
              </div>
            </div>
          ))}
        </div>
        {loading && <PageLoader />}
        {!loading && !done && rows.length > 0 && (
          <Button block variant="secondary" className="mt-4" onClick={() => setPage((p) => p + 1)}>
            عرض المزيد
          </Button>
        )}
      </Page>
    </>
  )
}

import { createContext, useCallback, useContext, useRef, useState, type ReactNode } from 'react'
import { createPortal } from 'react-dom'
import { AlertTriangle, CheckCircle2, Info } from 'lucide-react'
import { Sheet } from './Sheet'
import { Button } from './ui'

type ToastKind = 'success' | 'error' | 'info'
interface ConfirmOpts {
  title: string
  text?: ReactNode
  confirmLabel?: string
  danger?: boolean
}

interface Feedback {
  toast: (msg: string, kind?: ToastKind) => void
  confirm: (opts: ConfirmOpts) => Promise<boolean>
}

const Ctx = createContext<Feedback | null>(null)

export function FeedbackProvider({ children }: { children: ReactNode }) {
  const [toast, setToast] = useState<{ msg: string; kind: ToastKind; id: number } | null>(null)
  const [dialog, setDialog] = useState<ConfirmOpts | null>(null)
  const resolver = useRef<(v: boolean) => void>(undefined)
  const timer = useRef<number>(undefined)

  const showToast = useCallback((msg: string, kind: ToastKind = 'success') => {
    window.clearTimeout(timer.current)
    setToast({ msg, kind, id: Date.now() })
    timer.current = window.setTimeout(() => setToast(null), kind === 'error' ? 4500 : 2800)
  }, [])

  const confirm = useCallback((opts: ConfirmOpts) => {
    setDialog(opts)
    return new Promise<boolean>((resolve) => {
      resolver.current = resolve
    })
  }, [])

  const close = (v: boolean) => {
    resolver.current?.(v)
    setDialog(null)
  }

  const Icon = toast?.kind === 'error' ? AlertTriangle : toast?.kind === 'info' ? Info : CheckCircle2
  return (
    <Ctx.Provider value={{ toast: showToast, confirm }}>
      {children}
      {toast &&
        createPortal(
          <div
            key={toast.id}
            role="status"
            className="animate-toast safe-top fixed left-1/2 top-3 z-[60] flex w-[calc(100%-32px)] max-w-md -translate-x-1/2 items-center gap-3 rounded-2xl bg-fg px-4 py-3.5 text-[15px] font-medium text-bg shadow-2xl"
            onClick={() => setToast(null)}
          >
            <Icon className={toast.kind === 'error' ? 'size-5 shrink-0 text-red-400' : 'size-5 shrink-0 text-emerald-400'} />
            <span>{toast.msg}</span>
          </div>,
          document.body,
        )}
      <Sheet
        open={!!dialog}
        onClose={() => close(false)}
        title={dialog?.title}
        footer={
          <div className="flex gap-3">
            <Button variant={dialog?.danger ? 'danger' : 'primary'} block onClick={() => close(true)}>
              {dialog?.confirmLabel ?? 'تأكيد'}
            </Button>
            <Button variant="secondary" block onClick={() => close(false)}>
              إلغاء
            </Button>
          </div>
        }
      >
        {dialog?.text && <div className="text-[16px] leading-relaxed text-muted">{dialog.text}</div>}
      </Sheet>
    </Ctx.Provider>
  )
}

export function useFeedback() {
  const v = useContext(Ctx)
  if (!v) throw new Error('useFeedback outside provider')
  return v
}

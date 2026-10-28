import { forwardRef, type ButtonHTMLAttributes, type InputHTMLAttributes, type ReactNode, type SelectHTMLAttributes, type TextareaHTMLAttributes } from 'react'
import { Check, Loader2 } from 'lucide-react'
import { useStoreLogo } from '../context'
import { PALETTE, money } from '../lib/format'
import { t } from '../lib/i18n'

const cx = (...c: (string | false | null | undefined)[]) => c.filter(Boolean).join(' ')
export { cx }

type Variant = 'primary' | 'secondary' | 'ghost' | 'danger' | 'soft'

const VARIANTS: Record<Variant, string> = {
  primary: 'bg-primary text-primary-fg hover:opacity-90',
  secondary: 'bg-surface-2 text-fg hover:bg-line',
  soft: 'bg-primary-soft text-primary hover:opacity-90',
  ghost: 'bg-transparent text-fg hover:bg-surface-2',
  danger: 'bg-danger-soft text-danger hover:opacity-90',
}

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant
  size?: 'md' | 'lg' | 'sm'
  loading?: boolean
  icon?: ReactNode
  block?: boolean
}

export function Button({ variant = 'primary', size = 'md', loading, icon, block, className, children, disabled, ...rest }: ButtonProps) {
  return (
    <button
      {...rest}
      disabled={disabled || loading}
      className={cx(
        'inline-flex items-center justify-center gap-2 rounded-2xl font-semibold transition select-none active:scale-[0.98] disabled:opacity-50 disabled:pointer-events-none',
        size === 'lg' && 'h-14 px-6 text-[17px]',
        size === 'md' && 'h-12 px-5 text-[16px]',
        size === 'sm' && 'h-10 px-4 text-[15px]',
        block && 'w-full',
        VARIANTS[variant],
        className,
      )}
    >
      {loading ? <Loader2 className="size-5 animate-spin" /> : icon}
      {children}
    </button>
  )
}

export function IconButton({ className, label, children, ...rest }: ButtonHTMLAttributes<HTMLButtonElement> & { label: string }) {
  return (
    <button
      {...rest}
      aria-label={label}
      title={label}
      className={cx('inline-flex size-11 items-center justify-center rounded-full text-fg transition hover:bg-surface-2 active:scale-95', className)}
    >
      {children}
    </button>
  )
}

export function Field({ label, hint, error, children, required, className }: { label: string; hint?: string; error?: string; children: ReactNode; required?: boolean; className?: string }) {
  return (
    <label className={cx('block', className)}>
      <span className="mb-1.5 block text-[15px] font-medium text-fg">
        {label}
        {required && <span className="ms-1 text-danger">*</span>}
      </span>
      {children}
      {hint && !error && <span className="mt-1 block text-[13px] text-muted">{hint}</span>}
      {error && <span className="mt-1 block text-[13px] text-danger">{error}</span>}
    </label>
  )
}

const inputBase =
  'w-full rounded-2xl border border-line bg-surface px-4 text-[16px] text-fg placeholder:text-muted/70 outline-none transition focus:border-primary focus:ring-4 focus:ring-primary/15'

export const Input = forwardRef<HTMLInputElement, InputHTMLAttributes<HTMLInputElement>>(function Input({ className, ...rest }, ref) {
  return <input ref={ref} {...rest} className={cx(inputBase, 'h-13 py-3', className)} />
})

export function Textarea({ className, ...rest }: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea {...rest} className={cx(inputBase, 'min-h-24 py-3 leading-relaxed', className)} />
}

export function Select({ className, children, ...rest }: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select {...rest} className={cx(inputBase, 'h-13 appearance-none py-3', className)}>
      {children}
    </select>
  )
}

export function Card({ className, children, onClick }: { className?: string; children: ReactNode; onClick?: () => void }) {
  const Tag = onClick ? 'button' : 'div'
  return (
    <Tag
      onClick={onClick}
      className={cx('block w-full rounded-3xl border border-line bg-surface p-4 text-start shadow-card', onClick && 'transition active:scale-[0.99]', className)}
    >
      {children}
    </Tag>
  )
}

export function Chip({
  active,
  onClick,
  children,
  color,
  className,
}: {
  active?: boolean
  onClick?: () => void
  children: ReactNode
  color?: string
  className?: string
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cx(
        'inline-flex h-10 shrink-0 items-center gap-1.5 rounded-full border px-4 text-[15px] font-medium transition active:scale-95',
        active ? 'border-primary bg-primary text-primary-fg' : 'border-line bg-surface text-fg',
        className,
      )}
    >
      {color && <span className="size-2.5 rounded-full" style={{ background: color }} />}
      {children}
    </button>
  )
}

export function Badge({ children, color, tone = 'neutral', className }: { children: ReactNode; color?: string; tone?: 'neutral' | 'warn' | 'success' | 'primary'; className?: string }) {
  const tones = {
    neutral: 'bg-surface-2 text-fg',
    warn: 'bg-warn-soft text-warn',
    success: 'bg-success-soft text-success',
    primary: 'bg-primary-soft text-primary',
  }
  return (
    <span
      className={cx('inline-flex max-w-full items-center gap-1 truncate rounded-full px-2.5 py-0.5 text-[13px] font-medium', !color && tones[tone], className)}
      style={color ? { background: `${color}1f`, color } : undefined}
    >
      {children}
    </span>
  )
}

/** Store color dot — or the store's logo when `storeId` is given and it has one. */
export function StoreDot({ color, className, storeId, logoClassName }: { color: string; className?: string; storeId?: number | null; logoClassName?: string }) {
  const logo = useStoreLogo(storeId)
  if (logo) return <img src={logo.src} alt="" className={cx('inline-block shrink-0 object-contain p-px ring-1 ring-line', logoClassName ?? 'size-6 rounded-md', logo.bg === 'dark' ? 'bg-slate-800' : 'bg-white')} />
  return <span className={cx('inline-block size-2.5 shrink-0 rounded-full', className)} style={{ background: color }} />
}

export function Segmented<T extends string>({ value, onChange, options, className }: { value: T; onChange: (v: T) => void; options: { value: T; label: ReactNode }[]; className?: string }) {
  return (
    <div className={cx('flex rounded-2xl bg-surface-2 p-1', className)}>
      {options.map((o) => (
        <button
          key={o.value}
          type="button"
          onClick={() => onChange(o.value)}
          className={cx(
            'flex h-11 flex-1 items-center justify-center gap-1.5 rounded-xl text-[15px] font-semibold transition',
            value === o.value ? 'bg-surface text-fg shadow-card' : 'text-muted',
          )}
        >
          {o.label}
        </button>
      ))}
    </div>
  )
}

export function Switch({ checked, onChange, label }: { checked: boolean; onChange: (v: boolean) => void; label: ReactNode }) {
  return (
    <button type="button" onClick={() => onChange(!checked)} className="flex min-h-12 w-full items-center justify-between gap-3 text-start">
      <span className="text-[16px]">{label}</span>
      <span className={cx('relative h-7 w-12 shrink-0 rounded-full transition', checked ? 'bg-primary' : 'bg-line')}>
        <span className={cx('absolute top-1 size-5 rounded-full bg-white shadow transition-all', checked ? 'start-6' : 'start-1')} />
      </span>
    </button>
  )
}

export function ColorPicker({ value, onChange }: { value: string; onChange: (c: string) => void }) {
  return (
    <div className="flex flex-wrap gap-2.5">
      {PALETTE.map((c) => (
        <button
          key={c}
          type="button"
          aria-label={c}
          onClick={() => onChange(c)}
          className="flex size-10 items-center justify-center rounded-full ring-offset-2 ring-offset-surface transition active:scale-90"
          style={{ background: c, boxShadow: value === c ? `0 0 0 3px var(--surface), 0 0 0 5px ${c}` : undefined }}
        >
          {value === c && <Check className="size-5 text-white" />}
        </button>
      ))}
    </div>
  )
}

export function Spinner({ className }: { className?: string }) {
  return <Loader2 className={cx('size-6 animate-spin text-muted', className)} />
}

export function PageLoader() {
  return (
    <div className="flex justify-center py-16">
      <Spinner className="size-8" />
    </div>
  )
}

export function EmptyState({ icon, title, text, action }: { icon: ReactNode; title: string; text?: string; action?: ReactNode }) {
  return (
    <div className="flex flex-col items-center px-6 py-14 text-center">
      <div className="mb-4 flex size-16 items-center justify-center rounded-3xl bg-surface-2 text-muted">{icon}</div>
      <p className="text-[17px] font-semibold">{title}</p>
      {text && <p className="mt-1 max-w-xs text-[15px] text-muted">{text}</p>}
      {action && <div className="mt-5">{action}</div>}
    </div>
  )
}

/** `flush` drops the top margin, for sections laid out in columns (spacing then comes from the section itself). */
export function SectionTitle({ children, action, className, flush }: { children: ReactNode; action?: ReactNode; className?: string; flush?: boolean }) {
  return (
    <div className={cx('mb-2 flex items-center justify-between px-1', flush ? 'mt-0' : 'mt-6', className)}>
      <h2 className="text-[15px] font-semibold text-muted">{children}</h2>
      {action}
    </div>
  )
}

export function Money({ value, className }: { value: number; className?: string }) {
  return (
    <span className={cx('whitespace-nowrap', className)}>
      <span className="num">{money(value)}</span>
      <span className="ms-1 text-[0.8em] font-normal text-muted">{t('ر.س')}</span>
    </span>
  )
}

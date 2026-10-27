import { useRef, useState } from 'react'
import { ImagePlus, Trash2 } from 'lucide-react'
import { fileToLogo, type LogoImage } from '../lib/image'
import { useFeedback } from './Feedback'
import { Button, cx } from './ui'
import { t } from '../lib/i18n'

/** Square store badge: the logo if there is one, otherwise the colored initial. */
export function StoreAvatar({ name, color, src, bg, className }: { name: string; color: string; src?: string | null; bg?: 'light' | 'dark' | null; className?: string }) {
  return src ? (
    <img src={src} alt="" className={cx('shrink-0 rounded-2xl border border-line object-contain p-1', bg === 'dark' ? 'bg-slate-800' : 'bg-white', className ?? 'size-12')} />
  ) : (
    <span className={cx('flex shrink-0 items-center justify-center rounded-2xl text-[20px] font-bold text-white', className ?? 'size-12')} style={{ background: color }}>
      {name.trim().slice(0, 1).toUpperCase() || '؟'}
    </span>
  )
}

/** Preview + choose/remove buttons. `src` is the current logo (URL or a not-yet-uploaded data URL). */
export function LogoPicker({
  name,
  color,
  src,
  bg,
  busy,
  onPick,
  onRemove,
}: {
  name: string
  color: string
  src: string | null
  bg?: 'light' | 'dark' | null
  busy?: boolean
  onPick: (logo: LogoImage) => void | Promise<void>
  onRemove: () => unknown
}) {
  const { toast } = useFeedback()
  const input = useRef<HTMLInputElement>(null)
  const [reading, setReading] = useState(false)

  const choose = async (file?: File) => {
    if (!file) return
    setReading(true)
    try {
      await onPick(await fileToLogo(file))
    } catch (e) {
      toast(e instanceof Error ? e.message : t('تعذّر رفع الشعار'), 'error')
    } finally {
      setReading(false)
      if (input.current) input.current.value = ''
    }
  }

  return (
    <div className="flex items-center gap-4">
      <StoreAvatar name={name} color={color} src={src} bg={bg} className="size-20 text-[28px]" />
      <div className="flex min-w-0 flex-1 flex-col items-start gap-2">
        <input ref={input} type="file" accept="image/png,image/jpeg,image/webp,image/svg+xml,.svg" className="hidden" onChange={(e) => choose(e.target.files?.[0])} />
        <Button size="sm" variant="soft" loading={reading || busy} icon={<ImagePlus className="size-4" />} onClick={() => input.current?.click()}>
          {src ? t('تغيير الشعار') : t('رفع شعار')}
        </Button>
        {src && (
          <Button size="sm" variant="ghost" disabled={reading || busy} className="text-danger" icon={<Trash2 className="size-4" />} onClick={() => onRemove()}>
            
            {t('حذف الشعار')}
          </Button>
        )}
        {!src && <p className="text-[13px] text-muted">{t('PNG أو JPG أو WebP أو SVG — يُصغَّر تلقائياً')}</p>}
      </div>
    </div>
  )
}

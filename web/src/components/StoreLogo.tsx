import { useRef, useState } from 'react'
import { ImagePlus, Trash2 } from 'lucide-react'
import { fileToLogoDataUrl } from '../lib/image'
import { useFeedback } from './Feedback'
import { Button, cx } from './ui'

/** Square store badge: the logo if there is one, otherwise the colored initial. */
export function StoreAvatar({ name, color, src, className }: { name: string; color: string; src?: string | null; className?: string }) {
  return src ? (
    <img src={src} alt="" className={cx('shrink-0 rounded-2xl border border-line bg-white object-contain p-1', className ?? 'size-12')} />
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
  busy,
  onPick,
  onRemove,
}: {
  name: string
  color: string
  src: string | null
  busy?: boolean
  onPick: (dataUrl: string) => void | Promise<void>
  onRemove: () => unknown
}) {
  const { toast } = useFeedback()
  const input = useRef<HTMLInputElement>(null)
  const [reading, setReading] = useState(false)

  const choose = async (file?: File) => {
    if (!file) return
    setReading(true)
    try {
      await onPick(await fileToLogoDataUrl(file))
    } catch (e) {
      toast(e instanceof Error ? e.message : 'تعذّر رفع الشعار', 'error')
    } finally {
      setReading(false)
      if (input.current) input.current.value = ''
    }
  }

  return (
    <div className="flex items-center gap-4">
      <StoreAvatar name={name} color={color} src={src} className="size-20 text-[28px]" />
      <div className="flex min-w-0 flex-1 flex-col items-start gap-2">
        <input ref={input} type="file" accept="image/png,image/jpeg,image/webp" className="hidden" onChange={(e) => choose(e.target.files?.[0])} />
        <Button size="sm" variant="soft" loading={reading || busy} icon={<ImagePlus className="size-4" />} onClick={() => input.current?.click()}>
          {src ? 'تغيير الشعار' : 'رفع شعار'}
        </Button>
        {src && (
          <Button size="sm" variant="ghost" disabled={reading || busy} className="text-danger" icon={<Trash2 className="size-4" />} onClick={() => onRemove()}>
            حذف الشعار
          </Button>
        )}
        {!src && <p className="text-[13px] text-muted">PNG أو JPG أو WebP — يُصغَّر تلقائياً</p>}
      </div>
    </div>
  )
}

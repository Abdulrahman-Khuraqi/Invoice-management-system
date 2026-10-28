import { useEffect, type ReactNode } from 'react'
import { createPortal } from 'react-dom'
import { X } from 'lucide-react'
import { IconButton } from './ui'
import { t } from '../lib/i18n'

/**
 * The page behind open sheets must not scroll. Sheets can stack (a picker over an invoice, a confirm over
 * both) and close in any order, so they share one counter: the page scrolls again when the last one closes.
 */
let openSheets = 0
function lockPageScroll() {
  if (openSheets++ === 0) document.body.style.overflow = 'hidden'
  let released = false
  return () => {
    if (released) return
    released = true
    if (--openSheets === 0) document.body.style.overflow = ''
  }
}

/** Bottom sheet on phones, centered dialog on wide screens. */
export function Sheet({
  open,
  onClose,
  title,
  children,
  footer,
}: {
  open: boolean
  onClose: () => void
  title?: ReactNode
  children: ReactNode
  footer?: ReactNode
}) {
  useEffect(() => (open ? lockPageScroll() : undefined), [open])
  useEffect(() => {
    if (!open) return
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose()
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, onClose])

  if (!open) return null
  return createPortal(
    <div className="fixed inset-0 z-50 flex items-end justify-center sm:items-center" role="dialog" aria-modal="true">
      <div className="animate-fade absolute inset-0 bg-black/45 backdrop-blur-[2px]" onClick={onClose} />
      <div className="animate-sheet relative flex max-h-[92dvh] w-full flex-col rounded-t-[28px] bg-surface shadow-2xl sm:max-w-lg sm:rounded-[28px]">
        <div className="mx-auto mt-2.5 h-1.5 w-10 rounded-full bg-line sm:hidden" />
        <div className="flex items-center justify-between gap-2 px-5 pb-2 pt-3">
          <h2 className="min-w-0 truncate text-[19px] font-bold">{title}</h2>
          <IconButton label={t('إغلاق')} onClick={onClose} className="-me-2">
            <X className="size-6" />
          </IconButton>
        </div>
        <div className="flex-1 overflow-y-auto overscroll-contain px-5 pb-5">{children}</div>
        {/* Not .safe-bottom: that rule is unlayered CSS and would zero out the padding below. */}
        {footer && <div className="border-t border-line px-5 pt-4 pb-[calc(1.25rem+env(safe-area-inset-bottom))]">{footer}</div>}
        {!footer && <div className="safe-bottom" />}
      </div>
    </div>,
    document.body,
  )
}

import { useState } from 'react'
import { Check, Download } from 'lucide-react'
import { ALL_EXPORT_KEYS, EXPORT_COLUMNS } from '../lib/excel'
import { load, save } from '../lib/storage'
import { Sheet } from './Sheet'
import { Button, Switch, cx } from './ui'

interface Preset {
  id: string
  title: string
  hint: string
  keys: string[]
  totalRow: boolean
}

const PRESETS: Preset[] = [
  { id: 'all', title: 'كل المعلومات', hint: 'كل الأعمدة. يمكنك تعديل الملف ثم رفعه لتحديث الفواتير', keys: ALL_EXPORT_KEYS, totalRow: false },
  { id: 'customer', title: 'العميل والمبلغ', hint: 'اسم العميل مع مبلغ فاتورته', keys: ['customer', 'amount'], totalRow: true },
  { id: 'invoice', title: 'رقم الفاتورة والمبلغ', hint: 'رقم كل فاتورة مع مبلغها', keys: ['invoiceNo', 'amount'], totalRow: true },
  { id: 'sales', title: 'سجل المبيعات', hint: 'التاريخ والعميل والخدمة والمبلغ', keys: ['date', 'customer', 'item', 'amount'], totalRow: true },
]

const sameKeys = (a: string[], b: string[]) => a.length === b.length && a.every((k) => b.includes(k))

/** Lets the user pick what goes into the invoices Excel file: everything (default), a preset, or any columns. */
export function ExportSheet({
  open,
  onClose,
  count,
  busy,
  onExport,
}: {
  open: boolean
  onClose: () => void
  count: number
  busy: boolean
  onExport: (keys: string[], totalRow: boolean) => void
}) {
  const [keys, setKeys] = useState<string[]>(() => load<string[]>('exportKeys', ALL_EXPORT_KEYS).filter((k) => ALL_EXPORT_KEYS.includes(k)))
  const [totalRow, setTotalRow] = useState(() => load<boolean>('exportTotal', false))

  const active = PRESETS.find((p) => sameKeys(p.keys, keys))
  const toggle = (k: string) => setKeys((cur) => (cur.includes(k) ? cur.filter((x) => x !== k) : [...cur, k]))
  const hasAmount = keys.includes('amount')
  // Full export is meant for re-uploading, so no totals row there.
  const withTotal = totalRow && hasAmount && !sameKeys(keys, ALL_EXPORT_KEYS)

  const go = () => {
    const ordered = ALL_EXPORT_KEYS.filter((k) => keys.includes(k))
    save('exportKeys', ordered)
    save('exportTotal', totalRow)
    onExport(ordered, withTotal)
  }

  return (
    <Sheet
      open={open}
      onClose={onClose}
      title="تصدير إلى Excel"
      footer={
        <Button block size="lg" loading={busy} disabled={!keys.length || !count} icon={<Download className="size-5" />} onClick={go}>
          تصدير <span className="num">{count}</span> فاتورة
        </Button>
      }
    >
      <div className="space-y-5">
        <div>
          <p className="mb-2 text-[15px] font-semibold">ماذا تريد أن تصدّر؟</p>
          <div className="space-y-2">
            {PRESETS.map((p) => (
              <button
                key={p.id}
                type="button"
                onClick={() => {
                  setKeys(p.keys)
                  setTotalRow(p.totalRow)
                }}
                className={cx(
                  'flex w-full items-center gap-3 rounded-2xl border px-4 py-3 text-start transition',
                  active?.id === p.id ? 'border-primary bg-primary-soft' : 'border-line hover:bg-surface-2',
                )}
              >
                <span className={cx('flex size-5 shrink-0 items-center justify-center rounded-full border-2', active?.id === p.id ? 'border-primary bg-primary text-primary-fg' : 'border-line')}>
                  {active?.id === p.id && <Check className="size-3" strokeWidth={3} />}
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block text-[16px] font-semibold">{p.title}</span>
                  <span className="block text-[13px] text-muted">{p.hint}</span>
                </span>
              </button>
            ))}
          </div>
        </div>

        <div>
          <p className="mb-2 text-[15px] font-semibold">
            الأعمدة {!active && <span className="text-[13px] font-normal text-primary">· مخصّص</span>}
          </p>
          <div className="flex flex-wrap gap-2">
            {EXPORT_COLUMNS.map((c) => {
              const on = keys.includes(c.key)
              return (
                <button
                  key={c.key}
                  type="button"
                  onClick={() => toggle(c.key)}
                  className={cx(
                    'inline-flex h-10 items-center gap-1.5 rounded-full border px-3.5 text-[14px] font-medium transition',
                    on ? 'border-primary bg-primary-soft text-primary' : 'border-line text-muted hover:bg-surface-2',
                  )}
                >
                  {on && <Check className="size-4" />}
                  {c.label}
                </button>
              )
            })}
          </div>
        </div>

        {hasAmount && !sameKeys(keys, ALL_EXPORT_KEYS) && <Switch checked={totalRow} onChange={setTotalRow} label="إضافة صف المجموع في النهاية" />}
      </div>
    </Sheet>
  )
}

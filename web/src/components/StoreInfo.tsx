import { Building2, Copy, FileText, Globe, Mail, MapPin, MessageCircle, Phone, StickyNote } from 'lucide-react'
import type { ReactNode } from 'react'
import { storeLogoUrl } from '../api'
import type { Store, StoreInfo } from '../types'
import { useFeedback } from './Feedback'
import { StoreAvatar } from './StoreLogo'
import { Card, Field, Input, Textarea } from './ui'

export const EMPTY_INFO: StoreInfo = { website: null, phone: null, whatsapp: null, email: null, address: null, cr_number: null, vat_number: null, notes: null }

export const hasInfo = (i: StoreInfo) => Object.values(i).some((v) => v && v.trim())

const AR_DIGITS = '٠١٢٣٤٥٦٧٨٩'
const normalizeDigits = (s: string) => s.replace(/[٠-٩]/g, (d) => String(AR_DIGITS.indexOf(d)))
const digitsOnly = (s: string) => normalizeDigits(s).replace(/\D/g, '')

/** tel: link for the first number in the field (several numbers may be separated by "/" or ","). */
const telHref = (s: string) => `tel:${normalizeDigits(s.split(/[\/,،]/)[0]).replace(/[^\d+]/g, '')}`

/** wa.me wants an international number; a local Saudi "05xxxxxxxx" becomes 9665xxxxxxxx. */
const waHref = (s: string) => {
  let n = digitsOnly(s.split(/[\/,،]/)[0])
  if (n.startsWith('00')) n = n.slice(2)
  else if (n.startsWith('0')) n = '966' + n.slice(1)
  return `https://wa.me/${n}`
}

const hostOf = (url: string) => url.replace(/^https?:\/\//i, '').replace(/\/$/, '')

/** Form fields for the store's info (controlled; the parent saves them). */
export function StoreInfoFields({ value, onChange }: { value: StoreInfo; onChange: (v: StoreInfo) => void }) {
  const set = (k: keyof StoreInfo) => (e: { target: { value: string } }) => onChange({ ...value, [k]: e.target.value || null })
  const v = (k: keyof StoreInfo) => value[k] ?? ''
  return (
    <div className="space-y-4">
      <Field label="الموقع الإلكتروني">
        <Input type="url" dir="ltr" inputMode="url" placeholder="https://example.com" value={v('website')} onChange={set('website')} className="text-start" />
      </Field>
      <div className="grid grid-cols-2 gap-3">
        <Field label="الجوال / الهاتف">
          <Input type="tel" dir="ltr" inputMode="tel" placeholder="05xxxxxxxx" value={v('phone')} onChange={set('phone')} className="text-start" />
        </Field>
        <Field label="واتساب">
          <Input type="tel" dir="ltr" inputMode="tel" placeholder="05xxxxxxxx" value={v('whatsapp')} onChange={set('whatsapp')} className="text-start" />
        </Field>
      </div>
      <Field label="البريد الإلكتروني">
        <Input type="email" dir="ltr" inputMode="email" placeholder="info@example.com" value={v('email')} onChange={set('email')} className="text-start" />
      </Field>
      <Field label="العنوان">
        <Input value={v('address')} onChange={set('address')} />
      </Field>
      <div className="grid grid-cols-2 gap-3">
        <Field label="السجل التجاري">
          <Input dir="ltr" inputMode="numeric" value={v('cr_number')} onChange={set('cr_number')} className="num text-start" />
        </Field>
        <Field label="الرقم الضريبي">
          <Input dir="ltr" inputMode="numeric" value={v('vat_number')} onChange={set('vat_number')} className="num text-start" />
        </Field>
      </div>
      <Field label="ملاحظات">
        <Textarea value={v('notes')} onChange={set('notes')} placeholder="أي معلومات أخرى مهمة عن المتجر…" />
      </Field>
    </div>
  )
}

function InfoRow({ icon, label, children, copy, href }: { icon: ReactNode; label: string; children: ReactNode; copy?: string; href?: string }) {
  const { toast } = useFeedback()
  const body = <span className="min-w-0 break-words text-[15px] font-medium">{children}</span>
  return (
    <div className="flex items-start gap-3 py-2.5">
      <span className="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-lg bg-surface-2 text-muted [&>svg]:size-4">{icon}</span>
      <div className="min-w-0 flex-1">
        <p className="text-[12px] text-muted">{label}</p>
        {href ? (
          <a href={href} target={href.startsWith('http') ? '_blank' : undefined} rel="noopener noreferrer" className="text-primary hover:underline">
            {body}
          </a>
        ) : (
          body
        )}
      </div>
      {copy && (
        <button
          aria-label="نسخ"
          className="shrink-0 p-1.5 text-muted hover:text-fg"
          onClick={() => navigator.clipboard?.writeText(copy).then(() => toast('تم النسخ'), () => {})}
        >
          <Copy className="size-4" />
        </button>
      )}
    </div>
  )
}

/** Read-only summary of a store's details, with tap-to-call / open-site / WhatsApp links. */
export function StoreInfoCard({ store }: { store: Store }) {
  const i = store.info
  return (
    <Card>
      <div className="flex items-center gap-3 border-b border-line pb-3">
        <StoreAvatar name={store.name} color={store.color} src={storeLogoUrl(store)} bg={store.logo_bg} className="size-12" />
        <div className="min-w-0 flex-1">
          <p className="truncate text-[17px] font-bold">{store.name}</p>
          <p className="text-[13px] text-muted">معلومات المتجر</p>
        </div>
      </div>
      <div className="divide-y divide-line lg:grid lg:grid-cols-2 lg:gap-x-8 lg:divide-y-0">
        {i.website && (
          <InfoRow icon={<Globe />} label="الموقع الإلكتروني" href={i.website} copy={i.website}>
            <span dir="ltr" className="inline-block">{hostOf(i.website)}</span>
          </InfoRow>
        )}
        {i.phone && (
          <InfoRow icon={<Phone />} label="الجوال / الهاتف" href={telHref(i.phone)} copy={i.phone}>
            <span className="num">{i.phone}</span>
          </InfoRow>
        )}
        {i.whatsapp && (
          <InfoRow icon={<MessageCircle />} label="واتساب" href={waHref(i.whatsapp)} copy={i.whatsapp}>
            <span className="num">{i.whatsapp}</span>
          </InfoRow>
        )}
        {i.email && (
          <InfoRow icon={<Mail />} label="البريد الإلكتروني" href={`mailto:${i.email}`} copy={i.email}>
            <span dir="ltr" className="inline-block">{i.email}</span>
          </InfoRow>
        )}
        {i.address && (
          <InfoRow icon={<MapPin />} label="العنوان" copy={i.address}>
            {i.address}
          </InfoRow>
        )}
        {i.cr_number && (
          <InfoRow icon={<Building2 />} label="السجل التجاري" copy={i.cr_number}>
            <span className="num">{i.cr_number}</span>
          </InfoRow>
        )}
        {i.vat_number && (
          <InfoRow icon={<FileText />} label="الرقم الضريبي" copy={i.vat_number}>
            <span className="num">{i.vat_number}</span>
          </InfoRow>
        )}
        {i.notes && (
          <InfoRow icon={<StickyNote />} label="ملاحظات">
            <span className="whitespace-pre-line">{i.notes}</span>
          </InfoRow>
        )}
      </div>
    </Card>
  )
}

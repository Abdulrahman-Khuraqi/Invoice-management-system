import { useNavigate } from '../../lib/nav'
import { Info, Pencil } from 'lucide-react'
import { storeLogoUrl } from '../../api'
import { useApp } from '../../context'
import { Page, TopBar } from '../../components/Layout'
import { StoreInfoCard, hasInfo } from '../../components/StoreInfo'
import { StoreAvatar } from '../../components/StoreLogo'
import { Button, Card, EmptyState } from '../../components/ui'
import { t } from '../../lib/i18n'

/** Contact and business details of every store (website, phones, tax numbers…). Edited in Settings → Stores. */
export default function StoreInfoPage() {
  const { activeStores, can } = useApp()
  const navigate = useNavigate()
  const withInfo = activeStores.filter((s) => hasInfo(s.info))
  const without = activeStores.filter((s) => !hasInfo(s.info))

  return (
    <>
      <TopBar
        title={t('معلومات المتاجر')}
        back
        actions={
          can('admin') && (
            <Button size="sm" variant="soft" icon={<Pencil className="size-4" />} onClick={() => navigate('/settings/stores')}>
              
              {t('تعديل')}
            </Button>
          )
        }
      />
      <Page>
        {!activeStores.length && <EmptyState icon={<Info className="size-8" />} title={t('لا توجد متاجر')} />}
        <div className="space-y-3 lg:grid lg:grid-cols-2 lg:items-start lg:gap-4 lg:space-y-0">
          {withInfo.map((s) => (
            <StoreInfoCard key={s.id} store={s} />
          ))}
        </div>
        {without.length > 0 && (
          <div className="mt-3 space-y-2">
            <p className="px-1 text-[14px] text-muted">{withInfo.length ? t('متاجر بدون معلومات') : t('لم تُضف معلومات لأي متجر بعد')}</p>
            {without.map((s) => (
              <Card key={s.id} className="flex items-center gap-3 !p-3" onClick={can('admin') ? () => navigate('/settings/stores') : undefined}>
                <StoreAvatar name={s.name} color={s.color} src={storeLogoUrl(s)} bg={s.logo_bg} className="size-10 text-[16px]" />
                <span className="flex-1 text-[15px] font-medium">{s.name}</span>
                {can('admin') && <span className="text-[13px] text-primary">{t('إضافة معلومات')}</span>}
              </Card>
            ))}
          </div>
        )}
      </Page>
    </>
  )
}

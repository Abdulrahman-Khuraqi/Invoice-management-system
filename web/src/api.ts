import { t, tServer } from './lib/i18n'
export class ApiError extends Error {
  status: number
  data: Record<string, unknown>
  constructor(status: number, message: string, data: Record<string, unknown> = {}) {
    super(message)
    this.status = status
    this.data = data
  }
}

type Query = Record<string, string | number | boolean | null | undefined>

/** Calls the PHP API (api/index.php?r=<path>). Relative URL so it works from any install folder. */
export async function api<T = unknown>(
  path: string,
  opts: { method?: 'GET' | 'POST' | 'PUT' | 'DELETE'; body?: unknown; query?: Query; signal?: AbortSignal } = {},
): Promise<T> {
  const params = new URLSearchParams({ r: path })
  for (const [k, v] of Object.entries(opts.query ?? {})) {
    if (v !== undefined && v !== null && v !== '' && v !== false) params.set(k, String(v))
  }
  let res: Response
  try {
    res = await fetch(`api/index.php?${params}`, {
      method: opts.method ?? 'GET',
      credentials: 'same-origin',
      headers: {
        'X-Requested-With': 'fetch',
        ...(opts.body !== undefined ? { 'Content-Type': 'application/json' } : {}),
      },
      body: opts.body !== undefined ? JSON.stringify(opts.body) : undefined,
      signal: opts.signal,
    })
  } catch {
    throw new ApiError(0, t('لا يوجد اتصال بالإنترنت أو السيرفر لا يستجيب'))
  }
  let data: Record<string, unknown> = {}
  try {
    data = await res.json()
  } catch {
    throw new ApiError(res.status, t('استجابة غير متوقعة من السيرفر'))
  }
  if (!res.ok) {
    if (res.status === 401 && path !== 'auth/login' && path !== 'auth/me') {
      window.dispatchEvent(new Event('auth:expired'))
    }
    throw new ApiError(res.status, tServer(String(data.error ?? 'حدث خطأ')), data)
  }
  return data as T
}

/** Same-origin URL of a store's logo (cookie-authenticated); `v` busts the cache when the logo changes. */
export const storeLogoUrl = (s: { id: number; logo_v: number | null }) => (s.logo_v ? `api/index.php?r=stores/${s.id}/logo&v=${s.logo_v}` : null)

export const errorMessage = (e: unknown) => (e instanceof Error ? e.message : t('حدث خطأ'))

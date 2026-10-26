import { EN, EN_PATTERNS, EN_SERVER } from './en'

export type Lang = 'ar' | 'en'

const STORAGE_KEY = 'lang'

function readLang(): Lang {
  try {
    return localStorage.getItem(STORAGE_KEY) === 'en' ? 'en' : 'ar'
  } catch {
    return 'ar'
  }
}

/**
 * The language is fixed for the lifetime of the page: changing it reloads the app, so every label, date and
 * number (including module-level constants) is produced in one language and no component has to subscribe.
 */
export const lang: Lang = readLang()
export const isEn = lang === 'en'
export const dir = isEn ? 'ltr' : 'rtl'

export function setLang(next: Lang) {
  try {
    localStorage.setItem(STORAGE_KEY, next)
  } catch {
    /* ignore */
  }
  window.location.reload()
}

/**
 * Translates an Arabic source string. Arabic is the key (and the default), English comes from the dictionary.
 * `{0}`, `{1}` are replaced by the extra arguments. An English entry may hold singular|plural; the first
 * numeric argument picks the form.
 */
export function t(key: string, ...args: (string | number | null | undefined)[]): string {
  let s = isEn ? EN[key] ?? key : key
  if (s.includes('|') && isEn) {
    const n = args.find((a) => typeof a === 'number')
    const [one, many] = s.split('|')
    s = n === 1 ? one : many
  }
  return args.length ? s.replace(/\{(\d+)\}/g, (_, i) => String(args[+i] ?? '')) : s
}

/** Messages that come from the server (always Arabic): exact match first, then known sentence patterns. */
export function tServer(msg: string): string {
  if (!isEn) return msg
  if (EN_SERVER[msg] ?? EN[msg]) return EN_SERVER[msg] ?? EN[msg]
  for (const [re, out] of EN_PATTERNS) {
    const m = msg.match(re)
    if (m) {
      const text = out.replace(/\{(\d+)\}/g, (_, i) => EN[m[+i + 1]] ?? m[+i + 1] ?? '')
      return m[1] === '1' ? text.replace(/\binvoices\b/, 'invoice') : text
    }
  }
  return msg
}

/** Arrow for "from → to" in the reading direction. */
export const ARROW = isEn ? '→' : '←'

/** Locale for Intl formatting; digits stay Western in both languages. */
export const LOCALE = isEn ? 'en-GB-u-nu-latn' : 'ar-SA-u-nu-latn'
export const LOCALE_GREG = isEn ? 'en-GB-u-nu-latn-ca-gregory' : 'ar-SA-u-nu-latn-ca-gregory'

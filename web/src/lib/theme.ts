export type ThemePref = 'light' | 'dark' | 'system'

const media = () => window.matchMedia('(prefers-color-scheme: dark)')

export function getThemePref(): ThemePref {
  try {
    const t = localStorage.getItem('theme')
    return t === 'light' || t === 'dark' ? t : 'system'
  } catch {
    return 'system'
  }
}

export function applyTheme(pref: ThemePref = getThemePref()) {
  const dark = pref === 'dark' || (pref === 'system' && media().matches)
  document.documentElement.classList.toggle('dark', dark)
  document.querySelectorAll('meta[name="theme-color"]').forEach((m) => {
    m.setAttribute('content', dark ? '#0b0f17' : '#f4f5f9')
    m.removeAttribute('media')
  })
}

export function setThemePref(pref: ThemePref) {
  try {
    localStorage.setItem('theme', pref)
  } catch {
    /* private mode: theme just won't persist */
  }
  applyTheme(pref)
}

export function watchSystemTheme() {
  media().addEventListener('change', () => {
    if (getThemePref() === 'system') applyTheme('system')
  })
}

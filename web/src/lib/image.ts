export interface LogoImage {
  dataUrl: string
  /** Backdrop to show behind the logo: light logos (e.g. off-white wordmarks) need a dark one. */
  bg: 'light' | 'dark'
}

const SVG_FALLBACK = 512

/** Loads an SVG at an explicit pixel size (browsers give size-less SVGs an unreliable intrinsic size). */
async function sizedSvgUrl(file: File, max: number): Promise<{ url: string; w: number; h: number }> {
  const doc = new DOMParser().parseFromString(await file.text(), 'image/svg+xml')
  const root = doc.documentElement
  if (root.nodeName.toLowerCase() !== 'svg') throw new Error('ملف SVG غير صالح')
  const vb = root.getAttribute('viewBox')?.trim().split(/[\s,]+/).map(Number)
  let w = vb && vb.length === 4 ? vb[2] : parseFloat(root.getAttribute('width') ?? '')
  let h = vb && vb.length === 4 ? vb[3] : parseFloat(root.getAttribute('height') ?? '')
  if (!(w > 0) || !(h > 0)) w = h = SVG_FALLBACK
  const scale = max / Math.max(w, h)
  w = Math.max(1, Math.round(w * scale))
  h = Math.max(1, Math.round(h * scale))
  root.setAttribute('width', String(w))
  root.setAttribute('height', String(h))
  const blob = new Blob([new XMLSerializer().serializeToString(root)], { type: 'image/svg+xml' })
  return { url: URL.createObjectURL(blob), w, h }
}

/**
 * Reads PNG/JPG/WebP/SVG and returns a PNG data URL no larger than `max` px (keeps transparency).
 * SVG is rasterized here, so the server never stores or serves SVG.
 */
export async function fileToLogo(file: File, max = 256): Promise<LogoImage> {
  const isSvg = file.type === 'image/svg+xml' || /\.svg$/i.test(file.name)
  if (!isSvg && !file.type.startsWith('image/')) throw new Error('اختر صورة بصيغة PNG أو JPG أو WebP أو SVG')

  let url: string
  let size: { w: number; h: number } | null = null
  if (isSvg) {
    const s = await sizedSvgUrl(file, max)
    url = s.url
    size = s
  } else {
    url = URL.createObjectURL(file)
  }
  try {
    const img = await new Promise<HTMLImageElement>((resolve, reject) => {
      const i = new Image()
      i.onload = () => resolve(i)
      i.onerror = () => reject(new Error('تعذّر قراءة الصورة'))
      i.src = url
    })
    let w = size?.w
    let h = size?.h
    if (!w || !h) {
      const scale = Math.min(1, max / Math.max(img.naturalWidth, img.naturalHeight))
      w = Math.max(1, Math.round(img.naturalWidth * scale))
      h = Math.max(1, Math.round(img.naturalHeight * scale))
    }
    const canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext('2d', { willReadFrequently: true })
    if (!ctx) throw new Error('تعذّر معالجة الصورة')
    ctx.drawImage(img, 0, 0, w, h)
    return { dataUrl: canvas.toDataURL('image/png'), bg: detectBackdrop(ctx, w, h) }
  } finally {
    URL.revokeObjectURL(url)
  }
}

/** Transparent logos with mostly light pixels get a dark backdrop. Opaque images bring their own background. */
function detectBackdrop(ctx: CanvasRenderingContext2D, w: number, h: number): 'light' | 'dark' {
  const { data } = ctx.getImageData(0, 0, w, h)
  let opaque = 0
  let visible = 0
  let lum = 0
  for (let i = 0; i < data.length; i += 4) {
    const a = data[i + 3]
    if (a > 200) opaque++
    if (a > 40) {
      visible++
      lum += (0.2126 * data[i] + 0.7152 * data[i + 1] + 0.0722 * data[i + 2]) / 255
    }
  }
  const pixels = data.length / 4
  if (!visible || opaque / pixels > 0.9) return 'light'
  return lum / visible > 0.75 ? 'dark' : 'light'
}

/** Reads an image file and returns a PNG data URL no larger than `max` px on either side (keeps transparency). */
export async function fileToLogoDataUrl(file: File, max = 256): Promise<string> {
  if (!file.type.startsWith('image/') || file.type === 'image/svg+xml') throw new Error('اختر صورة بصيغة PNG أو JPG أو WebP')
  const url = URL.createObjectURL(file)
  try {
    const img = await new Promise<HTMLImageElement>((resolve, reject) => {
      const i = new Image()
      i.onload = () => resolve(i)
      i.onerror = () => reject(new Error('تعذّر قراءة الصورة'))
      i.src = url
    })
    const scale = Math.min(1, max / Math.max(img.naturalWidth, img.naturalHeight))
    const w = Math.max(1, Math.round(img.naturalWidth * scale))
    const h = Math.max(1, Math.round(img.naturalHeight * scale))
    const canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext('2d')
    if (!ctx) throw new Error('تعذّر معالجة الصورة')
    ctx.drawImage(img, 0, 0, w, h)
    return canvas.toDataURL('image/png')
  } finally {
    URL.revokeObjectURL(url)
  }
}

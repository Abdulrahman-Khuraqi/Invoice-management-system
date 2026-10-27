/** Rasterizes the invoice paper and saves it as PNG or PDF. html2canvas/jsPDF load only when needed. */

// Mobile browsers cap canvas size (iOS Safari: ~16.7M pixels), so long invoices render at a lower scale.
const MAX_PIXELS = 12_000_000
const A4_MM = { w: 210, h: 297 }

async function settle(el: HTMLElement) {
  await document.fonts?.ready
  await Promise.all(
    [...el.querySelectorAll('img')].map((img) => (img.complete ? null : new Promise((r) => { img.onload = img.onerror = () => r(null) }))),
  )
}

async function render(el: HTMLElement) {
  await settle(el)
  const { default: html2canvas } = await import('html2canvas-pro')
  const scale = Math.min(3, Math.sqrt(MAX_PIXELS / (el.offsetWidth * el.offsetHeight)))
  return html2canvas(el, { scale, backgroundColor: '#ffffff', useCORS: true, logging: false })
}

const toBlob = (canvas: HTMLCanvasElement, type: string, quality?: number) =>
  new Promise<Blob>((resolve, reject) => canvas.toBlob((b) => (b ? resolve(b) : reject(new Error('تعذّر إنشاء الملف'))), type, quality))

/** Phones: open the share sheet (Save Image / Save to Files). Everything else: a normal download. */
async function save(blob: Blob, filename: string) {
  const file = new File([blob], filename, { type: blob.type })
  if (window.matchMedia('(pointer: coarse)').matches && navigator.canShare?.({ files: [file] })) {
    try {
      await navigator.share({ files: [file], title: filename })
      return
    } catch (e) {
      if ((e as Error).name === 'AbortError') return
      // Share not allowed (e.g. user gesture expired): fall back to a download.
    }
  }
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  a.remove()
  window.setTimeout(() => URL.revokeObjectURL(url), 10_000)
}

export async function exportPaperPng(el: HTMLElement, name: string) {
  const canvas = await render(el)
  await save(await toBlob(canvas, 'image/png'), `${name}.png`)
}

/** One page, A4 wide. An invoice longer than A4 gets a taller page rather than being split. */
export async function exportPaperPdf(el: HTMLElement, name: string) {
  const canvas = await render(el)
  const { jsPDF } = await import('jspdf')
  const imgH = (A4_MM.w * canvas.height) / canvas.width
  const pdf = new jsPDF({ unit: 'mm', format: [A4_MM.w, Math.max(A4_MM.h, imgH)], orientation: 'portrait', compress: true })
  pdf.addImage(canvas.toDataURL('image/jpeg', 0.95), 'JPEG', 0, 0, A4_MM.w, imgH)
  await save(pdf.output('blob'), `${name}.pdf`)
}

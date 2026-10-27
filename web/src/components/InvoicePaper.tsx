import { useEffect, useLayoutEffect, useMemo, useRef, useState, type CSSProperties } from 'react'
import { createPortal } from 'react-dom'
import { errorMessage } from '../api'
import { exportPaperPdf, exportPaperPng } from '../lib/invoiceExport'
import { buildPaperData, paperFileName, paperMoney, templateFor, type PaperTemplate } from '../lib/invoicePaper'
import type { Invoice } from '../types'
import { useFeedback } from './Feedback'
import './invoice-paper.css'

const PAPER_WIDTH = 794

/** Logo/seal files live in web/public/; a missing file just leaves that spot empty. */
function PaperImage({ src, className, alt }: { src?: string; className: string; alt: string }) {
  const [failed, setFailed] = useState(false)
  if (!src || failed) return null
  return <img src={`${import.meta.env.BASE_URL}${src}`} alt={alt} className={className} onError={() => setFailed(true)} />
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div className="ip-field">
      <span className="ip-field-label">{label}</span>
      <span className="ip-field-value" dir="auto">
        {value}
      </span>
    </div>
  )
}

/** The invoice as a sheet of paper. Fixed 794px wide; scale it with a transform to fit a screen. */
export function InvoicePaper({ invoice, template }: { invoice: Invoice; template: PaperTemplate }) {
  const d = useMemo(() => buildPaperData(invoice, template), [invoice, template])
  const cur = template.currency
  return (
    <div className="ip" style={{ '--ip-primary': template.color, '--ip-logo-h': `${template.logoHeight ?? 52}px`, '--ip-seal-w': `${template.sealWidth ?? 250}px` } as CSSProperties}>
      <header>
        <div className="ip-brand">{template.company}</div>
        <div className="ip-head-row">
          <h1 className="ip-title">{template.title}</h1>
          <PaperImage src={template.logo} alt={template.company} className="ip-logo" />
        </div>
        <div className="ip-rule" />
      </header>

      <section className="ip-parties">
        <div className="ip-block">
          <div className="ip-meta">
            <div className="ip-meta-item">
              <span className="ip-meta-label">Invoice Number:</span>
              <span className="ip-meta-value ip-num">{d.number}</span>
            </div>
            <div className="ip-meta-item">
              <span className="ip-meta-label">Invoice Date:</span>
              <span className="ip-meta-value ip-num">{d.date}</span>
            </div>
          </div>
          <h3 dir="auto">{template.company}</h3>
          {template.email && <div className="ip-company-info">{template.email}</div>}
        </div>
        <div className="ip-block">
          <h3>Bill To</h3>
          <Field label="Customer Name" value={d.customer} />
          <Field label="Email" value={d.email} />
        </div>
      </section>

      <table className="ip-table">
        <thead>
          <tr>
            <th className="ip-col-desc">Item &amp; Description</th>
            <th className="ip-col-price">Unit Price</th>
            <th className="ip-col-qty">Qty</th>
            <th className="ip-col-amount">Amount</th>
          </tr>
        </thead>
        <tbody>
          {d.rows.map((r, i) => (
            <tr key={i}>
              <td className="ip-col-desc">
                <div dir="auto">
                  {r.description}
                </div>
                {r.note && (
                  <div className="ip-item-note" dir="auto">
                    {r.note}
                  </div>
                )}
              </td>
              <td className="ip-col-price ip-num">
                {paperMoney(r.unitPrice)} {cur}
              </td>
              <td className="ip-col-qty ip-num">{r.qty}</td>
              <td className="ip-col-amount ip-num">
                {paperMoney(r.amount)} {cur}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <table className="ip-totals">
        <tbody>
          <tr>
            <td>Sub-Total</td>
            <td className="ip-num">
              {paperMoney(d.subTotal)} {cur}
            </td>
          </tr>
          <tr>
            <td>Discount</td>
            <td className="ip-num">
              {paperMoney(d.discount)} {cur}
            </td>
          </tr>
          <tr className="ip-total-row">
            <td>Total</td>
            <td className="ip-num">
              {paperMoney(d.total)} {cur}
            </td>
          </tr>
        </tbody>
      </table>

      <footer className="ip-footer">
        <PaperImage src={template.seal} alt={`Company Seal - ${template.company}`} className="ip-seal" />
      </footer>
    </div>
  )
}

/** Paper scaled down to the width of its container (phones show it as a shrunken A4 page). */
export function InvoicePaperPreview({ invoice }: { invoice: Invoice }) {
  const template = useMemo(() => templateFor(invoice.store_name), [invoice.store_name])
  const box = useRef<HTMLDivElement>(null)
  const paper = useRef<HTMLDivElement>(null)
  const [size, setSize] = useState({ scale: 1, height: 1123 })

  useLayoutEffect(() => {
    const measure = () => {
      if (!box.current || !paper.current) return
      const scale = Math.min(1, box.current.clientWidth / PAPER_WIDTH)
      setSize({ scale, height: paper.current.offsetHeight * scale })
    }
    measure()
    const ro = new ResizeObserver(measure)
    ro.observe(box.current!)
    ro.observe(paper.current!)
    return () => ro.disconnect()
  }, [invoice])

  return (
    // dir=ltr: in the RTL app the fixed-width paper would otherwise overflow to the left of its box.
    <div ref={box} dir="ltr" className="w-full overflow-hidden rounded-xl shadow-card ring-1 ring-line" style={{ height: size.height }}>
      <div ref={paper} style={{ width: PAPER_WIDTH, transform: `scale(${size.scale})`, transformOrigin: 'top left' }}>
        <InvoicePaper invoice={invoice} template={template} />
      </div>
    </div>
  )
}

export type PaperExportKind = 'png' | 'pdf'

/**
 * Exports render a separate, unscaled copy of the paper off-screen, so the file is always
 * full resolution regardless of how small the preview is. Render `host` somewhere in the tree.
 */
export function useInvoicePaperExport(invoice: Invoice | null) {
  const { toast } = useFeedback()
  const [job, setJob] = useState<PaperExportKind | null>(null)
  const hostRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!job || !invoice) return
    const paper = hostRef.current?.firstElementChild as HTMLElement | null
    if (!paper) return
    const template = templateFor(invoice.store_name)
    const name = paperFileName(template, buildPaperData(invoice, template))
    ;(job === 'png' ? exportPaperPng : exportPaperPdf)(paper, name)
      .catch((e) => toast(errorMessage(e), 'error'))
      .finally(() => setJob(null))
  }, [job, invoice, toast])

  const host =
    job && invoice
      ? createPortal(
          <div ref={hostRef} aria-hidden="true" style={{ position: 'fixed', top: 0, left: -10000, pointerEvents: 'none' }}>
            <InvoicePaper invoice={invoice} template={templateFor(invoice.store_name)} />
          </div>,
          document.body,
        )
      : null

  return { exporting: job, exportAs: setJob, host }
}

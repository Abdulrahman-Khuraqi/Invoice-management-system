import { forwardRef, useCallback } from 'react'
import { NavLink as RouterNavLink, useNavigate as useRouterNavigate, type NavLinkProps, type NavigateOptions, type To } from 'react-router-dom'

/**
 * Navigation that animates between pages with the browser's View Transitions API: the old page slides away
 * while the new one slides in (see index.css), with the top bar and bottom tabs staying put. Where the API
 * isn't available, or the user asked for reduced motion, it just navigates and the plain CSS entrance is used.
 *
 * Use these instead of react-router's `useNavigate` / `NavLink`.
 */

let finish: (() => void) | null = null

const supported = () =>
  typeof document !== 'undefined' &&
  typeof (document as Document & { startViewTransition?: unknown }).startViewTransition === 'function' &&
  !window.matchMedia('(prefers-reduced-motion: reduce)').matches

/** True while a view transition is waiting for the new page to be rendered. */
export const transitionPending = () => finish !== null

/** Called by RouteEffects once the new page is in the DOM; lets the browser take the "after" snapshot. */
export function transitionReady() {
  finish?.()
  finish = null
}

function withTransition(change: () => void) {
  if (!supported() || finish) return change()
  ;(document as Document & { startViewTransition: (cb: () => Promise<void>) => unknown }).startViewTransition(
    () =>
      new Promise<void>((resolve) => {
        // Safety net: a navigation that renders no new location (same page) must not leave the screen frozen.
        const timer = window.setTimeout(() => transitionReady(), 600)
        finish = () => {
          window.clearTimeout(timer)
          resolve()
        }
        change()
      }),
  )
}

const currentPath = () => window.location.hash.replace(/^#/, '').split('?')[0] || '/'
const targetPath = (to: To) => (typeof to === 'string' ? to : to.pathname ?? '').split('?')[0].split('#')[0]

export function useNavigate() {
  const navigate = useRouterNavigate()
  return useCallback(
    (to: To | number, options?: NavigateOptions) => {
      const go = () => (typeof to === 'number' ? navigate(to) : navigate(to, options))
      // Only a change of page is animated; changing a filter or query on the same page is not.
      if (typeof to !== 'number' && (options?.replace || targetPath(to) === currentPath())) return go()
      withTransition(go)
    },
    [navigate],
  )
}

/** Router NavLink whose plain clicks go through the transition. */
export const NavLink = forwardRef<HTMLAnchorElement, NavLinkProps>(function NavLink({ onClick, to, ...rest }, ref) {
  const navigate = useNavigate()
  return (
    <RouterNavLink
      {...rest}
      to={to}
      ref={ref}
      onClick={(e) => {
        onClick?.(e)
        if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey || (rest.target && rest.target !== '_self')) return
        e.preventDefault()
        navigate(to)
      }}
    />
  )
})

import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'
import { api } from './api'
import { load, save } from './lib/storage'
import type { CatalogItem, Category, Role, Store, User } from './types'

const RANK: Record<Role, number> = { viewer: 1, editor: 2, admin: 3 }

interface AppState {
  user: User
  setUser: (u: User | null) => void
  can: (role: Role) => boolean
  stores: Store[]
  activeStores: Store[]
  storeById: (id: number | null | undefined) => Store | undefined
  categories: Category[]
  items: CatalogItem[]
  /** Store chosen in the top switcher (null = all stores). */
  currentStore: number | null
  setCurrentStore: (id: number | null) => void
  reloadStores: () => Promise<void>
  reloadCatalog: () => Promise<void>
}

const Ctx = createContext<AppState | null>(null)

export function AppProvider({ user, setUser, children }: { user: User; setUser: (u: User | null) => void; children: ReactNode }) {
  const [stores, setStores] = useState<Store[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [items, setItems] = useState<CatalogItem[]>([])
  const [currentStore, setCurrent] = useState<number | null>(() => load<number | null>('currentStore', null))

  const reloadStores = useCallback(async () => {
    const r = await api<{ stores: Store[] }>('stores')
    setStores(r.stores)
  }, [])
  const reloadCatalog = useCallback(async () => {
    const [c, i] = await Promise.all([
      api<{ categories: Category[] }>('catalog/categories'),
      api<{ items: CatalogItem[] }>('catalog/items', { query: { include_inactive: 1 } }),
    ])
    setCategories(c.categories)
    setItems(i.items)
  }, [])

  useEffect(() => {
    reloadStores().catch(() => {})
    reloadCatalog().catch(() => {})
  }, [reloadStores, reloadCatalog])

  // Forget a switcher choice that points to a store that no longer exists or was archived.
  useEffect(() => {
    if (stores.length && currentStore !== null && !stores.some((s) => s.id === currentStore && s.is_active)) {
      setCurrent(null)
      save('currentStore', null)
    }
  }, [stores, currentStore])

  const value = useMemo<AppState>(
    () => ({
      user,
      setUser,
      can: (role) => RANK[user.role] >= RANK[role],
      stores,
      activeStores: stores.filter((s) => s.is_active),
      storeById: (id) => stores.find((s) => s.id === id),
      categories,
      items,
      currentStore,
      setCurrentStore: (id) => {
        setCurrent(id)
        save('currentStore', id)
      },
      reloadStores,
      reloadCatalog,
    }),
    [user, setUser, stores, categories, items, currentStore, reloadStores, reloadCatalog],
  )
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>
}

export function useApp() {
  const v = useContext(Ctx)
  if (!v) throw new Error('useApp outside AppProvider')
  return v
}

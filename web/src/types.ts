export type Role = 'admin' | 'editor' | 'viewer'

export interface User {
  id: number
  username: string
  display_name: string
  role: Role
  is_active: boolean
  store_ids: number[]
  created_at?: string
  last_login_at?: string | null
}

export interface Terminal {
  terminal_id: string
  label: string | null
}

export interface Store {
  id: number
  name: string
  color: string
  is_active: boolean
  sort: number
  invoice_count: number
  /** Version stamp of the uploaded logo (used in its URL); null = no logo. */
  logo_v: number | null
  terminals: Terminal[]
}

export interface Category {
  id: number
  name: string
  color: string
  sort: number
  item_count: number
}

export type ItemKind = 'service' | 'product'

export interface CatalogItem {
  id: number
  kind: ItemKind
  name: string
  description: string | null
  category_id: number | null
  store_id: number | null
  default_price: number | null
  sku: string | null
  is_active: boolean
  category_name: string | null
  category_color: string | null
  store_name: string | null
  usage_count: number
}

export interface InvoiceLine {
  item_id: number
  name: string
  kind: ItemKind
  is_active: boolean
  qty: number
  unit_price: number
  line_note: string | null
  category_name: string | null
  category_color: string | null
}

export interface Invoice {
  id: number
  store_id: number
  transaction_id: string | null
  invoice_no: string | null
  customer_name: string | null
  email: string | null
  phone: string | null
  amount: number
  status: string
  pay_method: string | null
  card_type: string | null
  card_last4: string | null
  terminal_id: string | null
  reference_no: string | null
  auth_code: string | null
  created_at_src: string | null
  paid_at: string | null
  note: string | null
  source: 'import' | 'manual'
  created_at: string
  updated_at: string
  store_name: string
  store_color: string
  created_by_name: string | null
  updated_by_name: string | null
  lines: InvoiceLine[]
}

export interface InvoiceList {
  invoices: Invoice[]
  total: number
  sum: number
  page: number
  per_page: number
}

export interface StatRow {
  id?: number
  name?: string
  color?: string
  kind?: ItemKind
  day?: string
  n: number
  total: number
}

export interface Stats {
  count: number
  sum: number
  unclassified: number
  unclassified_sum: number
  by_store: StatRow[]
  by_item: StatRow[]
  by_category: StatRow[]
  by_kind: StatRow[]
  daily: StatRow[]
}

export interface Activity {
  id: number
  action: string
  entity: string
  entity_id: number | null
  summary: string | null
  created_at: string
  user_name: string | null
}

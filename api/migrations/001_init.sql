-- Initial schema. Plain MariaDB/MySQL SQL that runs on Hostinger shared hosting:
-- InnoDB + utf8mb4, no triggers/procedures/JSON columns, indexed VARCHARs <= 191.

CREATE TABLE IF NOT EXISTS stores (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  color VARCHAR(16) NOT NULL DEFAULT '#6366f1',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS store_terminals (
  terminal_id VARCHAR(64) NOT NULL,
  store_id INT UNSIGNED NOT NULL,
  label VARCHAR(120) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (terminal_id),
  KEY idx_terminal_store (store_id),
  CONSTRAINT fk_terminal_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(64) NOT NULL,
  display_name VARCHAR(120) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','editor','viewer') NOT NULL DEFAULT 'viewer',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_login_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional per-user store restriction. No rows for a user = access to all stores.
CREATE TABLE IF NOT EXISTS user_stores (
  user_id INT UNSIGNED NOT NULL,
  store_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, store_id),
  KEY idx_us_store (store_id),
  CONSTRAINT fk_us_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_us_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS catalog_categories (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  color VARCHAR(16) NOT NULL DEFAULT '#0ea5e9',
  sort INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Services and products an invoice can be "for". store_id NULL = shared by all stores.
CREATE TABLE IF NOT EXISTS catalog_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kind ENUM('service','product') NOT NULL DEFAULT 'service',
  name VARCHAR(160) NOT NULL,
  description VARCHAR(500) NULL,
  category_id INT UNSIGNED NULL,
  store_id INT UNSIGNED NULL,
  default_price DECIMAL(12,2) NULL,
  sku VARCHAR(64) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_item_store (store_id),
  KEY idx_item_category (category_id),
  KEY idx_item_name (name),
  CONSTRAINT fk_item_category FOREIGN KEY (category_id) REFERENCES catalog_categories (id) ON DELETE SET NULL,
  CONSTRAINT fk_item_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS invoices (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  store_id INT UNSIGNED NOT NULL,
  transaction_id VARCHAR(64) NULL,
  invoice_no VARCHAR(64) NULL,
  customer_name VARCHAR(160) NULL,
  email VARCHAR(160) NULL,
  phone VARCHAR(40) NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  status VARCHAR(40) NOT NULL DEFAULT 'Paid',
  pay_method VARCHAR(40) NULL,
  card_type VARCHAR(40) NULL,
  card_last4 VARCHAR(8) NULL,
  terminal_id VARCHAR(64) NULL,
  reference_no VARCHAR(64) NULL,
  auth_code VARCHAR(32) NULL,
  created_at_src DATETIME NULL,
  paid_at DATETIME NULL,
  note TEXT NULL,
  source ENUM('import','manual') NOT NULL DEFAULT 'manual',
  created_by INT UNSIGNED NULL,
  updated_by INT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_transaction (transaction_id),
  KEY idx_inv_store_paid (store_id, paid_at),
  KEY idx_inv_paid (paid_at),
  KEY idx_inv_no (invoice_no),
  KEY idx_inv_phone (phone),
  KEY idx_inv_ref (reference_no),
  CONSTRAINT fk_inv_store FOREIGN KEY (store_id) REFERENCES stores (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Which services/products each invoice is for. No rows = "unclassified".
CREATE TABLE IF NOT EXISTS invoice_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_id INT UNSIGNED NOT NULL,
  item_id INT UNSIGNED NOT NULL,
  qty DECIMAL(10,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  line_note VARCHAR(255) NULL,
  PRIMARY KEY (id),
  KEY idx_ii_invoice (invoice_id),
  KEY idx_ii_item (item_id),
  CONSTRAINT fk_ii_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE,
  CONSTRAINT fk_ii_item FOREIGN KEY (item_id) REFERENCES catalog_items (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS activity_log (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NULL,
  action VARCHAR(40) NOT NULL,
  entity VARCHAR(40) NOT NULL,
  entity_id INT UNSIGNED NULL,
  summary VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_log_created (created_at),
  KEY idx_log_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS login_attempts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  ip VARCHAR(64) NOT NULL,
  attempted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_login_ip (ip, attempted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Initial data: only a starting point; everything is editable from the app.
-- INSERT IGNORE with fixed ids keeps this safe to re-run if a first attempt was interrupted.
INSERT IGNORE INTO stores (id, name, color, sort) VALUES
  (1, 'ARVO', '#7c3aed', 1),
  (2, 'X Run Studio', '#0ea5e9', 2),
  (3, 'anas', '#f59e0b', 3);

INSERT IGNORE INTO store_terminals (terminal_id, store_id) VALUES
  ('900000005043', 1),
  ('900000005316', 1),
  ('900000005166', 2),
  ('900000005268', 2),
  ('900000005223', 3);

INSERT IGNORE INTO catalog_categories (id, name, color, sort) VALUES
  (1, 'خدمات', '#0ea5e9', 1),
  (2, 'منتجات', '#10b981', 2),
  (3, 'اشتراكات', '#8b5cf6', 3),
  (4, 'أخرى', '#64748b', 4);

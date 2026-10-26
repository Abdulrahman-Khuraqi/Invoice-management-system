-- Contact / business details per store (all optional). Own table so no ALTER on `stores` is needed.

CREATE TABLE IF NOT EXISTS store_info (
  store_id INT UNSIGNED NOT NULL,
  website VARCHAR(255) NULL,
  phone VARCHAR(60) NULL,
  whatsapp VARCHAR(60) NULL,
  email VARCHAR(150) NULL,
  address VARCHAR(255) NULL,
  cr_number VARCHAR(40) NULL,
  vat_number VARCHAR(40) NULL,
  notes VARCHAR(1000) NULL,
  PRIMARY KEY (store_id),
  CONSTRAINT fk_info_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

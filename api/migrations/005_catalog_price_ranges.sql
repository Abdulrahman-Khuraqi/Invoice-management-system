-- Optional price range (lowest / highest usual price) per service or product.
-- Own table so no ALTER on `catalog_items` is needed; `default_price` stays the price pre-filled on an invoice.

CREATE TABLE IF NOT EXISTS catalog_item_ranges (
  item_id INT UNSIGNED NOT NULL,
  price_min DECIMAL(12,2) NOT NULL,
  price_max DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (item_id),
  CONSTRAINT fk_range_item FOREIGN KEY (item_id) REFERENCES catalog_items (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

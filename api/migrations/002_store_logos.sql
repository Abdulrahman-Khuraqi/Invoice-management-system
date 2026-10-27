-- Optional logo per store. Stored in the database (not on disk) so it survives FTP deploys
-- and needs no writable folder on shared hosting. Kept in its own table so the stores list stays light.

CREATE TABLE IF NOT EXISTS store_logos (
  store_id INT UNSIGNED NOT NULL,
  mime VARCHAR(32) NOT NULL,
  bg ENUM('light','dark') NOT NULL DEFAULT 'light', -- backdrop to show behind the logo (light logos need a dark one)
  data MEDIUMBLOB NOT NULL,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (store_id),
  CONSTRAINT fk_logo_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

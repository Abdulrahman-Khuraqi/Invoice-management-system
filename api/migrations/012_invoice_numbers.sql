-- System-generated invoice numbers like ARV-261009-0001 (store code - invoice date YYMMDD - daily counter).
-- Separate from invoices.invoice_no, which holds the payment gateway's / user-typed number and stays editable.
-- New tables only (no ALTER on existing ones), like the other migrations.

-- 2-4 letter code per store; the prefix of its invoice numbers. Created from the store name on first use.
CREATE TABLE IF NOT EXISTS store_codes (
  store_id INT UNSIGNED NOT NULL,
  code VARCHAR(8) NOT NULL,
  PRIMARY KEY (store_id),
  CONSTRAINT fk_code_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One permanent number per invoice. UNIQUE is the guarantee that two invoices never share a number.
CREATE TABLE IF NOT EXISTS invoice_numbers (
  invoice_id INT UNSIGNED NOT NULL,
  doc_no VARCHAR(32) NOT NULL,
  PRIMARY KEY (invoice_id),
  UNIQUE KEY uq_doc_no (doc_no),
  CONSTRAINT fk_docno_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Last counter used per "CODE-YYMMDD". Only ever goes up, so a deleted invoice's number is never handed out again.
CREATE TABLE IF NOT EXISTS invoice_counters (
  k VARCHAR(24) NOT NULL,
  n INT UNSIGNED NOT NULL,
  PRIMARY KEY (k)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

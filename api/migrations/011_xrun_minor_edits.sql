-- X Run Studio: the two 100 SAR invoices (586 and 196) are below every service's minimum price.
-- They are small design edits, so add a matching service and link them to it. Amounts are not changed.
-- Each invoice is found by its unique transaction number (رقم العملية); invoices that already have a service are skipped.

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تعديلات بسيطة على تصميم', 'تعديلات صغيرة على تصميم موجود', NULL, s.id, 100 FROM stores s
WHERE s.name = 'X Run Studio' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تعديلات بسيطة على تصميم');

INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 50, 300 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name = 'X Run Studio' AND x.name = 'تعديلات بسيطة على تصميم'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, 100.00
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديلات بسيطة على تصميم'
WHERE s.name = 'X Run Studio' AND i.transaction_id IN ('44124935a1fb43268fc0d5ff8a71c001', '5e73f982af0240298a55d959f1843264') AND i.amount = 100.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

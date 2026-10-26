-- Test run for the "anas" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices without a hand-made classification are touched. Every line is tagged 'اقتراح تلقائي' in its note so the whole
-- test can be undone with:  DELETE FROM invoice_items WHERE line_note = 'اقتراح تلقائي';
-- Items are matched by name inside the store, so anything missing from the live catalog is simply skipped.

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 10000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تطوير تجربة ألعاب متكاملة (باقة تجربة الألعاب)'
WHERE s.name = 'anas' AND i.invoice_no = '1010' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '1010' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '1001' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '995' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '995' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'عنصر ثلاثي الأبعاد إضافي'
WHERE s.name = 'anas' AND i.invoice_no = '995' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '993' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '993' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '987' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '918' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '927' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'استشارة تطوير ألعاب'
WHERE s.name = 'anas' AND i.invoice_no = '914' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '916' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '617' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '617' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '615' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '615' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1289.16, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '582' AND i.amount = 1289.16
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1286.21, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '570' AND i.amount = 1286.21
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5853.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '528' AND i.amount = 5853.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1427.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '503' AND i.amount = 1427.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

-- فاتورة 487 (10): المبلغ أقل من أي نطاق سعر، تُترك غير مصنّفة

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '432' AND i.amount = 2989.22
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 989.22, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'استشارة تطوير ألعاب'
WHERE s.name = 'anas' AND i.invoice_no = '432' AND i.amount = 2989.22
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '394' AND i.amount = 2896.11
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 896.11, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '394' AND i.amount = 2896.11
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '374' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1387.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '374' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '373' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 887.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'استشارة تطوير ألعاب'
WHERE s.name = 'anas' AND i.invoice_no = '373' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1528.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '370' AND i.amount = 3056.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1528.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '370' AND i.amount = 3056.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1512.50, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '336' AND i.amount = 3025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1512.50, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '336' AND i.amount = 3025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5714.29, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '312' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2285.71, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '312' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2001.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '289' AND i.amount = 2001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5001.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '274' AND i.amount = 5001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.50, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '273' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.50, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '273' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '254' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5002.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '235' AND i.amount = 5002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1550.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '230' AND i.amount = 1550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.50, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '226' AND i.amount = 4001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.38, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '226' AND i.amount = 4001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 500.12, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'شاشة واجهة إضافية'
WHERE s.name = 'anas' AND i.invoice_no = '226' AND i.amount = 4001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1581.60, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '199' AND i.amount = 2636.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1054.40, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'استشارة تطوير ألعاب'
WHERE s.name = 'anas' AND i.invoice_no = '199' AND i.amount = 2636.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '195' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '194' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '193' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1078.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '176' AND i.amount = 1078.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '163' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '163' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '162' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'استشارة تطوير ألعاب'
WHERE s.name = 'anas' AND i.invoice_no = '162' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
WHERE s.name = 'anas' AND i.invoice_no = '161' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1500.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
WHERE s.name = 'anas' AND i.invoice_no = '161' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2461.14, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '150' AND i.amount = 4307.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1845.86, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
WHERE s.name = 'anas' AND i.invoice_no = '150' AND i.amount = 4307.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2163.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '143' AND i.amount = 2163.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5034.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '125' AND i.amount = 5034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 7034.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '124' AND i.amount = 7034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1550.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
WHERE s.name = 'anas' AND i.invoice_no = '105' AND i.amount = 1550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 2040.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
WHERE s.name = 'anas' AND i.invoice_no = '100' AND i.amount = 2550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 510.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'عنصر ثلاثي الأبعاد إضافي'
WHERE s.name = 'anas' AND i.invoice_no = '100' AND i.amount = 2550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 5000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
WHERE s.name = 'anas' AND i.invoice_no = '71' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note)
SELECT i.id, ci.id, 1, 1000.00, 'اقتراح تلقائي'
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = 'تعديل وتطوير لعبة قائمة'
WHERE s.name = 'anas' AND i.invoice_no = '48' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id AND (k.line_note IS NULL OR k.line_note <> 'اقتراح تلقائي'));

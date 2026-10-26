-- Test run for the "anas" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices that have no services yet are touched, so nothing classified by hand is overwritten.
-- Items are matched by name inside the store, so anything missing from the live catalog is simply skipped.

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير تجربة ألعاب متكاملة (باقة تجربة الألعاب)' AS item_name, 10000.00 AS price
    UNION ALL SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '1010' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '1001' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
    UNION ALL SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'عنصر ثلاثي الأبعاد إضافي' AS item_name, 500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '995' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '993' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '987' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '918' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '927' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تطوير ألعاب' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '914' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '916' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '617' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '615' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1289.16 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '582' AND i.amount = 1289.16
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1286.21 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '570' AND i.amount = 1286.21
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5853.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '528' AND i.amount = 5853.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1427.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '503' AND i.amount = 1427.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

-- فاتورة 487 (10 ريال): أقل من أي نطاق سعر، فتُصنَّف كعملية تجربة (اختبار) بدل خدمة حقيقية.
INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'عملية تجربة (Test)', 'دفعة اختبار بمبلغ رمزي، وليست خدمة فعلية', (SELECT id FROM catalog_categories WHERE name = 'أخرى' LIMIT 1), s.id, 10 FROM stores s
WHERE s.name = 'anas' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'عملية تجربة (Test)');

INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1, 100 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name = 'anas' AND x.name = 'عملية تجربة (Test)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, 10.00
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN catalog_items ci ON ci.store_id = s.id AND ci.name = 'عملية تجربة (Test)'
WHERE s.name = 'anas' AND i.invoice_no = '487' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
    UNION ALL SELECT 'استشارة تطوير ألعاب' AS item_name, 989.22 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '432' AND i.amount = 2989.22
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
    UNION ALL SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 896.11 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '394' AND i.amount = 2896.11
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1387.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '374' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
    UNION ALL SELECT 'استشارة تطوير ألعاب' AS item_name, 887.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '373' AND i.amount = 2887.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1528.00 AS price
    UNION ALL SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1528.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '370' AND i.amount = 3056.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1512.50 AS price
    UNION ALL SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1512.50 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '336' AND i.amount = 3025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5714.29 AS price
    UNION ALL SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2285.71 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '312' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '289' AND i.amount = 2001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '274' AND i.amount = 5001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1500.50 AS price
    UNION ALL SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1500.50 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '273' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '254' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '235' AND i.amount = 5002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1550.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '230' AND i.amount = 1550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.50 AS price
    UNION ALL SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.38 AS price
    UNION ALL SELECT 'شاشة واجهة إضافية' AS item_name, 500.12 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '226' AND i.amount = 4001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1581.60 AS price
    UNION ALL SELECT 'استشارة تطوير ألعاب' AS item_name, 1054.40 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '199' AND i.amount = 2636.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '195' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '194' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '193' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1078.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '176' AND i.amount = 1078.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '163' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
    UNION ALL SELECT 'استشارة تطوير ألعاب' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '162' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '161' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2461.14 AS price
    UNION ALL SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1845.86 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '150' AND i.amount = 4307.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2163.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '143' AND i.amount = 2163.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5034.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '125' AND i.amount = 5034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 7034.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '124' AND i.amount = 7034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1550.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '105' AND i.amount = 1550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2040.00 AS price
    UNION ALL SELECT 'عنصر ثلاثي الأبعاد إضافي' AS item_name, 510.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '100' AND i.amount = 2550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '71' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.invoice_no = '48' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

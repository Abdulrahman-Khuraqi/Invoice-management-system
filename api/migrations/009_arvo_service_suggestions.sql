-- Test run for the "ARVO" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices that have no services yet are touched, so nothing classified by hand is overwritten.
-- Items are matched by name inside the store, so anything missing from the live catalog is simply skipped.
-- Invoices below every service's minimum price (the 10-11 SAR ones) are classified as a test payment.

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'عملية تجربة (Test)', 'دفعة اختبار بمبلغ رمزي، وليست خدمة فعلية', (SELECT id FROM catalog_categories WHERE name = 'أخرى' LIMIT 1), s.id, 10 FROM stores s
WHERE s.name = 'ARVO' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'عملية تجربة (Test)');

INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1, 100 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name = 'ARVO' AND x.name = 'عملية تجربة (Test)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '27' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير تطبيقات الجوال (iOS وAndroid)' AS item_name, 5699.04 AS price
    UNION ALL SELECT 'برمجة موقع إلكتروني' AS item_name, 7897.55 AS price
    UNION ALL SELECT 'تطوير متجر إلكتروني' AS item_name, 6403.41 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '11' AND i.amount = 20000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'حلول مدعومة بالذكاء الاصطناعي' AS item_name, 14000.00 AS price
    UNION ALL SELECT 'تقديم دعم فني' AS item_name, 6000.00 AS price
    UNION ALL SELECT 'التسويق الرقمي' AS item_name, 10000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '6' AND i.amount = 30000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '3' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 11.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '2' AND i.amount = 11.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1023.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1705' AND i.amount = 1023.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2500.00 AS price
    UNION ALL SELECT 'استضافة ونطاق (سنوي)' AS item_name, 500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1696' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1684' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1491.00 AS price
    UNION ALL SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2485.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1657' AND i.amount = 3976.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1273.21 AS price
    UNION ALL SELECT 'استشارة تقنية متخصصة' AS item_name, 2478.21 AS price
    UNION ALL SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2273.58 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1616' AND i.amount = 6025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'التسويق الرقمي' AS item_name, 3688.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1603' AND i.amount = 3688.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1601' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'حلول مدعومة بالذكاء الاصطناعي' AS item_name, 3625.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1596' AND i.amount = 3625.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1578' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1559' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1555' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1550' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1199.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1537' AND i.amount = 1199.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1089.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1426' AND i.amount = 1089.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تقديم دعم فني' AS item_name, 3058.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1378' AND i.amount = 3058.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 3085.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1350' AND i.amount = 3085.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1063.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1343' AND i.amount = 1063.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1079.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1308' AND i.amount = 1079.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1312' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير متجر إلكتروني' AS item_name, 5712.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1302' AND i.amount = 5712.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استضافة ونطاق (سنوي)' AS item_name, 550.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1298' AND i.amount = 550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1089.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1289' AND i.amount = 1089.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1293' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1290' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة موقع إلكتروني' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1272' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية متخصصة' AS item_name, 3098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1238' AND i.amount = 3098.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تقديم دعم فني' AS item_name, 3199.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1205' AND i.amount = 3199.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1099.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1154' AND i.amount = 1099.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2099.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1133' AND i.amount = 2099.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 3199.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1083' AND i.amount = 3199.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '1008' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '990' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '961' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية متخصصة' AS item_name, 2203.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '925' AND i.amount = 2203.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1099.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '870' AND i.amount = 1099.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2099.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '869' AND i.amount = 2099.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '851' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 1575.36 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '837' AND i.amount = 1575.36
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '828' AND i.amount = 2001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة موقع إلكتروني' AS item_name, 18007.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '820' AND i.amount = 18007.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '808' AND i.amount = 2003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '788' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '781' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '779' AND i.amount = 1001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '778' AND i.amount = 1001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '774' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '771' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '757' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '756' AND i.amount = 2002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '751' AND i.amount = 1001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '747' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '743' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1004.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '742' AND i.amount = 1004.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1004.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '741' AND i.amount = 1004.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1006.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '740' AND i.amount = 1006.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '739' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1006.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '734' AND i.amount = 1006.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1005.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '733' AND i.amount = 1005.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '730' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1006.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '727' AND i.amount = 1006.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '724' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '723' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1006.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '719' AND i.amount = 1006.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '715' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '708' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '704' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1004.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '703' AND i.amount = 1004.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '700' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '701' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '695' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '693' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '691' AND i.amount = 1002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '683' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '679' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '678' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '671' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '669' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '670' AND i.amount = 1003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '656' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1018.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '602' AND i.amount = 1018.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '620' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1068.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '561' AND i.amount = 1068.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '595' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'التسويق الرقمي' AS item_name, 2688.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '593' AND i.amount = 2688.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2085.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '574' AND i.amount = 2085.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '562' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '546' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '516' AND i.amount = 1098.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '499' AND i.amount = 1026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '495' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير تطبيقات الجوال (iOS وAndroid)' AS item_name, 8000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '477' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير متجر إلكتروني' AS item_name, 8000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '476' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تطوير تطبيقات الجوال (iOS وAndroid)' AS item_name, 8000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '475' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1106.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '419' AND i.amount = 1106.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'حلول مدعومة بالذكاء الاصطناعي' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '386' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '379' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '378' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '367' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1400.69 AS price
    UNION ALL SELECT 'استضافة ونطاق (سنوي)' AS item_name, 625.31 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '358' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1022.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '333' AND i.amount = 1022.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '331' AND i.amount = 1026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '324' AND i.amount = 1026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '318' AND i.amount = 1028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1021.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '312' AND i.amount = 1021.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '299' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تقديم دعم فني' AS item_name, 3068.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '296' AND i.amount = 3068.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1024.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '272' AND i.amount = 1024.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1021.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '260' AND i.amount = 1021.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '238' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1886.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '231' AND i.amount = 1886.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية متخصصة' AS item_name, 2326.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '228' AND i.amount = 2326.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '217' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1056.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '191' AND i.amount = 1056.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '192' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1256.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '189' AND i.amount = 1256.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1126.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '195' AND i.amount = 1126.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1526.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '194' AND i.amount = 1526.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '174' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '154' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1389.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '160' AND i.amount = 1389.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '148' AND i.amount = 1026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1065.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '136' AND i.amount = 1065.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '118' AND i.amount = 1028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1025.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '110' AND i.amount = 1025.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تقنية عامة' AS item_name, 1211.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '78' AND i.amount = 1211.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'إدارة الحملات الإعلانية (شهري)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '97' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحسين محركات البحث (SEO)' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '92' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1052.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '83' AND i.amount = 1052.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1088.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '79' AND i.amount = 1088.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ربط الأنظمة وواجهات API' AS item_name, 1688.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '63' AND i.amount = 1688.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1024.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '38' AND i.amount = 1024.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1088.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '48' AND i.amount = 1088.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صفحة هبوط (Landing Page)' AS item_name, 1088.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '46' AND i.amount = 1088.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '11' AND i.amount = 1028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '6' AND i.amount = 1028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'صيانة وتحديث موقع أو تطبيق (شهري)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'ARVO' AND i.invoice_no = '3' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

-- Test run for the "X Run Studio" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices that have no services yet are touched, so nothing classified by hand is overwritten.
-- Items are matched by name inside the store, so anything missing from the live catalog is simply skipped.
-- The 10-11 SAR invoices are classified as a test payment; the two 100 SAR ones are below every service's minimum
-- but not clearly a test, so they are left unclassified.

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'عملية تجربة (Test)', 'دفعة اختبار بمبلغ رمزي، وليست خدمة فعلية', (SELECT id FROM catalog_categories WHERE name = 'أخرى' LIMIT 1), s.id, 10 FROM stores s
WHERE s.name = 'X Run Studio' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'عملية تجربة (Test)');

INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1, 100 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name = 'X Run Studio' AND x.name = 'عملية تجربة (Test)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '921' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '916' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 1650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '912' AND i.amount = 1650.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1100.00 AS price
    UNION ALL SELECT 'تصميم العروض التقديمية' AS item_name, 750.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '909' AND i.amount = 1850.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '895' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 11.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '892' AND i.amount = 11.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '850' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '849' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '848' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '840' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '771' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شعار فقط' AS item_name, 600.00 AS price
    UNION ALL SELECT 'بروشور أو فلاير' AS item_name, 400.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '731' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 700.00 AS price
    UNION ALL SELECT 'جولة تعديل إضافية' AS item_name, 300.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '729' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم أغلفة وصور حسابات' AS item_name, 350.00 AS price
    UNION ALL SELECT 'الموشن جرافيك والريلز' AS item_name, 650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '709' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3800.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '708' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم المطبوعات' AS item_name, 368.42 AS price
    UNION ALL SELECT 'منيو مطعم أو مقهى' AS item_name, 631.58 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '701' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بطاقة أعمال وقرطاسية' AS item_name, 368.42 AS price
    UNION ALL SELECT 'تحريك شعار' AS item_name, 631.58 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '695' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 4000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '682' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '671' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '669' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '658' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 3000.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '648' AND i.amount = 12500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '627' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '599' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '591' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '590' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '563' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '540' AND i.amount = 1200.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم ملصقات منتجات' AS item_name, 450.00 AS price
    UNION ALL SELECT 'الموشن جرافيك والريلز' AS item_name, 650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '538' AND i.amount = 1100.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 3500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '523' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شعار فقط' AS item_name, 600.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '520' AND i.amount = 2800.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1100.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '519' AND i.amount = 1100.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '471' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '470' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم ملصقات منتجات' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '464' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروشور أو فلاير' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '463' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'منيو مطعم أو مقهى' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '461' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '462' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحريك شعار' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '459' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 6000.00 AS price
    UNION ALL SELECT 'باقة العلامة + سوشيال' AS item_name, 14000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '437' AND i.amount = 20000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 4920.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '454' AND i.amount = 9420.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم أغلفة وصور حسابات' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '439' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 6000.00 AS price
    UNION ALL SELECT 'باقة العلامة + سوشيال' AS item_name, 14000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '413' AND i.amount = 20000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1000.00 AS price
    UNION ALL SELECT 'باقة العلامة + سوشيال' AS item_name, 14000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '414' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '392' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم المطبوعات' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '407' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '409' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '350' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '341' AND i.amount = 7500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '346' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '335' AND i.amount = 11000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 4000.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '295' AND i.amount = 8500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '257' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 800.00 AS price
    UNION ALL SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 700.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '258' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3120.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '185' AND i.amount = 5320.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2068.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '158' AND i.amount = 2068.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '153' AND i.amount = 4028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '150' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4615.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '129' AND i.amount = 4615.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '128' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 803.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '125' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3004.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '123' AND i.amount = 3004.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '114' AND i.amount = 3002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '113' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 803.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '111' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '72' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '62' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 1900.63 AS price
    UNION ALL SELECT 'تصميم العبوات والتغليف' AS item_name, 1100.37 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '56' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 801.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '54' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 11.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '53' AND i.amount = 11.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '52' AND i.amount = 2098.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '41' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '32' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بطاقة أعمال وقرطاسية' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '24' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
    UNION ALL SELECT 'جولة تعديل إضافية' AS item_name, 700.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '20' AND i.amount = 5200.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '22' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شعار فقط' AS item_name, 550.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '7' AND i.amount = 10050.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1300.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '2' AND i.amount = 3500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1974' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1050.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1970' AND i.amount = 5550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3051.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1902' AND i.amount = 3051.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1824' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1786' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2046.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1780' AND i.amount = 2046.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم ملصقات منتجات' AS item_name, 523.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1768' AND i.amount = 5023.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1708' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1687' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1664' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1657' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1631' AND i.amount = 2200.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1629' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروشور أو فلاير' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1395' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1387' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1381' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1374' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1353' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1310' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1264' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'منيو مطعم أو مقهى' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1218' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2134.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1143' AND i.amount = 2134.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1124' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1123' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم أغلفة وصور حسابات' AS item_name, 350.00 AS price
    UNION ALL SELECT 'الموشن جرافيك والريلز' AS item_name, 650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1106' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1103' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم المطبوعات' AS item_name, 368.42 AS price
    UNION ALL SELECT 'تحريك شعار' AS item_name, 631.58 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1098' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1059' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1049' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1047' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1045' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '1038' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '931' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '919' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 800.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '916' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '903' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '901' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بطاقة أعمال وقرطاسية' AS item_name, 350.00 AS price
    UNION ALL SELECT 'الموشن جرافيك والريلز' AS item_name, 650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '888' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1050.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '840' AND i.amount = 1050.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '814' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '812' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '806' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '803' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 900.00 AS price
    UNION ALL SELECT 'تصميم العبوات والتغليف' AS item_name, 1100.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '801' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شعار فقط' AS item_name, 689.58 AS price
    UNION ALL SELECT 'جولة تعديل إضافية' AS item_name, 344.79 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '774' AND i.amount = 1034.37
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4522.69 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '741' AND i.amount = 4522.69
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'منيو مطعم أو مقهى' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '731' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1800.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '728' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '703' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم ملصقات منتجات' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '695' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروشور أو فلاير' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '667' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تحريك شعار' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '604' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 2166.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '594' AND i.amount = 6666.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

-- فاتورة 586 (100): أقل من أي نطاق سعر، تُترك غير مصنّفة

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم أغلفة وصور حسابات' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '558' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2534.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '499' AND i.amount = 2534.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '473' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '427' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '423' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '405' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '388' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1051.22 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '373' AND i.amount = 1051.22
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 4300.00 AS price
    UNION ALL SELECT 'باقة الهوية الكاملة' AS item_name, 9500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '297' AND i.amount = 13800.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '279' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '256' AND i.amount = 4500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم المطبوعات' AS item_name, 500.00 AS price
    UNION ALL SELECT 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '201' AND i.amount = 2700.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

-- فاتورة 196 (100): أقل من أي نطاق سعر، تُترك غير مصنّفة

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '173' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3300.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '170' AND i.amount = 3300.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2501.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '168' AND i.amount = 2501.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 2992.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '166' AND i.amount = 2992.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 2983.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '165' AND i.amount = 2983.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الموشن جرافيك والريلز' AS item_name, 1500.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '146' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '35' AND i.amount = 1098.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 2122.00 AS price
    UNION ALL SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.invoice_no = '24' AND i.amount = 6622.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

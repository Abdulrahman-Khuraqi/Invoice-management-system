-- Test run for the "X Run Studio" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices that have no services yet are touched, so nothing classified by hand is overwritten.
-- Each invoice is found by its unique transaction number (رقم العملية), with the amount as a safety check.
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '05f7358a1baf4b5a9f171e78d04a2ec9' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '98e5efe9ed3343039348811ecb68aa70' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 1650.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'dc4c9184d7b9468f8532e84c19f122ee' AND i.amount = 1650.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'd41b7974c6784cbf934f79c859ce6910' AND i.amount = 1850.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '88726f8efb8a4ca28ec8557ad219d26a' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 11.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'e487ec8811ee4d2a91a8b7e94aebe65c' AND i.amount = 11.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'b5aacb8ce0ff453cbb0a144ea7f3adc6' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'c884e17cf0214dacb6825d6d9c4cccaf' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3b833bce2a58450995ab36b105b760ec' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ea73c286537946c88333250d7160daf3' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3c87d90fbe494f599725e2935199e8e4' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '35de29f4dbb2421b91fb4140612f2635' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0fd6f97fd7d94bc5bfc81634d86b3c11' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '781f8efc7e424073aeae2740aa8e1953' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8e514e028aa449ca8356e83b891cbf34' AND i.amount = 6000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3df3e4bcdc6c4c9ab6b4dd2a6e15e63d' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '663fab93b68240959193fb4bf056c7d2' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 4000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '72ea97e456564a238fbfff1fbdc16f8b' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '2c8fcacfd2834a1a88d0b774091f0ac8' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'aff24c58aceb43f895f2a4242f184947' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'a6c10ed880b44724843ad2040d8f7a89' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '1eae6a5b56c84a65a6303123fbbdc31c' AND i.amount = 12500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'db55e165c4b04c8092ca99e21991263e' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '92d64eea63db4de8a1f71146cc725b6b' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '229ab09c74e14e73a2f175ce09e255a9' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '494bcf91821740a9b0948c784cfb10d5' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'a3de6f9d610441d1bc42ef8a6e10f8a3' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '4f0f6943ff684835bc3523d60f2d1e58' AND i.amount = 1200.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '08719eb4e689412ebbaed699fda7f4a2' AND i.amount = 1100.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '6d950ab1fa254afdadd8ac3d3c4eca35' AND i.amount = 8000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '468a96818ddd406f8024984edc6baca5' AND i.amount = 2800.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العبوات والتغليف' AS item_name, 1100.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5da5b3e9cd3246ef906b6115b2273a3e' AND i.amount = 1100.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3e7f2f9657b04a3198c8f7133cd11bfc' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '60df85008fe64dc8a14e0f1ef910db0f' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '207ccc8179634ec1b4cec48781289634' AND i.amount = 5000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '4c7876510de24e01a2b2ad3bae5ed269' AND i.amount = 10000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f680af777f724c4d8912c020c5046c73' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f1969e813d094c31b627b2bd18834c43' AND i.amount = 10.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3c6b3df9b52a4323b863c83bf16ba3d3' AND i.amount = 10000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '56d043f4a1a54cf49c128359badbaa4c' AND i.amount = 20000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '99e608ad81aa44b7a4fca22d77765b18' AND i.amount = 9420.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '941d44a6fdb24a4188aaf5473b8becec' AND i.amount = 10000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f71d230f0c7b40babcf193431953e1dd' AND i.amount = 20000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '70a547738c29453d8fa066ec91e90f25' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'fd785c6fd1cc496ca279f42957300d9a' AND i.amount = 2000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '27396af864014adf93bdb28b92809fc0' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f015c5d6fd5249c1b8cabe25ca3825e8' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'e1026b843ef144c68055d893aeba8627' AND i.amount = 1500.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '60b041d8f95c496eaf298dfb60e63345' AND i.amount = 7500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '62f3f1855185439386ac1444101cc6ef' AND i.amount = 1500.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3931043d10394e3bbde2ee16b0230188' AND i.amount = 11000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '4f08e0ef61484394ad6f240f1611c4a5' AND i.amount = 8500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'c09665471b6546acb6fed61717689c0c' AND i.amount = 1500.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '009c2a8e76dd4d3eb3900c0095d8aa6d' AND i.amount = 1500.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '844539ea071b4addbf11427e38f51e70' AND i.amount = 5320.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2068.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '22f3beba2e8b44cc994eb97dad647ccc' AND i.amount = 2068.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4028.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '463e4740c2884327aca2f57f258a5749' AND i.amount = 4028.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2026.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '56ecda87200340e3860e66bf44c198dc' AND i.amount = 2026.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4615.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '28d4f68358c34f0babb79645ecced8f1' AND i.amount = 4615.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ddb6a04d052444ef9bfa63b92820d1c6' AND i.amount = 3003.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'bff1138f968f45e88fdf968e89d7d488' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3004.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f1dc3e525d124b4083987005aee6a7e6' AND i.amount = 3004.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '42a1213ce2654b1f8b169fc1c37e49dc' AND i.amount = 3002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3003.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '827be978abd34a06adef5bfc17284439' AND i.amount = 3003.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ab509190570345b7bf50aa6cc1776b61' AND i.amount = 3003.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3497a40a3a5e4a3381e59ec3f6358b17' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '107da01b6b49403bb6e6570affb47504' AND i.amount = 3001.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '29eaa9e297364f01b2868a2841eafbbe' AND i.amount = 3001.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'b823647186114eaa9fa847bca32582f9' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 11.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'b1de9a39eda143a5a1b337e4bdc78f71' AND i.amount = 11.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0a7f1beb22e5439d824a4b91f6be3e5e' AND i.amount = 2098.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8c890031ecaa4d099c9fa05a7503d817' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0442e77ba09a4b9d9c4b8eeff4ee4e42' AND i.amount = 10.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '9b0377d294ae4d5cbdf6ef747fe41563' AND i.amount = 10000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '95c88203eacd4d3e8b9f98d76ce88550' AND i.amount = 5200.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '2c6e4ff3493e44d0bb90ba9c102d2b11' AND i.amount = 3000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '50ce54f17c734139b0ae8d7459cfbb2f' AND i.amount = 10050.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '2b345cf86106461180e75251bdcfb209' AND i.amount = 3500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3b5e58bfa06849439081a20bd973090d' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5cab79ecc2d14abba7b27739be06ae03' AND i.amount = 10.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '51776954114e4b688ad7f6c5d14eef95' AND i.amount = 5550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3051.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'b66de9e830e2464b8255587314d9e810' AND i.amount = 3051.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ca617ecdf0e34536be540f35d14f5117' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'edf9c5f9a9b749b8ba3f50706d49480d' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2046.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '3a1ed5659bc54473b39d129dc300a70b' AND i.amount = 2046.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0ed85b252c6c4e879977cec5435c5791' AND i.amount = 5023.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f3cf32b804264fa8a437294f1b18a16f' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'بروفايل شركة' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f5c2a2d9d605439b8a2e1d225caa1fd3' AND i.amount = 1500.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '19c3d780e4da423e8d0de6252d5c1208' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '6c3bd6ef5cf941cc96d9375143ddd64c' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2200.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0b6495adc3b14c1e8143de6603f1237f' AND i.amount = 2200.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '704146a3ca91421189eaf31d95c87daa' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'b662325552434a13a3569ff14f2b04bf' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'bf5bb95ad51a491ca476a03c66090818' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '1e4cbba932924f5cb9343250e6536b26' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '1bd7345201ea462da62e933f59643021' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5918edf576ed43d4b9c021e599514ee5' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8a851bbf30b040c6810c3f277878d184' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ca59edcf14d34264af8f6da9f0f2ed5a' AND i.amount = 10.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '4a7c8d48b189479ab9c6bf5c3c41bd74' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2134.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'bc0a473faf224b9895e0e635cbad6ad9' AND i.amount = 2134.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '77bbc266ab744840ae722e374ae6eb50' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '0c8074fba63c4d0ebf32e022410b67a1' AND i.amount = 2000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'f6426de637e0430290c00fbf1aaaec61' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'db23fe9a7fe943c3801487448a4f6118' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'cfb14a4de6484d5ea3838a490288fecf' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'dabd91c832754c679757ebca739ecff6' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'a1563ec0e758456e904fdff135d90d0c' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '052d0655841a470fae71b56db1a200fd' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'bd2fdf2913474290b3e0540a06ccb3d0' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'عملية تجربة (Test)' AS item_name, 10.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'c03f742362e745d7b1fde4052d8a301e' AND i.amount = 10.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '70b6376f792147da903bf2c519ea0dc0' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'cf082eb8975946d89af4efaddb164bd4' AND i.amount = 3000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '6657cd6fe29d43f887166d797a5b63a7' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '88ac7075c71d4a43bb1b1bb405c38344' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '30f75fb0cd334bfb8a85d71979b3a458' AND i.amount = 1000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ffb29b03a1414d4da679390a5c891b71' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1050.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'cb579225091a43dfbfa67c02fe905e88' AND i.amount = 1050.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'قوالب سوشيال ميديا قابلة للتعديل' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '76214cb066a04044bb5c3ba04614e823' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '9332543099a546fda28c821d6dc96a84' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'c43af288087746cfbc57c322440f599a' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'c5fd20bb4ac546c8abe94d0ad2226484' AND i.amount = 2000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '84132185348f44488a0e4f8305cf754f' AND i.amount = 2000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '37ef8abc9d474d4e9d073b6902f1e30f' AND i.amount = 1034.37
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 4522.69 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '46eb17fa561e4f70bb42b8840a77ccf9' AND i.amount = 4522.69
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '23159b27e7364e6fb1be60c1aa4d9485' AND i.amount = 6000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '312f305eb7464b7fb7a5ecb36373a9e5' AND i.amount = 4000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '095363f7b94741f994a7c3806844b9b1' AND i.amount = 3000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5935d8e704e048e28f88a2540ef5bb75' AND i.amount = 6000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'a788427745594b2dae7ebca488f6844d' AND i.amount = 5000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '1f1db4c08aba43e1970ec14b4764e5c0' AND i.amount = 10000.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '510c9d7269e04d028619ff3b90eb894d' AND i.amount = 6666.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'ce4c9dbc258241d48ad9dc0eabed68ab' AND i.amount = 10000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2534.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'de9f2c46402a4e26aaf8f8f853dadcbc' AND i.amount = 2534.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '9959b41e38c54ea1998e83d0a8990ca8' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'a105041d05e5463697e154d771d61fed' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'الهوية البصرية والشعار' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '7fd419a5fdb543e89f25c0ea9414ecb6' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'دليل الهوية (Brand Guidelines)' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '1be372473e5547398faa65f3c2cb0cd3' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'ريلز أو فيديو قصير' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '76cf518498dc415da2b745d7c1a11804' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم العروض التقديمية' AS item_name, 1051.22 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '7f5fb8105c01464fb1589f8fc2ae2b8d' AND i.amount = 1051.22
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '9c001030f6144ff0b222760868d6549d' AND i.amount = 13800.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 3000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '36b7bf9f790c4c37a96d4a0695634ad2' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'باقة الإطلاق' AS item_name, 4500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5b212b2e7b6940e8962d64478091c386' AND i.amount = 4500.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8450798844144ca3a815dff553317ba9' AND i.amount = 2700.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8aad481c8daf4c7fa2527cafcc4ba4bf' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 3300.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '2c1a2a89a7724eb69dadd0ed349f1747' AND i.amount = 3300.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'Pitch Deck للمستثمرين' AS item_name, 2501.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '08a77b5d17404412aa058571d24f312b' AND i.amount = 2501.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهة تطبيق جوال (UI)' AS item_name, 2992.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = 'e7bb8e437d984c18a2be0af2799caff2' AND i.amount = 2992.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم واجهات المواقع والمتاجر' AS item_name, 2983.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '5a6ed0ebdcaf4e588c558a13ff95f3f2' AND i.amount = 2983.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '375532ef905f4ce3b64129144c833149' AND i.amount = 6000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم السوشيال ميديا' AS item_name, 1098.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'X Run Studio' AND i.transaction_id = '9b2b1f5b929240579bb53c4664d6e6b3' AND i.amount = 1098.00
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
WHERE s.name = 'X Run Studio' AND i.transaction_id = '8e5b613739cf4cdd94001aba98ac0ba3' AND i.amount = 6622.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

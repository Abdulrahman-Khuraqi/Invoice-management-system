-- Test run for the "anas" store only: link each existing invoice to 1-3 services whose price range fits its amount.
-- Invoice amounts are never changed; the line prices add up exactly to the invoice amount.
-- Only invoices that have no services yet are touched, so nothing classified by hand is overwritten.
-- Each invoice is found by its unique transaction number (رقم العملية), with the amount as a safety check.
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
WHERE s.name = 'anas' AND i.transaction_id = '300bf070597a42fab12d204d94dfef10' AND i.amount = 15000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)' AS item_name, 1500.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'e241baaf8435477aa70d39b66ad5e5b6' AND i.amount = 1500.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'e57959c951d44660ad090b01a41fbcfd' AND i.amount = 4000.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'bf320787ba3d45d7b47f1ff860177023' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '3fc4ca6da0c8412ab15f71534d6f71ed' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '4c5d1cbc3755424f8971f1079c4951ad' AND i.amount = 2000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '25f2405cd17540ffba0fc9b61f18788f' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'استشارة تطوير ألعاب' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '2601cdec2144447180980301655c2604' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'f78ebb0bf7aa4756b0dbc39df516058d' AND i.amount = 1000.00
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
WHERE s.name = 'anas' AND i.transaction_id = '1dddcd64aaee49c3b0c6d70e0bc5b2e7' AND i.amount = 3000.00
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
WHERE s.name = 'anas' AND i.transaction_id = '337c284847174849b9f2380f8af53f58' AND i.amount = 3000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1289.16 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '1abdffbf8ceb42bb95eb1315c7bd366c' AND i.amount = 1289.16
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1286.21 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '8472ef63f1d74020b42e0085e9374361' AND i.amount = 1286.21
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5853.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'c6ac1abdad9e40538518dd044a45207c' AND i.amount = 5853.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)' AS item_name, 1427.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'b51d21fa71664a52bfc684124bd4800a' AND i.amount = 1427.00
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
WHERE s.name = 'anas' AND i.transaction_id = '5193c2e320e14258945832392c46f3b7' AND i.amount = 10.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'caa417f345954b7e860a928f08a4b9a8' AND i.amount = 2989.22
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
WHERE s.name = 'anas' AND i.transaction_id = '3db608a38e5949cd9833bdefab2fbcd9' AND i.amount = 2896.11
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
WHERE s.name = 'anas' AND i.transaction_id = '7116b250697f471889a5a6fe6fad9a4e' AND i.amount = 2887.00
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
WHERE s.name = 'anas' AND i.transaction_id = '217d2b9b694442e5ab3cc6b366d78952' AND i.amount = 2887.00
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
WHERE s.name = 'anas' AND i.transaction_id = '9f36b5cf2f6e40feaa48f85387eb8dff' AND i.amount = 3056.00
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
WHERE s.name = 'anas' AND i.transaction_id = '0de47ca43e3044249335cf1448285571' AND i.amount = 3025.00
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
WHERE s.name = 'anas' AND i.transaction_id = '41162912e6b145f8a5269f4e343d5316' AND i.amount = 8000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '95c02423e9114d459095de4c2e17bfcc' AND i.amount = 2001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5001.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'a9c0674544624c699c38a959f46970de' AND i.amount = 5001.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'c570a9fe2cb94fd18dec503906b3e107' AND i.amount = 3001.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'a3c3811d28e449338270f954a4f66c33' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5002.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'b4e76f6190ce49af98abc5aa36726221' AND i.amount = 5002.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1550.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '554caff48696461aaa1585f8b3808744' AND i.amount = 1550.00
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
WHERE s.name = 'anas' AND i.transaction_id = '24cd8db2ef024d09a053dbe5d66d69a9' AND i.amount = 4001.00
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
WHERE s.name = 'anas' AND i.transaction_id = '8edd4eccbc3e43dfadd6c9200bc28c94' AND i.amount = 2636.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'e2806bcb31cb4ad6939d9ec04ef55cf7' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'e3bcdbed353e4514aa511cd0cd7a2965' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '1a2a0c1067a144f4aa7334183155893e' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1078.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '4a7ef90b7db24af2aba819faea247a67' AND i.amount = 1078.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'fc44040ed19c4a6baa473ac73eeafc4f' AND i.amount = 3000.00
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
WHERE s.name = 'anas' AND i.transaction_id = '31e445afe00549bea60f9030eaf060dd' AND i.amount = 3000.00
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
WHERE s.name = 'anas' AND i.transaction_id = '977ead39f2f6490ca38d2d199c6ea0bc' AND i.amount = 3000.00
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
WHERE s.name = 'anas' AND i.transaction_id = '4eca8ece41c8493aa3a8107b3a41e045' AND i.amount = 4307.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'برمجة الألعاب (باقة نظام لعب واحد)' AS item_name, 2163.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '28b0f1429d7244c39da3329b8452a256' AND i.amount = 2163.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5034.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '5f1118757d35482aa543c99b420aa660' AND i.amount = 5034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 7034.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '55f6dbe39bfe4844827c651e9886016c' AND i.amount = 7034.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'رفع اللعبة على المتاجر (Google Play وApp Store)' AS item_name, 1550.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'c56384d163db403d8c1cf60d7c5297f1' AND i.amount = 1550.00
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
WHERE s.name = 'anas' AND i.transaction_id = 'e0aeadf814fc4e648cedd671949cee8a' AND i.amount = 2550.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تصميم وتطوير الألعاب (باقة النموذج الأولي)' AS item_name, 5000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = '2c80c8c17e9643e49d65c3e075796629' AND i.amount = 5000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price)
SELECT i.id, ci.id, 1, v.price
FROM invoices i
JOIN stores s ON s.id = i.store_id
JOIN (
    SELECT 'تعديل وتطوير لعبة قائمة' AS item_name, 1000.00 AS price
) v
JOIN catalog_items ci ON ci.store_id = s.id AND ci.is_active = 1 AND ci.name = v.item_name
WHERE s.name = 'anas' AND i.transaction_id = 'fea6e87bad944e2581b39ce030d6f6ea' AND i.amount = 1000.00
  AND NOT EXISTS (SELECT 1 FROM invoice_items k WHERE k.invoice_id = i.id);

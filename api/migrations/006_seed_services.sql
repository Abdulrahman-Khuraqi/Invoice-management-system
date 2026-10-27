-- Starter catalog of services for each store, with a usual price range and a default price.
-- Taken from each store's website (xrunstudio.itsak.tech, arvo-sa.com, anas.itsak.tech): "starts from" prices and packages
-- are the published ones (marked in the description); the upper end of each range and the extra services are estimates
-- based on the invoices already received. Edit or archive anything from Settings > Services and products.
-- Runs once; stores are matched by name, items and categories that already exist (same name) are not duplicated.

INSERT INTO catalog_categories (name, color) SELECT 'هوية بصرية', '#8b5cf6' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'هوية بصرية');

INSERT INTO catalog_categories (name, color) SELECT 'سوشيال ميديا', '#ec4899' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'سوشيال ميديا');

INSERT INTO catalog_categories (name, color) SELECT 'مطبوعات', '#f59e0b' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'مطبوعات');

INSERT INTO catalog_categories (name, color) SELECT 'واجهات ومتاجر', '#0ea5e9' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'واجهات ومتاجر');

INSERT INTO catalog_categories (name, color) SELECT 'تغليف', '#10b981' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'تغليف');

INSERT INTO catalog_categories (name, color) SELECT 'عروض تقديمية', '#f97316' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'عروض تقديمية');

INSERT INTO catalog_categories (name, color) SELECT 'موشن جرافيك', '#ef4444' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'موشن جرافيك');

INSERT INTO catalog_categories (name, color) SELECT 'باقات', '#6366f1' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'باقات');

INSERT INTO catalog_categories (name, color) SELECT 'استشارات', '#14b8a6' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'استشارات');

INSERT INTO catalog_categories (name, color) SELECT 'تطوير', '#3b82f6' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'تطوير');

INSERT INTO catalog_categories (name, color) SELECT 'دعم فني', '#64748b' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'دعم فني');

INSERT INTO catalog_categories (name, color) SELECT 'تسويق رقمي', '#d946ef' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'تسويق رقمي');

INSERT INTO catalog_categories (name, color) SELECT 'تصميم وتطوير الألعاب', '#22c55e' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب');


-- XRUN

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'الهوية البصرية والشعار', 'تصميم شعار، نظام ألوان، دليل استخدام، قرطاسية. يبدأ من 1,900 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'هوية بصرية' LIMIT 1), s.id, 1900 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'الهوية البصرية والشعار');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1900, 6000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'الهوية البصرية والشعار'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم شعار فقط', 'شعار باتجاهين مع الملفات الجاهزة', (SELECT id FROM catalog_categories WHERE name = 'هوية بصرية' LIMIT 1), s.id, 600 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم شعار فقط');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 1500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم شعار فقط'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'دليل الهوية (Brand Guidelines)', 'دليل استخدام الهوية بصيغة PDF', (SELECT id FROM catalog_categories WHERE name = 'هوية بصرية' LIMIT 1), s.id, 800 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'دليل الهوية (Brand Guidelines)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 600, 2500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'دليل الهوية (Brand Guidelines)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم السوشيال ميديا', 'منشورات، ستوري، أغلفة، قوالب. يبدأ من 900 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'سوشيال ميديا' LIMIT 1), s.id, 900 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم السوشيال ميديا');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 900, 3000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم السوشيال ميديا'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'قوالب سوشيال ميديا قابلة للتعديل', 'حزمة قوالب منشورات وستوري على هوية العميل', (SELECT id FROM catalog_categories WHERE name = 'سوشيال ميديا' LIMIT 1), s.id, 700 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'قوالب سوشيال ميديا قابلة للتعديل');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 1800 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'قوالب سوشيال ميديا قابلة للتعديل'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم أغلفة وصور حسابات', 'أغلفة وصور شخصية لحسابات التواصل', (SELECT id FROM catalog_categories WHERE name = 'سوشيال ميديا' LIMIT 1), s.id, 350 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم أغلفة وصور حسابات');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 250, 800 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم أغلفة وصور حسابات'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم المطبوعات', 'بروشور، فلاير، منيو، بطاقة أعمال. يبدأ من 350 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'مطبوعات' LIMIT 1), s.id, 350 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم المطبوعات');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 350, 1500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم المطبوعات'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'بروشور أو فلاير', 'تصميم جاهز للطباعة', (SELECT id FROM catalog_categories WHERE name = 'مطبوعات' LIMIT 1), s.id, 400 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'بروشور أو فلاير');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 350, 1200 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'بروشور أو فلاير'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'منيو مطعم أو مقهى', 'تصميم منيو جاهز للطباعة والعرض الرقمي', (SELECT id FROM catalog_categories WHERE name = 'مطبوعات' LIMIT 1), s.id, 600 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'منيو مطعم أو مقهى');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 450, 2000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'منيو مطعم أو مقهى'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'بطاقة أعمال وقرطاسية', 'بطاقة أعمال، ترويسة، ظرف، توقيع بريد', (SELECT id FROM catalog_categories WHERE name = 'مطبوعات' LIMIT 1), s.id, 350 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'بطاقة أعمال وقرطاسية');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 300, 1200 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'بطاقة أعمال وقرطاسية'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم واجهات المواقع والمتاجر', 'UI، متاجر، نظام مكوّنات، Figma. يبدأ من 2,400 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'واجهات ومتاجر' LIMIT 1), s.id, 2400 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم واجهات المواقع والمتاجر');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2400, 10000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم واجهات المواقع والمتاجر'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم واجهة تطبيق جوال (UI)', 'تصميم شاشات التطبيق على Figma', (SELECT id FROM catalog_categories WHERE name = 'واجهات ومتاجر' LIMIT 1), s.id, 3000 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم واجهة تطبيق جوال (UI)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2400, 12000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم واجهة تطبيق جوال (UI)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم العبوات والتغليف', 'عبوات، ملصقات، مواد غذائية، Dieline. يبدأ من 1,100 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تغليف' LIMIT 1), s.id, 1100 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم العبوات والتغليف');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1100, 4000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم العبوات والتغليف'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم ملصقات منتجات', 'ملصقات وستيكرات للمنتجات', (SELECT id FROM catalog_categories WHERE name = 'تغليف' LIMIT 1), s.id, 450 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم ملصقات منتجات');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 350, 1500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم ملصقات منتجات'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم العروض التقديمية', 'PowerPoint، إنفوجرافيك. يبدأ من 750 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'عروض تقديمية' LIMIT 1), s.id, 750 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم العروض التقديمية');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 750, 3000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم العروض التقديمية'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'بروفايل شركة', 'ملف تعريفي للشركة بتصميم احترافي', (SELECT id FROM catalog_categories WHERE name = 'عروض تقديمية' LIMIT 1), s.id, 1500 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'بروفايل شركة');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1000, 4500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'بروفايل شركة'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'Pitch Deck للمستثمرين', 'عرض استثماري مصمم بالكامل', (SELECT id FROM catalog_categories WHERE name = 'عروض تقديمية' LIMIT 1), s.id, 2000 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'Pitch Deck للمستثمرين');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 5000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'Pitch Deck للمستثمرين'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'الموشن جرافيك والريلز', 'تحريك شعار، ريلز، انترو، ستوري متحرك. يبدأ من 650 (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'موشن جرافيك' LIMIT 1), s.id, 650 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'الموشن جرافيك والريلز');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 650, 2500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'الموشن جرافيك والريلز'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تحريك شعار', 'لوجو موشن بصيغ جاهزة', (SELECT id FROM catalog_categories WHERE name = 'موشن جرافيك' LIMIT 1), s.id, 600 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تحريك شعار');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 1200 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تحريك شعار'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'ريلز أو فيديو قصير', 'مونتاج وتحريك لفيديو قصير', (SELECT id FROM catalog_categories WHERE name = 'موشن جرافيك' LIMIT 1), s.id, 800 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'ريلز أو فيديو قصير');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 650, 2500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'ريلز أو فيديو قصير'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'باقة الإطلاق', 'شعار باتجاهين، لوحة ألوان وخطوط، بطاقة أعمال وترويسة وتوقيع بريد، 3 قوالب سوشيال، غلاف لحسابين، جولتا تعديل. 2–3 أسابيع (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'باقات' LIMIT 1), s.id, 4500 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'باقة الإطلاق');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 4500, 4500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'باقة الإطلاق'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'باقة الهوية الكاملة', 'كل ما في باقة الإطلاق مع 2–3 اتجاهات شعار، دليل هوية، عناصر داعمة، 6 قوالب سوشيال، Mockups، 3 جولات تعديل. 4–6 أسابيع (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'باقات' LIMIT 1), s.id, 9500 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'باقة الهوية الكاملة');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 9500, 9500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'باقة الهوية الكاملة'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'باقة العلامة + سوشيال', 'كل ما في الهوية الكاملة مع 16 تصميم سوشيال في الشهر الأول وتصميمين متحركين وأولوية تسليم شهر. 5–7 أسابيع (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'باقات' LIMIT 1), s.id, 14000 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'باقة العلامة + سوشيال');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 14000, 14000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'باقة العلامة + سوشيال'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)', '16 منشور و8 ستوري وتصميم متحرك شهرياً، تسليم أسبوعي، رد خلال يوم عمل (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'باقات' LIMIT 1), s.id, 2200 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2200, 2200 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'باقة إدارة تصميم السوشيال ميديا (اشتراك شهري)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'جولة تعديل إضافية', 'تعديلات إضافية خارج جولات الباقة', NULL, s.id, 300 FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'جولة تعديل إضافية');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 150, 800 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'جولة تعديل إضافية'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم مخصص (السعر حسب الاتفاق)', 'اكتب السعر المتفق عليه عند الفاتورة', NULL, s.id, NULL FROM stores s
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم مخصص (السعر حسب الاتفاق)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 350, 20000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%X Run%' OR s.name LIKE '%XRun%') AND x.name = 'تصميم مخصص (السعر حسب الاتفاق)'
ON DUPLICATE KEY UPDATE price_min = price_min;


-- ARVO

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'استشارة مجانية', 'استشارة أولية مجانية (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'استشارات' LIMIT 1), s.id, 0 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'استشارة مجانية');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 0, 0 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'استشارة مجانية'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'استشارة تقنية عامة', 'استشارة تقنية عامة (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'استشارات' LIMIT 1), s.id, 1120 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'استشارة تقنية عامة');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1120, 2000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'استشارة تقنية عامة'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'استشارة تقنية متخصصة', 'استشارة متخصصة في مجال محدد (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'استشارات' LIMIT 1), s.id, 2180 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'استشارة تقنية متخصصة');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2180, 4500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'استشارة تقنية متخصصة'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تطوير تطبيقات الجوال (iOS وAndroid)', 'تطبيقات جوال لنظامي iOS وAndroid (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 5340 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تطوير تطبيقات الجوال (iOS وAndroid)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 5340, 30000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'تطوير تطبيقات الجوال (iOS وAndroid)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'برمجة موقع إلكتروني', 'برمجة موقع إلكتروني بحسب نطاق العمل (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 7400 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'برمجة موقع إلكتروني');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 3000, 20000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'برمجة موقع إلكتروني'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تطوير متجر إلكتروني', 'متجر إلكتروني متكامل مع بوابة الدفع', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 6000 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تطوير متجر إلكتروني');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 4000, 20000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'تطوير متجر إلكتروني'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'صفحة هبوط (Landing Page)', 'صفحة تسويقية واحدة', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 1500 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'صفحة هبوط (Landing Page)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1000, 3500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'صفحة هبوط (Landing Page)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'حلول مدعومة بالذكاء الاصطناعي', 'دمج الذكاء الاصطناعي في الأنظمة والتطبيقات', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 4000 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'حلول مدعومة بالذكاء الاصطناعي');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2500, 15000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'حلول مدعومة بالذكاء الاصطناعي'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'ربط الأنظمة وواجهات API', 'ربط أنظمة وخدمات خارجية', (SELECT id FROM catalog_categories WHERE name = 'تطوير' LIMIT 1), s.id, 2500 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'ربط الأنظمة وواجهات API');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 8000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'ربط الأنظمة وواجهات API'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تقديم دعم فني', 'دعم فني مستمر (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'دعم فني' LIMIT 1), s.id, 3200 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تقديم دعم فني');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1000, 6000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'تقديم دعم فني'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'صيانة وتحديث موقع أو تطبيق (شهري)', 'صيانة دورية وتحديثات وإصلاح أعطال', (SELECT id FROM catalog_categories WHERE name = 'دعم فني' LIMIT 1), s.id, 1000 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'صيانة وتحديث موقع أو تطبيق (شهري)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 3000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'صيانة وتحديث موقع أو تطبيق (شهري)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'استضافة ونطاق (سنوي)', 'استضافة ودومين وشهادة SSL', (SELECT id FROM catalog_categories WHERE name = 'دعم فني' LIMIT 1), s.id, 500 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'استضافة ونطاق (سنوي)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 250, 1500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'استضافة ونطاق (سنوي)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'التسويق الرقمي', 'خطة وتنفيذ تسويق رقمي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تسويق رقمي' LIMIT 1), s.id, 3900 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'التسويق الرقمي');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 10000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'التسويق الرقمي'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'إدارة الحملات الإعلانية (شهري)', 'إدارة حملات سناب وتيك توك وجوجل وميتا', (SELECT id FROM catalog_categories WHERE name = 'تسويق رقمي' LIMIT 1), s.id, 2500 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'إدارة الحملات الإعلانية (شهري)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 8000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'إدارة الحملات الإعلانية (شهري)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تحسين محركات البحث (SEO)', 'تحسين ظهور الموقع في نتائج البحث', (SELECT id FROM catalog_categories WHERE name = 'تسويق رقمي' LIMIT 1), s.id, 2000 FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تحسين محركات البحث (SEO)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1200, 6000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'تحسين محركات البحث (SEO)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تطوير مخصص (السعر حسب الاتفاق)', 'اكتب السعر المتفق عليه عند الفاتورة', NULL, s.id, NULL FROM stores s
WHERE s.name LIKE '%ARVO%' AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تطوير مخصص (السعر حسب الاتفاق)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1000, 30000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE s.name LIKE '%ARVO%' AND x.name = 'تطوير مخصص (السعر حسب الاتفاق)'
ON DUPLICATE KEY UPDATE price_min = price_min;


-- GAMES

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تطوير تجربة ألعاب متكاملة (باقة تجربة الألعاب)', '25–35 يوم عمل، 3 جولات تعديل. سعر تجريبي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 10000 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تطوير تجربة ألعاب متكاملة (باقة تجربة الألعاب)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 10000, 25000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تطوير تجربة ألعاب متكاملة (باقة تجربة الألعاب)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم وتطوير الألعاب (باقة النموذج الأولي)', '15–20 يوم عمل، جولتا تعديل. سعر تجريبي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 5000 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 5000, 12000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تصميم وتطوير الألعاب (باقة النموذج الأولي)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'برمجة الألعاب (باقة نظام لعب واحد)', '5–7 أيام عمل، جولتا تعديل. سعر تجريبي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 2000 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'برمجة الألعاب (باقة نظام لعب واحد)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 2000, 5000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'برمجة الألعاب (باقة نظام لعب واحد)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)', '5–7 أيام عمل، جولتا تعديل. سعر تجريبي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 1500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 5000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تصميم عناصر الألعاب ثلاثية الأبعاد (باقة 3 عناصر بسيطة)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)', '5–7 أيام عمل، جولتا تعديل. سعر تجريبي (السعر المعلن في الموقع)', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 1500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1500, 4500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تصميم واجهات وتجربة مستخدم الألعاب (باقة 3 شاشات)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'عنصر ثلاثي الأبعاد إضافي', 'نمذجة عنصر واحد إضافي', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'عنصر ثلاثي الأبعاد إضافي');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 300, 1500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'عنصر ثلاثي الأبعاد إضافي'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'شاشة واجهة إضافية', 'تصميم شاشة إضافية للعبة', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'شاشة واجهة إضافية');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 300, 1200 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'شاشة واجهة إضافية'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)', 'رسم شخصيات وخلفيات وأصول اللعبة', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 1500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 800, 5000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تصميم شخصيات وبيئات ثنائية الأبعاد (2D)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تعديل وتطوير لعبة قائمة', 'إضافة ميزات أو إصلاح لعبة موجودة', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 1000 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تعديل وتطوير لعبة قائمة');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 5000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تعديل وتطوير لعبة قائمة'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'رفع اللعبة على المتاجر (Google Play وApp Store)', 'تجهيز ونشر اللعبة', (SELECT id FROM catalog_categories WHERE name = 'تصميم وتطوير الألعاب' LIMIT 1), s.id, 1500 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 800, 3000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'رفع اللعبة على المتاجر (Google Play وApp Store)'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'استشارة تطوير ألعاب', 'جلسة استشارية في فكرة اللعبة وتقنياتها', (SELECT id FROM catalog_categories WHERE name = 'استشارات' LIMIT 1), s.id, 1000 FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'استشارة تطوير ألعاب');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 500, 2500 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'استشارة تطوير ألعاب'
ON DUPLICATE KEY UPDATE price_min = price_min;

INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price)
SELECT 'service', 'تطوير مخصص (السعر حسب الاتفاق)', 'اكتب السعر المتفق عليه عند الفاتورة', NULL, s.id, NULL FROM stores s
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND NOT EXISTS (SELECT 1 FROM catalog_items x WHERE x.store_id = s.id AND x.name = 'تطوير مخصص (السعر حسب الاتفاق)');
INSERT INTO catalog_item_ranges (item_id, price_min, price_max)
SELECT x.id, 1000, 15000 FROM catalog_items x JOIN stores s ON s.id = x.store_id
WHERE (s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%') AND x.name = 'تطوير مخصص (السعر حسب الاتفاق)'
ON DUPLICATE KEY UPDATE price_min = price_min;

-- Contact details taken from each store's public website (xrunstudio.itsak.tech, arvo-sa.com, anas.itsak.tech).
-- Stores are matched by name; values already filled in from the dashboard are kept (COALESCE), only empty fields are set.

INSERT INTO store_info (store_id, website, phone, whatsapp, email, notes)
SELECT s.id, 'https://xrunstudio.itsak.tech', '0551728288', '966551728288', 'aans21420@gmail.com',
       'أنس أحمد بن عيسى عسيري — وثيقة العمل الحر FL-506013033 (وزارة الموارد البشرية والتنمية الاجتماعية). الدوام: الأحد إلى الخميس 9 ص – 6 م'
FROM stores s
WHERE s.name LIKE '%X Run%' OR s.name LIKE '%XRun%'
ON DUPLICATE KEY UPDATE
  website = COALESCE(store_info.website, VALUES(website)),
  phone = COALESCE(store_info.phone, VALUES(phone)),
  whatsapp = COALESCE(store_info.whatsapp, VALUES(whatsapp)),
  email = COALESCE(store_info.email, VALUES(email)),
  notes = COALESCE(store_info.notes, VALUES(notes));

INSERT INTO store_info (store_id, website, phone, whatsapp, email)
SELECT s.id, 'https://arvo-sa.com', '0551728288', '966551728288', 'info@arvo-sa.com'
FROM stores s
WHERE s.name LIKE '%ARVO%'
ON DUPLICATE KEY UPDATE
  website = COALESCE(store_info.website, VALUES(website)),
  phone = COALESCE(store_info.phone, VALUES(phone)),
  whatsapp = COALESCE(store_info.whatsapp, VALUES(whatsapp)),
  email = COALESCE(store_info.email, VALUES(email));

INSERT INTO store_info (store_id, website, phone, whatsapp, email, notes)
SELECT s.id, 'https://anas.itsak.tech', '0551728288', '966551728288', 'anas707.707aa@gmail.com',
       'وثيقة العمل الحر FL-216314344'
FROM stores s
WHERE s.name LIKE '%تصميم وتطوير الالعاب%'
ON DUPLICATE KEY UPDATE
  website = COALESCE(store_info.website, VALUES(website)),
  phone = COALESCE(store_info.phone, VALUES(phone)),
  whatsapp = COALESCE(store_info.whatsapp, VALUES(whatsapp)),
  email = COALESCE(store_info.email, VALUES(email)),
  notes = COALESCE(store_info.notes, VALUES(notes));

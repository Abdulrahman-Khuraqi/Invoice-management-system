-- Contact details of the games store (anas.itsak.tech). The store is seeded as "anas", so 004 did not match it by its merchant name.
-- Values already filled in from the dashboard are kept (COALESCE), only empty fields are set.

INSERT INTO store_info (store_id, website, phone, whatsapp, email, notes)
SELECT s.id, 'https://anas.itsak.tech', '0551728288', '966551728288', 'anas707.707aa@gmail.com',
       'وثيقة العمل الحر FL-216314344'
FROM stores s
WHERE s.name LIKE '%anas%' OR s.name LIKE '%تصميم وتطوير الالعاب%'
ON DUPLICATE KEY UPDATE
  website = COALESCE(store_info.website, VALUES(website)),
  phone = COALESCE(store_info.phone, VALUES(phone)),
  whatsapp = COALESCE(store_info.whatsapp, VALUES(whatsapp)),
  email = COALESCE(store_info.email, VALUES(email)),
  notes = COALESCE(store_info.notes, VALUES(notes));

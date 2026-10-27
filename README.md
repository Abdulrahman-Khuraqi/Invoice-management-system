# إدارة الفواتير — Invoice Management System

تطبيق ويب عربي (PWA) لإدارة فواتير المتاجر: استيراد ملفات Excel من بوابة الدفع، إضافة يدوية، بحث، وربط كل فاتورة بالخدمة أو المنتج الذي دُفعت من أجله. يعمل على الجوال مثل التطبيق، مع وضع داكن وفاتح.

## المزايا

- **متاجر غير محدودة**: إضافة، تعديل، أرشفة، وحذف المتاجر من الإعدادات بدون برمجة.
- **ربط تلقائي بالمتجر**: كل رقم جهاز (TerminalID) في ملفات بوابة الدفع مربوط بمتجر، والجهاز الجديد يُسأل عنه مرة واحدة فقط.
- **الخدمات والمنتجات**: كتالوج تديره بنفسك (خدمة/منتج، تصنيف، سعر، لمتجر معيّن أو لكل المتاجر). كل فاتورة تُربط ببند واحد أو أكثر، والفواتير بدون بند تظهر «غير مصنّفة».
- **استيراد Excel**: ملفات بوابة الدفع كما هي، أو قالب النظام لإضافة فواتير كثيرة. التكرار مستحيل لأن رقم العملية فريد.
- **بحث وفلترة**: بالاسم، الجوال، الإيميل، رقم الفاتورة، الرقم المرجعي، آخر 4 أرقام، اسم الخدمة، أو المبلغ.
- **عمليات جماعية**: تصنيف، نقل لمتجر آخر، أو حذف عدة فواتير مرة واحدة.
- **تقارير**: حسب المتجر، الخدمة/المنتج، التصنيف، والمبيعات اليومية مع تصدير Excel.
- **مستخدمون وصلاحيات**: مدير، محرر، مشاهد، مع إمكانية حصر المستخدم في متاجر معيّنة، وسجل نشاط لكل العمليات.

## التشغيل على Hostinger (أول مرة)

1. **قاعدة البيانات**: من hPanel ← Databases ← MySQL Databases أنشئ قاعدة بيانات ومستخدماً لها.
2. **إصدار PHP**: من hPanel ← Advanced ← PHP Configuration اختر PHP 8.1 أو أحدث.
3. **SSL**: فعّل شهادة SSL للدومين حتى يعمل الموقع بـ https.
4. **الأسرار في GitHub** (Settings ← Secrets and variables ← Actions):

   | الاسم | القيمة |
   |---|---|
   | `FTP_SERVER` | `82.198.230.29` (بدون ftp://) |
   | `FTP_USERNAME` | `u122068939.ms` |
   | `FTP_PASSWORD` | كلمة مرور حساب FTP |
   | `DB_NAME` | اسم قاعدة البيانات، مثل `u122068939_invoices` |
   | `DB_USER` | اسم مستخدم قاعدة البيانات |
   | `DB_PASS` | كلمة مرور مستخدم قاعدة البيانات |

5. **النشر**: أي دفع (push) إلى فرع `main` ينشر تلقائياً. ويمكن التشغيل يدوياً من تبويب Actions ← Deploy to Hostinger ← Run workflow.
6. افتح `https://ms.asrixsa.com/` وأنشئ حساب المدير، ثم ارفع ملفات Excel من «إضافة ← استيراد Excel».

الجداول تُنشأ تلقائياً عند أول طلب (أو يدوياً عبر phpMyAdmin باستيراد `api/migrations/001_init.sql`).

> ⚠️ ملفات Excel فيها بيانات عملاء، لا ترفعها إلى المستودع (ملفات `*.xlsx` مستثناة في `.gitignore`).

---

## Development

**Stack**: React 19 + TypeScript + Vite + Tailwind 4 (`web/`), plain PHP 8.1+ with PDO/MySQL (`api/`), no server framework or Composer needed — it runs on shared hosting.

```bash
# API (needs MariaDB/MySQL)
cp api/config.example.php api/config.php   # set DB credentials
php -S 127.0.0.1:8000                      # from the repo root

# Web
cd web && npm install && npm run dev        # proxies /api to :8000
```

```
api/
  index.php            router — every request is api/index.php?r=<route>
  lib/                 db (PDO + migrations), auth (sessions, roles, store scope), http helpers
  routes/              auth, stores, catalog, invoices, import, stats, users
  migrations/*.sql     applied automatically, in order, once each
web/src/
  pages/               Home, Invoices, Add (manual + Excel import), Reports, Settings/*
  components/          UI kit, bottom sheet, invoice form/card/sheet, item picker
  lib/excel.ts         gateway & template parsing, Excel export (SheetJS, lazy-loaded)
  lib/invoicePaper.ts  per-store printable invoice templates (ARVO + default) and data mapping
  lib/invoiceExport.ts invoice paper → PNG / PDF (html2canvas-pro + jsPDF, lazy-loaded)
```

**Invoice paper**: opening an invoice shows it as a printable paper (tab «الفاتورة») with PNG/PDF export. Each store's look is a template in `web/src/lib/invoicePaper.ts`; stores without one use a plain default. ARVO's logo and seal are `web/public/invoice/arvo/logo.png` and `seal.png` (a missing file just leaves that spot empty). Exported files are named like the original invoices: `Purchase_Invoice_ARVO-<number>_<dd-mm-yyyy>_<total>`.

**Schema changes**: add `api/migrations/002_*.sql` (plain MySQL, `IF NOT EXISTS` / idempotent statements). It runs on the next request after deploy.

**Hosting notes**: SQL avoids triggers, procedures, JSON columns and other features that Hostinger shared hosting restricts; all tables are InnoDB `utf8mb4_unicode_ci`. The app uses relative URLs and a hash router, so it works from any sub-folder without rewrite rules. `api/.htaccess` blocks direct access to everything except `index.php`.

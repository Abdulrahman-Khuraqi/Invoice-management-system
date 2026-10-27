<?php
defined('APP') or exit;

function stores_list(): void
{
    $u = require_user();
    [$scope, $params] = store_scope_sql($u, 's.id');
    $stores = all(
        "SELECT s.id, s.name, s.color, s.is_active, s.sort,
                (SELECT COUNT(*) FROM invoices i WHERE i.store_id = s.id) AS invoice_count,
                (SELECT UNIX_TIMESTAMP(l.updated_at) FROM store_logos l WHERE l.store_id = s.id) AS logo_v,
                (SELECT l.bg FROM store_logos l WHERE l.store_id = s.id) AS logo_bg
         FROM stores s WHERE $scope ORDER BY s.is_active DESC, s.sort, s.id",
        $params
    );
    $terminals = all('SELECT terminal_id, store_id, label FROM store_terminals ORDER BY terminal_id');
    $infoRows = [];
    foreach (all('SELECT * FROM store_info') as $r) {
        $infoRows[(int)$r['store_id']] = $r;
    }
    $byStore = [];
    foreach ($terminals as $t) {
        $byStore[(int)$t['store_id']][] = ['terminal_id' => $t['terminal_id'], 'label' => $t['label']];
    }
    foreach ($stores as &$s) {
        $s['id'] = (int)$s['id'];
        $s['is_active'] = (bool)$s['is_active'];
        $s['invoice_count'] = (int)$s['invoice_count'];
        // Version stamp used as a cache-buster in the logo URL; null = no logo.
        $s['logo_v'] = $s['logo_v'] === null ? null : (int)$s['logo_v'];
        $s['logo_bg'] = $s['logo_v'] === null ? null : $s['logo_bg'];
        $s['terminals'] = $byStore[$s['id']] ?? [];
        $s['info'] = store_info_out($infoRows[$s['id']] ?? []);
        $s['code'] = store_code($s['id']);
    }
    json_out(['stores' => $stores]);
}

function stores_create(): void
{
    $u = require_user('admin');
    $b = body();
    $name = str_in($b['name'] ?? null, 120, true, 'اسم المتجر');
    assert_store_name_free($name);
    $sort = (int)scalar('SELECT COALESCE(MAX(sort), 0) + 1 FROM stores');
    q('INSERT INTO stores (name, color, sort) VALUES (?, ?, ?)', [$name, color_in($b['color'] ?? null, '#6366f1'), $sort]);
    $id = (int)db()->lastInsertId();
    log_activity($u, 'create', 'store', $id, "إضافة متجر: $name");
    json_out(['id' => $id]);
}

function stores_update(string $id): void
{
    $u = require_user('admin');
    $store = find_store((int)$id);
    $b = body();
    $name = array_key_exists('name', $b) ? str_in($b['name'], 120, true, 'اسم المتجر') : $store['name'];
    if ($name !== $store['name']) {
        assert_store_name_free($name, (int)$id);
    }
    $color = array_key_exists('color', $b) ? color_in($b['color'], $store['color']) : $store['color'];
    $sort = array_key_exists('sort', $b) ? (int)$b['sort'] : (int)$store['sort'];
    $active = array_key_exists('is_active', $b) ? bool_in($b['is_active']) : (bool)$store['is_active'];

    $info = array_key_exists('info', $b) && is_array($b['info']) ? store_info_in($b['info']) : null;

    q('UPDATE stores SET name = ?, color = ?, sort = ?, is_active = ? WHERE id = ?', [$name, $color, $sort, (int)$active, (int)$id]);
    if ($info !== null) {
        store_info_save((int)$id, $info);
    }
    if (array_key_exists('code', $b) && strtoupper(trim((string)$b['code'])) !== store_code((int)$id)) {
        store_code_set((int)$id, $b['code']);
    }
    if ($active !== (bool)$store['is_active']) {
        log_activity($u, $active ? 'restore' : 'archive', 'store', (int)$id, ($active ? 'استعادة متجر: ' : 'أرشفة متجر: ') . $name);
    } else {
        log_activity($u, 'update', 'store', (int)$id, "تعديل متجر: $name");
    }
    json_out(['ok' => true]);
}

const STORE_INFO_FIELDS = [
    'website' => 255, 'phone' => 60, 'whatsapp' => 60, 'email' => 150,
    'address' => 255, 'cr_number' => 40, 'vat_number' => 40, 'notes' => 1000,
];

/** Always returns every field (null when empty) so the app can bind inputs directly. */
function store_info_out(array $row): array
{
    $out = [];
    foreach (STORE_INFO_FIELDS as $f => $_) {
        $out[$f] = $row[$f] ?? null;
    }
    return $out;
}

/** Validates the optional info fields. A bare "example.com" website gets https:// added. */
function store_info_in(array $in): array
{
    $out = [];
    foreach (STORE_INFO_FIELDS as $f => $max) {
        $out[$f] = str_in($in[$f] ?? null, $max);
    }
    // Phone / ID numbers: store Western digits so tel: and wa.me links work.
    foreach (['phone', 'whatsapp', 'cr_number', 'vat_number'] as $f) {
        if ($out[$f] !== null) {
            $out[$f] = strtr($out[$f], ['٠' => '0', '١' => '1', '٢' => '2', '٣' => '3', '٤' => '4', '٥' => '5', '٦' => '6', '٧' => '7', '٨' => '8', '٩' => '9']);
        }
    }
    if ($out['website'] !== null) {
        if (!preg_match('#^https?://#i', $out['website'])) {
            // Any other scheme (ftp://, javascript:, data: ...) is refused rather than prefixed.
            if (preg_match('#^[a-z][a-z0-9+.\-]*://#i', $out['website']) || preg_match('#^(javascript|data|vbscript|file):#i', $out['website'])) {
                fail(422, 'رابط الموقع غير صحيح');
            }
            $out['website'] = 'https://' . $out['website'];
        }
        $scheme = strtolower((string)parse_url($out['website'], PHP_URL_SCHEME));
        if (!filter_var($out['website'], FILTER_VALIDATE_URL) || !in_array($scheme, ['http', 'https'], true)) {
            fail(422, 'رابط الموقع غير صحيح');
        }
    }
    if ($out['email'] !== null && !filter_var($out['email'], FILTER_VALIDATE_EMAIL)) {
        fail(422, 'البريد الإلكتروني غير صحيح');
    }
    return $out;
}

function store_info_save(int $storeId, array $info): void
{
    if (!array_filter($info, fn($v) => $v !== null)) {
        q('DELETE FROM store_info WHERE store_id = ?', [$storeId]);
        return;
    }
    $cols = array_keys(STORE_INFO_FIELDS);
    q(
        'INSERT INTO store_info (store_id, ' . implode(', ', $cols) . ') VALUES (?, ' . placeholders($cols) . ')
         ON DUPLICATE KEY UPDATE ' . implode(', ', array_map(fn($c) => "$c = VALUES($c)", $cols)),
        array_merge([$storeId], array_map(fn($c) => $info[$c], $cols))
    );
}

const LOGO_MAX_BYTES = 524288; // 512 KB; the web app downsizes to ~256px before uploading
const LOGO_TYPES = ['image/png' => 'png', 'image/jpeg' => 'jpg', 'image/webp' => 'webp'];

/** Body: {"data": "data:image/png;base64,..."} (PNG, JPEG or WebP). SVG is refused on purpose (script injection). */
function stores_logo_save(string $id): void
{
    $u = require_user('admin');
    $store = find_store((int)$id);
    $raw = body()['data'] ?? null;
    $bg = (body()['bg'] ?? 'light') === 'dark' ? 'dark' : 'light';
    if (!is_string($raw) || !preg_match('#^data:(image/[a-z+]+);base64,([A-Za-z0-9+/=\s]+)$#', $raw, $m)) {
        fail(422, 'صيغة الصورة غير صحيحة');
    }
    $bin = base64_decode(preg_replace('/\s+/', '', $m[2]), true);
    if ($bin === false || $bin === '') {
        fail(422, 'صيغة الصورة غير صحيحة');
    }
    if (strlen($bin) > LOGO_MAX_BYTES) {
        fail(422, 'حجم الشعار كبير، الحد الأقصى 512 كيلوبايت');
    }
    // Trust the file's real content, not the declared type.
    $info = @getimagesizefromstring($bin);
    if (!$info || !isset(LOGO_TYPES[$info['mime']])) {
        fail(422, 'الملف ليس صورة مدعومة (PNG أو JPG أو WebP)');
    }
    if ($info[0] > 2048 || $info[1] > 2048) {
        fail(422, 'أبعاد الصورة كبيرة جداً');
    }
    q(
        'INSERT INTO store_logos (store_id, mime, bg, data, updated_at) VALUES (?, ?, ?, ?, NOW())
         ON DUPLICATE KEY UPDATE mime = VALUES(mime), bg = VALUES(bg), data = VALUES(data), updated_at = NOW()',
        [(int)$id, $info['mime'], $bg, $bin]
    );
    log_activity($u, 'update', 'store', (int)$id, 'تحديث شعار متجر: ' . $store['name']);
    json_out(['ok' => true]);
}

function stores_logo_delete(string $id): void
{
    $u = require_user('admin');
    $store = find_store((int)$id);
    q('DELETE FROM store_logos WHERE store_id = ?', [(int)$id]);
    log_activity($u, 'update', 'store', (int)$id, 'حذف شعار متجر: ' . $store['name']);
    json_out(['ok' => true]);
}

/** Streams the image. The app adds ?v=<logo_v>, so it can be cached for a long time. */
function stores_logo_get(string $id): void
{
    $u = require_user();
    assert_store_access($u, (int)$id);
    $row = one('SELECT mime, data FROM store_logos WHERE store_id = ?', [(int)$id]);
    if (!$row) {
        fail(404, 'لا يوجد شعار');
    }
    header('Content-Type: ' . $row['mime']);
    header('Content-Length: ' . strlen($row['data']));
    header('Cache-Control: private, max-age=31536000, immutable');
    header("Content-Security-Policy: default-src 'none'");
    echo $row['data'];
    exit;
}

/** Hard delete is only allowed for a store with no invoices; otherwise archive or move invoices first. */
function stores_delete(string $id): void
{
    $u = require_user('admin');
    $store = find_store((int)$id);
    $count = (int)scalar('SELECT COUNT(*) FROM invoices WHERE store_id = ?', [(int)$id]);
    if ($count > 0) {
        fail(409, "لا يمكن حذف متجر عليه $count فاتورة. انقل الفواتير لمتجر آخر أو أرشف المتجر بدلاً من ذلك", ['invoice_count' => $count]);
    }
    db()->beginTransaction();
    // Items of this store still used by invoices elsewhere (after a move) become shared instead of being deleted.
    q('UPDATE catalog_items SET store_id = NULL WHERE store_id = ? AND id IN (SELECT item_id FROM invoice_items)', [(int)$id]);
    q('DELETE FROM stores WHERE id = ?', [(int)$id]);
    log_activity($u, 'delete', 'store', (int)$id, 'حذف متجر: ' . $store['name']);
    db()->commit();
    json_out(['ok' => true]);
}

function stores_move_invoices(string $id): void
{
    $u = require_user('admin');
    $from = find_store((int)$id);
    $toId = int_in(body()['to_store_id'] ?? null, true, 'المتجر الجديد');
    $to = find_store($toId);
    if ($toId === (int)$id) {
        fail(422, 'اختر متجراً مختلفاً');
    }
    db()->beginTransaction();
    $n = q('UPDATE invoices SET store_id = ?, updated_by = ? WHERE store_id = ?', [$toId, $u['id'], (int)$id])->rowCount();
    // Store-specific catalog items move with the invoices so their history stays consistent.
    q('UPDATE catalog_items SET store_id = ? WHERE store_id = ?', [$toId, (int)$id]);
    log_activity($u, 'move', 'store', (int)$id, "نقل $n فاتورة من {$from['name']} إلى {$to['name']}");
    db()->commit();
    json_out(['moved' => $n]);
}

/** Creates or reassigns a terminal (TerminalID from the payment gateway) to a store. */
function terminals_save(): void
{
    $u = require_user('admin');
    $b = body();
    $tid = str_in($b['terminal_id'] ?? null, 64, true, 'رقم الجهاز');
    if (!preg_match('/^[\w\-]+$/', $tid)) {
        fail(422, 'رقم الجهاز غير صحيح');
    }
    $storeId = int_in($b['store_id'] ?? null, true, 'المتجر');
    $store = find_store($storeId);
    q(
        'INSERT INTO store_terminals (terminal_id, store_id, label) VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE store_id = VALUES(store_id), label = VALUES(label)',
        [$tid, $storeId, str_in($b['label'] ?? null, 120)]
    );
    log_activity($u, 'update', 'terminal', null, "ربط الجهاز $tid بمتجر {$store['name']}");
    json_out(['ok' => true]);
}

function terminals_delete(string $tid): void
{
    $u = require_user('admin');
    q('DELETE FROM store_terminals WHERE terminal_id = ?', [$tid]);
    log_activity($u, 'delete', 'terminal', null, "إلغاء ربط الجهاز $tid");
    json_out(['ok' => true]);
}

function find_store(int $id): array
{
    $s = one('SELECT * FROM stores WHERE id = ?', [$id]);
    if (!$s) {
        fail(404, 'المتجر غير موجود');
    }
    return $s;
}

function assert_store_name_free(string $name, int $exceptId = 0): void
{
    if (scalar('SELECT id FROM stores WHERE name = ? AND id <> ?', [$name, $exceptId])) {
        fail(422, 'يوجد متجر بنفس الاسم');
    }
}

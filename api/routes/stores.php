<?php
defined('APP') or exit;

function stores_list(): void
{
    $u = require_user();
    [$scope, $params] = store_scope_sql($u, 's.id');
    $stores = all(
        "SELECT s.id, s.name, s.color, s.is_active, s.sort,
                (SELECT COUNT(*) FROM invoices i WHERE i.store_id = s.id) AS invoice_count
         FROM stores s WHERE $scope ORDER BY s.is_active DESC, s.sort, s.id",
        $params
    );
    $terminals = all('SELECT terminal_id, store_id, label FROM store_terminals ORDER BY terminal_id');
    $byStore = [];
    foreach ($terminals as $t) {
        $byStore[(int)$t['store_id']][] = ['terminal_id' => $t['terminal_id'], 'label' => $t['label']];
    }
    foreach ($stores as &$s) {
        $s['id'] = (int)$s['id'];
        $s['is_active'] = (bool)$s['is_active'];
        $s['invoice_count'] = (int)$s['invoice_count'];
        $s['terminals'] = $byStore[$s['id']] ?? [];
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

    q('UPDATE stores SET name = ?, color = ?, sort = ?, is_active = ? WHERE id = ?', [$name, $color, $sort, (int)$active, (int)$id]);
    if ($active !== (bool)$store['is_active']) {
        log_activity($u, $active ? 'restore' : 'archive', 'store', (int)$id, ($active ? 'استعادة متجر: ' : 'أرشفة متجر: ') . $name);
    } else {
        log_activity($u, 'update', 'store', (int)$id, "تعديل متجر: $name");
    }
    json_out(['ok' => true]);
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

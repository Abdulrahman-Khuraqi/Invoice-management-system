<?php
defined('APP') or exit;

/** Returns which of the given gateway TransactionIDs already exist, for the import preview. */
function import_check(): void
{
    require_user('editor');
    $ids = body()['transaction_ids'] ?? [];
    if (!is_array($ids) || count($ids) > 5000) {
        fail(422, 'قائمة غير صحيحة');
    }
    $ids = array_values(array_unique(array_filter(array_map(fn($v) => is_scalar($v) ? substr((string)$v, 0, 64) : '', $ids))));
    $existing = [];
    foreach (array_chunk($ids, 500) as $chunk) {
        $existing = array_merge($existing, array_column(
            all('SELECT transaction_id FROM invoices WHERE transaction_id IN (' . placeholders($chunk) . ')', $chunk),
            'transaction_id'
        ));
    }
    json_out(['existing' => $existing]);
}

/**
 * Inserts a batch of rows parsed from the gateway's Excel export.
 * Rows whose TransactionID already exists are skipped, so re-importing a file is safe.
 * Body: { rows: [...], terminals: [{terminal_id, store_id}] } — terminals are remembered for next time.
 * A row may carry item_id (service/product, from the Excel template) and a note.
 */
function import_rows(): void
{
    $u = require_user('editor');
    $b = body();
    $rows = $b['rows'] ?? null;
    if (!is_array($rows) || !$rows) {
        fail(422, 'لا توجد بيانات للاستيراد');
    }
    if (count($rows) > 500) {
        fail(422, 'الدفعة كبيرة جداً، الحد 500 صف');
    }

    db()->beginTransaction();

    if (is_array($b['terminals'] ?? null) && $u['role'] === 'admin') {
        $t = db()->prepare(
            'INSERT INTO store_terminals (terminal_id, store_id) VALUES (?, ?) ON DUPLICATE KEY UPDATE store_id = VALUES(store_id)'
        );
        foreach ($b['terminals'] as $term) {
            $tid = str_in($term['terminal_id'] ?? null, 64);
            $sid = int_in($term['store_id'] ?? null);
            if ($tid && $sid && preg_match('/^[\w\-]+$/', $tid)) {
                find_store($sid);
                $t->execute([$tid, $sid]);
            }
        }
    }

    $ins = db()->prepare(
        'INSERT IGNORE INTO invoices (store_id, transaction_id, invoice_no, customer_name, email, phone, amount, status,
            pay_method, card_type, card_last4, terminal_id, reference_no, auth_code, created_at_src, paid_at, note, source, created_by, updated_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'import\', ?, ?)'
    );
    $line = db()->prepare('INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price) VALUES (?, ?, 1, ?)');
    $itemCache = [];
    $storeCache = [];
    $inserted = 0;
    $skipped = 0;
    $sum = 0.0;
    foreach ($rows as $i => $r) {
        if (!is_array($r)) {
            fail(422, 'صف غير صحيح رقم ' . ($i + 1));
        }
        $storeId = int_in($r['store_id'] ?? null, true, 'المتجر');
        if (!isset($storeCache[$storeId])) {
            find_store($storeId);
            assert_store_access($u, $storeId);
            $storeCache[$storeId] = true;
        }
        $txn = str_in($r['transaction_id'] ?? null, 64, true, 'رقم العملية (TransactionID)');
        $amount = money_in($r['amount'] ?? null, true, 'المبلغ');
        $paid = date_in($r['paid_at'] ?? null) ?? date_in($r['created_at_src'] ?? null) ?? date('Y-m-d H:i:s');
        $itemId = int_in($r['item_id'] ?? null);
        if ($itemId !== null && !array_key_exists($itemId, $itemCache)) {
            $item = one('SELECT id, store_id FROM catalog_items WHERE id = ? AND is_active = 1', [$itemId]);
            $itemCache[$itemId] = $item ? ($item['store_id'] === null ? null : (int)$item['store_id']) : false;
        }
        // Ignore an item that doesn't exist or belongs to another store.
        if ($itemId !== null && ($itemCache[$itemId] === false || ($itemCache[$itemId] !== null && $itemCache[$itemId] !== $storeId))) {
            $itemId = null;
        }
        $ins->execute([
            $storeId, $txn,
            str_in($r['invoice_no'] ?? null, 64),
            str_in($r['customer_name'] ?? null, 160),
            str_in($r['email'] ?? null, 160),
            str_in($r['phone'] ?? null, 40),
            $amount,
            str_in($r['status'] ?? null, 40) ?? 'Paid',
            str_in($r['pay_method'] ?? null, 40),
            str_in($r['card_type'] ?? null, 40),
            str_in($r['card_last4'] ?? null, 8),
            str_in($r['terminal_id'] ?? null, 64),
            str_in($r['reference_no'] ?? null, 64),
            str_in($r['auth_code'] ?? null, 32),
            date_in($r['created_at_src'] ?? null),
            $paid,
            str_in($r['note'] ?? null, 5000),
            $u['id'], $u['id'],
        ]);
        if ($ins->rowCount() > 0) {
            if ($itemId !== null) {
                $line->execute([(int)db()->lastInsertId(), $itemId, $amount]);
            }
            $inserted++;
            $sum += $amount;
        } else {
            $skipped++;
        }
    }
    if ($inserted > 0) {
        $file = str_in($b['file_name'] ?? null, 120);
        log_activity($u, 'import', 'invoice', null, "استيراد $inserted فاتورة" . ($file ? " من $file" : '') . ' بمجموع ' . round($sum, 2));
    }
    db()->commit();
    json_out(['inserted' => $inserted, 'skipped' => $skipped]);
}

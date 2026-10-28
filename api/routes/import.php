<?php
defined('APP') or exit;

/**
 * Import preview. Body: { transaction_ids: [...], ids: [...] }.
 * Returns `existing` (which TransactionIDs are already stored, so re-imports skip them) and `invoices`
 * (full current data of the invoices matching a TransactionID or a system id, within the user's stores),
 * which the app compares with an edited Excel file to offer updates.
 */
function import_check(): void
{
    $u = require_user('editor');
    $b = body();
    $ids = $b['transaction_ids'] ?? [];
    $invIds = $b['ids'] ?? [];
    if (!is_array($ids) || !is_array($invIds) || count($ids) > 5000 || count($invIds) > 5000) {
        fail(422, 'قائمة غير صحيحة');
    }
    $ids = array_values(array_unique(array_filter(array_map(fn($v) => is_scalar($v) ? substr((string)$v, 0, 64) : '', $ids))));
    $invIds = array_values(array_unique(array_filter(array_map('intval', $invIds), fn($i) => $i > 0)));

    $existing = [];
    foreach (array_chunk($ids, 500) as $chunk) {
        $existing = array_merge($existing, array_column(
            all('SELECT transaction_id FROM invoices WHERE transaction_id IN (' . placeholders($chunk) . ')', $chunk),
            'transaction_id'
        ));
    }

    [$scope, $scopeParams] = store_scope_sql($u, 'i.store_id');
    $found = [];
    foreach (array_chunk($ids, 500) as $chunk) {
        foreach (all('SELECT ' . INVOICE_COLUMNS . ' ' . INVOICE_FROM . ' WHERE i.transaction_id IN (' . placeholders($chunk) . ") AND $scope", array_merge($chunk, $scopeParams)) as $r) {
            $found[(int)$r['id']] = $r;
        }
    }
    foreach (array_chunk($invIds, 500) as $chunk) {
        foreach (all('SELECT ' . INVOICE_COLUMNS . ' ' . INVOICE_FROM . ' WHERE i.id IN (' . placeholders($chunk) . ") AND $scope", array_merge($chunk, $scopeParams)) as $r) {
            $found[(int)$r['id']] = $r;
        }
    }
    json_out(['existing' => $existing, 'invoices' => attach_lines(array_map('cast_invoice', array_values($found)))]);
}

const IMPORT_UPDATE_FIELDS = ['store_id', 'paid_at', 'amount', 'customer_name', 'phone', 'email', 'invoice_no',
    'pay_method', 'note', 'card_type', 'card_last4', 'reference_no', 'auth_code'];

/**
 * Updates existing invoices from an edited Excel file.
 * Body: { rows: [{ id, <any of IMPORT_UPDATE_FIELDS>, items?: [{item_id, qty?, unit_price?}] }], file_name }.
 * Only the given fields change; a row that fails validation is rolled back on its own and reported,
 * the rest still apply. Returns { updated, unchanged, errors: [{id, message}] }.
 */
function import_update(): void
{
    $u = require_user('editor');
    $b = body();
    $rows = $b['rows'] ?? null;
    if (!is_array($rows) || !$rows) {
        fail(422, 'لا توجد بيانات للتحديث');
    }
    if (count($rows) > 500) {
        fail(422, 'الدفعة كبيرة جداً، الحد 500 صف');
    }

    $updated = 0;
    $unchanged = 0;
    $errors = [];
    db()->beginTransaction();
    foreach ($rows as $r) {
        if (!is_array($r)) {
            fail(422, 'صف غير صحيح');
        }
        $id = int_in($r['id'] ?? null, true, 'معرّف الفاتورة');
        db()->exec('SAVEPOINT row_update');
        try {
            $existing = load_invoice($id, $u);
            $patch = array_intersect_key($r, array_flip(IMPORT_UPDATE_FIELDS));
            $d = invoice_input($patch + $existing, $u, $existing['store_id']);
            $hasItems = array_key_exists('items', $r);
            if (!$hasItems && !invoice_fields_changed($existing, $d)) {
                $unchanged++;
                db()->exec('RELEASE SAVEPOINT row_update');
                continue;
            }
            q(
                'UPDATE invoices SET store_id = ?, invoice_no = ?, customer_name = ?, email = ?, phone = ?, amount = ?, status = ?,
                    pay_method = ?, card_type = ?, card_last4 = ?, reference_no = ?, auth_code = ?, paid_at = ?, note = ?, updated_by = ?
                 WHERE id = ?',
                [$d['store_id'], $d['invoice_no'], $d['customer_name'], $d['email'], $d['phone'], $d['amount'], $d['status'],
                    $d['pay_method'], $d['card_type'], $d['card_last4'], $d['reference_no'], $d['auth_code'], $d['paid_at'],
                    $d['note'], $u['id'], $id]
            );
            if ($hasItems) {
                save_lines($id, $d['store_id'], $r['items'], $d['amount'], $u, array_column($existing['lines'], 'item_id'));
            }
            db()->exec('RELEASE SAVEPOINT row_update');
            $updated++;
        } catch (HttpError $e) {
            db()->exec('ROLLBACK TO SAVEPOINT row_update');
            $errors[] = ['id' => $id, 'message' => $e->getMessage()];
        }
    }
    if ($updated > 0) {
        $file = str_in($b['file_name'] ?? null, 120);
        log_activity($u, 'update', 'invoice', null, "تحديث $updated فاتورة من ملف Excel" . ($file ? " ($file)" : ''));
    }
    db()->commit();
    json_out(['updated' => $updated, 'unchanged' => $unchanged, 'errors' => $errors]);
}

function invoice_fields_changed(array $old, array $new): bool
{
    foreach (IMPORT_UPDATE_FIELDS as $f) {
        if ($f === 'amount') {
            if (abs((float)$old['amount'] - (float)$new['amount']) > 0.004) {
                return true;
            }
        } elseif ((string)($old[$f] ?? '') !== (string)($new[$f] ?? '')) {
            return true;
        }
    }
    return false;
}

/** Fields an already-imported invoice takes from the file again, but only where it is still empty. */
const IMPORT_FILL_FIELDS = ['invoice_no' => 64, 'customer_name' => 160, 'email' => 160, 'phone' => 40, 'pay_method' => 40,
    'card_type' => 40, 'card_last4' => 8, 'terminal_id' => 64, 'reference_no' => 64, 'auth_code' => 32];

/**
 * Inserts a batch of rows parsed from the gateway's Excel export.
 * Rows whose TransactionID already exists are not added again; their empty fields (e.g. an email that an
 * earlier import missed) are filled from the row, nothing already set is overwritten.
 * Body: { rows: [...], terminals: [{terminal_id, store_id}] } — terminals are remembered for next time.
 * A row may carry item_id (service/product, from the Excel template) and a note.
 * Returns { inserted, filled, skipped }.
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
    $fill = db()->prepare(
        'UPDATE invoices SET '
        . implode(', ', array_map(fn($f) => "$f = COALESCE(NULLIF($f, ''), ?, $f)", array_keys(IMPORT_FILL_FIELDS)))
        . ', created_at_src = COALESCE(created_at_src, ?) WHERE transaction_id = ? AND store_id = ?'
    );
    $itemCache = [];
    $storeCache = [];
    $inserted = 0;
    $filled = 0;
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
            // Already imported: only fill what is still empty, and only in a store this user may edit.
            $values = [];
            foreach (IMPORT_FILL_FIELDS as $f => $max) {
                $values[] = str_in($r[$f] ?? null, $max);
            }
            $fill->execute(array_merge($values, [date_in($r['created_at_src'] ?? null), $txn, $storeId]));
            if ($fill->rowCount() > 0) {
                $filled++;
            } else {
                $skipped++;
            }
        }
    }
    $file = str_in($b['file_name'] ?? null, 120);
    if ($inserted > 0) {
        assign_invoice_numbers();
        log_activity($u, 'import', 'invoice', null, "استيراد $inserted فاتورة" . ($file ? " من $file" : '') . ' بمجموع ' . round($sum, 2));
    }
    if ($filled > 0) {
        log_activity($u, 'update', 'invoice', null, "إكمال بيانات $filled فاتورة" . ($file ? " من $file" : ''));
    }
    db()->commit();
    json_out(['inserted' => $inserted, 'filled' => $filled, 'skipped' => $skipped]);
}

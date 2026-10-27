<?php
defined('APP') or exit;

const INVOICE_COLUMNS = 'i.id, i.store_id, i.transaction_id, i.invoice_no, n.doc_no, i.customer_name, i.email, i.phone, i.amount,
    i.status, i.pay_method, i.card_type, i.card_last4, i.terminal_id, i.reference_no, i.auth_code,
    i.created_at_src, i.paid_at, i.note, i.source, i.created_at, i.updated_at,
    s.name AS store_name, s.color AS store_color, cu.display_name AS created_by_name, uu.display_name AS updated_by_name';

const INVOICE_FROM = 'FROM invoices i
    JOIN stores s ON s.id = i.store_id
    LEFT JOIN invoice_numbers n ON n.invoice_id = i.id
    LEFT JOIN users cu ON cu.id = i.created_by
    LEFT JOIN users uu ON uu.id = i.updated_by';

const SORTS = [
    'paid_desc' => 'COALESCE(i.paid_at, i.created_at) DESC, i.id DESC',
    'paid_asc' => 'COALESCE(i.paid_at, i.created_at) ASC, i.id ASC',
    'amount_desc' => 'i.amount DESC, i.id DESC',
    'amount_asc' => 'i.amount ASC, i.id ASC',
    'added_desc' => 'i.id DESC',
];

function like_escape(string $s): string
{
    return '%' . addcslashes($s, '%_\\') . '%';
}

/** WHERE clause shared by the list, export and stats endpoints. */
function invoice_filters(array $u, array $in): array
{
    [$scope, $params] = store_scope_sql($u, 'i.store_id');
    $where = [$scope];

    if (($store = int_in($in['store'] ?? null)) !== null) {
        $where[] = 'i.store_id = ?';
        $params[] = $store;
    }
    if (($q = str_in($in['q'] ?? null, 100)) !== null) {
        $like = like_escape($q);
        $cols = ['i.customer_name', 'i.phone', 'i.email', 'i.invoice_no', 'i.reference_no', 'i.auth_code',
            'i.transaction_id', 'i.card_last4', 'i.note', 'i.terminal_id'];
        $parts = array_map(fn($c) => "$c LIKE ?", $cols);
        $parts[] = 'EXISTS (SELECT 1 FROM invoice_numbers sn WHERE sn.invoice_id = i.id AND sn.doc_no LIKE ?)';
        $parts[] = 'EXISTS (SELECT 1 FROM invoice_items sii JOIN catalog_items sci ON sci.id = sii.item_id
                     WHERE sii.invoice_id = i.id AND (sci.name LIKE ? OR sii.line_note LIKE ?))';
        $where[] = '(' . implode(' OR ', $parts) . ')';
        $params = array_merge($params, array_fill(0, count($cols) + 3, $like));
        // Amount search: "1500" also finds invoices of exactly 1500.
        if (is_numeric(str_replace(',', '', $q))) {
            $where[count($where) - 1] = '(' . implode(' OR ', $parts) . ' OR i.amount = ?)';
            $params[] = (float)str_replace(',', '', $q);
        }
    }
    if (($item = int_in($in['item'] ?? null)) !== null) {
        $where[] = 'EXISTS (SELECT 1 FROM invoice_items fi WHERE fi.invoice_id = i.id AND fi.item_id = ?)';
        $params[] = $item;
    }
    if (in_array($in['kind'] ?? '', ['service', 'product'], true)) {
        $where[] = 'EXISTS (SELECT 1 FROM invoice_items fk JOIN catalog_items fkc ON fkc.id = fk.item_id
                     WHERE fk.invoice_id = i.id AND fkc.kind = ?)';
        $params[] = $in['kind'];
    }
    if (($cat = int_in($in['category'] ?? null)) !== null) {
        $where[] = 'EXISTS (SELECT 1 FROM invoice_items fc JOIN catalog_items fcc ON fcc.id = fc.item_id
                     WHERE fc.invoice_id = i.id AND fcc.category_id = ?)';
        $params[] = $cat;
    }
    if (bool_in($in['unclassified'] ?? null)) {
        $where[] = 'NOT EXISTS (SELECT 1 FROM invoice_items fu WHERE fu.invoice_id = i.id)';
    }
    if (($from = date_in($in['from'] ?? null)) !== null) {
        $where[] = 'COALESCE(i.paid_at, i.created_at) >= ?';
        $params[] = substr($from, 0, 10) . ' 00:00:00';
    }
    if (($to = date_in($in['to'] ?? null)) !== null) {
        $where[] = 'COALESCE(i.paid_at, i.created_at) <= ?';
        $params[] = substr($to, 0, 10) . ' 23:59:59';
    }
    if (($min = money_in($in['min'] ?? null)) !== null) {
        $where[] = 'i.amount >= ?';
        $params[] = $min;
    }
    if (($max = money_in($in['max'] ?? null)) !== null) {
        $where[] = 'i.amount <= ?';
        $params[] = $max;
    }
    if (($pm = str_in($in['pay_method'] ?? null, 40)) !== null) {
        $where[] = 'i.pay_method = ?';
        $params[] = $pm;
    }
    if (in_array($in['source'] ?? '', ['import', 'manual'], true)) {
        $where[] = 'i.source = ?';
        $params[] = $in['source'];
    }
    return [implode(' AND ', $where), $params];
}

function invoices_list(): void
{
    $u = require_user();
    session_write_close();
    assign_invoice_numbers();
    [$where, $params] = invoice_filters($u, $_GET);
    $perPage = min(max((int)($_GET['per_page'] ?? 30), 1), 5000); // large pages are used by Excel export
    $page = max((int)($_GET['page'] ?? 1), 1);
    $order = SORTS[$_GET['sort'] ?? ''] ?? SORTS['paid_desc'];

    $totals = one("SELECT COUNT(*) AS n, COALESCE(SUM(i.amount), 0) AS total FROM invoices i WHERE $where", $params);
    $rows = all(
        'SELECT ' . INVOICE_COLUMNS . ' ' . INVOICE_FROM . " WHERE $where ORDER BY $order LIMIT $perPage OFFSET " . (($page - 1) * $perPage),
        $params
    );
    json_out([
        'invoices' => attach_lines(array_map('cast_invoice', $rows)),
        'total' => (int)$totals['n'],
        'sum' => (float)$totals['total'],
        'page' => $page,
        'per_page' => $perPage,
    ]);
}

function invoices_get(string $id): void
{
    $u = require_user();
    json_out(['invoice' => load_invoice((int)$id, $u)]);
}

function invoices_create(): void
{
    $u = require_user('editor');
    $b = body();
    $d = invoice_input($b, $u);
    if ($d['transaction_id'] !== null && scalar('SELECT id FROM invoices WHERE transaction_id = ?', [$d['transaction_id']])) {
        fail(422, 'توجد فاتورة بنفس رقم العملية');
    }
    db()->beginTransaction();
    q(
        'INSERT INTO invoices (store_id, transaction_id, invoice_no, customer_name, email, phone, amount, status, pay_method,
            card_type, card_last4, terminal_id, reference_no, auth_code, paid_at, note, source, created_by, updated_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, \'manual\', ?, ?)',
        [$d['store_id'], $d['transaction_id'], $d['invoice_no'], $d['customer_name'], $d['email'], $d['phone'], $d['amount'],
            $d['status'], $d['pay_method'], $d['card_type'], $d['card_last4'], $d['terminal_id'], $d['reference_no'],
            $d['auth_code'], $d['paid_at'], $d['note'], $u['id'], $u['id']]
    );
    $id = (int)db()->lastInsertId();
    if (array_key_exists('items', $b)) {
        save_lines($id, $d['store_id'], $b['items'], $d['amount'], $u);
    }
    assign_invoice_numbers();
    log_activity($u, 'create', 'invoice', $id, 'إضافة فاتورة ' . ($d['customer_name'] ?? '') . ' بمبلغ ' . $d['amount']);
    db()->commit();
    json_out(['invoice' => load_invoice($id, $u)]);
}

function invoices_update(string $id): void
{
    $u = require_user('editor');
    $existing = load_invoice((int)$id, $u);
    $b = body();
    // Partial updates: missing fields keep their current values.
    $d = invoice_input($b + $existing, $u, $existing['store_id']);

    db()->beginTransaction();
    q(
        'UPDATE invoices SET store_id = ?, invoice_no = ?, customer_name = ?, email = ?, phone = ?, amount = ?, status = ?,
            pay_method = ?, card_type = ?, card_last4 = ?, reference_no = ?, auth_code = ?, paid_at = ?, note = ?, updated_by = ?
         WHERE id = ?',
        [$d['store_id'], $d['invoice_no'], $d['customer_name'], $d['email'], $d['phone'], $d['amount'], $d['status'],
            $d['pay_method'], $d['card_type'], $d['card_last4'], $d['reference_no'], $d['auth_code'], $d['paid_at'],
            $d['note'], $u['id'], (int)$id]
    );
    if (array_key_exists('items', $b)) {
        save_lines((int)$id, $d['store_id'], $b['items'], $d['amount'], $u, array_column($existing['lines'], 'item_id'));
        log_activity($u, 'classify', 'invoice', (int)$id, 'تحديد الخدمة/المنتج لفاتورة ' . ($d['customer_name'] ?? '#' . $id));
    } else {
        log_activity($u, 'update', 'invoice', (int)$id, 'تعديل فاتورة ' . ($d['customer_name'] ?? '#' . $id));
    }
    db()->commit();
    json_out(['invoice' => load_invoice((int)$id, $u)]);
}

function invoices_delete(string $id): void
{
    $u = require_user('editor');
    $inv = load_invoice((int)$id, $u);
    q('DELETE FROM invoices WHERE id = ?', [(int)$id]);
    log_activity($u, 'delete', 'invoice', (int)$id, 'حذف فاتورة ' . ($inv['customer_name'] ?? '') . ' بمبلغ ' . $inv['amount']);
    json_out(['ok' => true]);
}

/** Bulk actions on selected invoices: delete, assign a service/product, or move to another store. */
function invoices_bulk(): void
{
    $u = require_user('editor');
    $b = body();
    $ids = id_list($b['ids'] ?? null);
    if (!$ids) {
        fail(422, 'لم يتم اختيار أي فاتورة');
    }
    [$scope, $scopeParams] = store_scope_sql($u, 'store_id');
    $rows = all('SELECT id, store_id, amount FROM invoices WHERE id IN (' . placeholders($ids) . ") AND $scope", array_merge($ids, $scopeParams));
    if (count($rows) !== count($ids)) {
        fail(403, 'بعض الفواتير غير موجودة أو ليست لديك صلاحية عليها');
    }
    $n = count($rows);

    db()->beginTransaction();
    switch ($b['action'] ?? '') {
        case 'delete':
            q('DELETE FROM invoices WHERE id IN (' . placeholders($ids) . ')', $ids);
            log_activity($u, 'delete', 'invoice', null, "حذف جماعي لـ $n فاتورة");
            break;

        case 'assign_item':
            $item = one('SELECT * FROM catalog_items WHERE id = ?', [int_in($b['item_id'] ?? null, true, 'الخدمة/المنتج')]);
            if (!$item || !(int)$item['is_active']) {
                fail(422, 'الخدمة/المنتج غير موجود');
            }
            if ($item['store_id'] !== null) {
                foreach ($rows as $r) {
                    if ((int)$r['store_id'] !== (int)$item['store_id']) {
                        fail(422, 'هذا العنصر خاص بمتجر آخر؛ بعض الفواتير المختارة من متجر مختلف');
                    }
                }
            }
            $append = ($b['mode'] ?? 'replace') === 'append';
            if (!$append) {
                q('DELETE FROM invoice_items WHERE invoice_id IN (' . placeholders($ids) . ')', $ids);
            }
            $ins = db()->prepare('INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price) VALUES (?, ?, 1, ?)');
            foreach ($rows as $r) {
                $ins->execute([$r['id'], $item['id'], $append ? (float)($item['default_price'] ?? 0) : (float)$r['amount']]);
            }
            q('UPDATE invoices SET updated_by = ? WHERE id IN (' . placeholders($ids) . ')', array_merge([$u['id']], $ids));
            log_activity($u, 'classify', 'invoice', null, "تحديد «{$item['name']}» لـ $n فاتورة");
            break;

        case 'move_store':
            $storeId = int_in($b['store_id'] ?? null, true, 'المتجر');
            $store = find_store($storeId);
            assert_store_access($u, $storeId);
            q('UPDATE invoices SET store_id = ?, updated_by = ? WHERE id IN (' . placeholders($ids) . ')', array_merge([$storeId, $u['id']], $ids));
            log_activity($u, 'move', 'invoice', null, "نقل $n فاتورة إلى {$store['name']}");
            break;

        default:
            fail(422, 'إجراء غير معروف');
    }
    db()->commit();
    json_out(['affected' => $n]);
}

// ---- helpers -------------------------------------------------------------

/** $currentStoreId is the invoice's store before an update (null when creating). */
function invoice_input(array $b, array $u, ?int $currentStoreId = null): array
{
    $storeId = int_in($b['store_id'] ?? null, true, 'المتجر');
    $store = find_store($storeId);
    assert_store_access($u, $storeId);
    // Archived stores keep their old invoices but don't receive new ones.
    if (!(int)$store['is_active'] && $storeId !== $currentStoreId) {
        fail(422, 'هذا المتجر مؤرشف، استعده أولاً من الإعدادات');
    }
    $amount = money_in($b['amount'] ?? null, true, 'المبلغ');
    $last4 = str_in($b['card_last4'] ?? null, 8);
    if ($last4 !== null && !preg_match('/^\d{1,8}$/', $last4)) {
        fail(422, 'آخر 4 أرقام من البطاقة غير صحيحة');
    }
    $email = str_in($b['email'] ?? null, 160);
    return [
        'store_id' => $storeId,
        'transaction_id' => str_in($b['transaction_id'] ?? null, 64),
        'invoice_no' => str_in($b['invoice_no'] ?? null, 64),
        'customer_name' => str_in($b['customer_name'] ?? null, 160),
        'email' => $email,
        'phone' => str_in($b['phone'] ?? null, 40),
        'amount' => $amount,
        'status' => str_in($b['status'] ?? null, 40) ?? 'Paid',
        'pay_method' => str_in($b['pay_method'] ?? null, 40),
        'card_type' => str_in($b['card_type'] ?? null, 40),
        'card_last4' => $last4,
        'terminal_id' => str_in($b['terminal_id'] ?? null, 64),
        'reference_no' => str_in($b['reference_no'] ?? null, 64),
        'auth_code' => str_in($b['auth_code'] ?? null, 32),
        'paid_at' => date_in($b['paid_at'] ?? null, true, 'تاريخ الفاتورة'),
        'note' => str_in($b['note'] ?? null, 5000),
    ];
}

/**
 * Replaces an invoice's service/product lines.
 * Items must be active (unless already on this invoice) and belong to the invoice's store or be shared.
 */
function save_lines(int $invoiceId, int $storeId, $lines, float $amount, array $u, array $keepItemIds = []): void
{
    if (!is_array($lines)) {
        fail(422, 'قائمة الخدمات/المنتجات غير صحيحة');
    }
    if (count($lines) > 50) {
        fail(422, 'عدد البنود كبير جداً');
    }
    q('DELETE FROM invoice_items WHERE invoice_id = ?', [$invoiceId]);
    $ins = db()->prepare('INSERT INTO invoice_items (invoice_id, item_id, qty, unit_price, line_note) VALUES (?, ?, ?, ?, ?)');
    foreach ($lines as $line) {
        if (!is_array($line)) {
            fail(422, 'بند غير صحيح');
        }
        $itemId = int_in($line['item_id'] ?? null, true, 'الخدمة/المنتج');
        $item = one('SELECT id, store_id, is_active, name FROM catalog_items WHERE id = ?', [$itemId]);
        if (!$item) {
            fail(422, 'الخدمة/المنتج غير موجود');
        }
        if (!(int)$item['is_active'] && !in_array($itemId, $keepItemIds, true)) {
            fail(422, "«{$item['name']}» مؤرشف ولا يمكن إضافته");
        }
        if ($item['store_id'] !== null && (int)$item['store_id'] !== $storeId) {
            fail(422, "«{$item['name']}» خاص بمتجر آخر");
        }
        $qty = money_in($line['qty'] ?? 1, false, 'الكمية') ?? 1;
        if ($qty <= 0) {
            fail(422, 'الكمية يجب أن تكون أكبر من صفر');
        }
        // A single line without a price takes the invoice amount, so the common case is one tap.
        $price = money_in($line['unit_price'] ?? null, false, 'السعر');
        if ($price === null) {
            $price = count($lines) === 1 ? round($amount / $qty, 2) : 0;
        }
        $ins->execute([$invoiceId, $itemId, $qty, $price, str_in($line['line_note'] ?? null, 255)]);
    }
}

function load_invoice(int $id, array $u): array
{
    assign_invoice_numbers();
    $row = one('SELECT ' . INVOICE_COLUMNS . ' ' . INVOICE_FROM . ' WHERE i.id = ?', [$id]);
    if (!$row) {
        fail(404, 'الفاتورة غير موجودة');
    }
    assert_store_access($u, (int)$row['store_id']);
    return attach_lines([cast_invoice($row)])[0];
}

function cast_invoice(array $r): array
{
    $r['id'] = (int)$r['id'];
    $r['store_id'] = (int)$r['store_id'];
    $r['amount'] = (float)$r['amount'];
    return $r;
}

/** Adds each invoice's service/product lines in one query. */
function attach_lines(array $invoices): array
{
    if (!$invoices) {
        return [];
    }
    $ids = array_column($invoices, 'id');
    $lines = all(
        'SELECT ii.invoice_id, ii.item_id, ii.qty, ii.unit_price, ii.line_note, ci.name, ci.kind, ci.is_active,
                cc.name AS category_name, cc.color AS category_color
         FROM invoice_items ii
         JOIN catalog_items ci ON ci.id = ii.item_id
         LEFT JOIN catalog_categories cc ON cc.id = ci.category_id
         WHERE ii.invoice_id IN (' . placeholders($ids) . ')
         ORDER BY ii.id',
        $ids
    );
    $by = [];
    foreach ($lines as $l) {
        $by[(int)$l['invoice_id']][] = [
            'item_id' => (int)$l['item_id'],
            'name' => $l['name'],
            'kind' => $l['kind'],
            'is_active' => (bool)$l['is_active'],
            'qty' => (float)$l['qty'],
            'unit_price' => (float)$l['unit_price'],
            'line_note' => $l['line_note'],
            'category_name' => $l['category_name'],
            'category_color' => $l['category_color'],
        ];
    }
    foreach ($invoices as &$inv) {
        $inv['lines'] = $by[$inv['id']] ?? [];
    }
    return $invoices;
}

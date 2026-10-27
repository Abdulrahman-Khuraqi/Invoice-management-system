<?php
defined('APP') or exit;

/*
 * Invoice numbers: CODE-YYMMDD-NNNN, e.g. ARV-261009-0001.
 *   CODE    2-4 letters/digits of the store (store_codes), taken from its name unless an admin sets it.
 *   YYMMDD  the invoice date when the number was issued.
 *   NNNN    counter for that code and day. It only goes up (invoice_counters), so numbers are never reused.
 * A number is issued once and never changes, even if the invoice is edited or moved to another store.
 */

/** "ARVO" → ARV, "anas" → ANA, "X Run Studio" → XRS, "Royal Games" → RG. Names without Latin letters → INV. */
function derive_store_code(string $name): string
{
    preg_match_all('/[A-Za-z0-9]+/', $name, $m);
    $words = $m[0];
    if (!$words) {
        return 'INV';
    }
    if (count($words) === 1) {
        return strtoupper(substr($words[0], 0, 3));
    }
    return strtoupper(implode('', array_map(fn($w) => $w[0], array_slice($words, 0, 3))));
}

function store_code_taken(string $code, int $exceptStoreId): bool
{
    return (bool)scalar('SELECT 1 FROM store_codes WHERE code = ? AND store_id <> ?', [$code, $exceptStoreId]);
}

/** The store's code; derived from its name and saved the first time it is needed. */
function store_code(int $storeId): string
{
    $code = scalar('SELECT code FROM store_codes WHERE store_id = ?', [$storeId]);
    if ($code !== null) {
        return (string)$code;
    }
    $store = find_store($storeId);
    $base = derive_store_code((string)$store['name']);
    $code = $base;
    // Another store already uses it: AR2, AR3 ... (never used for names that derive to something unique).
    for ($i = 2; store_code_taken($code, $storeId) && $i < 100; $i++) {
        $code = substr($base, 0, max(1, 4 - strlen((string)$i))) . $i;
    }
    q('INSERT IGNORE INTO store_codes (store_id, code) VALUES (?, ?)', [$storeId, $code]);
    return (string)scalar('SELECT code FROM store_codes WHERE store_id = ?', [$storeId]);
}

/** Admin-chosen code: 2-4 letters or digits. Only affects invoices numbered from now on. */
function store_code_set(int $storeId, $raw): void
{
    $code = strtoupper(trim((string)$raw));
    if (!preg_match('/^[A-Z0-9]{2,4}$/', $code)) {
        fail(422, 'رمز المتجر يجب أن يكون من 2 إلى 4 أحرف إنجليزية أو أرقام');
    }
    if (store_code_taken($code, $storeId)) {
        fail(422, 'رمز المتجر مستخدم في متجر آخر');
    }
    q('INSERT INTO store_codes (store_id, code) VALUES (?, ?) ON DUPLICATE KEY UPDATE code = VALUES(code)', [$storeId, $code]);
}

/** Next counter value for "CODE-YYMMDD", atomically (safe with concurrent requests). */
function next_counter(string $key): int
{
    q('INSERT INTO invoice_counters (k, n) VALUES (?, LAST_INSERT_ID(1)) ON DUPLICATE KEY UPDATE n = LAST_INSERT_ID(n + 1)', [$key]);
    return (int)scalar('SELECT LAST_INSERT_ID()');
}

/**
 * Gives a number to every invoice that has none: new ones, and all existing ones the first time this runs.
 * Oldest first, so earlier invoices get the lower counter of their day.
 */
function assign_invoice_numbers(): void
{
    $rows = all(
        'SELECT i.id, i.store_id, i.paid_at, i.created_at FROM invoices i
         WHERE NOT EXISTS (SELECT 1 FROM invoice_numbers n WHERE n.invoice_id = i.id)
         ORDER BY i.paid_at, i.id LIMIT 5000'
    );
    if (!$rows) {
        return;
    }
    $ins = db()->prepare('INSERT IGNORE INTO invoice_numbers (invoice_id, doc_no) VALUES (?, ?)');
    foreach ($rows as $r) {
        $when = (string)($r['paid_at'] ?? $r['created_at']);
        $day = substr($when, 2, 2) . substr($when, 5, 2) . substr($when, 8, 2);
        $prefix = store_code((int)$r['store_id']) . '-' . $day;
        $ins->execute([(int)$r['id'], $prefix . '-' . str_pad((string)next_counter($prefix), 4, '0', STR_PAD_LEFT)]);
    }
}

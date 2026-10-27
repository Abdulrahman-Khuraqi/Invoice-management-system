<?php
defined('APP') or exit;

// ---- categories ----------------------------------------------------------

function categories_list(): void
{
    require_user();
    $rows = all(
        'SELECT c.id, c.name, c.color, c.sort, (SELECT COUNT(*) FROM catalog_items i WHERE i.category_id = c.id) AS item_count
         FROM catalog_categories c ORDER BY c.sort, c.id'
    );
    foreach ($rows as &$r) {
        $r['id'] = (int)$r['id'];
        $r['item_count'] = (int)$r['item_count'];
    }
    json_out(['categories' => $rows]);
}

function categories_create(): void
{
    $u = require_user('editor');
    $b = body();
    $name = str_in($b['name'] ?? null, 120, true, 'اسم التصنيف');
    $sort = (int)scalar('SELECT COALESCE(MAX(sort), 0) + 1 FROM catalog_categories');
    q('INSERT INTO catalog_categories (name, color, sort) VALUES (?, ?, ?)', [$name, color_in($b['color'] ?? null, '#0ea5e9'), $sort]);
    $id = (int)db()->lastInsertId();
    log_activity($u, 'create', 'category', $id, "إضافة تصنيف: $name");
    json_out(['id' => $id]);
}

function categories_update(string $id): void
{
    $u = require_user('editor');
    $c = one('SELECT * FROM catalog_categories WHERE id = ?', [(int)$id]) ?? fail(404, 'التصنيف غير موجود');
    $b = body();
    $name = array_key_exists('name', $b) ? str_in($b['name'], 120, true, 'اسم التصنيف') : $c['name'];
    $color = array_key_exists('color', $b) ? color_in($b['color'], $c['color']) : $c['color'];
    $sort = array_key_exists('sort', $b) ? (int)$b['sort'] : (int)$c['sort'];
    q('UPDATE catalog_categories SET name = ?, color = ?, sort = ? WHERE id = ?', [$name, $color, $sort, (int)$id]);
    log_activity($u, 'update', 'category', (int)$id, "تعديل تصنيف: $name");
    json_out(['ok' => true]);
}

function categories_delete(string $id): void
{
    $u = require_user('admin');
    $c = one('SELECT * FROM catalog_categories WHERE id = ?', [(int)$id]) ?? fail(404, 'التصنيف غير موجود');
    q('DELETE FROM catalog_categories WHERE id = ?', [(int)$id]); // items keep existing, category becomes empty
    log_activity($u, 'delete', 'category', (int)$id, 'حذف تصنيف: ' . $c['name']);
    json_out(['ok' => true]);
}

// ---- services & products -------------------------------------------------

function items_list(): void
{
    $u = require_user();
    $where = [];
    $params = [];
    [$scope, $scopeParams] = store_scope_sql($u, 'i.store_id');
    $where[] = "(i.store_id IS NULL OR $scope)";
    $params = array_merge($params, $scopeParams);

    if (!bool_in($_GET['include_inactive'] ?? null)) {
        $where[] = 'i.is_active = 1';
    }
    // For a given store: its own items plus the shared ones.
    if (($store = int_in($_GET['store'] ?? null)) !== null) {
        $where[] = '(i.store_id IS NULL OR i.store_id = ?)';
        $params[] = $store;
    }
    if (in_array($_GET['kind'] ?? '', ['service', 'product'], true)) {
        $where[] = 'i.kind = ?';
        $params[] = $_GET['kind'];
    }
    if (($q = str_in($_GET['q'] ?? null, 100)) !== null) {
        $where[] = '(i.name LIKE ? OR i.sku LIKE ? OR i.description LIKE ?)';
        array_push($params, "%$q%", "%$q%", "%$q%");
    }

    $rows = all(
        'SELECT i.id, i.kind, i.name, i.description, i.category_id, i.store_id, i.default_price, i.sku, i.is_active,
                r.price_min, r.price_max,
                c.name AS category_name, c.color AS category_color, s.name AS store_name,
                (SELECT COUNT(*) FROM invoice_items ii WHERE ii.item_id = i.id) AS usage_count
         FROM catalog_items i
         LEFT JOIN catalog_item_ranges r ON r.item_id = i.id
         LEFT JOIN catalog_categories c ON c.id = i.category_id
         LEFT JOIN stores s ON s.id = i.store_id
         WHERE ' . implode(' AND ', $where) . '
         ORDER BY i.is_active DESC, usage_count DESC, i.name',
        $params
    );
    foreach ($rows as &$r) {
        $r['id'] = (int)$r['id'];
        $r['category_id'] = $r['category_id'] === null ? null : (int)$r['category_id'];
        $r['store_id'] = $r['store_id'] === null ? null : (int)$r['store_id'];
        $r['default_price'] = $r['default_price'] === null ? null : (float)$r['default_price'];
        $r['price_min'] = $r['price_min'] === null ? null : (float)$r['price_min'];
        $r['price_max'] = $r['price_max'] === null ? null : (float)$r['price_max'];
        $r['is_active'] = (bool)$r['is_active'];
        $r['usage_count'] = (int)$r['usage_count'];
    }
    json_out(['items' => $rows]);
}

function items_create(): void
{
    $u = require_user('editor');
    $data = item_input(body(), $u);
    q(
        'INSERT INTO catalog_items (kind, name, description, category_id, store_id, default_price, sku)
         VALUES (?, ?, ?, ?, ?, ?, ?)',
        [$data['kind'], $data['name'], $data['description'], $data['category_id'], $data['store_id'], $data['default_price'], $data['sku']]
    );
    $id = (int)db()->lastInsertId();
    item_range_save($id, $data['price_min'], $data['price_max']);
    log_activity($u, 'create', 'item', $id, ($data['kind'] === 'service' ? 'إضافة خدمة: ' : 'إضافة منتج: ') . $data['name']);
    json_out(['id' => $id]);
}

function items_update(string $id): void
{
    $u = require_user('editor');
    $item = find_item((int)$id, $u);
    $b = body() + [
        'kind' => $item['kind'], 'name' => $item['name'], 'description' => $item['description'],
        'category_id' => $item['category_id'], 'store_id' => $item['store_id'],
        'default_price' => $item['default_price'], 'sku' => $item['sku'],
    ];
    $data = item_input($b, $u);
    $active = array_key_exists('is_active', body()) ? bool_in(body()['is_active']) : (bool)$item['is_active'];
    q(
        'UPDATE catalog_items SET kind = ?, name = ?, description = ?, category_id = ?, store_id = ?, default_price = ?, sku = ?, is_active = ?
         WHERE id = ?',
        [$data['kind'], $data['name'], $data['description'], $data['category_id'], $data['store_id'], $data['default_price'], $data['sku'], (int)$active, (int)$id]
    );
    // Clients that don't send the range keys leave the stored range alone.
    if (array_key_exists('price_min', body()) || array_key_exists('price_max', body())) {
        item_range_save((int)$id, $data['price_min'], $data['price_max']);
    }
    log_activity($u, 'update', 'item', (int)$id, 'تعديل: ' . $data['name']);
    json_out(['ok' => true]);
}

/** Items used on invoices are archived (kept for history); unused ones are deleted. */
function items_delete(string $id): void
{
    $u = require_user('editor');
    $item = find_item((int)$id, $u);
    $used = (int)scalar('SELECT COUNT(*) FROM invoice_items WHERE item_id = ?', [(int)$id]);
    if ($used > 0) {
        q('UPDATE catalog_items SET is_active = 0 WHERE id = ?', [(int)$id]);
        log_activity($u, 'archive', 'item', (int)$id, 'أرشفة: ' . $item['name']);
        json_out(['archived' => true, 'usage_count' => $used]);
    }
    q('DELETE FROM catalog_items WHERE id = ?', [(int)$id]);
    log_activity($u, 'delete', 'item', (int)$id, 'حذف: ' . $item['name']);
    json_out(['deleted' => true]);
}

function item_input(array $b, array $u): array
{
    $kind = in_array($b['kind'] ?? '', ['service', 'product'], true) ? $b['kind'] : 'service';
    $categoryId = int_in($b['category_id'] ?? null);
    if ($categoryId !== null && !scalar('SELECT id FROM catalog_categories WHERE id = ?', [$categoryId])) {
        fail(422, 'التصنيف غير موجود');
    }
    $storeId = int_in($b['store_id'] ?? null);
    if ($storeId !== null) {
        find_store($storeId);
        assert_store_access($u, $storeId);
    } elseif (allowed_stores($u) !== null) {
        fail(403, 'إضافة عنصر مشترك لكل المتاجر تتطلب صلاحية على كل المتاجر');
    }
    $price = money_in($b['default_price'] ?? null, false, 'السعر');
    if ($price !== null && $price < 0) {
        fail(422, 'السعر غير صحيح');
    }
    $min = money_in($b['price_min'] ?? null, false, 'أقل سعر');
    $max = money_in($b['price_max'] ?? null, false, 'أعلى سعر');
    if (($min === null) !== ($max === null)) {
        fail(422, 'أدخل أقل سعر وأعلى سعر معاً');
    }
    if ($min !== null && ($min < 0 || $max < $min)) {
        fail(422, 'نطاق السعر غير صحيح');
    }
    return [
        'kind' => $kind,
        'name' => str_in($b['name'] ?? null, 160, true, 'الاسم'),
        'description' => str_in($b['description'] ?? null, 500),
        'category_id' => $categoryId,
        'store_id' => $storeId,
        'default_price' => $price,
        'price_min' => $min,
        'price_max' => $max,
        'sku' => str_in($b['sku'] ?? null, 64),
    ];
}

/** Saves the optional price range of an item; null/null removes it. */
function item_range_save(int $itemId, ?float $min, ?float $max): void
{
    if ($min === null || $max === null) {
        q('DELETE FROM catalog_item_ranges WHERE item_id = ?', [$itemId]);
        return;
    }
    q(
        'INSERT INTO catalog_item_ranges (item_id, price_min, price_max) VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE price_min = VALUES(price_min), price_max = VALUES(price_max)',
        [$itemId, $min, $max]
    );
}

function find_item(int $id, array $u): array
{
    $item = one('SELECT * FROM catalog_items WHERE id = ?', [$id]);
    if (!$item) {
        fail(404, 'العنصر غير موجود');
    }
    if ($item['store_id'] !== null) {
        assert_store_access($u, (int)$item['store_id']);
    }
    return $item;
}

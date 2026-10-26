<?php
defined('APP') or exit;

function users_list(): void
{
    require_user('admin');
    $users = all('SELECT id, username, display_name, role, is_active, created_at, last_login_at FROM users ORDER BY is_active DESC, id');
    foreach ($users as &$x) {
        $x['id'] = (int)$x['id'];
        $x['is_active'] = (bool)$x['is_active'];
        $x['store_ids'] = user_store_ids($x['id']);
    }
    json_out(['users' => $users]);
}

function users_create(): void
{
    $u = require_user('admin');
    $b = body();
    $username = validate_username($b['username'] ?? null);
    if (scalar('SELECT id FROM users WHERE username = ?', [$username])) {
        fail(422, 'اسم المستخدم مستخدم مسبقاً');
    }
    $role = role_in($b['role'] ?? null);
    db()->beginTransaction();
    q(
        'INSERT INTO users (username, display_name, password_hash, role) VALUES (?, ?, ?, ?)',
        [$username, str_in($b['display_name'] ?? null, 120, true, 'الاسم'), password_hash(validate_password($b['password'] ?? null), PASSWORD_DEFAULT), $role]
    );
    $id = (int)db()->lastInsertId();
    save_user_stores($id, $b['store_ids'] ?? []);
    log_activity($u, 'create', 'user', $id, "إضافة مستخدم: $username");
    db()->commit();
    json_out(['id' => $id]);
}

function users_update(string $id): void
{
    $u = require_user('admin');
    $target = one('SELECT * FROM users WHERE id = ?', [(int)$id]) ?? fail(404, 'المستخدم غير موجود');
    $b = body();
    $role = array_key_exists('role', $b) ? role_in($b['role']) : $target['role'];
    $active = array_key_exists('is_active', $b) ? bool_in($b['is_active']) : (bool)$target['is_active'];

    if ((int)$id === $u['id'] && ($role !== 'admin' || !$active)) {
        fail(422, 'لا يمكنك إزالة صلاحية المدير أو إيقاف حسابك بنفسك');
    }
    if ($target['role'] === 'admin' && ($role !== 'admin' || !$active)) {
        assert_not_last_admin((int)$id);
    }

    db()->beginTransaction();
    q(
        'UPDATE users SET display_name = ?, role = ?, is_active = ? WHERE id = ?',
        [array_key_exists('display_name', $b) ? str_in($b['display_name'], 120, true, 'الاسم') : $target['display_name'], $role, (int)$active, (int)$id]
    );
    if (!empty($b['password'])) {
        q('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash(validate_password($b['password']), PASSWORD_DEFAULT), (int)$id]);
    }
    if (array_key_exists('store_ids', $b)) {
        save_user_stores((int)$id, $b['store_ids']);
    }
    log_activity($u, 'update', 'user', (int)$id, 'تعديل مستخدم: ' . $target['username']);
    db()->commit();
    json_out(['ok' => true]);
}

/** Users who have done work are deactivated (to keep the history); others are deleted. */
function users_delete(string $id): void
{
    $u = require_user('admin');
    $target = one('SELECT * FROM users WHERE id = ?', [(int)$id]) ?? fail(404, 'المستخدم غير موجود');
    if ((int)$id === $u['id']) {
        fail(422, 'لا يمكنك حذف حسابك');
    }
    if ($target['role'] === 'admin') {
        assert_not_last_admin((int)$id);
    }
    $hasHistory = scalar('SELECT 1 FROM invoices WHERE created_by = ? OR updated_by = ? LIMIT 1', [(int)$id, (int)$id])
        || scalar('SELECT 1 FROM activity_log WHERE user_id = ? LIMIT 1', [(int)$id]);
    if ($hasHistory) {
        q('UPDATE users SET is_active = 0 WHERE id = ?', [(int)$id]);
        log_activity($u, 'archive', 'user', (int)$id, 'إيقاف مستخدم: ' . $target['username']);
        json_out(['deactivated' => true]);
    }
    q('DELETE FROM users WHERE id = ?', [(int)$id]);
    log_activity($u, 'delete', 'user', (int)$id, 'حذف مستخدم: ' . $target['username']);
    json_out(['deleted' => true]);
}

function activity_list(): void
{
    require_user('admin');
    $page = max((int)($_GET['page'] ?? 1), 1);
    $rows = all(
        'SELECT a.id, a.action, a.entity, a.entity_id, a.summary, a.created_at, u.display_name AS user_name
         FROM activity_log a LEFT JOIN users u ON u.id = a.user_id
         ORDER BY a.id DESC LIMIT 50 OFFSET ' . (($page - 1) * 50)
    );
    json_out(['activity' => $rows, 'page' => $page]);
}

function role_in($v): string
{
    return in_array($v, ['admin', 'editor', 'viewer'], true) ? $v : 'viewer';
}

function save_user_stores(int $userId, $storeIds): void
{
    q('DELETE FROM user_stores WHERE user_id = ?', [$userId]);
    foreach (id_list($storeIds) as $sid) {
        find_store($sid);
        q('INSERT INTO user_stores (user_id, store_id) VALUES (?, ?)', [$userId, $sid]);
    }
}

function assert_not_last_admin(int $exceptId): void
{
    if ((int)scalar("SELECT COUNT(*) FROM users WHERE role = 'admin' AND is_active = 1 AND id <> ?", [$exceptId]) === 0) {
        fail(422, 'يجب أن يبقى مدير واحد نشط على الأقل');
    }
}

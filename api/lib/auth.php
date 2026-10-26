<?php
defined('APP') or exit;

const ROLE_RANK = ['viewer' => 1, 'editor' => 2, 'admin' => 3];
const SESSION_LIFETIME = 60 * 60 * 24 * 30; // stay signed in for 30 days, like an app

function start_session(): void
{
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    ini_set('session.gc_maxlifetime', (string)SESSION_LIFETIME);
    ini_set('session.use_strict_mode', '1');
    session_name('INVSESS');
    session_set_cookie_params([
        'lifetime' => SESSION_LIFETIME,
        'path' => '/',
        'secure' => $https,
        'httponly' => true,
        'samesite' => 'Strict',
    ]);
    session_start();
}

/** The signed-in user (fresh from the DB so role changes and deactivation apply immediately). */
function current_user(): ?array
{
    static $user = false;
    if ($user === false) {
        $user = null;
        $id = $_SESSION['uid'] ?? null;
        if ($id) {
            $row = one('SELECT id, username, display_name, role, is_active FROM users WHERE id = ?', [$id]);
            if ($row && (int)$row['is_active'] === 1) {
                $row['id'] = (int)$row['id'];
                $row['is_active'] = true;
                $row['store_ids'] = user_store_ids($row['id']);
                $user = $row;
            }
        }
    }
    return $user;
}

function user_store_ids(int $userId): array
{
    return array_map('intval', array_column(all('SELECT store_id FROM user_stores WHERE user_id = ?', [$userId]), 'store_id'));
}

function require_user(string $minRole = 'viewer'): array
{
    $u = current_user();
    if (!$u) {
        fail(401, 'يجب تسجيل الدخول');
    }
    if (ROLE_RANK[$u['role']] < ROLE_RANK[$minRole]) {
        fail(403, 'ليست لديك صلاحية لهذا الإجراء');
    }
    return $u;
}

/** Store ids the user may see, or null for "all stores". */
function allowed_stores(array $u): ?array
{
    return $u['role'] === 'admin' || !$u['store_ids'] ? null : $u['store_ids'];
}

function can_access_store(array $u, int $storeId): bool
{
    $allowed = allowed_stores($u);
    return $allowed === null || in_array($storeId, $allowed, true);
}

function assert_store_access(array $u, int $storeId): void
{
    if (!can_access_store($u, $storeId)) {
        fail(403, 'ليست لديك صلاحية على هذا المتجر');
    }
}

/** SQL fragment restricting a store_id column to the user's stores. */
function store_scope_sql(array $u, string $column): array
{
    $allowed = allowed_stores($u);
    if ($allowed === null) {
        return ['1=1', []];
    }
    return ["$column IN (" . placeholders($allowed) . ")", $allowed];
}

function login_throttled(): bool
{
    q('DELETE FROM login_attempts WHERE attempted_at < (NOW() - INTERVAL 1 DAY)');
    $n = (int)scalar(
        'SELECT COUNT(*) FROM login_attempts WHERE ip = ? AND attempted_at > (NOW() - INTERVAL 15 MINUTE)',
        [client_ip()]
    );
    return $n >= 10;
}

function log_activity(?array $u, string $action, string $entity, ?int $entityId, string $summary): void
{
    q(
        'INSERT INTO activity_log (user_id, action, entity, entity_id, summary) VALUES (?, ?, ?, ?, ?)',
        [$u['id'] ?? null, $action, $entity, $entityId, mb_substr($summary, 0, 255)]
    );
}

<?php
defined('APP') or exit;

function setup_status(): void
{
    json_out(['needsSetup' => (int)scalar('SELECT COUNT(*) FROM users') === 0]);
}

/** Creates the very first admin. Only works while there are no users at all. */
function setup_create(): void
{
    if ((int)scalar('SELECT COUNT(*) FROM users') > 0) {
        fail(409, 'تم إعداد النظام مسبقاً');
    }
    $b = body();
    $username = validate_username($b['username'] ?? null);
    $name = str_in($b['display_name'] ?? null, 120, true, 'الاسم');
    $password = validate_password($b['password'] ?? null);

    db()->beginTransaction();
    if ((int)scalar('SELECT COUNT(*) FROM users FOR UPDATE') > 0) {
        fail(409, 'تم إعداد النظام مسبقاً');
    }
    q(
        'INSERT INTO users (username, display_name, password_hash, role) VALUES (?, ?, ?, ?)',
        [$username, $name, password_hash($password, PASSWORD_DEFAULT), 'admin']
    );
    $id = (int)db()->lastInsertId();
    db()->commit();

    session_regenerate_id(true);
    $_SESSION['uid'] = $id;
    log_activity(['id' => $id], 'setup', 'user', $id, 'إنشاء حساب المدير الأول');
    json_out(['user' => current_user()]);
}

function auth_login(): void
{
    if (login_throttled()) {
        fail(429, 'محاولات كثيرة، حاول مرة أخرى بعد 15 دقيقة');
    }
    $b = body();
    $username = strtolower(str_in($b['username'] ?? null, 64, true, 'اسم المستخدم'));
    $password = (string)($b['password'] ?? '');

    $row = one('SELECT id, password_hash, is_active FROM users WHERE username = ?', [$username]);
    if (!$row || !password_verify($password, $row['password_hash'])) {
        q('INSERT INTO login_attempts (ip) VALUES (?)', [client_ip()]);
        fail(401, 'اسم المستخدم أو كلمة المرور غير صحيحة');
    }
    if ((int)$row['is_active'] !== 1) {
        fail(403, 'هذا الحساب موقوف، تواصل مع المدير');
    }
    if (password_needs_rehash($row['password_hash'], PASSWORD_DEFAULT)) {
        q('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash($password, PASSWORD_DEFAULT), $row['id']]);
    }
    q('DELETE FROM login_attempts WHERE ip = ?', [client_ip()]);
    q('UPDATE users SET last_login_at = NOW() WHERE id = ?', [$row['id']]);

    session_regenerate_id(true);
    $_SESSION['uid'] = (int)$row['id'];
    json_out(['user' => current_user()]);
}

function auth_logout(): void
{
    $_SESSION = [];
    session_destroy();
    json_out(['ok' => true]);
}

function auth_me(): void
{
    $u = current_user();
    session_write_close();
    if (!$u) {
        fail(401, 'يجب تسجيل الدخول');
    }
    json_out(['user' => $u]);
}

function auth_change_password(): void
{
    $u = require_user();
    $b = body();
    $hash = (string)scalar('SELECT password_hash FROM users WHERE id = ?', [$u['id']]);
    if (!password_verify((string)($b['current_password'] ?? ''), $hash)) {
        fail(422, 'كلمة المرور الحالية غير صحيحة');
    }
    $new = validate_password($b['new_password'] ?? null);
    q('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash($new, PASSWORD_DEFAULT), $u['id']]);
    log_activity($u, 'update', 'user', $u['id'], 'تغيير كلمة المرور');
    json_out(['ok' => true]);
}

function validate_username($v): string
{
    $s = str_in($v, 64, true, 'اسم المستخدم');
    if (!preg_match('/^[A-Za-z0-9_.\-]{3,64}$/', $s)) {
        fail(422, 'اسم المستخدم يجب أن يكون 3 أحرف إنجليزية أو أرقام على الأقل');
    }
    return strtolower($s);
}

function validate_password($v): string
{
    $s = is_string($v) ? $v : '';
    if (mb_strlen($s) < 8) {
        fail(422, 'كلمة المرور يجب أن تكون 8 أحرف على الأقل');
    }
    return $s;
}

<?php
defined('APP') or exit;

function config(): array
{
    static $cfg = null;
    if ($cfg === null) {
        $file = __DIR__ . '/../config.php';
        if (!is_file($file)) {
            fail(500, 'ملف الإعدادات config.php غير موجود على السيرفر');
        }
        $cfg = require $file;
    }
    return $cfg;
}

function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $c = config();
        $dsn = sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
            $c['db_host'] ?? 'localhost',
            (int)($c['db_port'] ?? 3306),
            $c['db_name']
        );
        try {
            $pdo = new PDO($dsn, $c['db_user'], $c['db_pass'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::ATTR_STRINGIFY_FETCHES => false,
            ]);
        } catch (PDOException $e) {
            error_log('DB connect failed: ' . $e->getMessage());
            fail(500, 'تعذّر الاتصال بقاعدة البيانات، تحقق من بيانات الاتصال');
        }
        $pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
        $pdo->exec("SET time_zone = '+03:00'");
    }
    return $pdo;
}

function q(string $sql, array $params = []): PDOStatement
{
    $st = db()->prepare($sql);
    $st->execute($params);
    return $st;
}

function one(string $sql, array $params = []): ?array
{
    $row = q($sql, $params)->fetch();
    return $row === false ? null : $row;
}

function all(string $sql, array $params = []): array
{
    return q($sql, $params)->fetchAll();
}

function scalar(string $sql, array $params = [])
{
    $v = q($sql, $params)->fetchColumn();
    return $v === false ? null : $v;
}

/** Builds "?,?,?" for an IN() list. */
function placeholders(array $values): string
{
    return implode(',', array_fill(0, count($values), '?'));
}

/**
 * Applies any migrations in api/migrations/ that haven't run yet.
 * Uses only CREATE TABLE / INSERT so it works with Hostinger's restricted DB user.
 */
function ensure_schema(): void
{
    $pdo = db();
    $pdo->exec("CREATE TABLE IF NOT EXISTS app_migrations (
        name VARCHAR(191) NOT NULL PRIMARY KEY,
        applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");

    $files = glob(__DIR__ . '/../migrations/*.sql') ?: [];
    sort($files);
    $applied = array_flip($pdo->query('SELECT name FROM app_migrations')->fetchAll(PDO::FETCH_COLUMN));
    $pending = array_filter($files, fn($f) => !isset($applied[basename($f)]));
    if (!$pending) {
        return;
    }

    // Serialize concurrent first requests so a migration never runs twice.
    if ((int)scalar('SELECT GET_LOCK(?, 15)', ['invoice_app_migrate']) !== 1) {
        fail(503, 'جاري تجهيز قاعدة البيانات، حاول بعد لحظات');
    }
    try {
        $applied = array_flip($pdo->query('SELECT name FROM app_migrations')->fetchAll(PDO::FETCH_COLUMN));
        foreach ($pending as $file) {
            $name = basename($file);
            if (isset($applied[$name])) {
                continue;
            }
            foreach (split_sql((string)file_get_contents($file)) as $stmt) {
                $pdo->exec($stmt);
            }
            q('INSERT INTO app_migrations (name) VALUES (?)', [$name]);
        }
    } finally {
        scalar('SELECT RELEASE_LOCK(?)', ['invoice_app_migrate']);
    }
}

/** Splits a migration file on statement-ending semicolons, skipping -- comments. */
function split_sql(string $sql): array
{
    $lines = array_filter(
        preg_split('/\R/u', $sql),
        fn($l) => !preg_match('/^\s*--/u', $l)
    );
    $parts = preg_split('/;\s*(?:\R|$)/u', implode("\n", $lines));
    return array_values(array_filter(array_map('trim', $parts), fn($s) => $s !== ''));
}

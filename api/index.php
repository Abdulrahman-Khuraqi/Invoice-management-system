<?php
/**
 * Single entry point for the API. Routes are passed as ?r=<path>, e.g.
 *   GET  index.php?r=invoices&q=ahmed
 *   PUT  index.php?r=invoices/12
 * so no URL rewriting is required on the host.
 */
declare(strict_types=1);
define('APP', true);

header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');
header('Cache-Control: no-store');

require __DIR__ . '/lib/http.php';
require __DIR__ . '/lib/db.php';
require __DIR__ . '/lib/auth.php';
require __DIR__ . '/lib/numbering.php';
foreach (glob(__DIR__ . '/routes/*.php') as $file) {
    require $file;
}

const ROUTES = [
    ['GET', 'setup-status', 'setup_status'],
    ['POST', 'setup', 'setup_create'],
    ['POST', 'auth/login', 'auth_login'],
    ['POST', 'auth/logout', 'auth_logout'],
    ['GET', 'auth/me', 'auth_me'],
    ['POST', 'auth/password', 'auth_change_password'],

    ['GET', 'stores', 'stores_list'],
    ['POST', 'stores', 'stores_create'],
    ['PUT', 'stores/(\d+)', 'stores_update'],
    ['DELETE', 'stores/(\d+)', 'stores_delete'],
    ['GET', 'stores/(\d+)/logo', 'stores_logo_get'],
    ['POST', 'stores/(\d+)/logo', 'stores_logo_save'],
    ['DELETE', 'stores/(\d+)/logo', 'stores_logo_delete'],
    ['POST', 'stores/(\d+)/move-invoices', 'stores_move_invoices'],
    ['POST', 'terminals', 'terminals_save'],
    ['DELETE', 'terminals/([\w\-]+)', 'terminals_delete'],

    ['GET', 'catalog/categories', 'categories_list'],
    ['POST', 'catalog/categories', 'categories_create'],
    ['PUT', 'catalog/categories/(\d+)', 'categories_update'],
    ['DELETE', 'catalog/categories/(\d+)', 'categories_delete'],
    ['GET', 'catalog/items', 'items_list'],
    ['POST', 'catalog/items', 'items_create'],
    ['PUT', 'catalog/items/(\d+)', 'items_update'],
    ['DELETE', 'catalog/items/(\d+)', 'items_delete'],

    ['GET', 'invoices', 'invoices_list'],
    ['POST', 'invoices', 'invoices_create'],
    ['POST', 'invoices/bulk', 'invoices_bulk'],
    ['GET', 'invoices/(\d+)', 'invoices_get'],
    ['PUT', 'invoices/(\d+)', 'invoices_update'],
    ['DELETE', 'invoices/(\d+)', 'invoices_delete'],
    ['POST', 'import/check', 'import_check'],
    ['POST', 'import', 'import_rows'],
    ['POST', 'import/update', 'import_update'],

    ['GET', 'stats', 'stats_get'],

    ['GET', 'users', 'users_list'],
    ['POST', 'users', 'users_create'],
    ['PUT', 'users/(\d+)', 'users_update'],
    ['DELETE', 'users/(\d+)', 'users_delete'],
    ['GET', 'activity', 'activity_list'],
];

try {
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    $path = trim((string)($_GET['r'] ?? ''), '/');

    // Writes must come from our own app (fetch with this header); blocks cross-site form posts.
    if ($method !== 'GET' && ($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '') !== 'fetch') {
        fail(403, 'طلب غير مسموح');
    }

    start_session();
    ensure_schema();

    $matched = false;
    foreach (ROUTES as [$m, $pattern, $handler]) {
        if (preg_match('#^' . $pattern . '$#', $path, $args)) {
            $matched = true;
            if ($m === $method) {
                array_shift($args);
                $handler(...$args);
                json_out(['ok' => true]);
            }
        }
    }
    fail($matched ? 405 : 404, 'المسار غير موجود');
} catch (HttpError $e) {
    if (db_in_transaction()) {
        db()->rollBack();
    }
    json_out(['error' => $e->getMessage()] + $e->extra, $e->status);
} catch (Throwable $e) {
    if (db_in_transaction()) {
        db()->rollBack();
    }
    error_log('API error: ' . $e);
    $debug = is_file(__DIR__ . '/config.php') && !empty((require __DIR__ . '/config.php')['debug']);
    json_out(['error' => 'حدث خطأ غير متوقع في السيرفر'] + ($debug ? ['detail' => $e->getMessage()] : []), 500);
}

function db_in_transaction(): bool
{
    try {
        return db()->inTransaction();
    } catch (Throwable $e) {
        return false;
    }
}

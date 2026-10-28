<?php
defined('APP') or exit;

/** Dashboard and reports: totals per store, per service/product and per category, plus payment counts per day/week/month/year. */
function stats_get(): void
{
    $u = require_user();
    session_write_close();
    $filters = array_intersect_key($_GET, array_flip(['store', 'from', 'to']));
    [$where, $params] = invoice_filters($u, $filters);

    $totals = one(
        "SELECT COUNT(*) AS n, COALESCE(SUM(i.amount), 0) AS total,
                SUM(NOT EXISTS (SELECT 1 FROM invoice_items x WHERE x.invoice_id = i.id)) AS unclassified,
                COALESCE(SUM(CASE WHEN NOT EXISTS (SELECT 1 FROM invoice_items x WHERE x.invoice_id = i.id) THEN i.amount END), 0) AS unclassified_sum
         FROM invoices i WHERE $where",
        $params
    );

    $byStore = all(
        "SELECT s.id, s.name, s.color, COUNT(i.id) AS n, COALESCE(SUM(i.amount), 0) AS total
         FROM invoices i JOIN stores s ON s.id = i.store_id
         WHERE $where GROUP BY s.id, s.name, s.color ORDER BY total DESC",
        $params
    );

    // Revenue per service/product uses the line amounts (qty × unit price).
    $byItem = all(
        "SELECT ci.id, ci.name, ci.kind, COUNT(DISTINCT i.id) AS n, COALESCE(SUM(ii.qty * ii.unit_price), 0) AS total
         FROM invoices i
         JOIN invoice_items ii ON ii.invoice_id = i.id
         JOIN catalog_items ci ON ci.id = ii.item_id
         WHERE $where GROUP BY ci.id, ci.name, ci.kind ORDER BY total DESC LIMIT 50",
        $params
    );

    $byCategory = all(
        "SELECT cc.id, COALESCE(cc.name, 'بدون تصنيف') AS name, COALESCE(cc.color, '#94a3b8') AS color,
                COUNT(DISTINCT i.id) AS n, COALESCE(SUM(ii.qty * ii.unit_price), 0) AS total
         FROM invoices i
         JOIN invoice_items ii ON ii.invoice_id = i.id
         JOIN catalog_items ci ON ci.id = ii.item_id
         LEFT JOIN catalog_categories cc ON cc.id = ci.category_id
         WHERE $where GROUP BY cc.id, cc.name, cc.color ORDER BY total DESC",
        $params
    );

    $byKind = all(
        "SELECT ci.kind, COUNT(DISTINCT i.id) AS n, COALESCE(SUM(ii.qty * ii.unit_price), 0) AS total
         FROM invoices i
         JOIN invoice_items ii ON ii.invoice_id = i.id
         JOIN catalog_items ci ON ci.id = ii.item_id
         WHERE $where GROUP BY ci.kind",
        $params
    );

    $daily = all(
        "SELECT DATE(COALESCE(i.paid_at, i.created_at)) AS day, COUNT(*) AS n, COALESCE(SUM(i.amount), 0) AS total
         FROM invoices i WHERE $where GROUP BY day ORDER BY day DESC LIMIT 90",
        $params
    );

    // Payment counts over longer periods. Each row's `day` is the first day of its period
    // (week = Sunday, month = the 1st, year = 1 Jan), so the app treats every series the same way.
    $when = 'COALESCE(i.paid_at, i.created_at)';
    $period = fn(string $expr, int $limit) => all(
        "SELECT $expr AS day, COUNT(*) AS n, COALESCE(SUM(i.amount), 0) AS total
         FROM invoices i WHERE $where GROUP BY day ORDER BY day DESC LIMIT $limit",
        $params
    );
    $weekly = $period("DATE_SUB(DATE($when), INTERVAL (DAYOFWEEK($when) - 1) DAY)", 53);
    $monthly = $period("DATE_FORMAT($when, '%Y-%m-01')", 36);
    $yearly = $period("DATE_FORMAT($when, '%Y-01-01')", 10);

    // 1 = Sunday ... 7 = Saturday
    $byWeekday = all(
        "SELECT DAYOFWEEK($when) AS dow, COUNT(*) AS n FROM invoices i WHERE $where GROUP BY dow ORDER BY dow",
        $params
    );
    $busiest = one(
        "SELECT DATE($when) AS day, COUNT(*) AS n FROM invoices i WHERE $where GROUP BY day ORDER BY n DESC, day DESC LIMIT 1",
        $params
    );
    $span = one("SELECT MIN(DATE($when)) AS first_day, MAX(DATE($when)) AS last_day FROM invoices i WHERE $where", $params);

    $num = function (array $rows): array {
        foreach ($rows as &$r) {
            if (isset($r['id'])) {
                $r['id'] = (int)$r['id'];
            }
            $r['n'] = (int)$r['n'];
            if (isset($r['total'])) {
                $r['total'] = (float)$r['total'];
            }
            if (isset($r['dow'])) {
                $r['dow'] = (int)$r['dow'];
            }
        }
        return $rows;
    };

    json_out([
        'count' => (int)$totals['n'],
        'sum' => (float)$totals['total'],
        'unclassified' => (int)$totals['unclassified'],
        'unclassified_sum' => (float)$totals['unclassified_sum'],
        'by_store' => $num($byStore),
        'by_item' => $num($byItem),
        'by_category' => $num($byCategory),
        'by_kind' => $num($byKind),
        'daily' => array_reverse($num($daily)),
        'weekly' => array_reverse($num($weekly)),
        'monthly' => array_reverse($num($monthly)),
        'yearly' => array_reverse($num($yearly)),
        'by_weekday' => $num($byWeekday),
        'busiest' => $busiest ? ['day' => $busiest['day'], 'n' => (int)$busiest['n']] : null,
        'first_day' => $span['first_day'] ?? null,
        'last_day' => $span['last_day'] ?? null,
    ]);
}

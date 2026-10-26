<?php
defined('APP') or exit;

final class HttpError extends Exception
{
    public function __construct(public int $status, string $message, public array $extra = [])
    {
        parent::__construct($message);
    }
}

function json_out($data, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION);
    exit;
}

function fail(int $status, string $message, array $extra = []): void
{
    throw new HttpError($status, $message, $extra);
}

function body(): array
{
    static $data = null;
    if ($data === null) {
        $raw = file_get_contents('php://input');
        $data = $raw === '' ? [] : json_decode($raw, true);
        if (!is_array($data)) {
            fail(400, 'صيغة البيانات غير صحيحة');
        }
    }
    return $data;
}

// ---- input helpers -------------------------------------------------------

function str_in($v, int $max = 255, bool $required = false, string $label = 'الحقل'): ?string
{
    if ($v === null || (is_string($v) && trim($v) === '')) {
        if ($required) {
            fail(422, "$label مطلوب");
        }
        return null;
    }
    if (!is_scalar($v)) {
        fail(422, "$label غير صحيح");
    }
    $s = trim((string)$v);
    if (mb_strlen($s) > $max) {
        $s = mb_substr($s, 0, $max);
    }
    return $s;
}

function int_in($v, bool $required = false, string $label = 'الحقل'): ?int
{
    if ($v === null || $v === '') {
        if ($required) {
            fail(422, "$label مطلوب");
        }
        return null;
    }
    if (!is_numeric($v) || (int)$v != $v) {
        fail(422, "$label غير صحيح");
    }
    return (int)$v;
}

/** Accepts 1234.5, "1,234.50", "١٢٣٤٫٥" (Arabic digits). */
function money_in($v, bool $required = false, string $label = 'المبلغ'): ?float
{
    if ($v === null || $v === '') {
        if ($required) {
            fail(422, "$label مطلوب");
        }
        return null;
    }
    if (is_string($v)) {
        $v = strtr($v, ['٠' => '0', '١' => '1', '٢' => '2', '٣' => '3', '٤' => '4', '٥' => '5',
            '٦' => '6', '٧' => '7', '٨' => '8', '٩' => '9', '٫' => '.', '٬' => '', ',' => '', ' ' => '']);
    }
    if (!is_numeric($v)) {
        fail(422, "$label غير صحيح");
    }
    $n = round((float)$v, 2);
    if (abs($n) > 9999999999) {
        fail(422, "$label كبير جداً");
    }
    return $n;
}

/** Accepts "YYYY-MM-DD", "YYYY-MM-DD HH:MM[:SS]" or ISO "YYYY-MM-DDTHH:MM". Returns MySQL DATETIME. */
function date_in($v, bool $required = false, string $label = 'التاريخ'): ?string
{
    if ($v === null || $v === '') {
        if ($required) {
            fail(422, "$label مطلوب");
        }
        return null;
    }
    if (!is_string($v) || !preg_match('/^(\d{4}-\d{2}-\d{2})(?:[T ](\d{2}:\d{2})(?::(\d{2}))?)?/', $v, $m)) {
        fail(422, "$label غير صحيح");
    }
    $s = $m[1] . ' ' . ($m[2] ?? '00:00') . ':' . ($m[3] ?? '00');
    $dt = DateTime::createFromFormat('Y-m-d H:i:s', $s);
    if (!$dt || $dt->format('Y-m-d H:i:s') !== $s) {
        fail(422, "$label غير صحيح");
    }
    return $s;
}

function bool_in($v): bool
{
    return $v === true || $v === 1 || $v === '1' || $v === 'true';
}

function color_in($v, string $default): string
{
    return is_string($v) && preg_match('/^#[0-9a-fA-F]{6}$/', $v) ? strtolower($v) : $default;
}

function id_list($v): array
{
    if (!is_array($v)) {
        return [];
    }
    $ids = array_values(array_unique(array_filter(array_map('intval', $v), fn($i) => $i > 0)));
    if (count($ids) > 1000) {
        fail(422, 'عدد العناصر كبير جداً، الحد 1000');
    }
    return $ids;
}

function client_ip(): string
{
    return substr((string)($_SERVER['REMOTE_ADDR'] ?? 'unknown'), 0, 64);
}

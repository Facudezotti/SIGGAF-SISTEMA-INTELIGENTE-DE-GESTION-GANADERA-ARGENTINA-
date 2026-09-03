<?php

declare(strict_types=1);

namespace App\Core;

final class Auth
{
    public static function check(): bool
    {
        return is_array(Session::get('usuario'));
    }

    public static function user(): ?array
    {
        $user = Session::get('usuario');
        return is_array($user) ? $user : null;
    }

    public static function login(array $user): void
    {
        Session::regenerate();
        Session::put('usuario', [
            'id_usuario' => (int) $user['id_usuario'],
            'nombre_usuario' => $user['nombre_usuario'],
            'nombre_completo' => trim($user['nombre'] . ' ' . $user['apellido']),
            'rol' => $user['rol'],
            'permisos' => $user['permisos'] ?? [],
        ]);
    }

    public static function can(string $permission): bool
    {
        $user = self::user();
        return $user !== null && in_array($permission, $user['permisos'] ?? [], true);
    }

    public static function logout(): void
    {
        Session::destroy();
    }
}

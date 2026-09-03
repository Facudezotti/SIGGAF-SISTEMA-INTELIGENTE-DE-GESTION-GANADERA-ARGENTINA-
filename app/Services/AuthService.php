<?php

declare(strict_types=1);

namespace App\Services;

use App\Core\Auth;
use App\Repositories\UsuarioRepository;

final class AuthService
{
    public function autenticar(string $usuario, string $contrasena): bool
    {
        $registro = (new UsuarioRepository())->buscarParaAutenticacion($usuario);
        if ($registro === null || $registro['estado'] !== 'ACTIVO') {
            return false;
        }

        if (!password_verify($contrasena, $registro['hash_contrasena'])) {
            return false;
        }

        $registro['permisos'] = (new UsuarioRepository())->permisos((int) $registro['id_usuario']);
        Auth::login($registro);
        return true;
    }
}

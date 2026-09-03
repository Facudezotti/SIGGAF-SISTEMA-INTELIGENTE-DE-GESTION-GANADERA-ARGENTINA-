<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;

final class UsuarioRepository
{
    public function buscarParaAutenticacion(string $nombreUsuario): ?array
    {
        $sql = <<<'SQL'
            SELECT
                u.id_usuario,
                u.nombre_usuario,
                u.hash_contrasena,
                p.nombre,
                p.apellido,
                r.nombre AS rol,
                eu.codigo AS estado
            FROM usuario u
            INNER JOIN persona p ON p.id_persona = u.id_persona
            INNER JOIN rol r ON r.id_rol = u.id_rol
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.id_estado_usuario
            WHERE u.nombre_usuario = :nombre_usuario
            LIMIT 1
        SQL;

        $statement = Database::connection()->prepare($sql);
        $statement->execute(['nombre_usuario' => $nombreUsuario]);
        $usuario = $statement->fetch();
        return $usuario === false ? null : $usuario;
    }

    public function permisos(int $usuarioId): array
    {
        $sql = <<<'SQL'
            SELECT pe.nombre
            FROM usuario u
            INNER JOIN rol_permiso rp ON rp.id_rol = u.id_rol
            INNER JOIN permiso pe ON pe.id_permiso = rp.id_permiso
            WHERE u.id_usuario = :id_usuario
            ORDER BY pe.nombre
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['id_usuario' => $usuarioId]);
        return array_column($statement->fetchAll(), 'nombre');
    }
}

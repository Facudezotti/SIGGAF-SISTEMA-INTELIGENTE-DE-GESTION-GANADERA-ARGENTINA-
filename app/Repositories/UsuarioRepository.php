<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;
use PDO;

final class UsuarioRepository
{
    public function buscarParaAutenticacion(string $nombreUsuario): ?array
    {
        $sql = <<<'SQL'
            SELECT u.id_usuario, u.nombre_usuario, u.hash_contrasena,
                   p.nombre, p.apellido, r.nombre AS rol, eu.codigo AS estado
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
            SELECT DISTINCT permisos.nombre
            FROM (
                SELECT pe.nombre
                FROM usuario u
                INNER JOIN rol_permiso rp ON rp.id_rol = u.id_rol
                INNER JOIN permiso pe ON pe.id_permiso = rp.id_permiso
                WHERE u.id_usuario = :usuario_rol
                UNION
                SELECT pe.nombre
                FROM usuario_permiso up
                INNER JOIN permiso pe ON pe.id_permiso = up.id_permiso
                WHERE up.id_usuario = :usuario_directo
            ) AS permisos
            ORDER BY permisos.nombre
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['usuario_rol' => $usuarioId, 'usuario_directo' => $usuarioId]);
        return array_column($statement->fetchAll(), 'nombre');
    }

    public function listar(): array
    {
        $sql = <<<'SQL'
            SELECT u.id_usuario, u.nombre_usuario, p.nombre, p.apellido, p.correo,
                   r.nombre AS rol, eu.codigo AS estado
            FROM usuario u
            INNER JOIN persona p ON p.id_persona = u.id_persona
            INNER JOIN rol r ON r.id_rol = u.id_rol
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.id_estado_usuario
            ORDER BY p.apellido, p.nombre
        SQL;
        return Database::connection()->query($sql)->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $sql = <<<'SQL'
            SELECT u.id_usuario, u.id_persona, u.id_rol, u.id_estado_usuario,
                   u.nombre_usuario, p.nombre, p.apellido, p.cuil, p.direccion,
                   p.correo, p.telefono, r.nombre AS rol, eu.codigo AS estado
            FROM usuario u
            INNER JOIN persona p ON p.id_persona = u.id_persona
            INNER JOIN rol r ON r.id_rol = u.id_rol
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.id_estado_usuario
            WHERE u.id_usuario = :id
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['id' => $id]);
        $usuario = $statement->fetch();
        return $usuario === false ? null : $usuario;
    }

    public function roles(): array
    {
        return Database::connection()->query('SELECT id_rol, nombre, descripcion FROM rol ORDER BY nombre')->fetchAll();
    }

    public function estados(): array
    {
        return Database::connection()->query('SELECT id_estado_usuario, codigo, descripcion FROM estado_usuario ORDER BY codigo')->fetchAll();
    }

    public function catalogoPermisos(): array
    {
        return Database::connection()->query('SELECT id_permiso, nombre, descripcion FROM permiso ORDER BY nombre')->fetchAll();
    }

    public function preguntasActivas(): array
    {
        return Database::connection()->query('SELECT id_pregunta_seguridad, texto FROM pregunta_seguridad WHERE activa = TRUE ORDER BY texto')->fetchAll();
    }

    public function permisosDirectos(int $usuarioId): array
    {
        $statement = Database::connection()->prepare('SELECT id_permiso FROM usuario_permiso WHERE id_usuario = :id');
        $statement->execute(['id' => $usuarioId]);
        return array_map('intval', array_column($statement->fetchAll(), 'id_permiso'));
    }

    public function respuestasSeguridad(int $usuarioId): array
    {
        $sql = <<<'SQL'
            SELECT rsu.id_pregunta_seguridad, ps.texto, rsu.hash_respuesta
            FROM respuesta_seguridad_usuario rsu
            INNER JOIN pregunta_seguridad ps
                ON ps.id_pregunta_seguridad = rsu.id_pregunta_seguridad
            WHERE rsu.id_usuario = :id AND ps.activa = TRUE
            ORDER BY rsu.id_pregunta_seguridad
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['id' => $usuarioId]);
        return $statement->fetchAll();
    }

    public function existeNombreUsuario(string $nombreUsuario, ?int $exceptoId = null): bool
    {
        $sql = 'SELECT COUNT(*) FROM usuario WHERE nombre_usuario = :nombre';
        $params = ['nombre' => $nombreUsuario];
        if ($exceptoId !== null) {
            $sql .= ' AND id_usuario <> :excepto';
            $params['excepto'] = $exceptoId;
        }
        $statement = Database::connection()->prepare($sql);
        $statement->execute($params);
        return (int) $statement->fetchColumn() > 0;
    }

    public function crear(array $datos, array $permisos, array $respuestas): int
    {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $persona = $pdo->prepare(<<<'SQL'
                INSERT INTO persona (nombre, apellido, cuil, direccion, correo, telefono)
                VALUES (:nombre, :apellido, :cuil, :direccion, :correo, :telefono)
            SQL);
            $persona->execute([
                'nombre' => $datos['nombre'], 'apellido' => $datos['apellido'],
                'cuil' => $datos['cuil'], 'direccion' => $datos['direccion'],
                'correo' => $datos['correo'], 'telefono' => $datos['telefono'],
            ]);
            $idPersona = (int) $pdo->lastInsertId();

            $usuario = $pdo->prepare(<<<'SQL'
                INSERT INTO usuario (id_persona, id_rol, id_estado_usuario, nombre_usuario, hash_contrasena)
                VALUES (:id_persona, :id_rol, :id_estado_usuario, :nombre_usuario, :hash_contrasena)
            SQL);
            $usuario->execute([
                'id_persona' => $idPersona,
                'id_rol' => $datos['id_rol'],
                'id_estado_usuario' => $datos['id_estado_usuario'],
                'nombre_usuario' => $datos['nombre_usuario'],
                'hash_contrasena' => password_hash($datos['contrasena'], PASSWORD_DEFAULT),
            ]);
            $idUsuario = (int) $pdo->lastInsertId();
            $this->sincronizarPermisos($idUsuario, $permisos, $pdo);
            $this->reemplazarRespuestas($idUsuario, $respuestas, $pdo);
            $pdo->commit();
            return $idUsuario;
        } catch (\Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function actualizar(int $id, array $datos, array $permisos, array $respuestas = []): void
    {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $persona = $pdo->prepare(<<<'SQL'
                UPDATE persona SET nombre = :nombre, apellido = :apellido, cuil = :cuil,
                    direccion = :direccion, correo = :correo, telefono = :telefono
                WHERE id_persona = :id_persona
            SQL);
            $persona->execute([
                'nombre' => $datos['nombre'], 'apellido' => $datos['apellido'],
                'cuil' => $datos['cuil'], 'direccion' => $datos['direccion'],
                'correo' => $datos['correo'], 'telefono' => $datos['telefono'],
                'id_persona' => $datos['id_persona'],
            ]);

            $sql = 'UPDATE usuario SET id_rol = :id_rol, id_estado_usuario = :estado, nombre_usuario = :usuario';
            $params = ['id_rol' => $datos['id_rol'], 'estado' => $datos['id_estado_usuario'], 'usuario' => $datos['nombre_usuario'], 'id' => $id];
            if ($datos['contrasena'] !== '') {
                $sql .= ', hash_contrasena = :hash';
                $params['hash'] = password_hash($datos['contrasena'], PASSWORD_DEFAULT);
            }
            $sql .= ' WHERE id_usuario = :id';
            $statement = $pdo->prepare($sql);
            $statement->execute($params);
            $this->sincronizarPermisos($id, $permisos, $pdo);
            if ($respuestas !== []) {
                $this->reemplazarRespuestas($id, $respuestas, $pdo);
            }
            $pdo->commit();
        } catch (\Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function desactivar(int $id): void
    {
        $sql = <<<'SQL'
            UPDATE usuario
            SET id_estado_usuario = (SELECT id_estado_usuario FROM estado_usuario WHERE codigo = 'INACTIVO')
            WHERE id_usuario = :id
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['id' => $id]);
    }

    public function cantidadDuenosActivos(): int
    {
        $sql = <<<'SQL'
            SELECT COUNT(*) FROM usuario u
            INNER JOIN rol r ON r.id_rol = u.id_rol
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.id_estado_usuario
            WHERE r.nombre = 'DUENO' AND eu.codigo = 'ACTIVO'
        SQL;
        return (int) Database::connection()->query($sql)->fetchColumn();
    }

    public function actualizarContrasena(int $id, string $contrasena): void
    {
        $statement = Database::connection()->prepare('UPDATE usuario SET hash_contrasena = :hash WHERE id_usuario = :id');
        $statement->execute(['hash' => password_hash($contrasena, PASSWORD_DEFAULT), 'id' => $id]);
    }

    private function sincronizarPermisos(int $usuarioId, array $permisos, PDO $pdo): void
    {
        $delete = $pdo->prepare('DELETE FROM usuario_permiso WHERE id_usuario = :id');
        $delete->execute(['id' => $usuarioId]);
        $insert = $pdo->prepare('INSERT INTO usuario_permiso (id_usuario, id_permiso) VALUES (:usuario, :permiso)');
        foreach (array_unique(array_map('intval', $permisos)) as $permisoId) {
            if ($permisoId > 0) {
                $insert->execute(['usuario' => $usuarioId, 'permiso' => $permisoId]);
            }
        }
    }

    private function reemplazarRespuestas(int $usuarioId, array $respuestas, PDO $pdo): void
    {
        $delete = $pdo->prepare('DELETE FROM respuesta_seguridad_usuario WHERE id_usuario = :id');
        $delete->execute(['id' => $usuarioId]);
        $insert = $pdo->prepare(<<<'SQL'
            INSERT INTO respuesta_seguridad_usuario (id_usuario, id_pregunta_seguridad, hash_respuesta)
            VALUES (:usuario, :pregunta, :respuesta)
        SQL);
        foreach ($respuestas as $respuesta) {
            $insert->execute([
                'usuario' => $usuarioId,
                'pregunta' => $respuesta['id_pregunta_seguridad'],
                'respuesta' => password_hash($respuesta['respuesta_normalizada'], PASSWORD_DEFAULT),
            ]);
        }
    }
}

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
            SELECT u.id_usuario, u.nombre_usuario, u.contrasena AS hash_contrasena,
                   u.nombre, u.apellido, r.nombre AS rol, eu.codigo AS estado
            FROM usuario u
            INNER JOIN rol r ON r.id_rol = u.rol_id
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.estado_usuario_id
            WHERE u.nombre_usuario = :nombre_usuario AND u.eliminado_en IS NULL
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
            SELECT DISTINCT permisos.codigo
            FROM (
                SELECT pe.codigo
                FROM usuario u
                INNER JOIN permiso_rol pr ON pr.rol_id = u.rol_id
                INNER JOIN permiso pe ON pe.id_permiso = pr.permiso_id
                WHERE u.id_usuario = :usuario_rol
                UNION
                SELECT pe.codigo
                FROM usuario_permiso up
                INNER JOIN permiso pe ON pe.id_permiso = up.id_permiso
                WHERE up.id_usuario = :usuario_directo
            ) AS permisos
            ORDER BY permisos.codigo
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['usuario_rol' => $usuarioId, 'usuario_directo' => $usuarioId]);
        return array_column($statement->fetchAll(), 'codigo');
    }

    public function listar(): array
    {
        $sql = <<<'SQL'
            SELECT u.id_usuario, u.nombre_usuario, u.nombre, u.apellido, u.correo,
                   r.nombre AS rol, eu.codigo AS estado, e.nombre AS establecimiento
            FROM usuario u
            INNER JOIN rol r ON r.id_rol = u.rol_id
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.estado_usuario_id
            INNER JOIN establecimiento e ON e.id_establecimiento = u.establecimiento_id
            WHERE u.eliminado_en IS NULL
            ORDER BY u.apellido, u.nombre
        SQL;
        return Database::connection()->query($sql)->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $sql = <<<'SQL'
            SELECT u.id_usuario, u.rol_id AS id_rol,
                   u.estado_usuario_id AS id_estado_usuario,
                   u.establecimiento_id AS id_establecimiento,
                   u.nombre_usuario, u.nombre, u.apellido, u.cuil, u.direccion,
                   u.correo, u.telefono, r.nombre AS rol, eu.codigo AS estado
            FROM usuario u
            INNER JOIN rol r ON r.id_rol = u.rol_id
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.estado_usuario_id
            WHERE u.id_usuario = :id AND u.eliminado_en IS NULL
        SQL;
        $statement = Database::connection()->prepare($sql);
        $statement->execute(['id' => $id]);
        $usuario = $statement->fetch();
        return $usuario === false ? null : $usuario;
    }

    public function roles(): array
    {
        return Database::connection()->query(
            'SELECT id_rol, nombre, descripcion FROM rol WHERE eliminado_en IS NULL ORDER BY nombre'
        )->fetchAll();
    }

    public function estados(): array
    {
        return Database::connection()->query(
            'SELECT id_estado_usuario, codigo, descripcion FROM estado_usuario ORDER BY codigo'
        )->fetchAll();
    }

    public function establecimientos(): array
    {
        return Database::connection()->query(
            'SELECT id_establecimiento, nombre FROM establecimiento WHERE eliminado_en IS NULL ORDER BY nombre'
        )->fetchAll();
    }

    public function catalogoPermisos(): array
    {
        return Database::connection()->query(
            'SELECT id_permiso, codigo AS nombre, descripcion FROM permiso ORDER BY codigo'
        )->fetchAll();
    }

    public function preguntasActivas(): array
    {
        return Database::connection()->query(
            'SELECT id_pregunta_seguridad, texto FROM pregunta_seguridad WHERE activa = TRUE ORDER BY texto'
        )->fetchAll();
    }

    public function permisosDirectos(int $usuarioId): array
    {
        $statement = Database::connection()->prepare(
            'SELECT id_permiso FROM usuario_permiso WHERE id_usuario = :id'
        );
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
            $usuario = $pdo->prepare(<<<'SQL'
                INSERT INTO usuario (
                    cuil, nombre, apellido, telefono, correo, direccion,
                    nombre_usuario, contrasena, establecimiento_id,
                    estado_usuario_id, rol_id
                ) VALUES (
                    :cuil, :nombre, :apellido, :telefono, :correo, :direccion,
                    :nombre_usuario, :contrasena, :establecimiento_id,
                    :estado_usuario_id, :rol_id
                )
            SQL);
            $usuario->execute([
                'cuil' => $datos['cuil'],
                'nombre' => $datos['nombre'],
                'apellido' => $datos['apellido'],
                'telefono' => $datos['telefono'],
                'correo' => $datos['correo'],
                'direccion' => $datos['direccion'],
                'nombre_usuario' => $datos['nombre_usuario'],
                'contrasena' => password_hash($datos['contrasena'], PASSWORD_DEFAULT),
                'establecimiento_id' => $datos['id_establecimiento'],
                'estado_usuario_id' => $datos['id_estado_usuario'],
                'rol_id' => $datos['id_rol'],
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
            $sql = <<<'SQL'
                UPDATE usuario SET
                    cuil = :cuil, nombre = :nombre, apellido = :apellido,
                    telefono = :telefono, correo = :correo, direccion = :direccion,
                    nombre_usuario = :usuario, establecimiento_id = :establecimiento,
                    estado_usuario_id = :estado, rol_id = :rol
            SQL;
            $params = [
                'cuil' => $datos['cuil'], 'nombre' => $datos['nombre'],
                'apellido' => $datos['apellido'], 'telefono' => $datos['telefono'],
                'correo' => $datos['correo'], 'direccion' => $datos['direccion'],
                'usuario' => $datos['nombre_usuario'],
                'establecimiento' => $datos['id_establecimiento'],
                'estado' => $datos['id_estado_usuario'], 'rol' => $datos['id_rol'],
                'id' => $id,
            ];
            if ($datos['contrasena'] !== '') {
                $sql .= ', contrasena = :contrasena';
                $params['contrasena'] = password_hash($datos['contrasena'], PASSWORD_DEFAULT);
            }
            $sql .= ' WHERE id_usuario = :id';
            $pdo->prepare($sql)->execute($params);
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
            SET estado_usuario_id = (
                SELECT id_estado_usuario FROM estado_usuario WHERE codigo = 'INACTIVO'
            )
            WHERE id_usuario = :id
        SQL;
        Database::connection()->prepare($sql)->execute(['id' => $id]);
    }

    public function cantidadDuenosActivos(): int
    {
        $sql = <<<'SQL'
            SELECT COUNT(*) FROM usuario u
            INNER JOIN rol r ON r.id_rol = u.rol_id
            INNER JOIN estado_usuario eu ON eu.id_estado_usuario = u.estado_usuario_id
            WHERE r.codigo = 'DUENO' AND eu.codigo = 'ACTIVO' AND u.eliminado_en IS NULL
        SQL;
        return (int) Database::connection()->query($sql)->fetchColumn();
    }

    public function actualizarContrasena(int $id, string $contrasena): void
    {
        $statement = Database::connection()->prepare(
            'UPDATE usuario SET contrasena = :hash WHERE id_usuario = :id'
        );
        $statement->execute([
            'hash' => password_hash($contrasena, PASSWORD_DEFAULT),
            'id' => $id,
        ]);
    }

    private function sincronizarPermisos(int $usuarioId, array $permisos, PDO $pdo): void
    {
        $pdo->prepare('DELETE FROM usuario_permiso WHERE id_usuario = :id')
            ->execute(['id' => $usuarioId]);
        $insert = $pdo->prepare(
            'INSERT INTO usuario_permiso (id_usuario, id_permiso) VALUES (:usuario, :permiso)'
        );
        foreach (array_unique(array_map('intval', $permisos)) as $permisoId) {
            if ($permisoId > 0) {
                $insert->execute(['usuario' => $usuarioId, 'permiso' => $permisoId]);
            }
        }
    }

    private function reemplazarRespuestas(int $usuarioId, array $respuestas, PDO $pdo): void
    {
        $pdo->prepare('DELETE FROM respuesta_seguridad_usuario WHERE id_usuario = :id')
            ->execute(['id' => $usuarioId]);
        $insert = $pdo->prepare(<<<'SQL'
            INSERT INTO respuesta_seguridad_usuario
                (id_usuario, id_pregunta_seguridad, hash_respuesta)
            VALUES (:usuario, :pregunta, :respuesta)
        SQL);
        foreach ($respuestas as $respuesta) {
            $insert->execute([
                'usuario' => $usuarioId,
                'pregunta' => $respuesta['id_pregunta_seguridad'],
                'respuesta' => password_hash(
                    $respuesta['respuesta_normalizada'],
                    PASSWORD_DEFAULT
                ),
            ]);
        }
    }
}

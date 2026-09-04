<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;

final class AdministracionRepository
{
    public function roles(): array
    {
        $roles = Database::connection()->query('SELECT * FROM rol ORDER BY nombre')->fetchAll();
        $statement = Database::connection()->prepare('SELECT id_permiso FROM rol_permiso WHERE id_rol = :id');
        foreach ($roles as &$rol) {
            $statement->execute(['id' => $rol['id_rol']]);
            $rol['permisos'] = array_map('intval', array_column($statement->fetchAll(), 'id_permiso'));
        }
        return $roles;
    }

    public function permisos(): array
    {
        return Database::connection()->query('SELECT * FROM permiso ORDER BY nombre')->fetchAll();
    }

    public function establecimientos(): array
    {
        return Database::connection()->query('SELECT * FROM establecimiento ORDER BY nombre')->fetchAll();
    }

    public function preguntas(): array
    {
        return Database::connection()->query('SELECT * FROM pregunta_seguridad ORDER BY texto')->fetchAll();
    }

    public function crearRol(string $nombre, ?string $descripcion, array $permisos): void
    {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $statement = $pdo->prepare('INSERT INTO rol (nombre, descripcion) VALUES (:nombre, :descripcion)');
            $statement->execute(['nombre' => $nombre, 'descripcion' => $descripcion]);
            $this->sincronizarPermisosRol((int) $pdo->lastInsertId(), $permisos);
            $pdo->commit();
        } catch (\Throwable $e) { $pdo->rollBack(); throw $e; }
    }

    public function actualizarRol(int $id, string $nombre, ?string $descripcion, array $permisos): void
    {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $statement = $pdo->prepare('UPDATE rol SET nombre = :nombre, descripcion = :descripcion WHERE id_rol = :id');
            $statement->execute(['nombre' => $nombre, 'descripcion' => $descripcion, 'id' => $id]);
            $this->sincronizarPermisosRol($id, $permisos);
            $pdo->commit();
        } catch (\Throwable $e) { $pdo->rollBack(); throw $e; }
    }

    public function eliminarRol(int $id): void
    {
        $statement = Database::connection()->prepare('DELETE FROM rol WHERE id_rol = :id');
        $statement->execute(['id' => $id]);
    }

    public function crearPermiso(string $nombre, ?string $descripcion): void
    {
        $statement = Database::connection()->prepare('INSERT INTO permiso (nombre, descripcion) VALUES (:nombre, :descripcion)');
        $statement->execute(compact('nombre', 'descripcion'));
    }

    public function actualizarPermiso(int $id, string $nombre, ?string $descripcion): void
    {
        $statement = Database::connection()->prepare('UPDATE permiso SET nombre = :nombre, descripcion = :descripcion WHERE id_permiso = :id');
        $statement->execute(['nombre' => $nombre, 'descripcion' => $descripcion, 'id' => $id]);
    }

    public function eliminarPermiso(int $id): void
    {
        $statement = Database::connection()->prepare('DELETE FROM permiso WHERE id_permiso = :id');
        $statement->execute(['id' => $id]);
    }

    public function crearEstablecimiento(string $nombre, ?string $descripcion): void
    {
        $statement = Database::connection()->prepare('INSERT INTO establecimiento (nombre, descripcion) VALUES (:nombre, :descripcion)');
        $statement->execute(compact('nombre', 'descripcion'));
    }

    public function actualizarEstablecimiento(int $id, string $nombre, ?string $descripcion): void
    {
        $statement = Database::connection()->prepare('UPDATE establecimiento SET nombre = :nombre, descripcion = :descripcion WHERE id_establecimiento = :id');
        $statement->execute(['nombre' => $nombre, 'descripcion' => $descripcion, 'id' => $id]);
    }

    public function eliminarEstablecimiento(int $id): void
    {
        $statement = Database::connection()->prepare('DELETE FROM establecimiento WHERE id_establecimiento = :id');
        $statement->execute(['id' => $id]);
    }

    public function crearPregunta(string $texto, bool $activa): void
    {
        $statement = Database::connection()->prepare('INSERT INTO pregunta_seguridad (texto, activa) VALUES (:texto, :activa)');
        $statement->execute(['texto' => $texto, 'activa' => $activa]);
    }

    public function actualizarPregunta(int $id, string $texto, bool $activa): void
    {
        $statement = Database::connection()->prepare('UPDATE pregunta_seguridad SET texto = :texto, activa = :activa WHERE id_pregunta_seguridad = :id');
        $statement->execute(['texto' => $texto, 'activa' => $activa, 'id' => $id]);
    }

    public function eliminarPregunta(int $id): void
    {
        $statement = Database::connection()->prepare('DELETE FROM pregunta_seguridad WHERE id_pregunta_seguridad = :id');
        $statement->execute(['id' => $id]);
    }

    private function sincronizarPermisosRol(int $rolId, array $permisos): void
    {
        $pdo = Database::connection();
        $delete = $pdo->prepare('DELETE FROM rol_permiso WHERE id_rol = :id');
        $delete->execute(['id' => $rolId]);
        $insert = $pdo->prepare('INSERT INTO rol_permiso (id_rol, id_permiso) VALUES (:rol, :permiso)');
        foreach (array_unique(array_map('intval', $permisos)) as $permisoId) {
            if ($permisoId > 0) $insert->execute(['rol' => $rolId, 'permiso' => $permisoId]);
        }
    }
}


<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;
use PDO;

final class PotreroRepository
{
    public function listar(): array
    {
        $sql = <<<'SQL'
            SELECT p.*, p.establecimiento_id AS id_establecimiento,
                   e.nombre AS establecimiento,
                   (
                       SELECT COUNT(*)
                       FROM recurso_potrero rp
                       WHERE rp.potrero_id = p.id_potrero
                         AND rp.eliminado_en IS NULL
                   ) AS cantidad_recursos
            FROM potrero p
            INNER JOIN establecimiento e
                ON e.id_establecimiento = p.establecimiento_id
            WHERE p.eliminado_en IS NULL
            ORDER BY e.nombre, p.nombre
        SQL;
        return Database::connection()->query($sql)->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $statement = Database::connection()->prepare(<<<'SQL'
            SELECT p.*, p.establecimiento_id AS id_establecimiento,
                   e.nombre AS establecimiento
            FROM potrero p
            INNER JOIN establecimiento e
                ON e.id_establecimiento = p.establecimiento_id
            WHERE p.id_potrero = :id AND p.eliminado_en IS NULL
        SQL);
        $statement->execute(['id' => $id]);
        $potrero = $statement->fetch();
        return $potrero === false ? null : $potrero;
    }

    public function establecimientos(): array
    {
        return Database::connection()->query(
            'SELECT id_establecimiento, nombre
             FROM establecimiento
             WHERE eliminado_en IS NULL
             ORDER BY nombre'
        )->fetchAll();
    }

    public function existeNombre(int $establecimientoId, string $nombre, ?int $exceptoId = null): bool
    {
        $sql = 'SELECT COUNT(*) FROM potrero
                WHERE establecimiento_id = :establecimiento
                  AND nombre = :nombre
                  AND eliminado_en IS NULL';
        $parameters = ['establecimiento' => $establecimientoId, 'nombre' => $nombre];
        if ($exceptoId !== null) {
            $sql .= ' AND id_potrero <> :excepto';
            $parameters['excepto'] = $exceptoId;
        }
        $statement = Database::connection()->prepare($sql);
        $statement->execute($parameters);
        return (int) $statement->fetchColumn() > 0;
    }

    public function crear(array $datos): int
    {
        $statement = Database::connection()->prepare(<<<'SQL'
            INSERT INTO potrero
                (establecimiento_id, nombre, largo, ancho, superficie)
            VALUES
                (:id_establecimiento, :nombre, :largo, :ancho, :superficie)
        SQL);
        $statement->execute($datos);
        return (int) Database::connection()->lastInsertId();
    }

    public function actualizar(int $id, array $datos): void
    {
        $datos['id'] = $id;
        Database::connection()->prepare(<<<'SQL'
            UPDATE potrero SET
                establecimiento_id = :id_establecimiento,
                nombre = :nombre,
                largo = :largo,
                ancho = :ancho,
                superficie = :superficie
            WHERE id_potrero = :id
        SQL)->execute($datos);
    }

    public function eliminar(int $id): void
    {
        Database::connection()->prepare(
            'DELETE FROM potrero WHERE id_potrero = :id'
        )->execute(['id' => $id]);
    }

    public function recursos(int $potreroId): array
    {
        $statement = Database::connection()->prepare(<<<'SQL'
            SELECT rp.id_recurso_potrero, rp.potrero_id AS id_potrero,
                   tr.nombre, rp.disponible,
                   COALESCE(rp.observacion, rp.descripcion) AS observacion
            FROM recurso_potrero rp
            INNER JOIN tipo_recurso tr
                ON tr.id_tipo_recurso = rp.tipo_recurso_id
            WHERE rp.potrero_id = :id AND rp.eliminado_en IS NULL
            ORDER BY tr.nombre
        SQL);
        $statement->execute(['id' => $potreroId]);
        return $statement->fetchAll();
    }

    public function agregarRecurso(
        int $potreroId,
        string $nombre,
        bool $disponible,
        ?string $observacion
    ): void {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $tipoId = $this->obtenerOCrearTipo($nombre, $pdo);
            $statement = $pdo->prepare(<<<'SQL'
                INSERT INTO recurso_potrero
                    (potrero_id, tipo_recurso_id, descripcion, disponible, observacion)
                VALUES
                    (:potrero, :tipo, :descripcion, :disponible, :observacion)
            SQL);
            $statement->bindValue(':potrero', $potreroId, PDO::PARAM_INT);
            $statement->bindValue(':tipo', $tipoId, PDO::PARAM_INT);
            $statement->bindValue(':descripcion', $observacion);
            $statement->bindValue(':disponible', $disponible, PDO::PARAM_BOOL);
            $statement->bindValue(':observacion', $observacion);
            $statement->execute();
            $pdo->commit();
        } catch (\Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function cambiarDisponibilidad(int $potreroId, int $recursoId): bool
    {
        $statement = Database::connection()->prepare(<<<'SQL'
            UPDATE recurso_potrero
            SET disponible = NOT disponible
            WHERE id_recurso_potrero = :recurso
              AND potrero_id = :potrero
              AND eliminado_en IS NULL
        SQL);
        $statement->execute(['recurso' => $recursoId, 'potrero' => $potreroId]);
        return $statement->rowCount() === 1;
    }

    public function actualizarRecurso(
        int $potreroId,
        int $recursoId,
        string $nombre,
        bool $disponible,
        ?string $observacion
    ): bool {
        $pdo = Database::connection();
        $pdo->beginTransaction();
        try {
            $tipoId = $this->obtenerOCrearTipo($nombre, $pdo);
            $statement = $pdo->prepare(<<<'SQL'
                UPDATE recurso_potrero SET
                    tipo_recurso_id = :tipo,
                    descripcion = :descripcion,
                    disponible = :disponible,
                    observacion = :observacion
                WHERE id_recurso_potrero = :recurso
                  AND potrero_id = :potrero
                  AND eliminado_en IS NULL
            SQL);
            $statement->bindValue(':tipo', $tipoId, PDO::PARAM_INT);
            $statement->bindValue(':descripcion', $observacion);
            $statement->bindValue(':disponible', $disponible, PDO::PARAM_BOOL);
            $statement->bindValue(':observacion', $observacion);
            $statement->bindValue(':recurso', $recursoId, PDO::PARAM_INT);
            $statement->bindValue(':potrero', $potreroId, PDO::PARAM_INT);
            $statement->execute();
            $actualizado = $statement->rowCount() <= 1;
            $pdo->commit();
            return $actualizado;
        } catch (\Throwable $exception) {
            $pdo->rollBack();
            throw $exception;
        }
    }

    public function eliminarRecurso(int $potreroId, int $recursoId): bool
    {
        $statement = Database::connection()->prepare(<<<'SQL'
            DELETE FROM recurso_potrero
            WHERE id_recurso_potrero = :recurso AND potrero_id = :potrero
        SQL);
        $statement->execute(['recurso' => $recursoId, 'potrero' => $potreroId]);
        return $statement->rowCount() === 1;
    }

    private function obtenerOCrearTipo(string $nombre, PDO $pdo): int
    {
        $buscar = $pdo->prepare(
            'SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre = :nombre LIMIT 1'
        );
        $buscar->execute(['nombre' => $nombre]);
        $id = $buscar->fetchColumn();
        if ($id !== false) {
            return (int) $id;
        }

        $codigo = $this->normalizarCodigo($nombre);
        $insertar = $pdo->prepare(
            'INSERT INTO tipo_recurso (codigo, nombre) VALUES (:codigo, :nombre)'
        );
        $insertar->execute(['codigo' => $codigo, 'nombre' => $nombre]);
        return (int) $pdo->lastInsertId();
    }

    private function normalizarCodigo(string $nombre): string
    {
        $ascii = iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $nombre);
        $codigo = strtoupper((string) ($ascii === false ? $nombre : $ascii));
        $codigo = preg_replace('/[^A-Z0-9]+/', '_', $codigo) ?? '';
        $codigo = trim($codigo, '_');
        return substr($codigo !== '' ? $codigo : 'RECURSO', 0, 45);
    }
}

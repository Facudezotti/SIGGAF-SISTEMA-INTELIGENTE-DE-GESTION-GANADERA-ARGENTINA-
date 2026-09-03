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
            SELECT p.*, e.nombre AS establecimiento,
                   (SELECT COUNT(*) FROM recurso_potrero rp WHERE rp.id_potrero = p.id_potrero) AS cantidad_recursos
            FROM potrero p
            INNER JOIN establecimiento e ON e.id_establecimiento = p.id_establecimiento
            ORDER BY e.nombre, p.nombre
        SQL;
        return Database::connection()->query($sql)->fetchAll();
    }

    public function buscar(int $id): ?array
    {
        $statement = Database::connection()->prepare(
            'SELECT p.*, e.nombre AS establecimiento FROM potrero p INNER JOIN establecimiento e ON e.id_establecimiento = p.id_establecimiento WHERE p.id_potrero = :id'
        );
        $statement->execute(['id' => $id]);
        $potrero = $statement->fetch();
        return $potrero === false ? null : $potrero;
    }

    public function establecimientos(): array
    {
        return Database::connection()->query('SELECT id_establecimiento, nombre FROM establecimiento ORDER BY nombre')->fetchAll();
    }

    public function existeNombre(int $establecimientoId, string $nombre, ?int $exceptoId = null): bool
    {
        $sql = 'SELECT COUNT(*) FROM potrero WHERE id_establecimiento = :establecimiento AND nombre = :nombre';
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
        $statement = Database::connection()->prepare(
            'INSERT INTO potrero (id_establecimiento, nombre, largo, ancho, superficie) VALUES (:id_establecimiento, :nombre, :largo, :ancho, :superficie)'
        );
        $statement->execute($datos);
        return (int) Database::connection()->lastInsertId();
    }

    public function actualizar(int $id, array $datos): void
    {
        $datos['id'] = $id;
        $statement = Database::connection()->prepare(
            'UPDATE potrero SET id_establecimiento = :id_establecimiento, nombre = :nombre, largo = :largo, ancho = :ancho, superficie = :superficie WHERE id_potrero = :id'
        );
        $statement->execute($datos);
    }

    public function recursos(int $potreroId): array
    {
        $statement = Database::connection()->prepare('SELECT * FROM recurso_potrero WHERE id_potrero = :id ORDER BY nombre');
        $statement->execute(['id' => $potreroId]);
        return $statement->fetchAll();
    }

    public function agregarRecurso(int $potreroId, string $nombre, bool $disponible, ?string $observacion): void
    {
        $statement = Database::connection()->prepare(
            'INSERT INTO recurso_potrero (id_potrero, nombre, disponible, observacion) VALUES (:id_potrero, :nombre, :disponible, :observacion)'
        );
        $statement->bindValue(':id_potrero', $potreroId, PDO::PARAM_INT);
        $statement->bindValue(':nombre', $nombre);
        $statement->bindValue(':disponible', $disponible, PDO::PARAM_BOOL);
        $statement->bindValue(':observacion', $observacion);
        $statement->execute();
    }

    public function cambiarDisponibilidad(int $potreroId, int $recursoId): bool
    {
        $statement = Database::connection()->prepare(
            'UPDATE recurso_potrero SET disponible = NOT disponible WHERE id_recurso_potrero = :recurso AND id_potrero = :potrero'
        );
        $statement->execute(['recurso' => $recursoId, 'potrero' => $potreroId]);
        return $statement->rowCount() === 1;
    }
}

<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Core\Database;

final class ConfiguracionVisualRepository
{
    public function obtener(): ?array
    {
        $statement = Database::connection()->query(
            'SELECT id_configuracion_visual, logo_ruta, logo_nombre_original, logo_mime,
                    fondo_ruta, fondo_nombre_original, fondo_mime, fecha_actualizacion,
                    id_usuario_actualizacion
             FROM configuracion_visual
             WHERE id_configuracion_visual = 1'
        );

        $configuracion = $statement->fetch();

        return is_array($configuracion) ? $configuracion : null;
    }

    public function actualizarImagen(
        string $tipo,
        string $ruta,
        ?string $nombreOriginal,
        ?string $mime,
        int $usuarioId
    ): void {
        if (!in_array($tipo, ['logo', 'fondo'], true)) {
            throw new \InvalidArgumentException('Tipo de imagen no permitido.');
        }

        $statement = Database::connection()->prepare(
            "UPDATE configuracion_visual
             SET {$tipo}_ruta = :ruta,
                 {$tipo}_nombre_original = :nombre_original,
                 {$tipo}_mime = :mime,
                 id_usuario_actualizacion = :usuario,
                 fecha_actualizacion = CURRENT_TIMESTAMP
             WHERE id_configuracion_visual = 1"
        );
        $statement->execute([
            'ruta' => $ruta,
            'nombre_original' => $nombreOriginal,
            'mime' => $mime,
            'usuario' => $usuarioId,
        ]);

        if ($statement->rowCount() === 0 && $this->obtener() === null) {
            throw new \RuntimeException('No existe la configuración visual inicial.');
        }
    }
}


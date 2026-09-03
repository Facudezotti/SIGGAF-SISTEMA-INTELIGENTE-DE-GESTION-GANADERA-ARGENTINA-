<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\PotreroRepository;

final class PotreroService
{
    public function validar(array $entrada, ?int $exceptoId = null): array
    {
        $errores = [];
        $establecimiento = filter_var($entrada['id_establecimiento'] ?? null, FILTER_VALIDATE_INT);
        $nombre = trim((string) ($entrada['nombre'] ?? ''));
        $largo = filter_var($entrada['largo'] ?? null, FILTER_VALIDATE_FLOAT);
        $ancho = filter_var($entrada['ancho'] ?? null, FILTER_VALIDATE_FLOAT);

        if ($establecimiento === false || $establecimiento < 1) {
            $errores['id_establecimiento'] = 'Selecciona un establecimiento válido.';
        }
        if ($nombre === '' || mb_strlen($nombre) > 150) {
            $errores['nombre'] = 'El nombre es obligatorio y admite hasta 150 caracteres.';
        }
        if ($largo === false || $largo <= 0) {
            $errores['largo'] = 'El largo debe ser mayor que cero.';
        }
        if ($ancho === false || $ancho <= 0) {
            $errores['ancho'] = 'El ancho debe ser mayor que cero.';
        }

        if ($errores === [] && (new PotreroRepository())->existeNombre((int) $establecimiento, $nombre, $exceptoId)) {
            $errores['nombre'] = 'Ya existe un potrero con ese nombre en el establecimiento.';
        }

        return [
            'errores' => $errores,
            'datos' => [
                'id_establecimiento' => (int) ($establecimiento ?: 0),
                'nombre' => $nombre,
                'largo' => round((float) ($largo ?: 0), 2),
                'ancho' => round((float) ($ancho ?: 0), 2),
                'superficie' => round((float) ($largo ?: 0) * (float) ($ancho ?: 0), 2),
            ],
        ];
    }
}


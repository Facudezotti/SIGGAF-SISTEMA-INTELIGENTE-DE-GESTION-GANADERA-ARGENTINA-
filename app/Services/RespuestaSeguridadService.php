<?php

declare(strict_types=1);

namespace App\Services;

final class RespuestaSeguridadService
{
    public static function normalizar(string $respuesta): string
    {
        $respuesta = mb_strtolower(trim($respuesta), 'UTF-8');
        return preg_replace('/\s+/u', ' ', $respuesta) ?? $respuesta;
    }
}


<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\UsuarioRepository;

final class RecuperacionService
{
    public function iniciar(string $nombreUsuario): ?array
    {
        $repository = new UsuarioRepository();
        $usuario = $repository->buscarParaAutenticacion(trim($nombreUsuario));
        if ($usuario === null || $usuario['estado'] !== 'ACTIVO') return null;
        $preguntas = $repository->respuestasSeguridad((int) $usuario['id_usuario']);
        if (count($preguntas) !== 3) return null;
        return ['usuario' => $usuario, 'preguntas' => $preguntas];
    }

    public function verificar(array $preguntasGuardadas, array $respuestas): bool
    {
        if (count($preguntasGuardadas) !== 3 || count($respuestas) !== 3) return false;
        foreach ($preguntasGuardadas as $indice => $pregunta) {
            $normalizada = RespuestaSeguridadService::normalizar((string) ($respuestas[$indice] ?? ''));
            if ($normalizada === '' || !password_verify($normalizada, $pregunta['hash_respuesta'])) return false;
        }
        return true;
    }
}


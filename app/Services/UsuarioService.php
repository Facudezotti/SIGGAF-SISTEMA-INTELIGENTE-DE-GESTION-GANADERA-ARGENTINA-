<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\UsuarioRepository;

final class UsuarioService
{
    public function validar(array $entrada, ?int $usuarioId = null, bool $respuestasOpcionales = false): array
    {
        $errores = [];
        $datos = [
            'id_persona' => (int) ($entrada['id_persona'] ?? 0),
            'nombre' => trim((string) ($entrada['nombre'] ?? '')),
            'apellido' => trim((string) ($entrada['apellido'] ?? '')),
            'cuil' => $this->nulo(trim((string) ($entrada['cuil'] ?? ''))),
            'direccion' => $this->nulo(trim((string) ($entrada['direccion'] ?? ''))),
            'correo' => $this->nulo(trim((string) ($entrada['correo'] ?? ''))),
            'telefono' => $this->nulo(trim((string) ($entrada['telefono'] ?? ''))),
            'nombre_usuario' => trim((string) ($entrada['nombre_usuario'] ?? '')),
            'id_rol' => (int) ($entrada['id_rol'] ?? 0),
            'id_estado_usuario' => (int) ($entrada['id_estado_usuario'] ?? 0),
            'contrasena' => (string) ($entrada['contrasena'] ?? ''),
        ];

        if ($datos['nombre'] === '' || mb_strlen($datos['nombre']) > 100) $errores['nombre'] = 'El nombre es obligatorio y admite hasta 100 caracteres.';
        if ($datos['apellido'] === '' || mb_strlen($datos['apellido']) > 100) $errores['apellido'] = 'El apellido es obligatorio y admite hasta 100 caracteres.';
        if ($datos['nombre_usuario'] === '' || mb_strlen($datos['nombre_usuario']) > 80) $errores['nombre_usuario'] = 'El nombre de usuario es obligatorio y admite hasta 80 caracteres.';
        if ($datos['correo'] !== null && !filter_var($datos['correo'], FILTER_VALIDATE_EMAIL)) $errores['correo'] = 'El correo electrónico no tiene un formato válido.';
        if ($datos['cuil'] !== null && !preg_match('/^\d{11}$/', $datos['cuil'])) $errores['cuil'] = 'El CUIL debe contener exactamente 11 números.';
        if ($datos['id_rol'] < 1) $errores['id_rol'] = 'Selecciona un rol.';
        if ($datos['id_estado_usuario'] < 1) $errores['id_estado_usuario'] = 'Selecciona un estado.';
        if ($usuarioId === null && strlen($datos['contrasena']) < 8) $errores['contrasena'] = 'La contraseña debe contener al menos 8 caracteres.';
        if ($usuarioId !== null && $datos['contrasena'] !== '' && strlen($datos['contrasena']) < 8) $errores['contrasena'] = 'La nueva contraseña debe contener al menos 8 caracteres.';
        if ((new UsuarioRepository())->existeNombreUsuario($datos['nombre_usuario'], $usuarioId)) $errores['nombre_usuario'] = 'El nombre de usuario ya está registrado.';

        $respuestas = $this->procesarRespuestas($entrada, $errores, $respuestasOpcionales);
        $permisos = array_values(array_filter(array_map('intval', (array) ($entrada['permisos'] ?? [])), static fn (int $id): bool => $id > 0));
        return compact('datos', 'permisos', 'respuestas', 'errores');
    }

    private function procesarRespuestas(array $entrada, array &$errores, bool $opcionales): array
    {
        $preguntas = (array) ($entrada['preguntas'] ?? []);
        $respuestasEntrada = (array) ($entrada['respuestas'] ?? []);
        $hayDatos = array_filter($preguntas) !== [] || array_filter($respuestasEntrada) !== [];
        if ($opcionales && !$hayDatos) return [];
        if (count($preguntas) !== 3 || count(array_unique(array_map('intval', $preguntas))) !== 3) {
            $errores['preguntas'] = 'Debes seleccionar tres preguntas diferentes.';
            return [];
        }
        $resultado = [];
        for ($i = 0; $i < 3; $i++) {
            $normalizada = RespuestaSeguridadService::normalizar((string) ($respuestasEntrada[$i] ?? ''));
            if ($normalizada === '') {
                $errores['respuestas'] = 'Debes responder las tres preguntas de seguridad.';
                return [];
            }
            $resultado[] = ['id_pregunta_seguridad' => (int) $preguntas[$i], 'respuesta_normalizada' => $normalizada];
        }
        return $resultado;
    }

    private function nulo(string $valor): ?string
    {
        return $valor === '' ? null : $valor;
    }
}


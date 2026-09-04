<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Repositories\UsuarioRepository;
use App\Services\RecuperacionService;

final class RecuperacionController
{
    public function solicitar(): void
    {
        $this->limpiarSiVencio();
        View::render('auth/recuperar', ['error' => Session::pullFlash('error')], 'auth');
    }

    public function preguntas(): void
    {
        $this->validarCsrf();
        $resultado = (new RecuperacionService())->iniciar((string) ($_POST['usuario'] ?? ''));
        if ($resultado === null) {
            Session::flash('error', 'No fue posible iniciar la recuperación con los datos proporcionados.');
            redirect('/recuperar');
        }
        Session::put('recuperacion', [
            'id_usuario' => (int) $resultado['usuario']['id_usuario'],
            'preguntas' => $resultado['preguntas'],
            'intentos' => 0,
            'vence' => time() + 600,
            'verificada' => false,
        ]);
        redirect('/recuperar/preguntas');
    }

    public function mostrarPreguntas(): void
    {
        $recuperacion = $this->recuperacionVigente(false);
        View::render('auth/preguntas', ['preguntas' => $recuperacion['preguntas'], 'error' => Session::pullFlash('error')], 'auth');
    }

    public function verificar(): void
    {
        $this->validarCsrf();
        $recuperacion = $this->recuperacionVigente(false);
        $recuperacion['intentos']++;
        if ($recuperacion['intentos'] > 5) {
            Session::remove('recuperacion');
            Session::flash('error', 'Se alcanzó el límite de intentos. Inicia nuevamente.');
            redirect('/recuperar');
        }
        if (!(new RecuperacionService())->verificar($recuperacion['preguntas'], (array) ($_POST['respuestas'] ?? []))) {
            Session::put('recuperacion', $recuperacion);
            Session::flash('error', 'Las respuestas proporcionadas no son correctas.');
            redirect('/recuperar/preguntas');
        }
        $recuperacion['verificada'] = true;
        $recuperacion['vence'] = time() + 600;
        Session::put('recuperacion', $recuperacion);
        redirect('/recuperar/nueva-contrasena');
    }

    public function nuevaContrasena(): void
    {
        $this->recuperacionVigente(true);
        View::render('auth/nueva_contrasena', ['error' => Session::pullFlash('error')], 'auth');
    }

    public function actualizarContrasena(): void
    {
        $this->validarCsrf();
        $recuperacion = $this->recuperacionVigente(true);
        $contrasena = (string) ($_POST['contrasena'] ?? '');
        $confirmacion = (string) ($_POST['confirmacion'] ?? '');
        if (strlen($contrasena) < 8 || $contrasena !== $confirmacion) {
            Session::flash('error', 'La contraseña debe tener al menos 8 caracteres y coincidir con su confirmación.');
            redirect('/recuperar/nueva-contrasena');
        }
        (new UsuarioRepository())->actualizarContrasena((int) $recuperacion['id_usuario'], $contrasena);
        Session::remove('recuperacion');
        Session::flash('mensaje', 'Contraseña actualizada. Ya puedes iniciar sesión.');
        redirect('/login');
    }

    private function recuperacionVigente(bool $exigirVerificada): array
    {
        $this->limpiarSiVencio();
        $datos = Session::get('recuperacion');
        if (!is_array($datos) || ($exigirVerificada && empty($datos['verificada']))) redirect('/recuperar');
        return $datos;
    }

    private function limpiarSiVencio(): void
    {
        $datos = Session::get('recuperacion');
        if (is_array($datos) && (int) ($datos['vence'] ?? 0) < time()) Session::remove('recuperacion');
    }

    private function validarCsrf(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            exit('La sesión del formulario venció.');
        }
    }
}

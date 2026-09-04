<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Auth;
use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Services\AuthService;

final class AuthController
{
    public function loginForm(): void
    {
        if (Auth::check()) {
            redirect('/dashboard');
        }
        View::render('auth/login', [
            'error' => Session::pullFlash('error'),
            'mensaje' => Session::pullFlash('mensaje'),
            'oldUsuario' => Session::pullFlash('old_usuario', ''),
        ], 'auth');
    }

    public function login(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            Session::flash('error', 'La sesión del formulario venció. Intenta nuevamente.');
            redirect('/login');
        }

        $usuario = trim((string) ($_POST['usuario'] ?? ''));
        $contrasena = (string) ($_POST['contrasena'] ?? '');
        Session::flash('old_usuario', $usuario);

        if ($usuario === '' || $contrasena === '' || !(new AuthService())->autenticar($usuario, $contrasena)) {
            Session::flash('error', 'Usuario o contraseña incorrectos.');
            redirect('/login');
        }

        Session::remove('_flash');
        redirect('/dashboard');
    }

    public function logout(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            exit('Solicitud no válida.');
        }
        Auth::logout();
        redirect('/login');
    }
}

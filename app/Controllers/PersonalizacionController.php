<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Auth;
use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Services\ConfiguracionVisualService;

final class PersonalizacionController
{
    private ConfiguracionVisualService $service;

    public function __construct()
    {
        if ((Auth::user()['rol'] ?? null) !== 'DUENO') {
            http_response_code(403);
            View::render('errors/403');
            exit;
        }

        $this->service = new ConfiguracionVisualService();
    }

    public function index(): void
    {
        View::render('personalizacion/index', [
            'configuracion' => $this->service->obtener(),
            'mensaje' => Session::pullFlash('mensaje'),
            'error' => Session::pullFlash('error'),
        ]);
    }

    public function actualizarLogo(): void
    {
        $this->actualizar('logo');
    }

    public function actualizarFondo(): void
    {
        $this->actualizar('fondo');
    }

    public function restaurarLogo(): void
    {
        $this->restaurar('logo');
    }

    public function restaurarFondo(): void
    {
        $this->restaurar('fondo');
    }

    private function actualizar(string $tipo): never
    {
        $this->validarCsrf();

        try {
            $usuarioId = (int) (Auth::user()['id_usuario'] ?? 0);
            $this->service->reemplazar($tipo, (array) ($_FILES[$tipo] ?? []), $usuarioId);
            Session::flash('mensaje', ucfirst($tipo) . ' actualizado correctamente.');
        } catch (\InvalidArgumentException|\RuntimeException $exception) {
            Session::flash('error', $exception->getMessage());
        } catch (\Throwable) {
            Session::flash('error', 'No fue posible actualizar la imagen. Verifica la base de datos y los permisos de la carpeta.');
        }

        redirect('/personalizacion');
    }

    private function restaurar(string $tipo): never
    {
        $this->validarCsrf();

        try {
            $usuarioId = (int) (Auth::user()['id_usuario'] ?? 0);
            $this->service->restaurar($tipo, $usuarioId);
            Session::flash('mensaje', ucfirst($tipo) . ' restaurado a la imagen predeterminada.');
        } catch (\Throwable) {
            Session::flash('error', 'No fue posible restaurar la imagen predeterminada.');
        }

        redirect('/personalizacion');
    }

    private function validarCsrf(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            exit('La sesión del formulario venció.');
        }
    }
}


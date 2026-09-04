<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Repositories\PotreroRepository;
use App\Services\PotreroService;

final class PotreroController
{
    private PotreroRepository $repository;

    public function __construct()
    {
        $this->repository = new PotreroRepository();
    }

    public function index(): void
    {
        View::render('potreros/index', [
            'potreros' => $this->repository->listar(),
            'mensaje' => Session::pullFlash('mensaje'),
        ]);
    }

    public function crear(): void
    {
        View::render('potreros/formulario', [
            'titulo' => 'Registrar potrero',
            'accion' => '/potreros',
            'potrero' => Session::pullFlash('datos', []),
            'errores' => Session::pullFlash('errores', []),
            'establecimientos' => $this->repository->establecimientos(),
        ]);
    }

    public function guardar(): void
    {
        $this->validarCsrf();
        $resultado = (new PotreroService())->validar($_POST);
        if ($resultado['errores'] !== []) {
            Session::flash('errores', $resultado['errores']);
            Session::flash('datos', $_POST);
            redirect('/potreros/crear');
        }
        $id = $this->repository->crear($resultado['datos']);
        Session::flash('mensaje', 'Potrero registrado correctamente.');
        redirect('/potreros/' . $id);
    }

    public function ver(string $id): void
    {
        $potrero = $this->obtenerPotrero($id);
        View::render('potreros/ver', [
            'potrero' => $potrero,
            'recursos' => $this->repository->recursos((int) $id),
            'mensaje' => Session::pullFlash('mensaje'),
            'error' => Session::pullFlash('error'),
        ]);
    }

    public function editar(string $id): void
    {
        $potrero = Session::pullFlash('datos', $this->obtenerPotrero($id));
        View::render('potreros/formulario', [
            'titulo' => 'Modificar potrero',
            'accion' => '/potreros/' . (int) $id . '/actualizar',
            'potrero' => $potrero,
            'errores' => Session::pullFlash('errores', []),
            'establecimientos' => $this->repository->establecimientos(),
        ]);
    }

    public function actualizar(string $id): void
    {
        $this->validarCsrf();
        $potrero = $this->obtenerPotrero($id);
        $resultado = (new PotreroService())->validar($_POST, (int) $potrero['id_potrero']);
        if ($resultado['errores'] !== []) {
            Session::flash('errores', $resultado['errores']);
            Session::flash('datos', $_POST);
            redirect('/potreros/' . (int) $id . '/editar');
        }
        $this->repository->actualizar((int) $id, $resultado['datos']);
        Session::flash('mensaje', 'Potrero actualizado correctamente.');
        redirect('/potreros/' . (int) $id);
    }

    public function eliminar(string $id): void
    {
        $this->validarCsrf();
        $this->obtenerPotrero($id);
        try {
            $this->repository->eliminar((int) $id);
            Session::flash('mensaje', 'Potrero eliminado correctamente.');
            redirect('/potreros');
        } catch (\PDOException) {
            Session::flash('error', 'No puede eliminarse un potrero que todavía contiene recursos.');
            redirect('/potreros/' . (int) $id);
        }
    }

    public function agregarRecurso(string $id): void
    {
        $this->validarCsrf();
        $this->obtenerPotrero($id);
        $nombre = trim((string) ($_POST['nombre'] ?? ''));
        $observacion = trim((string) ($_POST['observacion'] ?? ''));
        if ($nombre === '' || mb_strlen($nombre) > 120) {
            Session::flash('error', 'El nombre del recurso es obligatorio y admite hasta 120 caracteres.');
            redirect('/potreros/' . (int) $id);
        }
        try {
            $this->repository->agregarRecurso((int) $id, $nombre, isset($_POST['disponible']), $observacion ?: null);
            Session::flash('mensaje', 'Recurso agregado correctamente.');
        } catch (\PDOException) {
            Session::flash('error', 'Ese recurso ya está registrado en el potrero.');
        }
        redirect('/potreros/' . (int) $id);
    }

    public function cambiarDisponibilidad(string $id, string $recurso): void
    {
        $this->validarCsrf();
        $this->obtenerPotrero($id);
        if (!$this->repository->cambiarDisponibilidad((int) $id, (int) $recurso)) {
            http_response_code(404);
            View::render('errors/404');
            return;
        }
        Session::flash('mensaje', 'Disponibilidad del recurso actualizada.');
        redirect('/potreros/' . (int) $id);
    }

    public function actualizarRecurso(string $id, string $recurso): void
    {
        $this->validarCsrf();
        $this->obtenerPotrero($id);
        $nombre = trim((string) ($_POST['nombre'] ?? ''));
        $observacion = trim((string) ($_POST['observacion'] ?? ''));
        if ($nombre === '' || mb_strlen($nombre) > 120) {
            Session::flash('error', 'El nombre del recurso es obligatorio y admite hasta 120 caracteres.');
            redirect('/potreros/' . (int) $id);
        }
        try {
            $this->repository->actualizarRecurso((int) $id, (int) $recurso, $nombre, isset($_POST['disponible']), $observacion ?: null);
            Session::flash('mensaje', 'Recurso actualizado correctamente.');
        } catch (\PDOException) {
            Session::flash('error', 'No se pudo actualizar el recurso. Verifica que su nombre no esté repetido.');
        }
        redirect('/potreros/' . (int) $id);
    }

    public function eliminarRecurso(string $id, string $recurso): void
    {
        $this->validarCsrf();
        $this->obtenerPotrero($id);
        if ($this->repository->eliminarRecurso((int) $id, (int) $recurso)) Session::flash('mensaje', 'Recurso eliminado correctamente.');
        else Session::flash('error', 'El recurso indicado no existe.');
        redirect('/potreros/' . (int) $id);
    }

    private function obtenerPotrero(string $id): array
    {
        if (!ctype_digit($id) || (int) $id < 1) {
            http_response_code(404);
            View::render('errors/404');
            exit;
        }
        $potrero = $this->repository->buscar((int) $id);
        if ($potrero === null) {
            http_response_code(404);
            View::render('errors/404');
            exit;
        }
        return $potrero;
    }

    private function validarCsrf(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            exit('La sesión del formulario venció.');
        }
    }
}

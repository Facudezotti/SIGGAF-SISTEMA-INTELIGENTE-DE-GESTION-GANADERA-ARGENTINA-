<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Auth;
use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Repositories\UsuarioRepository;
use App\Services\UsuarioService;

final class UsuarioController
{
    private UsuarioRepository $repository;

    public function __construct()
    {
        if ((Auth::user()['rol'] ?? null) !== 'DUENO') {
            http_response_code(403);
            View::render('errors/403');
            exit;
        }
        $this->repository = new UsuarioRepository();
    }

    public function index(): void
    {
        View::render('usuarios/index', [
            'usuarios' => $this->repository->listar(),
            'mensaje' => Session::pullFlash('mensaje'),
            'error' => Session::pullFlash('error'),
        ]);
    }

    public function crear(): void
    {
        $this->formulario('Registrar usuario', '/usuarios', Session::pullFlash('datos', []), [], false);
    }

    public function guardar(): void
    {
        $this->validarCsrf();
        $resultado = (new UsuarioService())->validar($_POST);
        $rolSeleccionado = null;
        foreach ($this->repository->roles() as $rol) if ((int) $rol['id_rol'] === $resultado['datos']['id_rol']) $rolSeleccionado = $rol['nombre'];
        if ($rolSeleccionado === 'DUENO') $resultado['errores']['id_rol'] = 'Las nuevas cuentas de esta entrega deben ser usuarios operativos, no Dueños.';
        if ($resultado['errores'] !== []) {
            Session::flash('errores', $resultado['errores']);
            Session::flash('datos', $_POST);
            redirect('/usuarios/crear');
        }
        try {
            $id = $this->repository->crear($resultado['datos'], $resultado['permisos'], $resultado['respuestas']);
            Session::flash('mensaje', 'Usuario registrado correctamente.');
            redirect('/usuarios/' . $id . '/editar');
        } catch (\PDOException) {
            Session::flash('errores', ['general' => 'No se pudo registrar el usuario. Revisa que el CUIL y el correo no estén repetidos.']);
            Session::flash('datos', $_POST);
            redirect('/usuarios/crear');
        }
    }

    public function editar(string $id): void
    {
        $usuario = $this->obtener($id);
        $datos = Session::pullFlash('datos', $usuario);
        $this->formulario('Modificar usuario', '/usuarios/' . (int) $id . '/actualizar', $datos, $this->repository->permisosDirectos((int) $id), true);
    }

    public function actualizar(string $id): void
    {
        $this->validarCsrf();
        $usuario = $this->obtener($id);
        $_POST['id_persona'] = $usuario['id_persona'];
        $resultado = (new UsuarioService())->validar($_POST, (int) $id, true);
        if ((int) $id === (int) (Auth::user()['id_usuario'] ?? 0)
            && ((int) $usuario['id_rol'] !== $resultado['datos']['id_rol'] || (int) $usuario['id_estado_usuario'] !== $resultado['datos']['id_estado_usuario'])) {
            $resultado['errores']['general'] = 'No puedes cambiar el rol o estado de tu propia cuenta durante una sesión activa.';
        }
        if ($resultado['errores'] === [] && $this->dejaSinDuenoActivo($usuario, $resultado['datos'])) {
            $resultado['errores']['general'] = 'No es posible desactivar o cambiar el rol del último Dueño activo.';
        }
        if ($resultado['errores'] !== []) {
            Session::flash('errores', $resultado['errores']);
            Session::flash('datos', $_POST);
            redirect('/usuarios/' . (int) $id . '/editar');
        }
        try {
            $this->repository->actualizar((int) $id, $resultado['datos'], $resultado['permisos'], $resultado['respuestas']);
            Session::flash('mensaje', 'Usuario actualizado correctamente.');
        } catch (\PDOException) {
            Session::flash('errores', ['general' => 'No se pudo actualizar. Revisa que el CUIL, correo y usuario no estén repetidos.']);
            Session::flash('datos', $_POST);
        }
        redirect('/usuarios/' . (int) $id . '/editar');
    }

    public function desactivar(string $id): void
    {
        $this->validarCsrf();
        $usuario = $this->obtener($id);
        if ((int) $id === (int) (Auth::user()['id_usuario'] ?? 0)) {
            Session::flash('error', 'No puedes desactivar tu propia cuenta durante una sesión activa.');
        } elseif ($usuario['rol'] === 'DUENO' && $usuario['estado'] === 'ACTIVO' && $this->repository->cantidadDuenosActivos() <= 1) {
            Session::flash('error', 'No es posible desactivar al último Dueño activo.');
        } else {
            $this->repository->desactivar((int) $id);
            Session::flash('mensaje', 'Usuario desactivado correctamente.');
        }
        redirect('/usuarios');
    }

    private function formulario(string $titulo, string $accion, array $usuario, array $permisosSeleccionados, bool $edicion): void
    {
        View::render('usuarios/formulario', [
            'titulo' => $titulo, 'accion' => $accion, 'usuario' => $usuario,
            'roles' => array_values(array_filter($this->repository->roles(), static fn (array $rol): bool => $edicion || $rol['nombre'] !== 'DUENO')), 'estados' => $this->repository->estados(),
            'permisos' => $this->repository->catalogoPermisos(),
            'permisosSeleccionados' => array_map('intval', (array) ($usuario['permisos'] ?? $permisosSeleccionados)),
            'preguntas' => $this->repository->preguntasActivas(),
            'errores' => Session::pullFlash('errores', []),
            'mensaje' => Session::pullFlash('mensaje'), 'edicion' => $edicion,
        ]);
    }

    private function obtener(string $id): array
    {
        if (!ctype_digit($id) || ($usuario = $this->repository->buscar((int) $id)) === null) {
            http_response_code(404);
            View::render('errors/404');
            exit;
        }
        return $usuario;
    }

    private function dejaSinDuenoActivo(array $actual, array $nuevos): bool
    {
        if ($actual['rol'] !== 'DUENO' || $actual['estado'] !== 'ACTIVO' || $this->repository->cantidadDuenosActivos() > 1) return false;
        $rolNuevo = null;
        foreach ($this->repository->roles() as $rol) if ((int) $rol['id_rol'] === $nuevos['id_rol']) $rolNuevo = $rol['nombre'];
        $estadoNuevo = null;
        foreach ($this->repository->estados() as $estado) if ((int) $estado['id_estado_usuario'] === $nuevos['id_estado_usuario']) $estadoNuevo = $estado['codigo'];
        return $rolNuevo !== 'DUENO' || $estadoNuevo !== 'ACTIVO';
    }

    private function validarCsrf(): void
    {
        if (!Csrf::validate($_POST['_token'] ?? null)) {
            http_response_code(419);
            exit('La sesión del formulario venció.');
        }
    }
}

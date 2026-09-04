<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Auth;
use App\Core\Csrf;
use App\Core\Session;
use App\Core\View;
use App\Repositories\AdministracionRepository;

final class AdministracionController
{
    private AdministracionRepository $repository;

    public function __construct()
    {
        if ((Auth::user()['rol'] ?? null) !== 'DUENO') {
            http_response_code(403); View::render('errors/403'); exit;
        }
        $this->repository = new AdministracionRepository();
    }

    public function index(): void
    {
        View::render('administracion/index', [
            'roles' => $this->repository->roles(), 'permisos' => $this->repository->permisos(),
            'establecimientos' => $this->repository->establecimientos(), 'preguntas' => $this->repository->preguntas(),
            'mensaje' => Session::pullFlash('mensaje'), 'error' => Session::pullFlash('error'),
        ]);
    }

    public function crearRol(): void { $this->rol(null); }
    public function actualizarRol(string $id): void { $this->rol((int) $id); }
    public function eliminarRol(string $id): void
    {
        $this->validarCsrf();
        $rol = $this->buscar($this->repository->roles(), 'id_rol', (int) $id);
        if (in_array($rol['nombre'] ?? '', ['DUENO', 'PEON'], true)) $this->fallar('Los roles iniciales DUENO y PEON no pueden eliminarse.');
        $this->ejecutar(function () use ($id): void { $this->repository->eliminarRol((int) $id); }, 'Rol eliminado.', 'No puede eliminarse un rol asignado o relacionado con permisos.');
    }

    public function crearPermiso(): void { $this->permiso(null); }
    public function actualizarPermiso(string $id): void { $this->permiso((int) $id); }
    public function eliminarPermiso(string $id): void
    {
        $this->validarCsrf();
        $permiso = $this->buscar($this->repository->permisos(), 'id_permiso', (int) $id);
        if (in_array($permiso['nombre'] ?? '', $this->permisosSistema(), true)) $this->fallar('Los permisos utilizados internamente por el sistema no pueden eliminarse.');
        $this->ejecutar(function () use ($id): void { $this->repository->eliminarPermiso((int) $id); }, 'Permiso eliminado.', 'No puede eliminarse un permiso asignado a roles o usuarios.');
    }

    public function crearEstablecimiento(): void { $this->establecimiento(null); }
    public function actualizarEstablecimiento(string $id): void { $this->establecimiento((int) $id); }
    public function eliminarEstablecimiento(string $id): void
    {
        $this->validarCsrf();
        $this->ejecutar(function () use ($id): void { $this->repository->eliminarEstablecimiento((int) $id); }, 'Establecimiento eliminado.', 'No puede eliminarse un establecimiento que contiene potreros.');
    }

    public function crearPregunta(): void { $this->pregunta(null); }
    public function actualizarPregunta(string $id): void { $this->pregunta((int) $id); }
    public function eliminarPregunta(string $id): void
    {
        $this->validarCsrf();
        $this->ejecutar(function () use ($id): void { $this->repository->eliminarPregunta((int) $id); }, 'Pregunta eliminada.', 'No puede eliminarse una pregunta utilizada por un usuario. Puedes desactivarla.');
    }

    private function rol(?int $id): void
    {
        $this->validarCsrf();
        $nombre = strtoupper(trim((string) ($_POST['nombre'] ?? '')));
        $descripcion = $this->textoOpcional($_POST['descripcion'] ?? null);
        $permisos = (array) ($_POST['permisos'] ?? []);
        if ($nombre === '' || mb_strlen($nombre) > 60) $this->fallar('El nombre del rol es obligatorio y admite hasta 60 caracteres.');
        $actual = $id === null ? null : $this->buscar($this->repository->roles(), 'id_rol', $id);
        if (in_array($actual['nombre'] ?? '', ['DUENO', 'PEON'], true)) {
            $nombre = $actual['nombre'];
        }
        if (($actual['nombre'] ?? '') === 'DUENO') {
            $permisos = array_column($this->repository->permisos(), 'id_permiso');
        }
        $this->ejecutar(
            function () use ($id, $nombre, $descripcion, $permisos): void {
                if ($id === null) $this->repository->crearRol($nombre, $descripcion, $permisos);
                else $this->repository->actualizarRol($id, $nombre, $descripcion, $permisos);
            },
            'Rol guardado correctamente.', 'No se pudo guardar el rol. Verifica que el nombre no esté repetido.'
        );
    }

    private function permiso(?int $id): void
    {
        $this->validarCsrf();
        $nombre = strtoupper(trim((string) ($_POST['nombre'] ?? '')));
        $descripcion = $this->textoOpcional($_POST['descripcion'] ?? null);
        if ($nombre === '' || mb_strlen($nombre) > 100) $this->fallar('El nombre del permiso es obligatorio.');
        $actual = $id === null ? null : $this->buscar($this->repository->permisos(), 'id_permiso', $id);
        if (in_array($actual['nombre'] ?? '', $this->permisosSistema(), true)) $nombre = $actual['nombre'];
        $this->ejecutar(
            function () use ($id, $nombre, $descripcion): void {
                if ($id === null) $this->repository->crearPermiso($nombre, $descripcion);
                else $this->repository->actualizarPermiso($id, $nombre, $descripcion);
            },
            'Permiso guardado correctamente.', 'No se pudo guardar el permiso. Verifica que el nombre no esté repetido.'
        );
    }

    private function establecimiento(?int $id): void
    {
        $this->validarCsrf();
        $nombre = trim((string) ($_POST['nombre'] ?? ''));
        $descripcion = $this->textoOpcional($_POST['descripcion'] ?? null);
        if ($nombre === '' || mb_strlen($nombre) > 150) $this->fallar('El nombre del establecimiento es obligatorio.');
        $this->ejecutar(
            function () use ($id, $nombre, $descripcion): void {
                if ($id === null) $this->repository->crearEstablecimiento($nombre, $descripcion);
                else $this->repository->actualizarEstablecimiento($id, $nombre, $descripcion);
            },
            'Establecimiento guardado correctamente.', 'No se pudo guardar el establecimiento. Verifica que el nombre no esté repetido.'
        );
    }

    private function pregunta(?int $id): void
    {
        $this->validarCsrf();
        $texto = trim((string) ($_POST['texto'] ?? ''));
        $activa = isset($_POST['activa']);
        if ($texto === '' || mb_strlen($texto) > 200) $this->fallar('El texto de la pregunta es obligatorio.');
        $this->ejecutar(
            function () use ($id, $texto, $activa): void {
                if ($id === null) $this->repository->crearPregunta($texto, $activa);
                else $this->repository->actualizarPregunta($id, $texto, $activa);
            },
            'Pregunta guardada correctamente.', 'No se pudo guardar la pregunta. Verifica que no esté repetida.'
        );
    }

    private function ejecutar(callable $operacion, string $exito, string $error): never
    {
        try { $operacion(); Session::flash('mensaje', $exito); }
        catch (\PDOException) { Session::flash('error', $error); }
        redirect('/administracion');
    }

    private function fallar(string $mensaje): never { Session::flash('error', $mensaje); redirect('/administracion'); }
    private function textoOpcional(mixed $valor): ?string { $texto = trim((string) $valor); return $texto === '' ? null : $texto; }
    private function buscar(array $filas, string $clave, int $id): ?array { foreach ($filas as $fila) if ((int) $fila[$clave] === $id) return $fila; return null; }
    private function permisosSistema(): array { return ['POTRERO_CONSULTAR','POTRERO_CREAR','POTRERO_EDITAR','POTRERO_ELIMINAR','POTRERO_RECURSOS','USUARIO_GESTIONAR','ROL_GESTIONAR','PERMISO_GESTIONAR','ESTABLECIMIENTO_GESTIONAR','PREGUNTA_SEGURIDAD_GESTIONAR']; }
    private function validarCsrf(): void { if (!Csrf::validate($_POST['_token'] ?? null)) { http_response_code(419); exit('La sesión del formulario venció.'); } }
}

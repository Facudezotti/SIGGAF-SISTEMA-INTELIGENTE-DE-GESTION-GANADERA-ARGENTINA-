<?php

declare(strict_types=1);

use App\Controllers\AuthController;
use App\Controllers\DashboardController;
use App\Controllers\PotreroController;
use App\Controllers\RecuperacionController;
use App\Controllers\UsuarioController;
use App\Controllers\AdministracionController;
use App\Core\Auth;
use App\Core\Router;

require dirname(__DIR__) . '/bootstrap.php';
require dirname(__DIR__) . '/app/Core/helpers.php';

$router = new Router();
$router->get('/', static fn () => redirect(Auth::check() ? '/dashboard' : '/login'));
$router->get('/login', [AuthController::class, 'loginForm']);
$router->post('/login', [AuthController::class, 'login']);
$router->get('/recuperar', [RecuperacionController::class, 'solicitar']);
$router->post('/recuperar', [RecuperacionController::class, 'preguntas']);
$router->get('/recuperar/preguntas', [RecuperacionController::class, 'mostrarPreguntas']);
$router->post('/recuperar/verificar', [RecuperacionController::class, 'verificar']);
$router->get('/recuperar/nueva-contrasena', [RecuperacionController::class, 'nuevaContrasena']);
$router->post('/recuperar/nueva-contrasena', [RecuperacionController::class, 'actualizarContrasena']);
$router->post('/logout', [AuthController::class, 'logout'], true);
$router->get('/usuarios', [UsuarioController::class, 'index'], true, 'USUARIO_GESTIONAR');
$router->get('/usuarios/crear', [UsuarioController::class, 'crear'], true, 'USUARIO_GESTIONAR');
$router->post('/usuarios', [UsuarioController::class, 'guardar'], true, 'USUARIO_GESTIONAR');
$router->get('/usuarios/{id}/editar', [UsuarioController::class, 'editar'], true, 'USUARIO_GESTIONAR');
$router->post('/usuarios/{id}/actualizar', [UsuarioController::class, 'actualizar'], true, 'USUARIO_GESTIONAR');
$router->post('/usuarios/{id}/desactivar', [UsuarioController::class, 'desactivar'], true, 'USUARIO_GESTIONAR');
$router->get('/administracion', [AdministracionController::class, 'index'], true, 'ROL_GESTIONAR');
$router->post('/administracion/roles', [AdministracionController::class, 'crearRol'], true, 'ROL_GESTIONAR');
$router->post('/administracion/roles/{id}', [AdministracionController::class, 'actualizarRol'], true, 'ROL_GESTIONAR');
$router->post('/administracion/roles/{id}/eliminar', [AdministracionController::class, 'eliminarRol'], true, 'ROL_GESTIONAR');
$router->post('/administracion/permisos', [AdministracionController::class, 'crearPermiso'], true, 'PERMISO_GESTIONAR');
$router->post('/administracion/permisos/{id}', [AdministracionController::class, 'actualizarPermiso'], true, 'PERMISO_GESTIONAR');
$router->post('/administracion/permisos/{id}/eliminar', [AdministracionController::class, 'eliminarPermiso'], true, 'PERMISO_GESTIONAR');
$router->post('/administracion/establecimientos', [AdministracionController::class, 'crearEstablecimiento'], true, 'ESTABLECIMIENTO_GESTIONAR');
$router->post('/administracion/establecimientos/{id}', [AdministracionController::class, 'actualizarEstablecimiento'], true, 'ESTABLECIMIENTO_GESTIONAR');
$router->post('/administracion/establecimientos/{id}/eliminar', [AdministracionController::class, 'eliminarEstablecimiento'], true, 'ESTABLECIMIENTO_GESTIONAR');
$router->post('/administracion/preguntas', [AdministracionController::class, 'crearPregunta'], true, 'PREGUNTA_SEGURIDAD_GESTIONAR');
$router->post('/administracion/preguntas/{id}', [AdministracionController::class, 'actualizarPregunta'], true, 'PREGUNTA_SEGURIDAD_GESTIONAR');
$router->post('/administracion/preguntas/{id}/eliminar', [AdministracionController::class, 'eliminarPregunta'], true, 'PREGUNTA_SEGURIDAD_GESTIONAR');
$router->get('/dashboard', [DashboardController::class, 'index'], true);
$router->get('/potreros', [PotreroController::class, 'index'], true, 'POTRERO_CONSULTAR');
$router->get('/potreros/crear', [PotreroController::class, 'crear'], true, 'POTRERO_CREAR');
$router->post('/potreros', [PotreroController::class, 'guardar'], true, 'POTRERO_CREAR');
$router->get('/potreros/{id}', [PotreroController::class, 'ver'], true, 'POTRERO_CONSULTAR');
$router->get('/potreros/{id}/editar', [PotreroController::class, 'editar'], true, 'POTRERO_EDITAR');
$router->post('/potreros/{id}/actualizar', [PotreroController::class, 'actualizar'], true, 'POTRERO_EDITAR');
$router->post('/potreros/{id}/eliminar', [PotreroController::class, 'eliminar'], true, 'POTRERO_ELIMINAR');
$router->post('/potreros/{id}/recursos', [PotreroController::class, 'agregarRecurso'], true, 'POTRERO_RECURSOS');
$router->post('/potreros/{id}/recursos/{recurso}/disponibilidad', [PotreroController::class, 'cambiarDisponibilidad'], true, 'POTRERO_RECURSOS');
$router->post('/potreros/{id}/recursos/{recurso}/actualizar', [PotreroController::class, 'actualizarRecurso'], true, 'POTRERO_RECURSOS');
$router->post('/potreros/{id}/recursos/{recurso}/eliminar', [PotreroController::class, 'eliminarRecurso'], true, 'POTRERO_RECURSOS');
$router->dispatch($_SERVER['REQUEST_METHOD'] ?? 'GET', $_SERVER['REQUEST_URI'] ?? '/');

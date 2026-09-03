<?php

declare(strict_types=1);

use App\Controllers\AuthController;
use App\Controllers\DashboardController;
use App\Controllers\PotreroController;
use App\Core\Auth;
use App\Core\Router;

require dirname(__DIR__) . '/bootstrap.php';
require dirname(__DIR__) . '/app/Core/helpers.php';

$router = new Router();
$router->get('/', static fn () => redirect(Auth::check() ? '/dashboard' : '/login'));
$router->get('/login', [AuthController::class, 'loginForm']);
$router->post('/login', [AuthController::class, 'login']);
$router->post('/logout', [AuthController::class, 'logout'], true);
$router->get('/dashboard', [DashboardController::class, 'index'], true);
$router->get('/potreros', [PotreroController::class, 'index'], true, 'POTRERO_CONSULTAR');
$router->get('/potreros/crear', [PotreroController::class, 'crear'], true, 'POTRERO_CREAR');
$router->post('/potreros', [PotreroController::class, 'guardar'], true, 'POTRERO_CREAR');
$router->get('/potreros/{id}', [PotreroController::class, 'ver'], true, 'POTRERO_CONSULTAR');
$router->get('/potreros/{id}/editar', [PotreroController::class, 'editar'], true, 'POTRERO_EDITAR');
$router->post('/potreros/{id}/actualizar', [PotreroController::class, 'actualizar'], true, 'POTRERO_EDITAR');
$router->post('/potreros/{id}/recursos', [PotreroController::class, 'agregarRecurso'], true, 'POTRERO_RECURSOS');
$router->post('/potreros/{id}/recursos/{recurso}/disponibilidad', [PotreroController::class, 'cambiarDisponibilidad'], true, 'POTRERO_RECURSOS');
$router->dispatch($_SERVER['REQUEST_METHOD'] ?? 'GET', $_SERVER['REQUEST_URI'] ?? '/');

<?php

use App\Core\Auth;
use App\Core\Session;

$usuarioActual = Auth::user();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SIGGAF | La Celina</title>
    <link rel="stylesheet" href="<?= e(url('/assets/css/app.css')) ?>">
    <link rel="stylesheet" href="<?= e(url('/assets/css/potreros.css')) ?>">
</head>
<body>
<header class="topbar">
    <a class="brand" href="<?= e(url('/dashboard')) ?>">
        <img class="topbar-logo" src="<?= e(url($configuracionVisual['logo_ruta'])) ?>" alt="Logo de SIGGAF">
        <span class="brand-text"><strong>SIGGAF</strong><small>La Celina</small></span>
    </a>
    <nav class="navigation" aria-label="Navegación principal">
        <a href="<?= e(url('/dashboard')) ?>">Inicio</a>
        <?php if (Auth::can('POTRERO_CONSULTAR')): ?><a href="<?= e(url('/potreros')) ?>">Potreros</a><?php endif; ?>
        <?php if (($usuarioActual['rol'] ?? '') === 'DUENO' && Auth::can('USUARIO_GESTIONAR')): ?><a href="<?= e(url('/usuarios')) ?>">Usuarios</a><?php endif; ?>
        <?php if (($usuarioActual['rol'] ?? '') === 'DUENO' && Auth::can('ROL_GESTIONAR')): ?><a href="<?= e(url('/administracion')) ?>">Administración</a><?php endif; ?>
        <?php if (($usuarioActual['rol'] ?? '') === 'DUENO'): ?><a href="<?= e(url('/personalizacion')) ?>">Apariencia</a><?php endif; ?>
    </nav>
    <div class="user-area">
        <span><?= e($usuarioActual['nombre_completo'] ?? '') ?> · <?= e($usuarioActual['rol'] ?? '') ?></span>
        <form action="<?= e(url('/logout')) ?>" method="post">
            <?= csrf_field() ?>
            <button class="link-button" type="submit">Cerrar sesión</button>
        </form>
    </div>
</header>
<main class="container">
    <?php if ($globalError = Session::pullFlash('global_error')): ?>
        <div class="alert alert-error"><?= e($globalError) ?></div>
    <?php endif; ?>
    <?= $content ?>
</main>
</body>
</html>

<section class="page-heading">
    <div>
        <p class="eyebrow">Primera entrega</p>
        <h1>Panel principal</h1>
        <p>Accede a los módulos habilitados del Sistema Inteligente de Gestión Ganadera.</p>
    </div>
</section>

<section class="module-grid">
    <?php if (\App\Core\Auth::can('POTRERO_CONSULTAR')): ?>
    <a class="module-card" href="<?= e(url('/potreros')) ?>">
        <span class="module-icon" aria-hidden="true">▦</span>
        <div>
            <h2>Gestión de potreros</h2>
            <p>Registra dimensiones, consulta superficies y administra los recursos disponibles.</p>
        </div>
    </a>
    <?php endif; ?>
    <?php if ((\App\Core\Auth::user()['rol'] ?? '') === 'DUENO' && \App\Core\Auth::can('USUARIO_GESTIONAR')): ?>
    <a class="module-card" href="<?= e(url('/usuarios')) ?>"><span class="module-icon" aria-hidden="true">♙</span><div><h2>Administración de usuarios</h2><p>Crea peones y gestiona sus datos, roles, permisos y preguntas de seguridad.</p></div></a>
    <?php endif; ?>
    <?php if ((\App\Core\Auth::user()['rol'] ?? '') === 'DUENO' && \App\Core\Auth::can('ROL_GESTIONAR')): ?>
    <a class="module-card" href="<?= e(url('/administracion')) ?>"><span class="module-icon" aria-hidden="true">⚙</span><div><h2>Configuración</h2><p>Administra roles, permisos, establecimientos y preguntas de seguridad.</p></div></a>
    <?php endif; ?>
    <?php if (!\App\Core\Auth::can('POTRERO_CONSULTAR') && !\App\Core\Auth::can('USUARIO_GESTIONAR')): ?>
        <article class="panel"><p>No tienes módulos operativos habilitados. Consulta con el administrador.</p></article>
    <?php endif; ?>
</section>

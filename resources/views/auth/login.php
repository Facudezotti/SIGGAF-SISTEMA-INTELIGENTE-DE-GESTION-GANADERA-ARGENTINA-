<main class="login-shell">
    <section class="login-card" aria-labelledby="login-title">
        <img
            class="brand-logo"
            src="<?= e(url($configuracionVisual['logo_ruta'])) ?>"
            alt="Logo de SIGGAF"
            width="450"
            height="360"
        >
        <p class="system-name">Sistema Inteligente de Gestión Ganadera</p>
        <h1 id="login-title">La Celina</h1>
        <div class="title-divider"><span></span></div>

        <?php if (!empty($error)): ?>
            <div class="login-error" role="alert"><?= e($error) ?></div>
        <?php endif; ?>
        <?php if (!empty($mensaje)): ?><div class="login-success" role="status"><?= e($mensaje) ?></div><?php endif; ?>

        <form action="<?= e(url('/login')) ?>" method="post" class="login-form">
            <?= csrf_field() ?>
            <label class="input-group">
                <span class="input-icon" aria-hidden="true">♙</span>
                <span class="sr-only">Usuario</span>
                <input type="text" name="usuario" value="<?= e($oldUsuario ?? '') ?>" placeholder="Usuario" maxlength="80" autocomplete="username" required autofocus>
            </label>

            <label class="input-group">
                <span class="input-icon" aria-hidden="true">▣</span>
                <span class="sr-only">Contraseña</span>
                <input id="contrasena" type="password" name="contrasena" placeholder="Contraseña" autocomplete="current-password" required>
                <button id="alternar-contrasena" class="password-toggle" type="button" aria-label="Mostrar contraseña">Ver</button>
            </label>

            <button class="login-button" type="submit">Ingresar</button>
        </form>

        <a class="forgot-button" href="<?= e(url('/recuperar')) ?>">¿Olvidaste tu contraseña?</a>
    </section>
</main>

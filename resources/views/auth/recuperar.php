<main class="login-shell">
    <section class="login-card" aria-labelledby="recuperar-title">
        <div class="cattle-mark" aria-hidden="true">♉</div>
        <p class="system-name">Recuperación de acceso</p>
        <h1 id="recuperar-title" class="compact-title">Identificar cuenta</h1>
        <?php if (!empty($error)): ?><div class="login-error" role="alert"><?= e($error) ?></div><?php endif; ?>
        <form class="login-form" action="<?= e(url('/recuperar')) ?>" method="post">
            <?= csrf_field() ?>
            <label class="input-group">
                <span class="input-icon" aria-hidden="true">♙</span>
                <span class="sr-only">Usuario</span>
                <input type="text" name="usuario" placeholder="Nombre de usuario" maxlength="80" required autofocus>
            </label>
            <button class="login-button" type="submit">Continuar</button>
        </form>
        <a class="forgot-button" href="<?= e(url('/login')) ?>">Volver al inicio de sesión</a>
    </section>
</main>


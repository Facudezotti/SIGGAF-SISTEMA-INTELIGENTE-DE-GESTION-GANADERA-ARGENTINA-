<main class="login-shell">
    <section class="login-card recovery-card" aria-labelledby="contrasena-title">
        <p class="system-name">Recuperación de acceso</p>
        <h1 id="contrasena-title" class="compact-title">Nueva contraseña</h1>
        <p class="recovery-help">Utiliza al menos ocho caracteres.</p>
        <?php if (!empty($error)): ?><div class="login-error" role="alert"><?= e($error) ?></div><?php endif; ?>
        <form class="login-form" action="<?= e(url('/recuperar/nueva-contrasena')) ?>" method="post">
            <?= csrf_field() ?>
            <label class="input-group"><span class="sr-only">Nueva contraseña</span><input type="password" name="contrasena" placeholder="Nueva contraseña" minlength="8" required></label>
            <label class="input-group"><span class="sr-only">Confirmar contraseña</span><input type="password" name="confirmacion" placeholder="Confirmar contraseña" minlength="8" required></label>
            <button class="login-button" type="submit">Cambiar contraseña</button>
        </form>
    </section>
</main>

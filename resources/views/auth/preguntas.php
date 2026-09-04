<main class="login-shell">
    <section class="login-card recovery-card" aria-labelledby="preguntas-title">
        <img
            class="brand-logo brand-logo--compact"
            src="<?= e(url($configuracionVisual['logo_ruta'])) ?>"
            alt="Logo de SIGGAF"
            width="450"
            height="360"
        >
        <p class="system-name">Recuperación de acceso</p>
        <h1 id="preguntas-title" class="compact-title">Preguntas de seguridad</h1>
        <p class="recovery-help">Responde las tres preguntas para verificar tu identidad.</p>
        <?php if (!empty($error)): ?><div class="login-error" role="alert"><?= e($error) ?></div><?php endif; ?>
        <form class="login-form" action="<?= e(url('/recuperar/verificar')) ?>" method="post">
            <?= csrf_field() ?>
            <?php foreach ($preguntas as $indice => $pregunta): ?>
                <label class="recovery-field">
                    <span><?= e($pregunta['texto']) ?></span>
                    <input type="text" name="respuestas[<?= e($indice) ?>]" maxlength="200" autocomplete="off" required>
                </label>
            <?php endforeach; ?>
            <button class="login-button" type="submit">Verificar respuestas</button>
        </form>
        <a class="forgot-button" href="<?= e(url('/recuperar')) ?>">Comenzar nuevamente</a>
    </section>
</main>

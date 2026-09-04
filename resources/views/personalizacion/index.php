<section class="page-heading">
    <p class="eyebrow">Configuración visual</p>
    <h1>Apariencia del sistema</h1>
    <p>El logo se muestra en todo el sistema. El fondo se aplica solamente al acceso y a la recuperación de contraseña.</p>
</section>

<?php if (!empty($mensaje)): ?><div class="alert alert-success" role="status"><?= e($mensaje) ?></div><?php endif; ?>
<?php if (!empty($error)): ?><div class="alert alert-error" role="alert"><?= e($error) ?></div><?php endif; ?>

<section class="personalization-grid">
    <article class="panel personalization-card">
        <div>
            <h2>Logo global</h2>
            <p>Se utiliza en la cabecera del sistema y en las pantallas de acceso.</p>
        </div>

        <div class="image-preview">
            <img src="<?= e(url($configuracion['logo_ruta'])) ?>" alt="Vista previa del logo actual">
        </div>

        <form class="upload-form" action="<?= e(url('/personalizacion/logo')) ?>" method="post" enctype="multipart/form-data">
            <?= csrf_field() ?>
            <label for="logo">Seleccionar nuevo logo</label>
            <input id="logo" type="file" name="logo" accept="image/png,image/jpeg,image/webp" required>
            <span class="upload-help">Formatos permitidos: PNG, JPG, JPEG o WebP. Tamaño máximo: 5 MB.</span>
            <div class="personalization-actions">
                <button class="button button-primary" type="submit">Guardar logo</button>
            </div>
        </form>

        <form action="<?= e(url('/personalizacion/logo/restaurar')) ?>" method="post">
            <?= csrf_field() ?>
            <button class="button button-secondary" type="submit" onclick="return confirm('¿Restaurar el logo predeterminado?')">Restaurar logo original</button>
        </form>
    </article>

    <article class="panel personalization-card">
        <div>
            <h2>Fondo de acceso</h2>
            <p>Se muestra detrás del formulario de inicio de sesión y durante la recuperación de contraseña.</p>
        </div>

        <div class="image-preview image-preview--background">
            <img src="<?= e(url($configuracion['fondo_ruta'])) ?>" alt="Vista previa del fondo actual">
        </div>

        <form class="upload-form" action="<?= e(url('/personalizacion/fondo')) ?>" method="post" enctype="multipart/form-data">
            <?= csrf_field() ?>
            <label for="fondo">Seleccionar nuevo fondo</label>
            <input id="fondo" type="file" name="fondo" accept="image/png,image/jpeg,image/webp" required>
            <span class="upload-help">Formatos permitidos: PNG, JPG, JPEG o WebP. Se recomienda una imagen horizontal de al menos 1600 × 900 píxeles.</span>
            <div class="personalization-actions">
                <button class="button button-primary" type="submit">Guardar fondo</button>
            </div>
        </form>

        <form action="<?= e(url('/personalizacion/fondo/restaurar')) ?>" method="post">
            <?= csrf_field() ?>
            <button class="button button-secondary" type="submit" onclick="return confirm('¿Restaurar el fondo predeterminado?')">Restaurar fondo original</button>
        </form>
    </article>
</section>


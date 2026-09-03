<section class="page-heading heading-actions">
    <div>
        <p class="eyebrow">Establecimiento y potreros</p>
        <h1><?= e($titulo) ?></h1>
        <p>Los campos indicados son obligatorios.</p>
    </div>
    <a class="button button-secondary" href="<?= e(url('/potreros')) ?>">Volver</a>
</section>

<form class="panel form-grid" action="<?= e(url($accion)) ?>" method="post">
    <?= csrf_field() ?>

    <label class="field field-wide">
        <span>Establecimiento</span>
        <select name="id_establecimiento" required>
            <option value="">Seleccionar</option>
            <?php foreach ($establecimientos as $establecimiento): ?>
                <option value="<?= e($establecimiento['id_establecimiento']) ?>" <?= (string) ($potrero['id_establecimiento'] ?? '') === (string) $establecimiento['id_establecimiento'] ? 'selected' : '' ?>>
                    <?= e($establecimiento['nombre']) ?>
                </option>
            <?php endforeach; ?>
        </select>
        <?php if (isset($errores['id_establecimiento'])): ?><small class="field-error"><?= e($errores['id_establecimiento']) ?></small><?php endif; ?>
    </label>

    <label class="field field-wide">
        <span>Nombre del potrero</span>
        <input type="text" name="nombre" value="<?= e($potrero['nombre'] ?? '') ?>" maxlength="150" required>
        <?php if (isset($errores['nombre'])): ?><small class="field-error"><?= e($errores['nombre']) ?></small><?php endif; ?>
    </label>

    <label class="field">
        <span>Largo en metros</span>
        <input id="largo" type="number" name="largo" value="<?= e($potrero['largo'] ?? '') ?>" min="0.01" step="0.01" required>
        <?php if (isset($errores['largo'])): ?><small class="field-error"><?= e($errores['largo']) ?></small><?php endif; ?>
    </label>

    <label class="field">
        <span>Ancho en metros</span>
        <input id="ancho" type="number" name="ancho" value="<?= e($potrero['ancho'] ?? '') ?>" min="0.01" step="0.01" required>
        <?php if (isset($errores['ancho'])): ?><small class="field-error"><?= e($errores['ancho']) ?></small><?php endif; ?>
    </label>

    <div class="surface-preview field-wide">
        <span>Superficie calculada</span>
        <strong id="superficie-calculada"><?= e(number_format((float) ($potrero['superficie'] ?? 0), 2, ',', '.')) ?> m²</strong>
    </div>

    <div class="form-actions field-wide">
        <a class="button button-secondary" href="<?= e(url('/potreros')) ?>">Cancelar</a>
        <button class="button button-primary" type="submit">Guardar</button>
    </div>
</form>
<script src="<?= e(url('/assets/js/potreros.js')) ?>" defer></script>


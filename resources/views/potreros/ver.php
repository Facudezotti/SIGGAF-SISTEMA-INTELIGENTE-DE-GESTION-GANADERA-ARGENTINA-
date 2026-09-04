<section class="page-heading heading-actions">
    <div>
        <p class="eyebrow"><?= e($potrero['establecimiento']) ?></p>
        <h1><?= e($potrero['nombre']) ?></h1>
        <p>Detalle del potrero y sus recursos disponibles.</p>
    </div>
    <div class="action-group">
        <a class="button button-secondary" href="<?= e(url('/potreros')) ?>">Volver</a>
        <?php if (\App\Core\Auth::can('POTRERO_EDITAR')): ?><a class="button button-primary" href="<?= e(url('/potreros/' . $potrero['id_potrero'] . '/editar')) ?>">Editar</a><?php endif; ?>
    </div>
</section>

<?php if (!empty($mensaje)): ?><div class="alert alert-success"><?= e($mensaje) ?></div><?php endif; ?>
<?php if (!empty($error)): ?><div class="alert alert-error"><?= e($error) ?></div><?php endif; ?>

<section class="metric-grid">
    <article class="metric-card"><span>Largo</span><strong><?= e(number_format((float) $potrero['largo'], 2, ',', '.')) ?> m</strong></article>
    <article class="metric-card"><span>Ancho</span><strong><?= e(number_format((float) $potrero['ancho'], 2, ',', '.')) ?> m</strong></article>
    <article class="metric-card"><span>Superficie</span><strong><?= e(number_format((float) $potrero['superficie'], 2, ',', '.')) ?> m²</strong></article>
</section>

<section class="two-columns">
    <div class="panel">
        <div class="panel-heading"><h2>Recursos registrados</h2></div>
        <?php if ($recursos === []): ?>
            <p class="muted">Todavía no se registraron recursos.</p>
        <?php else: ?>
            <div class="resource-list">
                <?php foreach ($recursos as $recurso): ?>
                    <article class="resource-item resource-edit">
                        <?php if (\App\Core\Auth::can('POTRERO_RECURSOS')): ?><form class="resource-form" action="<?= e(url('/potreros/' . $potrero['id_potrero'] . '/recursos/' . $recurso['id_recurso_potrero'] . '/actualizar')) ?>" method="post">
                            <?= csrf_field() ?><input name="nombre" value="<?= e($recurso['nombre']) ?>" required><input name="observacion" value="<?= e($recurso['observacion']) ?>" placeholder="Observación"><label><input type="checkbox" name="disponible" <?= $recurso['disponible'] ? 'checked' : '' ?>> Disponible</label><button class="button button-secondary" type="submit">Guardar</button><button class="link-danger" formaction="<?= e(url('/potreros/' . $potrero['id_potrero'] . '/recursos/' . $recurso['id_recurso_potrero'] . '/eliminar')) ?>" onclick="return confirm('¿Eliminar este recurso?')">Eliminar</button>
                        </form><?php else: ?><div><h3><?= e($recurso['nombre']) ?></h3><p><?= e($recurso['observacion'] ?: 'Sin observaciones') ?></p></div><span class="status <?= $recurso['disponible'] ? 'available' : 'unavailable' ?>"><?= $recurso['disponible'] ? 'Disponible' : 'No disponible' ?></span><?php endif; ?>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>

    <?php if (\App\Core\Auth::can('POTRERO_RECURSOS')): ?><form class="panel" action="<?= e(url('/potreros/' . $potrero['id_potrero'] . '/recursos')) ?>" method="post">
        <?= csrf_field() ?>
        <div class="panel-heading"><h2>Agregar recurso</h2></div>
        <label class="field">
            <span>Nombre</span>
            <input type="text" name="nombre" maxlength="120" placeholder="Ej.: Agua" required>
        </label>
        <label class="field">
            <span>Observación</span>
            <textarea name="observacion" rows="4" placeholder="Información adicional"></textarea>
        </label>
        <label class="checkbox-field">
            <input type="checkbox" name="disponible" checked>
            <span>Disponible actualmente</span>
        </label>
        <button class="button button-primary button-full" type="submit">Agregar recurso</button>
    </form><?php endif; ?>
</section>

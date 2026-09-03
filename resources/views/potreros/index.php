<section class="page-heading heading-actions">
    <div>
        <p class="eyebrow">Establecimiento y potreros</p>
        <h1>Potreros</h1>
        <p>Consulta las dimensiones, superficies y recursos registrados.</p>
    </div>
    <?php if (\App\Core\Auth::can('POTRERO_CREAR')): ?>
        <a class="button button-primary" href="<?= e(url('/potreros/crear')) ?>">Registrar potrero</a>
    <?php endif; ?>
</section>

<?php if (!empty($mensaje)): ?>
    <div class="alert alert-success"><?= e($mensaje) ?></div>
<?php endif; ?>

<section class="panel">
    <?php if ($potreros === []): ?>
        <div class="empty-state">
            <h2>No hay potreros registrados</h2>
            <p>Registra el primer potrero para comenzar.</p>
        </div>
    <?php else: ?>
        <div class="table-wrapper">
            <table>
                <thead>
                <tr>
                    <th>Nombre</th>
                    <th>Establecimiento</th>
                    <th>Largo</th>
                    <th>Ancho</th>
                    <th>Superficie</th>
                    <th>Recursos</th>
                    <th>Acciones</th>
                </tr>
                </thead>
                <tbody>
                <?php foreach ($potreros as $potrero): ?>
                    <tr>
                        <td><strong><?= e($potrero['nombre']) ?></strong></td>
                        <td><?= e($potrero['establecimiento']) ?></td>
                        <td><?= e(number_format((float) $potrero['largo'], 2, ',', '.')) ?> m</td>
                        <td><?= e(number_format((float) $potrero['ancho'], 2, ',', '.')) ?> m</td>
                        <td><?= e(number_format((float) $potrero['superficie'], 2, ',', '.')) ?> m²</td>
                        <td><?= e($potrero['cantidad_recursos']) ?></td>
                        <td class="table-actions">
                            <a href="<?= e(url('/potreros/' . $potrero['id_potrero'])) ?>">Ver</a>
                            <?php if (\App\Core\Auth::can('POTRERO_EDITAR')): ?><a href="<?= e(url('/potreros/' . $potrero['id_potrero'] . '/editar')) ?>">Editar</a><?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</section>

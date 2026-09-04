<section class="page-heading heading-actions">
    <div><p class="eyebrow">Administración</p><h1>Usuarios</h1><p>Gestiona cuentas, roles, estados y permisos individuales.</p></div>
    <a class="button button-primary" href="<?= e(url('/usuarios/crear')) ?>">Registrar usuario</a>
</section>
<?php if (!empty($mensaje)): ?><div class="alert alert-success"><?= e($mensaje) ?></div><?php endif; ?>
<?php if (!empty($error)): ?><div class="alert alert-error"><?= e($error) ?></div><?php endif; ?>
<section class="panel"><div class="table-wrapper"><table>
    <thead><tr><th>Persona</th><th>Usuario</th><th>Rol</th><th>Estado</th><th>Correo</th><th>Acciones</th></tr></thead>
    <tbody><?php foreach ($usuarios as $item): ?><tr>
        <td><strong><?= e($item['apellido'] . ', ' . $item['nombre']) ?></strong></td><td><?= e($item['nombre_usuario']) ?></td>
        <td><?= e($item['rol']) ?></td><td><span class="status <?= $item['estado'] === 'ACTIVO' ? 'available' : 'unavailable' ?>"><?= e($item['estado']) ?></span></td>
        <td><?= e($item['correo'] ?: 'Sin correo') ?></td><td class="table-actions">
            <a href="<?= e(url('/usuarios/' . $item['id_usuario'] . '/editar')) ?>">Editar</a>
            <?php if ($item['estado'] === 'ACTIVO'): ?><form action="<?= e(url('/usuarios/' . $item['id_usuario'] . '/desactivar')) ?>" method="post" onsubmit="return confirm('¿Deseas desactivar este usuario?')"><?= csrf_field() ?><button class="link-danger" type="submit">Desactivar</button></form><?php endif; ?>
        </td>
    </tr><?php endforeach; ?></tbody>
</table></div></section>


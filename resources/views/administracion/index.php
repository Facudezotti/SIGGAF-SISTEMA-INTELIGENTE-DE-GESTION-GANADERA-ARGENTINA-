<section class="page-heading">
    <p class="eyebrow">Configuración</p><h1>Administración general</h1>
    <p>Gestiona roles, permisos, establecimientos y preguntas de seguridad.</p>
</section>
<?php if (!empty($mensaje)): ?><div class="alert alert-success"><?= e($mensaje) ?></div><?php endif; ?>
<?php if (!empty($error)): ?><div class="alert alert-error"><?= e($error) ?></div><?php endif; ?>

<section class="admin-section panel">
    <div class="panel-heading"><h2>Roles</h2></div>
    <form class="inline-create" action="<?= e(url('/administracion/roles')) ?>" method="post"><?= csrf_field() ?><input name="nombre" placeholder="Nombre del rol" maxlength="60" required><input name="descripcion" placeholder="Descripción"><button class="button button-primary" type="submit">Agregar</button></form>
    <div class="admin-cards"><?php foreach ($roles as $rol): ?><form class="admin-card" action="<?= e(url('/administracion/roles/' . $rol['id_rol'])) ?>" method="post"><?= csrf_field() ?>
        <div class="admin-fields"><input name="nombre" value="<?= e($rol['nombre']) ?>" <?= in_array($rol['nombre'], ['DUENO','PEON'], true) ? 'readonly' : '' ?> required><input name="descripcion" value="<?= e($rol['descripcion']) ?>" placeholder="Descripción"></div>
        <div class="compact-checks"><?php foreach ($permisos as $permiso): ?><label><input type="checkbox" name="permisos[]" value="<?= e($permiso['id_permiso']) ?>" <?= in_array((int) $permiso['id_permiso'], $rol['permisos'], true) ? 'checked' : '' ?> <?= $rol['nombre'] === 'DUENO' ? 'disabled' : '' ?>> <?= e($permiso['nombre']) ?></label><?php endforeach; ?></div>
        <?php if ($rol['nombre'] === 'DUENO'): ?><?php foreach ($permisos as $permiso): ?><input type="hidden" name="permisos[]" value="<?= e($permiso['id_permiso']) ?>"><?php endforeach; ?><?php endif; ?>
        <div class="admin-actions"><button class="button button-secondary" type="submit">Guardar</button><?php if (!in_array($rol['nombre'], ['DUENO','PEON'], true)): ?><button class="link-danger" formaction="<?= e(url('/administracion/roles/' . $rol['id_rol'] . '/eliminar')) ?>" onclick="return confirm('¿Eliminar este rol?')">Eliminar</button><?php endif; ?></div>
    </form><?php endforeach; ?></div>
</section>

<section class="admin-section panel">
    <div class="panel-heading"><h2>Permisos</h2></div>
    <form class="inline-create" action="<?= e(url('/administracion/permisos')) ?>" method="post"><?= csrf_field() ?><input name="nombre" placeholder="CÓDIGO_PERMISO" maxlength="100" required><input name="descripcion" placeholder="Descripción"><button class="button button-primary" type="submit">Agregar</button></form>
    <div class="admin-cards two-card-columns"><?php foreach ($permisos as $permiso): ?><form class="admin-card" action="<?= e(url('/administracion/permisos/' . $permiso['id_permiso'])) ?>" method="post"><?= csrf_field() ?><div class="admin-fields"><input name="nombre" value="<?= e($permiso['nombre']) ?>" required><input name="descripcion" value="<?= e($permiso['descripcion']) ?>"></div><div class="admin-actions"><button class="button button-secondary" type="submit">Guardar</button><button class="link-danger" formaction="<?= e(url('/administracion/permisos/' . $permiso['id_permiso'] . '/eliminar')) ?>" onclick="return confirm('Solo puede eliminarse si no está asignado. ¿Continuar?')">Eliminar</button></div></form><?php endforeach; ?></div>
</section>

<section class="admin-section panel">
    <div class="panel-heading"><h2>Establecimientos</h2></div>
    <form class="inline-create" action="<?= e(url('/administracion/establecimientos')) ?>" method="post"><?= csrf_field() ?><input name="nombre" placeholder="Nombre" maxlength="150" required><input name="descripcion" placeholder="Descripción"><button class="button button-primary" type="submit">Agregar</button></form>
    <div class="admin-cards two-card-columns"><?php foreach ($establecimientos as $establecimiento): ?><form class="admin-card" action="<?= e(url('/administracion/establecimientos/' . $establecimiento['id_establecimiento'])) ?>" method="post"><?= csrf_field() ?><div class="admin-fields"><input name="nombre" value="<?= e($establecimiento['nombre']) ?>" required><input name="descripcion" value="<?= e($establecimiento['descripcion']) ?>"></div><div class="admin-actions"><button class="button button-secondary" type="submit">Guardar</button><button class="link-danger" formaction="<?= e(url('/administracion/establecimientos/' . $establecimiento['id_establecimiento'] . '/eliminar')) ?>" onclick="return confirm('Solo puede eliminarse si no contiene potreros. ¿Continuar?')">Eliminar</button></div></form><?php endforeach; ?></div>
</section>

<section class="admin-section panel">
    <div class="panel-heading"><h2>Preguntas de seguridad</h2></div>
    <form class="inline-create" action="<?= e(url('/administracion/preguntas')) ?>" method="post"><?= csrf_field() ?><input name="texto" placeholder="Texto de la pregunta" maxlength="200" required><label class="checkbox-field"><input type="checkbox" name="activa" checked> Activa</label><button class="button button-primary" type="submit">Agregar</button></form>
    <div class="admin-cards two-card-columns"><?php foreach ($preguntas as $pregunta): ?><form class="admin-card" action="<?= e(url('/administracion/preguntas/' . $pregunta['id_pregunta_seguridad'])) ?>" method="post"><?= csrf_field() ?><div class="admin-fields"><input name="texto" value="<?= e($pregunta['texto']) ?>" required><label class="checkbox-field"><input type="checkbox" name="activa" <?= $pregunta['activa'] ? 'checked' : '' ?>> Activa</label></div><div class="admin-actions"><button class="button button-secondary" type="submit">Guardar</button><button class="link-danger" formaction="<?= e(url('/administracion/preguntas/' . $pregunta['id_pregunta_seguridad'] . '/eliminar')) ?>" onclick="return confirm('Solo puede eliminarse si ningún usuario la utiliza. ¿Continuar?')">Eliminar</button></div></form><?php endforeach; ?></div>
</section>

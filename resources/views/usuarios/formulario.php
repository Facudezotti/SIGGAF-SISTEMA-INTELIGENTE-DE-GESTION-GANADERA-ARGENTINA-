<section class="page-heading heading-actions">
    <div><p class="eyebrow">Administración de usuarios</p><h1><?= e($titulo) ?></h1><p>Los permisos individuales se suman a los permisos heredados del rol.</p></div>
    <a class="button button-secondary" href="<?= e(url('/usuarios')) ?>">Volver</a>
</section>
<?php if (!empty($mensaje)): ?><div class="alert alert-success"><?= e($mensaje) ?></div><?php endif; ?>
<?php if (isset($errores['general'])): ?><div class="alert alert-error"><?= e($errores['general']) ?></div><?php endif; ?>
<form class="panel form-grid" action="<?= e(url($accion)) ?>" method="post">
    <?= csrf_field() ?>
    <?php if ($edicion): ?><input type="hidden" name="id_persona" value="<?= e($usuario['id_persona'] ?? '') ?>"><?php endif; ?>
    <?php foreach ([['nombre','Nombre'],['apellido','Apellido'],['cuil','CUIL'],['correo','Correo electrónico'],['telefono','Teléfono'],['direccion','Dirección'],['nombre_usuario','Nombre de usuario']] as [$campo,$etiqueta]): ?>
        <label class="field <?= in_array($campo, ['direccion','nombre_usuario'], true) ? 'field-wide' : '' ?>"><span><?= e($etiqueta) ?></span><input type="<?= $campo === 'correo' ? 'email' : 'text' ?>" name="<?= e($campo) ?>" value="<?= e($usuario[$campo] ?? '') ?>" <?= in_array($campo, ['nombre','apellido','nombre_usuario'], true) ? 'required' : '' ?>><?php if (isset($errores[$campo])): ?><small class="field-error"><?= e($errores[$campo]) ?></small><?php endif; ?></label>
    <?php endforeach; ?>
    <label class="field"><span>Rol</span><select name="id_rol" required><option value="">Seleccionar</option><?php foreach ($roles as $rol): ?><option value="<?= e($rol['id_rol']) ?>" <?= (string) ($usuario['id_rol'] ?? '') === (string) $rol['id_rol'] ? 'selected' : '' ?>><?= e($rol['nombre']) ?></option><?php endforeach; ?></select><?php if (isset($errores['id_rol'])): ?><small class="field-error"><?= e($errores['id_rol']) ?></small><?php endif; ?></label>
    <label class="field"><span>Estado</span><select name="id_estado_usuario" required><option value="">Seleccionar</option><?php foreach ($estados as $estado): ?><option value="<?= e($estado['id_estado_usuario']) ?>" <?= (string) ($usuario['id_estado_usuario'] ?? '') === (string) $estado['id_estado_usuario'] ? 'selected' : '' ?>><?= e($estado['codigo']) ?></option><?php endforeach; ?></select><?php if (isset($errores['id_estado_usuario'])): ?><small class="field-error"><?= e($errores['id_estado_usuario']) ?></small><?php endif; ?></label>
    <label class="field field-wide"><span><?= $edicion ? 'Nueva contraseña (opcional)' : 'Contraseña inicial' ?></span><input type="password" name="contrasena" minlength="8" <?= $edicion ? '' : 'required' ?>><?php if (isset($errores['contrasena'])): ?><small class="field-error"><?= e($errores['contrasena']) ?></small><?php endif; ?></label>
    <fieldset class="field-wide permission-fieldset"><legend>Permisos individuales</legend><div class="check-grid"><?php foreach ($permisos as $permiso): ?><label class="checkbox-field"><input type="checkbox" name="permisos[]" value="<?= e($permiso['id_permiso']) ?>" <?= in_array((int) $permiso['id_permiso'], $permisosSeleccionados, true) ? 'checked' : '' ?>><span><strong><?= e($permiso['nombre']) ?></strong><small><?= e($permiso['descripcion']) ?></small></span></label><?php endforeach; ?></div></fieldset>
    <fieldset class="field-wide permission-fieldset"><legend>Preguntas de seguridad <?= $edicion ? '(completar solo para reemplazarlas)' : '' ?></legend>
        <?php if (isset($errores['preguntas'])): ?><small class="field-error"><?= e($errores['preguntas']) ?></small><?php endif; ?>
        <?php if (isset($errores['respuestas'])): ?><small class="field-error"><?= e($errores['respuestas']) ?></small><?php endif; ?>
        <?php for ($i=0; $i<3; $i++): ?><div class="security-row"><select name="preguntas[]" <?= $edicion ? '' : 'required' ?>><option value="">Seleccionar pregunta</option><?php foreach ($preguntas as $pregunta): ?><option value="<?= e($pregunta['id_pregunta_seguridad']) ?>"><?= e($pregunta['texto']) ?></option><?php endforeach; ?></select><input type="text" name="respuestas[]" placeholder="Respuesta" autocomplete="off" <?= $edicion ? '' : 'required' ?>></div><?php endfor; ?>
    </fieldset>
    <div class="form-actions field-wide"><a class="button button-secondary" href="<?= e(url('/usuarios')) ?>">Cancelar</a><button class="button button-primary" type="submit">Guardar usuario</button></div>
</form>

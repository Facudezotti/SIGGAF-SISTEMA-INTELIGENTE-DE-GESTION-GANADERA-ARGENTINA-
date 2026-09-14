<?php

declare(strict_types=1);

use App\Core\Database;
use App\Core\Env;
use App\Services\RespuestaSeguridadService;

require dirname(__DIR__) . '/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Este archivo solo puede ejecutarse desde la terminal.');
}

$usuario = trim((string) Env::get('SEED_ADMIN_USERNAME', 'admin'));
$contrasena = (string) Env::get('SEED_ADMIN_PASSWORD', '');
$nombre = trim((string) Env::get('SEED_ADMIN_NAME', 'Administrador'));
$apellido = trim((string) Env::get('SEED_ADMIN_LASTNAME', 'SIGGAF'));
$cuil = trim((string) Env::get('SEED_ADMIN_CUIL', '20000000001'));
$establecimientoNombre = trim((string) Env::get('SEED_ESTABLISHMENT_NAME', 'La Celina'));
$localidad = trim((string) Env::get('SEED_ESTABLISHMENT_CITY', 'Formosa'));
$provincia = trim((string) Env::get('SEED_ESTABLISHMENT_PROVINCE', 'Formosa'));
$superficie = (float) Env::get('SEED_ESTABLISHMENT_AREA', '1.00');
$respuestasSeguridad = [
    (string) Env::get('SEED_SECURITY_ANSWER_1', ''),
    (string) Env::get('SEED_SECURITY_ANSWER_2', ''),
    (string) Env::get('SEED_SECURITY_ANSWER_3', ''),
];

if ($contrasena === '' || strlen($contrasena) < 8) {
    fwrite(STDERR, "Configura SEED_ADMIN_PASSWORD en .env con al menos 8 caracteres.\n");
    exit(1);
}
if (!preg_match('/^\d{11}$/', $cuil)) {
    fwrite(STDERR, "SEED_ADMIN_CUIL debe contener exactamente 11 numeros.\n");
    exit(1);
}
if ($establecimientoNombre === '' || $localidad === '' || $provincia === '' || $superficie <= 0) {
    fwrite(STDERR, "Revisa los datos SEED_ESTABLISHMENT_* configurados en .env.\n");
    exit(1);
}
if (count(array_filter(array_map('trim', $respuestasSeguridad))) !== 3) {
    fwrite(STDERR, "Configura las tres respuestas SEED_SECURITY_ANSWER_1, 2 y 3 en .env.\n");
    exit(1);
}

$pdo = Database::connection();

try {
    $pdo->beginTransaction();

    $permisos = [
        'POTRERO_CONSULTAR' => 'Consultar el listado y detalle de potreros',
        'POTRERO_CREAR' => 'Registrar nuevos potreros',
        'POTRERO_EDITAR' => 'Modificar los datos de potreros',
        'POTRERO_ELIMINAR' => 'Eliminar potreros sin relaciones',
        'POTRERO_RECURSOS' => 'Registrar y actualizar recursos del potrero',
        'USUARIO_GESTIONAR' => 'Administrar usuarios',
        'ROL_GESTIONAR' => 'Administrar roles',
        'PERMISO_GESTIONAR' => 'Administrar permisos',
        'ESTABLECIMIENTO_GESTIONAR' => 'Administrar establecimientos',
        'PREGUNTA_SEGURIDAD_GESTIONAR' => 'Administrar preguntas de seguridad',
        'CONFIGURACION_VISUAL_GESTIONAR' => 'Personalizar logo y fondo',
    ];

    $insertarPermiso = $pdo->prepare(<<<'SQL'
        INSERT INTO permiso (codigo, nombre, descripcion)
        VALUES (:codigo, :nombre, :descripcion)
        ON DUPLICATE KEY UPDATE
            nombre = VALUES(nombre),
            descripcion = VALUES(descripcion)
    SQL);
    foreach ($permisos as $codigo => $descripcion) {
        $insertarPermiso->execute([
            'codigo' => $codigo,
            'nombre' => $codigo,
            'descripcion' => $descripcion,
        ]);
    }

    $pdo->exec(<<<'SQL'
        INSERT IGNORE INTO permiso_rol (permiso_id, rol_id)
        SELECT p.id_permiso, r.id_rol
        FROM permiso p
        CROSS JOIN rol r
        WHERE r.codigo = 'DUENO'
    SQL);
    $pdo->exec(<<<'SQL'
        INSERT IGNORE INTO permiso_rol (permiso_id, rol_id)
        SELECT p.id_permiso, r.id_rol
        FROM permiso p
        CROSS JOIN rol r
        WHERE r.codigo = 'PEON' AND p.codigo = 'POTRERO_CONSULTAR'
    SQL);

    $buscarEstablecimiento = $pdo->prepare(
        'SELECT id_establecimiento FROM establecimiento WHERE nombre = :nombre LIMIT 1'
    );
    $buscarEstablecimiento->execute(['nombre' => $establecimientoNombre]);
    $idEstablecimiento = $buscarEstablecimiento->fetchColumn();

    if ($idEstablecimiento === false) {
        $crearEstablecimiento = $pdo->prepare(<<<'SQL'
            INSERT INTO establecimiento
                (nombre, descripcion, localidad, provincia, superficie)
            VALUES
                (:nombre, :descripcion, :localidad, :provincia, :superficie)
        SQL);
        $crearEstablecimiento->execute([
            'nombre' => $establecimientoNombre,
            'descripcion' => 'Establecimiento inicial de SIGGAF',
            'localidad' => $localidad,
            'provincia' => $provincia,
            'superficie' => $superficie,
        ]);
        $idEstablecimiento = (int) $pdo->lastInsertId();
    }

    $statement = $pdo->prepare(
        'SELECT id_usuario FROM usuario WHERE nombre_usuario = :usuario LIMIT 1'
    );
    $statement->execute(['usuario' => $usuario]);
    $idUsuario = $statement->fetchColumn();

    if ($idUsuario === false) {
        $crearUsuario = $pdo->prepare(<<<'SQL'
            INSERT INTO usuario (
                cuil, nombre, apellido, nombre_usuario, contrasena,
                establecimiento_id, estado_usuario_id, rol_id
            )
            SELECT
                :cuil, :nombre, :apellido, :usuario, :contrasena,
                :establecimiento, eu.id_estado_usuario, r.id_rol
            FROM estado_usuario eu
            CROSS JOIN rol r
            WHERE eu.codigo = 'ACTIVO' AND r.codigo = 'DUENO'
        SQL);
        $crearUsuario->execute([
            'cuil' => $cuil,
            'nombre' => $nombre,
            'apellido' => $apellido,
            'usuario' => $usuario,
            'contrasena' => password_hash($contrasena, PASSWORD_DEFAULT),
            'establecimiento' => (int) $idEstablecimiento,
        ]);
        $idUsuario = (int) $pdo->lastInsertId();
    }

    $preguntas = $pdo->query(
        'SELECT id_pregunta_seguridad
         FROM pregunta_seguridad
         WHERE activa = TRUE
         ORDER BY id_pregunta_seguridad
         LIMIT 3'
    )->fetchAll();

    if (count($preguntas) !== 3) {
        throw new RuntimeException('Deben existir al menos tres preguntas de seguridad activas.');
    }

    $pdo->prepare(
        'DELETE FROM respuesta_seguridad_usuario WHERE id_usuario = :id'
    )->execute(['id' => (int) $idUsuario]);

    $insertarRespuesta = $pdo->prepare(<<<'SQL'
        INSERT INTO respuesta_seguridad_usuario
            (id_usuario, id_pregunta_seguridad, hash_respuesta)
        VALUES (:usuario, :pregunta, :respuesta)
    SQL);
    foreach ($preguntas as $indice => $pregunta) {
        $insertarRespuesta->execute([
            'usuario' => (int) $idUsuario,
            'pregunta' => (int) $pregunta['id_pregunta_seguridad'],
            'respuesta' => password_hash(
                RespuestaSeguridadService::normalizar($respuestasSeguridad[$indice]),
                PASSWORD_DEFAULT
            ),
        ]);
    }

    $pdo->commit();
    fwrite(STDOUT, "Datos iniciales cargados correctamente. Usuario: {$usuario}\n");
} catch (Throwable $exception) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    fwrite(STDERR, "No se pudieron cargar los datos iniciales: {$exception->getMessage()}\n");
    exit(1);
}

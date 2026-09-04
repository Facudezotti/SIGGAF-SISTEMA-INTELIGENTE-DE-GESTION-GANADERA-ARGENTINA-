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
$respuestasSeguridad = [
    (string) Env::get('SEED_SECURITY_ANSWER_1', ''),
    (string) Env::get('SEED_SECURITY_ANSWER_2', ''),
    (string) Env::get('SEED_SECURITY_ANSWER_3', ''),
];

if ($contrasena === '' || strlen($contrasena) < 8) {
    fwrite(STDERR, "Configura SEED_ADMIN_PASSWORD en .env con al menos 8 caracteres.\n");
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
    ];

    $insertarPermiso = $pdo->prepare(
        'INSERT INTO permiso (nombre, descripcion) VALUES (:nombre, :descripcion) ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion)'
    );
    foreach ($permisos as $codigo => $descripcion) {
        $insertarPermiso->execute(['nombre' => $codigo, 'descripcion' => $descripcion]);
    }

    $pdo->exec(<<<'SQL'
        INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
        SELECT r.id_rol, p.id_permiso
        FROM rol r
        CROSS JOIN permiso p
        WHERE r.nombre = 'DUENO'
    SQL);
    $pdo->exec(<<<'SQL'
        INSERT IGNORE INTO rol_permiso (id_rol, id_permiso)
        SELECT r.id_rol, p.id_permiso
        FROM rol r
        CROSS JOIN permiso p
        WHERE r.nombre = 'PEON' AND p.nombre = 'POTRERO_CONSULTAR'
    SQL);

    $statement = $pdo->prepare('SELECT id_usuario FROM usuario WHERE nombre_usuario = :usuario');
    $statement->execute(['usuario' => $usuario]);

    $idUsuario = $statement->fetchColumn();
    if ($idUsuario === false) {
        $persona = $pdo->prepare('INSERT INTO persona (nombre, apellido) VALUES (:nombre, :apellido)');
        $persona->execute(['nombre' => $nombre, 'apellido' => $apellido]);
        $idPersona = (int) $pdo->lastInsertId();

        $crearUsuario = $pdo->prepare(<<<'SQL'
            INSERT INTO usuario (id_persona, id_rol, id_estado_usuario, nombre_usuario, hash_contrasena)
            SELECT :id_persona, r.id_rol, eu.id_estado_usuario, :usuario, :hash
            FROM rol r
            CROSS JOIN estado_usuario eu
            WHERE r.nombre = 'DUENO' AND eu.codigo = 'ACTIVO'
        SQL);
        $crearUsuario->execute([
            'id_persona' => $idPersona,
            'usuario' => $usuario,
            'hash' => password_hash($contrasena, PASSWORD_DEFAULT),
        ]);
        $idUsuario = (int) $pdo->lastInsertId();
    }

    $preguntas = $pdo->query('SELECT id_pregunta_seguridad FROM pregunta_seguridad WHERE activa = TRUE ORDER BY id_pregunta_seguridad LIMIT 3')->fetchAll();
    if (count($preguntas) !== 3) {
        throw new RuntimeException('Deben existir al menos tres preguntas de seguridad activas.');
    }
    $eliminarRespuestas = $pdo->prepare('DELETE FROM respuesta_seguridad_usuario WHERE id_usuario = :id');
    $eliminarRespuestas->execute(['id' => (int) $idUsuario]);
    $insertarRespuesta = $pdo->prepare('INSERT INTO respuesta_seguridad_usuario (id_usuario, id_pregunta_seguridad, hash_respuesta) VALUES (:usuario, :pregunta, :respuesta)');
    foreach ($preguntas as $indice => $pregunta) {
        $insertarRespuesta->execute([
            'usuario' => (int) $idUsuario,
            'pregunta' => (int) $pregunta['id_pregunta_seguridad'],
            'respuesta' => password_hash(RespuestaSeguridadService::normalizar($respuestasSeguridad[$indice]), PASSWORD_DEFAULT),
        ]);
    }

    $establecimiento = $pdo->prepare(
        'INSERT INTO establecimiento (nombre, descripcion) SELECT :nombre, :descripcion WHERE NOT EXISTS (SELECT 1 FROM establecimiento WHERE nombre = :nombre_busqueda)'
    );
    $establecimiento->execute([
        'nombre' => 'La Celina',
        'descripcion' => 'Establecimiento inicial para la primera entrega de SIGGAF',
        'nombre_busqueda' => 'La Celina',
    ]);

    $pdo->commit();
    fwrite(STDOUT, "Datos iniciales cargados correctamente. Usuario: {$usuario}\n");
} catch (Throwable $exception) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    fwrite(STDERR, "No se pudieron cargar los datos iniciales: {$exception->getMessage()}\n");
    exit(1);
}

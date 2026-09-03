<?php

declare(strict_types=1);

use App\Core\Database;
use App\Core\Env;

require dirname(__DIR__) . '/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('Este archivo solo puede ejecutarse desde la terminal.');
}

$usuario = trim((string) Env::get('SEED_ADMIN_USERNAME', 'admin'));
$contrasena = (string) Env::get('SEED_ADMIN_PASSWORD', '');
$nombre = trim((string) Env::get('SEED_ADMIN_NAME', 'Administrador'));
$apellido = trim((string) Env::get('SEED_ADMIN_LASTNAME', 'SIGGAF'));

if ($contrasena === '' || strlen($contrasena) < 8) {
    fwrite(STDERR, "Configura SEED_ADMIN_PASSWORD en .env con al menos 8 caracteres.\n");
    exit(1);
}

$pdo = Database::connection();

try {
    $pdo->beginTransaction();

    $permisos = [
        'POTRERO_CONSULTAR' => 'Consultar el listado y detalle de potreros',
        'POTRERO_CREAR' => 'Registrar nuevos potreros',
        'POTRERO_EDITAR' => 'Modificar los datos de potreros',
        'POTRERO_RECURSOS' => 'Registrar y actualizar recursos del potrero',
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
        WHERE r.nombre = 'DUENO' AND p.nombre LIKE 'POTRERO_%'
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

    if ($statement->fetchColumn() === false) {
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


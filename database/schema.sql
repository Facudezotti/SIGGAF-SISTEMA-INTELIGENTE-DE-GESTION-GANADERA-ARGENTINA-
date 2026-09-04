-- ============================================================================
-- SIGGAF - BASE DE DATOS DE LA PRIMERA ENTREGA
-- Modulos implementados: acceso y gestion de potreros
-- Motor: MySQL 8.0 o MariaDB | InnoDB | utf8mb4
-- ============================================================================

CREATE DATABASE IF NOT EXISTS gestion_ganadera
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE gestion_ganadera;

-- ============================================================================
-- 1. ACCESO, USUARIOS, ROLES Y PERMISOS
-- ============================================================================

CREATE TABLE estado_usuario (
    id_estado_usuario TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_usuario PRIMARY KEY (id_estado_usuario),
    CONSTRAINT uq_estado_usuario_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE persona (
    id_persona BIGINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cuil CHAR(11) NULL,
    direccion VARCHAR(255) NULL,
    correo VARCHAR(254) NULL,
    telefono VARCHAR(30) NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    CONSTRAINT uq_persona_cuil UNIQUE (cuil),
    CONSTRAINT uq_persona_correo UNIQUE (correo)
) ENGINE = InnoDB;

CREATE TABLE rol (
    id_rol SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT pk_rol PRIMARY KEY (id_rol),
    CONSTRAINT uq_rol_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE permiso (
    id_permiso SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT pk_permiso PRIMARY KEY (id_permiso),
    CONSTRAINT uq_permiso_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE pregunta_seguridad (
    id_pregunta_seguridad SMALLINT UNSIGNED AUTO_INCREMENT,
    texto VARCHAR(200) NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_pregunta_seguridad PRIMARY KEY (id_pregunta_seguridad),
    CONSTRAINT uq_pregunta_seguridad_texto UNIQUE (texto)
) ENGINE = InnoDB;

CREATE TABLE rol_permiso (
    id_rol SMALLINT UNSIGNED NOT NULL,
    id_permiso SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_rol_permiso PRIMARY KEY (id_rol, id_permiso),
    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (id_permiso) REFERENCES permiso (id_permiso)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE usuario (
    id_usuario BIGINT UNSIGNED AUTO_INCREMENT,
    id_persona BIGINT UNSIGNED NOT NULL,
    id_rol SMALLINT UNSIGNED NOT NULL,
    id_estado_usuario TINYINT UNSIGNED NOT NULL,
    nombre_usuario VARCHAR(80) NOT NULL,
    hash_contrasena VARCHAR(255) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_persona UNIQUE (id_persona),
    CONSTRAINT uq_usuario_nombre UNIQUE (nombre_usuario),
    CONSTRAINT fk_usuario_persona
        FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_usuario_estado
        FOREIGN KEY (id_estado_usuario) REFERENCES estado_usuario (id_estado_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE usuario_permiso (
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_permiso SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_usuario_permiso PRIMARY KEY (id_usuario, id_permiso),
    CONSTRAINT fk_usuario_permiso_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_usuario_permiso_permiso
        FOREIGN KEY (id_permiso) REFERENCES permiso (id_permiso)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE respuesta_seguridad_usuario (
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_pregunta_seguridad SMALLINT UNSIGNED NOT NULL,
    hash_respuesta VARCHAR(255) NOT NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_respuesta_seguridad_usuario
        PRIMARY KEY (id_usuario, id_pregunta_seguridad),
    CONSTRAINT fk_respuesta_seguridad_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_respuesta_seguridad_pregunta
        FOREIGN KEY (id_pregunta_seguridad)
        REFERENCES pregunta_seguridad (id_pregunta_seguridad)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ============================================================================
-- 2. CONFIGURACION VISUAL
-- ============================================================================

CREATE TABLE configuracion_visual (
    id_configuracion_visual TINYINT UNSIGNED NOT NULL,
    logo_ruta VARCHAR(500) NOT NULL,
    logo_nombre_original VARCHAR(255) NULL,
    logo_mime VARCHAR(100) NULL,
    fondo_ruta VARCHAR(500) NOT NULL,
    fondo_nombre_original VARCHAR(255) NULL,
    fondo_mime VARCHAR(100) NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    id_usuario_actualizacion BIGINT UNSIGNED NULL,
    CONSTRAINT pk_configuracion_visual PRIMARY KEY (id_configuracion_visual),
    CONSTRAINT ck_configuracion_visual_unica CHECK (id_configuracion_visual = 1),
    CONSTRAINT fk_configuracion_visual_usuario
        FOREIGN KEY (id_usuario_actualizacion) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB;

-- ============================================================================
-- 3. ESTABLECIMIENTO, POTREROS Y RECURSOS
-- ============================================================================

CREATE TABLE establecimiento (
    id_establecimiento BIGINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_establecimiento PRIMARY KEY (id_establecimiento),
    CONSTRAINT uq_establecimiento_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE potrero (
    id_potrero BIGINT UNSIGNED AUTO_INCREMENT,
    id_establecimiento BIGINT UNSIGNED NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    largo DECIMAL(12,2) NOT NULL,
    ancho DECIMAL(12,2) NOT NULL,
    superficie DECIMAL(14,2) NOT NULL,
    CONSTRAINT pk_potrero PRIMARY KEY (id_potrero),
    CONSTRAINT uq_potrero_establecimiento_nombre
        UNIQUE (id_establecimiento, nombre),
    CONSTRAINT ck_potrero_largo CHECK (largo > 0),
    CONSTRAINT ck_potrero_ancho CHECK (ancho > 0),
    CONSTRAINT ck_potrero_superficie CHECK (superficie > 0),
    CONSTRAINT fk_potrero_establecimiento
        FOREIGN KEY (id_establecimiento)
        REFERENCES establecimiento (id_establecimiento)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE recurso_potrero (
    id_recurso_potrero BIGINT UNSIGNED AUTO_INCREMENT,
    id_potrero BIGINT UNSIGNED NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    disponible BOOLEAN NOT NULL DEFAULT TRUE,
    observacion TEXT NULL,
    CONSTRAINT pk_recurso_potrero PRIMARY KEY (id_recurso_potrero),
    CONSTRAINT uq_recurso_potrero_nombre UNIQUE (id_potrero, nombre),
    CONSTRAINT fk_recurso_potrero_potrero
        FOREIGN KEY (id_potrero) REFERENCES potrero (id_potrero)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ============================================================================
-- 4. DATOS DE CATALOGO INICIALES
-- El usuario administrador y el establecimiento se crean con seed.php.
-- ============================================================================

INSERT INTO estado_usuario (codigo, descripcion) VALUES
    ('ACTIVO', 'Usuario habilitado para acceder al sistema'),
    ('INACTIVO', 'Usuario desactivado sin eliminar su historial');

INSERT INTO rol (nombre, descripcion) VALUES
    ('DUENO', 'Rol con permisos de administracion y control general'),
    ('PEON', 'Rol operativo sujeto a los permisos asignados');

INSERT INTO permiso (nombre, descripcion) VALUES
    ('POTRERO_CONSULTAR', 'Consultar el listado y detalle de potreros'),
    ('POTRERO_CREAR', 'Registrar nuevos potreros'),
    ('POTRERO_EDITAR', 'Modificar los datos de potreros'),
    ('POTRERO_ELIMINAR', 'Eliminar potreros que no posean relaciones'),
    ('POTRERO_RECURSOS', 'Administrar recursos de los potreros'),
    ('USUARIO_GESTIONAR', 'Crear, consultar, modificar y desactivar usuarios'),
    ('ROL_GESTIONAR', 'Administrar roles y sus permisos'),
    ('PERMISO_GESTIONAR', 'Administrar el catalogo de permisos'),
    ('ESTABLECIMIENTO_GESTIONAR', 'Administrar establecimientos'),
    ('PREGUNTA_SEGURIDAD_GESTIONAR', 'Administrar preguntas de seguridad');

INSERT INTO pregunta_seguridad (texto, activa) VALUES
    ('¿Cuál fue el nombre de tu primera mascota?', TRUE),
    ('¿En qué ciudad naciste?', TRUE),
    ('¿Cuál era tu apodo durante la infancia?', TRUE),
    ('¿Cuál es el segundo nombre de tu madre?', TRUE),
    ('¿Cuál fue el nombre de tu primera escuela?', TRUE);

INSERT INTO configuracion_visual (
    id_configuracion_visual,
    logo_ruta,
    fondo_ruta
) VALUES (
    1,
    '/assets/img/logo-toro.png',
    '/assets/img/fondo-ganaderia.jpg'
);

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM rol r
CROSS JOIN permiso p
WHERE r.nombre = 'DUENO';

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM rol r
CROSS JOIN permiso p
WHERE r.nombre = 'PEON'
  AND p.nombre = 'POTRERO_CONSULTAR';

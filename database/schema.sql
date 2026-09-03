-- ============================================================================
-- SIGGAF - BASE DE DATOS DE LA PRIMERA ENTREGA
-- Modulos implementados: acceso y gestion de potreros
-- Motor: MySQL 8.0 | InnoDB | utf8mb4
-- ============================================================================

CREATE DATABASE IF NOT EXISTS gestion_ganadera
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

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

CREATE TABLE rol_permiso (
    id_rol SMALLINT UNSIGNED NOT NULL,
    id_permiso SMALLINT UNSIGNED NOT NULL,
    CONSTRAINT pk_rol_permiso PRIMARY KEY (id_rol, id_permiso),
    CONSTRAINT fk_rol_permiso_rol
        FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_rol_permiso_permiso
        FOREIGN KEY (id_permiso) REFERENCES permiso (id_permiso)
        ON UPDATE CASCADE ON DELETE CASCADE
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

-- ============================================================================
-- 2. ESTABLECIMIENTO, POTREROS Y RECURSOS
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
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- ============================================================================
-- 3. DATOS DE CATALOGO INICIALES
-- El usuario administrador y el establecimiento se crean con seed.php.
-- ============================================================================

INSERT INTO estado_usuario (codigo, descripcion) VALUES
    ('ACTIVO', 'Usuario habilitado para acceder al sistema'),
    ('INACTIVO', 'Usuario desactivado sin eliminar su historial');

INSERT INTO rol (nombre, descripcion) VALUES
    ('DUENO', 'Rol con permisos de administracion y control general'),
    ('PEON', 'Rol operativo sujeto a los permisos asignados');


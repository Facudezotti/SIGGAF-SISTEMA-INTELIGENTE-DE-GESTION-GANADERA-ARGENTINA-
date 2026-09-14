-- ============================================================
-- SIGGAF - ESQUEMA UNIFICADO
-- Motor: MySQL 8+ / MariaDB 10.4+ (compatible con phpMyAdmin)
-- Charset: utf8mb4
--
-- IMPORTANTE:
-- Este script elimina y vuelve a crear la base gestion_ganadera.
-- Realizar una copia de seguridad antes de ejecutarlo.
--
-- El esquema conserva la interfaz utilizada por la aplicacion PHP
-- actual y agrega el modelo ganadero de animales, lotes y movimientos.
-- ============================================================

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;

SET UNIQUE_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS gestion_ganadera;

CREATE DATABASE gestion_ganadera
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE gestion_ganadera;

-- ============================================================
-- 1. SEGURIDAD Y PERSONAS
-- ============================================================

CREATE TABLE estado_usuario (
  id_estado_usuario TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(50) NULL,
  descripcion VARCHAR(255) NULL,

  PRIMARY KEY (id_estado_usuario),
  UNIQUE KEY uk_estado_usuario_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE persona (
  id_persona INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  cuil CHAR(11) NULL,
  direccion VARCHAR(255) NULL
    COMMENT 'Direccion principal mantenida por compatibilidad con la aplicacion',
  correo VARCHAR(150) NULL,
  telefono VARCHAR(30) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_persona),
  UNIQUE KEY uk_persona_cuil (cuil),
  UNIQUE KEY uk_persona_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE rol (
  id_rol SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(30) NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,

  PRIMARY KEY (id_rol),
  UNIQUE KEY uk_rol_codigo (codigo),
  UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE permiso (
  id_permiso SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(60) NULL,
  nombre VARCHAR(100) NOT NULL
    COMMENT 'La aplicacion utiliza este campo como codigo del permiso',
  descripcion VARCHAR(255) NULL,

  PRIMARY KEY (id_permiso),
  UNIQUE KEY uk_permiso_codigo (codigo),
  UNIQUE KEY uk_permiso_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE pregunta_seguridad (
  id_pregunta_seguridad SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto VARCHAR(255) NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT TRUE,

  PRIMARY KEY (id_pregunta_seguridad),
  UNIQUE KEY uk_pregunta_seguridad_texto (texto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE rol_permiso (
  id_rol SMALLINT UNSIGNED NOT NULL,
  id_permiso SMALLINT UNSIGNED NOT NULL,

  PRIMARY KEY (id_rol, id_permiso),
  KEY idx_rol_permiso_permiso (id_permiso),

  CONSTRAINT fk_rol_permiso_rol
    FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_rol_permiso_permiso
    FOREIGN KEY (id_permiso) REFERENCES permiso (id_permiso)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. ESTABLECIMIENTOS Y USUARIOS
-- ============================================================

CREATE TABLE establecimiento (
  id_establecimiento INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,

  localidad VARCHAR(100) NULL,
  provincia VARCHAR(100) NULL,
  superficie DECIMAL(12,2) NULL
    COMMENT 'Superficie total expresada en hectareas',
  observaciones TEXT NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_establecimiento),
  UNIQUE KEY uk_establecimiento_nombre (nombre),
  KEY idx_establecimiento_eliminado_por (eliminado_por),

  CONSTRAINT chk_establecimiento_superficie
    CHECK (superficie IS NULL OR superficie > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE usuario (
  id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_persona INT UNSIGNED NOT NULL,
  id_rol SMALLINT UNSIGNED NOT NULL,
  id_estado_usuario TINYINT UNSIGNED NOT NULL,
  id_establecimiento INT UNSIGNED NULL,

  nombre_usuario VARCHAR(80) NOT NULL,
  hash_contrasena VARCHAR(255) NOT NULL
    COMMENT 'Hash generado con password_hash; nunca guardar texto plano',

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_usuario),
  UNIQUE KEY uk_usuario_nombre_usuario (nombre_usuario),

  KEY idx_usuario_persona (id_persona),
  KEY idx_usuario_rol (id_rol),
  KEY idx_usuario_estado (id_estado_usuario),
  KEY idx_usuario_establecimiento (id_establecimiento),
  KEY idx_usuario_eliminado_por (eliminado_por),

  CONSTRAINT fk_usuario_persona
    FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_usuario_rol
    FOREIGN KEY (id_rol) REFERENCES rol (id_rol)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_usuario_estado
    FOREIGN KEY (id_estado_usuario) REFERENCES estado_usuario (id_estado_usuario)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_usuario_establecimiento
    FOREIGN KEY (id_establecimiento) REFERENCES establecimiento (id_establecimiento)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_usuario_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


ALTER TABLE establecimiento
  ADD CONSTRAINT fk_establecimiento_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE;


CREATE TABLE usuario_permiso (
  id_usuario INT UNSIGNED NOT NULL,
  id_permiso SMALLINT UNSIGNED NOT NULL,

  PRIMARY KEY (id_usuario, id_permiso),
  KEY idx_usuario_permiso_permiso (id_permiso),

  CONSTRAINT fk_usuario_permiso_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_usuario_permiso_permiso
    FOREIGN KEY (id_permiso) REFERENCES permiso (id_permiso)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE respuesta_seguridad_usuario (
  id_usuario INT UNSIGNED NOT NULL,
  id_pregunta_seguridad SMALLINT UNSIGNED NOT NULL,
  hash_respuesta VARCHAR(255) NOT NULL,

  PRIMARY KEY (id_usuario, id_pregunta_seguridad),
  KEY idx_respuesta_pregunta (id_pregunta_seguridad),

  CONSTRAINT fk_respuesta_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_respuesta_pregunta
    FOREIGN KEY (id_pregunta_seguridad)
    REFERENCES pregunta_seguridad (id_pregunta_seguridad)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE direccion (
  id_direccion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_persona INT UNSIGNED NOT NULL,

  barrio VARCHAR(100) NULL,
  calle VARCHAR(120) NOT NULL,
  numero VARCHAR(15) NOT NULL,
  provincia VARCHAR(100) NOT NULL,
  localidad VARCHAR(100) NOT NULL,
  principal BOOLEAN NOT NULL DEFAULT FALSE,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_direccion),
  KEY idx_direccion_persona (id_persona),
  KEY idx_direccion_eliminado_por (eliminado_por),

  CONSTRAINT fk_direccion_persona
    FOREIGN KEY (id_persona) REFERENCES persona (id_persona)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_direccion_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


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
  id_usuario_actualizacion INT UNSIGNED NULL,

  PRIMARY KEY (id_configuracion_visual),
  KEY idx_configuracion_usuario (id_usuario_actualizacion),

  CONSTRAINT fk_configuracion_usuario
    FOREIGN KEY (id_usuario_actualizacion) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_configuracion_unica
    CHECK (id_configuracion_visual = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 3. POTREROS Y RECURSOS
-- ============================================================

CREATE TABLE potrero (
  id_potrero INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_establecimiento INT UNSIGNED NOT NULL,

  codigo VARCHAR(30) NULL,
  nombre VARCHAR(100) NOT NULL,
  largo DECIMAL(10,2) NOT NULL COMMENT 'Longitud expresada en metros',
  ancho DECIMAL(10,2) NOT NULL COMMENT 'Ancho expresado en metros',
  superficie DECIMAL(12,2) NOT NULL
    COMMENT 'Superficie calculada; la aplicacion actual la expresa en metros cuadrados',
  descripcion VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_potrero),
  UNIQUE KEY uk_potrero_establecimiento_nombre
    (id_establecimiento, nombre),
  UNIQUE KEY uk_potrero_establecimiento_codigo
    (id_establecimiento, codigo),

  KEY idx_potrero_establecimiento (id_establecimiento),
  KEY idx_potrero_eliminado_por (eliminado_por),

  CONSTRAINT fk_potrero_establecimiento
    FOREIGN KEY (id_establecimiento)
    REFERENCES establecimiento (id_establecimiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_potrero_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_potrero_largo CHECK (largo > 0),
  CONSTRAINT chk_potrero_ancho CHECK (ancho > 0),
  CONSTRAINT chk_potrero_superficie CHECK (superficie > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE tipo_recurso (
  id_tipo_recurso SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_tipo_recurso),
  UNIQUE KEY uk_tipo_recurso_codigo (codigo),
  UNIQUE KEY uk_tipo_recurso_nombre (nombre),
  KEY idx_tipo_recurso_eliminado_por (eliminado_por),

  CONSTRAINT fk_tipo_recurso_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE recurso_potrero (
  id_recurso_potrero INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_potrero INT UNSIGNED NOT NULL,
  id_tipo_recurso SMALLINT UNSIGNED NULL,

  nombre VARCHAR(100) NOT NULL
    COMMENT 'Nombre mantenido para compatibilidad con el modulo actual',
  disponible BOOLEAN NOT NULL DEFAULT TRUE,
  observacion VARCHAR(255) NULL,
  descripcion VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_recurso_potrero),
  KEY idx_recurso_potrero (id_potrero),
  KEY idx_recurso_tipo (id_tipo_recurso),
  KEY idx_recurso_eliminado_por (eliminado_por),

  CONSTRAINT fk_recurso_potrero
    FOREIGN KEY (id_potrero) REFERENCES potrero (id_potrero)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_recurso_tipo
    FOREIGN KEY (id_tipo_recurso) REFERENCES tipo_recurso (id_tipo_recurso)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_recurso_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4. ANIMALES, IDENTIFICACION Y PESAJE
-- ============================================================

CREATE TABLE categoria_animal (
  id_categoria_animal SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  descripcion VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,

  PRIMARY KEY (id_categoria_animal),
  UNIQUE KEY uk_categoria_animal_codigo (codigo),
  UNIQUE KEY uk_categoria_animal_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE estado_animal (
  id_estado_animal SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) NULL,

  PRIMARY KEY (id_estado_animal),
  UNIQUE KEY uk_estado_animal_codigo (codigo),
  UNIQUE KEY uk_estado_animal_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE animal (
  id_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  id_establecimiento INT UNSIGNED NOT NULL,
  id_categoria_animal SMALLINT UNSIGNED NOT NULL,
  id_estado_animal SMALLINT UNSIGNED NOT NULL,
  id_potrero_actual INT UNSIGNED NULL,

  sexo ENUM('M', 'H') NOT NULL COMMENT 'M = macho, H = hembra',
  fecha_nacimiento DATE NULL,
  nombre VARCHAR(100) NULL,
  observaciones TEXT NULL,

  id_madre BIGINT UNSIGNED NULL,
  id_padre BIGINT UNSIGNED NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  actualizado_por INT UNSIGNED NULL,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_animal),

  KEY idx_animal_establecimiento (id_establecimiento),
  KEY idx_animal_categoria (id_categoria_animal),
  KEY idx_animal_estado (id_estado_animal),
  KEY idx_animal_potrero_actual (id_potrero_actual),
  KEY idx_animal_madre (id_madre),
  KEY idx_animal_padre (id_padre),
  KEY idx_animal_creado_por (creado_por),
  KEY idx_animal_actualizado_por (actualizado_por),
  KEY idx_animal_eliminado_por (eliminado_por),

  CONSTRAINT fk_animal_establecimiento
    FOREIGN KEY (id_establecimiento)
    REFERENCES establecimiento (id_establecimiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_animal_categoria
    FOREIGN KEY (id_categoria_animal)
    REFERENCES categoria_animal (id_categoria_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_animal_estado
    FOREIGN KEY (id_estado_animal)
    REFERENCES estado_animal (id_estado_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_animal_potrero_actual
    FOREIGN KEY (id_potrero_actual) REFERENCES potrero (id_potrero)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_animal_madre
    FOREIGN KEY (id_madre) REFERENCES animal (id_animal)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_animal_padre
    FOREIGN KEY (id_padre) REFERENCES animal (id_animal)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_animal_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_animal_actualizado_por
    FOREIGN KEY (actualizado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_animal_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_animal_progenitores
    CHECK (
      (id_madre IS NULL OR id_madre <> id_animal)
      AND (id_padre IS NULL OR id_padre <> id_animal)
      AND (id_madre IS NULL OR id_padre IS NULL OR id_madre <> id_padre)
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE identificacion_animal (
  id_identificacion_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_animal BIGINT UNSIGNED NOT NULL,

  codigo_caravana VARCHAR(100) NOT NULL,
  fecha_desde DATE NOT NULL,
  fecha_hasta DATE NULL,
  motivo_cambio VARCHAR(255) NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,

  PRIMARY KEY (id_identificacion_animal),
  UNIQUE KEY uk_identificacion_codigo_caravana (codigo_caravana),
  KEY idx_identificacion_animal (id_animal),
  KEY idx_identificacion_vigencia (fecha_desde, fecha_hasta),
  KEY idx_identificacion_creado_por (creado_por),

  CONSTRAINT fk_identificacion_animal
    FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_identificacion_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_identificacion_fechas
    CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE pesaje (
  id_pesaje BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_animal BIGINT UNSIGNED NOT NULL,

  fecha_pesaje DATETIME NOT NULL,
  peso DECIMAL(8,2) NOT NULL COMMENT 'Peso expresado en kilogramos',
  observaciones TEXT NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_pesaje),
  KEY idx_pesaje_animal (id_animal),
  KEY idx_pesaje_fecha (fecha_pesaje),
  KEY idx_pesaje_creado_por (creado_por),
  KEY idx_pesaje_eliminado_por (eliminado_por),

  CONSTRAINT fk_pesaje_animal
    FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_pesaje_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_pesaje_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_pesaje_peso CHECK (peso > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 5. LOTES E HISTORIAL DE ASIGNACION
-- ============================================================

CREATE TABLE lote (
  id_lote INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_establecimiento INT UNSIGNED NOT NULL,

  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,
  fecha_creacion DATE NOT NULL,
  fecha_cierre DATE NULL,
  estado ENUM('ABIERTO', 'CERRADO') NOT NULL DEFAULT 'ABIERTO',

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_lote),
  UNIQUE KEY uk_lote_establecimiento_nombre (id_establecimiento, nombre),
  KEY idx_lote_establecimiento (id_establecimiento),
  KEY idx_lote_creado_por (creado_por),
  KEY idx_lote_eliminado_por (eliminado_por),

  CONSTRAINT fk_lote_establecimiento
    FOREIGN KEY (id_establecimiento)
    REFERENCES establecimiento (id_establecimiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_lote_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_lote_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_lote_fechas
    CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE lote_animal (
  id_lote_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_animal BIGINT UNSIGNED NOT NULL,
  id_lote INT UNSIGNED NOT NULL,

  fecha_desde DATETIME NOT NULL,
  fecha_hasta DATETIME NULL,

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,

  eliminado_en DATETIME NULL,
  eliminado_por INT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,

  PRIMARY KEY (id_lote_animal),
  KEY idx_lote_animal_animal (id_animal),
  KEY idx_lote_animal_lote (id_lote),
  KEY idx_lote_animal_fechas (fecha_desde, fecha_hasta),
  KEY idx_lote_animal_creado_por (creado_por),
  KEY idx_lote_animal_eliminado_por (eliminado_por),

  CONSTRAINT fk_lote_animal_animal
    FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_lote_animal_lote
    FOREIGN KEY (id_lote) REFERENCES lote (id_lote)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_lote_animal_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_lote_animal_eliminado_por
    FOREIGN KEY (eliminado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_lote_animal_fechas
    CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 6. MOVIMIENTOS
-- Un movimiento puede tener potrero de origen, destino o ambos.
-- La relacion movimiento_animal admite varios animales.
-- ============================================================

CREATE TABLE movimiento (
  id_movimiento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_establecimiento INT UNSIGNED NOT NULL,
  id_potrero_origen INT UNSIGNED NULL,
  id_potrero_destino INT UNSIGNED NULL,

  fecha_movimiento DATETIME NOT NULL,
  tipo_movimiento VARCHAR(60) NOT NULL,
  observaciones TEXT NULL,

  estado_movimiento ENUM('PENDIENTE', 'CONFIRMADO', 'ANULADO')
    NOT NULL DEFAULT 'PENDIENTE',

  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por INT UNSIGNED NULL,

  anulado_en DATETIME NULL,
  anulado_por INT UNSIGNED NULL,
  motivo_anulacion VARCHAR(255) NULL,

  PRIMARY KEY (id_movimiento),
  KEY idx_movimiento_establecimiento (id_establecimiento),
  KEY idx_movimiento_origen (id_potrero_origen),
  KEY idx_movimiento_destino (id_potrero_destino),
  KEY idx_movimiento_fecha (fecha_movimiento),
  KEY idx_movimiento_creado_por (creado_por),
  KEY idx_movimiento_anulado_por (anulado_por),

  CONSTRAINT fk_movimiento_establecimiento
    FOREIGN KEY (id_establecimiento)
    REFERENCES establecimiento (id_establecimiento)
    ON DELETE RESTRICT ON UPDATE CASCADE,

  CONSTRAINT fk_movimiento_origen
    FOREIGN KEY (id_potrero_origen) REFERENCES potrero (id_potrero)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_movimiento_destino
    FOREIGN KEY (id_potrero_destino) REFERENCES potrero (id_potrero)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_movimiento_creado_por
    FOREIGN KEY (creado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT fk_movimiento_anulado_por
    FOREIGN KEY (anulado_por) REFERENCES usuario (id_usuario)
    ON DELETE SET NULL ON UPDATE CASCADE,

  CONSTRAINT chk_movimiento_potreros
    CHECK (
      id_potrero_origen IS NULL
      OR id_potrero_destino IS NULL
      OR id_potrero_origen <> id_potrero_destino
    )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


CREATE TABLE movimiento_animal (
  id_movimiento_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_movimiento BIGINT UNSIGNED NOT NULL,
  id_animal BIGINT UNSIGNED NOT NULL,

  PRIMARY KEY (id_movimiento_animal),
  UNIQUE KEY uk_movimiento_animal (id_movimiento, id_animal),
  KEY idx_movimiento_animal_animal (id_animal),

  CONSTRAINT fk_movimiento_animal_movimiento
    FOREIGN KEY (id_movimiento) REFERENCES movimiento (id_movimiento)
    ON DELETE CASCADE ON UPDATE CASCADE,

  CONSTRAINT fk_movimiento_animal_animal
    FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 7. DATOS INICIALES
-- seed.php completa permisos, usuario administrador y preguntas.
-- Estos INSERT permiten que la aplicacion tenga catalogos base.
-- ============================================================

INSERT INTO estado_usuario (codigo, nombre, descripcion) VALUES
  ('ACTIVO', 'Activo', 'Usuario habilitado para ingresar al sistema'),
  ('INACTIVO', 'Inactivo', 'Usuario sin acceso al sistema');

INSERT INTO rol (codigo, nombre, descripcion) VALUES
  ('DUENO', 'DUENO', 'Acceso administrativo y funcional completo'),
  ('PEON', 'PEON', 'Acceso operativo restringido');

INSERT INTO permiso (codigo, nombre, descripcion) VALUES
  ('USUARIO_GESTIONAR', 'USUARIO_GESTIONAR', 'Alta, modificacion y desactivacion de usuarios'),
  ('ROL_GESTIONAR', 'ROL_GESTIONAR', 'Gestion de roles'),
  ('PERMISO_GESTIONAR', 'PERMISO_GESTIONAR', 'Gestion del catalogo de permisos'),
  ('ESTABLECIMIENTO_GESTIONAR', 'ESTABLECIMIENTO_GESTIONAR', 'Gestion de establecimientos'),
  ('PREGUNTA_SEGURIDAD_GESTIONAR', 'PREGUNTA_SEGURIDAD_GESTIONAR', 'Gestion de preguntas de seguridad'),
  ('POTRERO_CREAR', 'POTRERO_CREAR', 'Registro de potreros'),
  ('POTRERO_EDITAR', 'POTRERO_EDITAR', 'Modificacion de potreros'),
  ('POTRERO_ELIMINAR', 'POTRERO_ELIMINAR', 'Eliminacion de potreros'),
  ('POTRERO_CONSULTAR', 'POTRERO_CONSULTAR', 'Consulta de potreros'),
  ('CONFIGURACION_VISUAL_GESTIONAR', 'CONFIGURACION_VISUAL_GESTIONAR', 'Personalizacion de logo y fondo');

INSERT INTO pregunta_seguridad (texto, activa) VALUES
  ('¿Cual es el nombre de tu primera mascota?', TRUE),
  ('¿En que ciudad naciste?', TRUE),
  ('¿Cual era el apellido de tu maestro o maestra de primaria?', TRUE),
  ('¿Cual es el segundo nombre de tu madre?', TRUE),
  ('¿Cual fue tu primer trabajo?', TRUE);

INSERT INTO configuracion_visual (
  id_configuracion_visual,
  logo_ruta,
  fondo_ruta
) VALUES (
  1,
  '/assets/img/logo-toro.png',
  '/assets/img/fondo-ganaderia.jpg'
);

INSERT INTO categoria_animal (codigo, nombre, descripcion) VALUES
  ('TERNERO', 'Ternero', 'Bovino macho joven'),
  ('TERNERA', 'Ternera', 'Bovino hembra joven'),
  ('VAQUILLONA', 'Vaquillona', 'Hembra joven que aun no ha parido'),
  ('VACA', 'Vaca', 'Hembra bovina adulta'),
  ('NOVILLO', 'Novillo', 'Macho bovino castrado'),
  ('TORO', 'Toro', 'Macho bovino reproductor');

INSERT INTO estado_animal (codigo, nombre, descripcion) VALUES
  ('ACTIVO', 'Activo', 'Animal presente y activo en el establecimiento'),
  ('VENDIDO', 'Vendido', 'Animal vendido'),
  ('BAJA', 'Baja', 'Animal dado de baja'),
  ('TRASLADADO', 'Trasladado', 'Animal trasladado fuera del establecimiento');

INSERT INTO tipo_recurso (codigo, nombre, descripcion) VALUES
  ('BEBEDERO', 'Bebedero', 'Recurso para suministro de agua'),
  ('COMEDERO', 'Comedero', 'Recurso para suministro de alimento'),
  ('MOLINO', 'Molino', 'Equipo de extraccion o bombeo de agua'),
  ('MANGA', 'Manga', 'Instalacion para manejo del ganado');

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM rol r
CROSS JOIN permiso p
WHERE r.nombre = 'DUENO';

INSERT INTO rol_permiso (id_rol, id_permiso)
SELECT r.id_rol, p.id_permiso
FROM rol r
INNER JOIN permiso p ON p.nombre = 'POTRERO_CONSULTAR'
WHERE r.nombre = 'PEON';


SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;

-- ============================================================
-- FIN DEL ESQUEMA UNIFICADO
-- Despues de importarlo, ejecutar: php database/seed.php
-- ============================================================

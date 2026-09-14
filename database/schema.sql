-- ============================================================
-- SIGGAF - BASE GANADERIA AMPLIADA
-- MySQL 8+ / MariaDB 10.4+ - utf8mb4
--
-- La estructura principal corresponde a la base ganaderia.
-- Se anexan funciones implementadas previamente por SIGGAF:
-- preguntas de seguridad, permisos individuales, personalizacion
-- visual y dimensiones/disponibilidad de recursos.
--
-- ATENCION: elimina y reconstruye la base ganaderia.
-- ============================================================

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = 0;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS ganaderia;
CREATE DATABASE ganaderia CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ganaderia;

CREATE TABLE establecimiento (
  id_establecimiento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,
  localidad VARCHAR(100) NOT NULL,
  provincia VARCHAR(100) NOT NULL,
  superficie DECIMAL(12,2) NOT NULL COMMENT 'Superficie expresada en hectareas',
  observaciones TEXT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_establecimiento),
  UNIQUE KEY uk_establecimiento_nombre (nombre),
  CONSTRAINT chk_establecimiento_superficie CHECK (superficie > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estado_usuario (
  id_estado_usuario BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) NULL,
  PRIMARY KEY (id_estado_usuario),
  UNIQUE KEY uk_estado_usuario_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE rol (
  id_rol BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(30) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  PRIMARY KEY (id_rol),
  UNIQUE KEY uk_rol_codigo (codigo),
  UNIQUE KEY uk_rol_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permiso (
  id_permiso BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(60) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,
  PRIMARY KEY (id_permiso),
  UNIQUE KEY uk_permiso_codigo (codigo),
  UNIQUE KEY uk_permiso_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE permiso_rol (
  permiso_id BIGINT UNSIGNED NOT NULL,
  rol_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (permiso_id, rol_id),
  KEY idx_permiso_rol_rol (rol_id),
  CONSTRAINT fk_permiso_rol_permiso FOREIGN KEY (permiso_id)
    REFERENCES permiso (id_permiso) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_permiso_rol_rol FOREIGN KEY (rol_id)
    REFERENCES rol (id_rol) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuario (
  id_usuario BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cuil CHAR(11) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  telefono VARCHAR(30) NULL,
  correo VARCHAR(150) NULL,
  nombre_usuario VARCHAR(80) NOT NULL,
  contrasena VARCHAR(255) NOT NULL COMMENT 'Guardar hash, nunca texto plano',
  establecimiento_id BIGINT UNSIGNED NOT NULL,
  estado_usuario_id BIGINT UNSIGNED NOT NULL,
  rol_id BIGINT UNSIGNED NOT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uk_usuario_cuil (cuil),
  UNIQUE KEY uk_usuario_correo (correo),
  UNIQUE KEY uk_usuario_nombre_usuario (nombre_usuario),
  KEY idx_usuario_establecimiento (establecimiento_id),
  KEY idx_usuario_estado (estado_usuario_id),
  KEY idx_usuario_rol (rol_id),
  KEY idx_usuario_eliminado_por (eliminado_por),
  CONSTRAINT fk_usuario_establecimiento FOREIGN KEY (establecimiento_id)
    REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_estado FOREIGN KEY (estado_usuario_id)
    REFERENCES estado_usuario (id_estado_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_rol FOREIGN KEY (rol_id)
    REFERENCES rol (id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE establecimiento
  ADD KEY idx_establecimiento_eliminado_por (eliminado_por),
  ADD CONSTRAINT fk_establecimiento_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE direccion (
  id_direccion BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usuario_id BIGINT UNSIGNED NOT NULL,
  barrio VARCHAR(100) NULL,
  calle VARCHAR(120) NOT NULL,
  numero VARCHAR(15) NOT NULL,
  provincia VARCHAR(100) NOT NULL,
  localidad VARCHAR(100) NOT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_direccion),
  KEY idx_direccion_usuario (usuario_id),
  KEY idx_direccion_eliminado_por (eliminado_por),
  CONSTRAINT fk_direccion_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_direccion_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pregunta_seguridad (
  id_pregunta_seguridad BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  texto VARCHAR(255) NOT NULL,
  activa BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id_pregunta_seguridad),
  UNIQUE KEY uk_pregunta_seguridad_texto (texto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuario_permiso (
  id_usuario BIGINT UNSIGNED NOT NULL,
  id_permiso BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_usuario, id_permiso),
  KEY idx_usuario_permiso_permiso (id_permiso),
  CONSTRAINT fk_usuario_permiso_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_usuario_permiso_permiso FOREIGN KEY (id_permiso)
    REFERENCES permiso (id_permiso) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE respuesta_seguridad_usuario (
  id_usuario BIGINT UNSIGNED NOT NULL,
  id_pregunta_seguridad BIGINT UNSIGNED NOT NULL,
  hash_respuesta VARCHAR(255) NOT NULL,
  PRIMARY KEY (id_usuario, id_pregunta_seguridad),
  KEY idx_respuesta_pregunta (id_pregunta_seguridad),
  CONSTRAINT fk_respuesta_usuario FOREIGN KEY (id_usuario)
    REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_respuesta_pregunta FOREIGN KEY (id_pregunta_seguridad)
    REFERENCES pregunta_seguridad (id_pregunta_seguridad) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE configuracion_visual (
  id_configuracion_visual TINYINT UNSIGNED NOT NULL,
  logo_ruta VARCHAR(500) NOT NULL,
  logo_nombre_original VARCHAR(255) NULL,
  logo_mime VARCHAR(100) NULL,
  fondo_ruta VARCHAR(500) NOT NULL,
  fondo_nombre_original VARCHAR(255) NULL,
  fondo_mime VARCHAR(100) NULL,
  fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  id_usuario_actualizacion BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_configuracion_visual),
  KEY idx_configuracion_usuario (id_usuario_actualizacion),
  CONSTRAINT fk_configuracion_usuario FOREIGN KEY (id_usuario_actualizacion)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_configuracion_unica CHECK (id_configuracion_visual = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE potrero (
  id_potrero BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  establecimiento_id BIGINT UNSIGNED NOT NULL,
  codigo VARCHAR(30) NULL,
  nombre VARCHAR(100) NOT NULL,
  superficie DECIMAL(12,2) NULL COMMENT 'Superficie expresada en metros cuadrados',
  descripcion VARCHAR(255) NULL,
  largo DECIMAL(10,2) NULL COMMENT 'Dimension anexada, expresada en metros',
  ancho DECIMAL(10,2) NULL COMMENT 'Dimension anexada, expresada en metros',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_potrero),
  UNIQUE KEY uk_potrero_establecimiento_codigo (establecimiento_id, codigo),
  UNIQUE KEY uk_potrero_establecimiento_nombre (establecimiento_id, nombre),
  KEY idx_potrero_establecimiento (establecimiento_id),
  KEY idx_potrero_eliminado_por (eliminado_por),
  CONSTRAINT fk_potrero_establecimiento FOREIGN KEY (establecimiento_id)
    REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_potrero_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_potrero_superficie CHECK (superficie IS NULL OR superficie > 0),
  CONSTRAINT chk_potrero_largo CHECK (largo IS NULL OR largo > 0),
  CONSTRAINT chk_potrero_ancho CHECK (ancho IS NULL OR ancho > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_recurso (
  id_tipo_recurso BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_tipo_recurso),
  UNIQUE KEY uk_tipo_recurso_codigo (codigo),
  UNIQUE KEY uk_tipo_recurso_nombre (nombre),
  KEY idx_tipo_recurso_eliminado_por (eliminado_por),
  CONSTRAINT fk_tipo_recurso_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE recurso_potrero (
  id_recurso_potrero BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  potrero_id BIGINT UNSIGNED NOT NULL,
  tipo_recurso_id BIGINT UNSIGNED NOT NULL,
  descripcion VARCHAR(255) NULL,
  disponible BOOLEAN NOT NULL DEFAULT TRUE,
  observacion VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_recurso_potrero),
  UNIQUE KEY uk_recurso_potrero_tipo (potrero_id, tipo_recurso_id),
  KEY idx_recurso_potrero_tipo (tipo_recurso_id),
  KEY idx_recurso_potrero_eliminado_por (eliminado_por),
  CONSTRAINT fk_recurso_potrero_potrero FOREIGN KEY (potrero_id)
    REFERENCES potrero (id_potrero) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_recurso_potrero_tipo FOREIGN KEY (tipo_recurso_id)
    REFERENCES tipo_recurso (id_tipo_recurso) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_recurso_potrero_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categoria_animal (
  id_categoria_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  descripcion VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  eliminado_en DATETIME NULL,
  PRIMARY KEY (id_categoria_animal),
  UNIQUE KEY uk_categoria_animal_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estado_animal (
  id_estado_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo VARCHAR(45) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(255) NULL,
  PRIMARY KEY (id_estado_animal),
  UNIQUE KEY uk_estado_animal_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE animal (
  id_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  establecimiento_id BIGINT UNSIGNED NOT NULL,
  categoria_animal_id BIGINT UNSIGNED NOT NULL,
  estado_animal_id BIGINT UNSIGNED NOT NULL,
  sexo ENUM('M', 'H') NOT NULL COMMENT 'M = macho, H = hembra',
  fecha_nacimiento DATE NULL,
  nombre VARCHAR(100) NULL,
  observaciones TEXT NULL,
  id_madre BIGINT UNSIGNED NULL,
  id_padre BIGINT UNSIGNED NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  actualizado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  actualizado_por BIGINT UNSIGNED NULL,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_animal),
  KEY idx_animal_establecimiento (establecimiento_id),
  KEY idx_animal_categoria (categoria_animal_id),
  KEY idx_animal_estado (estado_animal_id),
  KEY idx_animal_madre (id_madre),
  KEY idx_animal_padre (id_padre),
  KEY idx_animal_creado_por (creado_por),
  KEY idx_animal_actualizado_por (actualizado_por),
  KEY idx_animal_eliminado_por (eliminado_por),
  CONSTRAINT fk_animal_establecimiento FOREIGN KEY (establecimiento_id)
    REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_animal_categoria FOREIGN KEY (categoria_animal_id)
    REFERENCES categoria_animal (id_categoria_animal) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_animal_estado FOREIGN KEY (estado_animal_id)
    REFERENCES estado_animal (id_estado_animal) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_animal_madre FOREIGN KEY (id_madre)
    REFERENCES animal (id_animal) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_animal_padre FOREIGN KEY (id_padre)
    REFERENCES animal (id_animal) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_animal_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_animal_actualizado_por FOREIGN KEY (actualizado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_animal_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE identificacion_animal (
  id_identificacion_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  animal_id BIGINT UNSIGNED NOT NULL,
  codigo_caravana VARCHAR(100) NOT NULL,
  fecha_desde DATE NOT NULL,
  fecha_hasta DATE NULL,
  motivo_cambio VARCHAR(255) NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_identificacion_animal),
  UNIQUE KEY uk_identificacion_codigo_caravana (codigo_caravana),
  KEY idx_identificacion_animal (animal_id),
  KEY idx_identificacion_creado_por (creado_por),
  CONSTRAINT fk_identificacion_animal FOREIGN KEY (animal_id)
    REFERENCES animal (id_animal) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_identificacion_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_identificacion_fechas CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pesaje (
  id_pesaje BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  animal_id BIGINT UNSIGNED NOT NULL,
  fecha_pesaje DATETIME NOT NULL,
  peso DECIMAL(8,2) NOT NULL COMMENT 'Peso expresado en kilogramos',
  observaciones TEXT NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_pesaje),
  KEY idx_pesaje_animal (animal_id),
  KEY idx_pesaje_fecha (fecha_pesaje),
  KEY idx_pesaje_creado_por (creado_por),
  KEY idx_pesaje_eliminado_por (eliminado_por),
  CONSTRAINT fk_pesaje_animal FOREIGN KEY (animal_id)
    REFERENCES animal (id_animal) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pesaje_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pesaje_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_pesaje_peso CHECK (peso > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lote (
  id_lote BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  establecimiento_id BIGINT UNSIGNED NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(255) NULL,
  fecha_creacion DATE NOT NULL,
  fecha_cierre DATE NULL,
  estado ENUM('ABIERTO', 'CERRADO') NOT NULL DEFAULT 'ABIERTO',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_lote),
  UNIQUE KEY uk_lote_establecimiento_nombre (establecimiento_id, nombre),
  KEY idx_lote_establecimiento (establecimiento_id),
  KEY idx_lote_creado_por (creado_por),
  KEY idx_lote_eliminado_por (eliminado_por),
  CONSTRAINT fk_lote_establecimiento FOREIGN KEY (establecimiento_id)
    REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_lote_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_lote_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_lote_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE lote_animal (
  id_lote_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  animal_id BIGINT UNSIGNED NOT NULL,
  lote_id BIGINT UNSIGNED NOT NULL,
  fecha_desde DATETIME NOT NULL,
  fecha_hasta DATETIME NULL,
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  eliminado_en DATETIME NULL,
  eliminado_por BIGINT UNSIGNED NULL,
  motivo_eliminacion VARCHAR(255) NULL,
  PRIMARY KEY (id_lote_animal),
  KEY idx_lote_animal_animal (animal_id),
  KEY idx_lote_animal_lote (lote_id),
  KEY idx_lote_animal_fechas (fecha_desde, fecha_hasta),
  KEY idx_lote_animal_creado_por (creado_por),
  KEY idx_lote_animal_eliminado_por (eliminado_por),
  CONSTRAINT fk_lote_animal_animal FOREIGN KEY (animal_id)
    REFERENCES animal (id_animal) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_lote_animal_lote FOREIGN KEY (lote_id)
    REFERENCES lote (id_lote) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_lote_animal_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_lote_animal_eliminado_por FOREIGN KEY (eliminado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_lote_animal_fechas CHECK (fecha_hasta IS NULL OR fecha_hasta >= fecha_desde)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimiento (
  id_movimiento BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  establecimiento_id BIGINT UNSIGNED NOT NULL,
  fecha_movimiento DATETIME NOT NULL,
  tipo_movimiento VARCHAR(60) NOT NULL,
  observaciones TEXT NULL,
  estado_movimiento ENUM('PENDIENTE', 'CONFIRMADO', 'ANULADO') NOT NULL DEFAULT 'PENDIENTE',
  creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  creado_por BIGINT UNSIGNED NULL,
  anulado_en DATETIME NULL,
  anulado_por BIGINT UNSIGNED NULL,
  motivo_anulacion VARCHAR(255) NULL,
  PRIMARY KEY (id_movimiento),
  KEY idx_movimiento_establecimiento (establecimiento_id),
  KEY idx_movimiento_fecha (fecha_movimiento),
  KEY idx_movimiento_creado_por (creado_por),
  KEY idx_movimiento_anulado_por (anulado_por),
  CONSTRAINT fk_movimiento_establecimiento FOREIGN KEY (establecimiento_id)
    REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_creado_por FOREIGN KEY (creado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_anulado_por FOREIGN KEY (anulado_por)
    REFERENCES usuario (id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE movimiento_animal (
  id_movimiento_animal BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  movimiento_id BIGINT UNSIGNED NOT NULL,
  animal_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_movimiento_animal),
  UNIQUE KEY uk_movimiento_animal (movimiento_id, animal_id),
  KEY idx_movimiento_animal_animal (animal_id),
  CONSTRAINT fk_movimiento_animal_movimiento FOREIGN KEY (movimiento_id)
    REFERENCES movimiento (id_movimiento) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_movimiento_animal_animal FOREIGN KEY (animal_id)
    REFERENCES animal (id_animal) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO estado_usuario (codigo,nombre,descripcion) VALUES
 ('ACTIVO','Activo','Usuario habilitado para ingresar'),
 ('INACTIVO','Inactivo','Usuario sin acceso');

INSERT INTO rol (codigo,nombre,descripcion) VALUES
 ('DUENO','DUENO','Acceso administrativo completo'),
 ('PEON','PEON','Acceso operativo restringido');

INSERT INTO permiso (codigo,nombre,descripcion) VALUES
 ('POTRERO_CONSULTAR','POTRERO_CONSULTAR','Consultar potreros'),
 ('POTRERO_CREAR','POTRERO_CREAR','Registrar potreros'),
 ('POTRERO_EDITAR','POTRERO_EDITAR','Modificar potreros'),
 ('POTRERO_ELIMINAR','POTRERO_ELIMINAR','Eliminar potreros'),
 ('POTRERO_RECURSOS','POTRERO_RECURSOS','Gestionar recursos de potreros'),
 ('USUARIO_GESTIONAR','USUARIO_GESTIONAR','Administrar usuarios'),
 ('ROL_GESTIONAR','ROL_GESTIONAR','Administrar roles'),
 ('PERMISO_GESTIONAR','PERMISO_GESTIONAR','Administrar permisos'),
 ('ESTABLECIMIENTO_GESTIONAR','ESTABLECIMIENTO_GESTIONAR','Administrar establecimientos'),
 ('PREGUNTA_SEGURIDAD_GESTIONAR','PREGUNTA_SEGURIDAD_GESTIONAR','Administrar preguntas de seguridad'),
 ('CONFIGURACION_VISUAL_GESTIONAR','CONFIGURACION_VISUAL_GESTIONAR','Personalizar logo y fondo');

INSERT INTO pregunta_seguridad (texto,activa) VALUES
 ('¿Cual es el nombre de tu primera mascota?',TRUE),
 ('¿En que ciudad naciste?',TRUE),
 ('¿Cual era el apellido de tu maestro o maestra de primaria?',TRUE),
 ('¿Cual es el segundo nombre de tu madre?',TRUE),
 ('¿Cual fue tu primer trabajo?',TRUE);

INSERT INTO configuracion_visual (id_configuracion_visual,logo_ruta,fondo_ruta)
VALUES (1,'/assets/img/logo-toro.png','/assets/img/fondo-ganaderia.jpg');

INSERT INTO categoria_animal (codigo,nombre,descripcion) VALUES
 ('TERNERO','Ternero','Bovino macho joven'),
 ('TERNERA','Ternera','Bovino hembra joven'),
 ('VAQUILLONA','Vaquillona','Hembra joven que aun no ha parido'),
 ('VACA','Vaca','Hembra bovina adulta'),
 ('NOVILLO','Novillo','Macho bovino castrado'),
 ('TORO','Toro','Macho bovino reproductor');

INSERT INTO estado_animal (codigo,nombre,descripcion) VALUES
 ('ACTIVO','Activo','Animal presente en el establecimiento'),
 ('VENDIDO','Vendido','Animal vendido'),
 ('BAJA','Baja','Animal dado de baja'),
 ('TRASLADADO','Trasladado','Animal trasladado fuera del establecimiento');

INSERT INTO tipo_recurso (codigo,nombre,descripcion) VALUES
 ('BEBEDERO','Bebedero','Suministro de agua'),
 ('COMEDERO','Comedero','Suministro de alimento'),
 ('MOLINO','Molino','Extraccion o bombeo de agua'),
 ('MANGA','Manga','Instalacion para manejo del ganado');

INSERT INTO permiso_rol (permiso_id,rol_id)
SELECT p.id_permiso,r.id_rol FROM permiso p CROSS JOIN rol r WHERE r.codigo='DUENO';

INSERT INTO permiso_rol (permiso_id,rol_id)
SELECT p.id_permiso,r.id_rol FROM permiso p CROSS JOIN rol r
WHERE r.codigo='PEON' AND p.codigo='POTRERO_CONSULTAR';

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;

-- Luego de importar: php database/seed.php

-- ============================================================================
-- SISTEMA DE GESTION GANADERA
-- Modelo relacional para MySQL 8.0
-- Preparado para ingeniería inversa con MySQL Workbench
-- Convención: nombres en español y snake_case
-- Motor: InnoDB | Codificación: utf8mb4
-- ============================================================================

CREATE DATABASE IF NOT EXISTS gestion_ganadera
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE gestion_ganadera;

-- ============================================================================
-- 1. TABLAS CATALOGO
-- Las enumeraciones UML se representan como tablas para mantener el modelo
-- normalizado y permitir que sus relaciones aparezcan en el DER.
-- ============================================================================

CREATE TABLE estado_usuario (
    id_estado_usuario TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_usuario PRIMARY KEY (id_estado_usuario),
    CONSTRAINT uq_estado_usuario_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_animal (
    id_estado_animal TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_animal PRIMARY KEY (id_estado_animal),
    CONSTRAINT uq_estado_animal_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE tipo_baja (
    id_tipo_baja TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_tipo_baja PRIMARY KEY (id_tipo_baja),
    CONSTRAINT uq_tipo_baja_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_alerta (
    id_estado_alerta TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_alerta PRIMARY KEY (id_estado_alerta),
    CONSTRAINT uq_estado_alerta_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE tipo_aplicacion_tratamiento (
    id_tipo_aplicacion TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_tipo_aplicacion_tratamiento PRIMARY KEY (id_tipo_aplicacion),
    CONSTRAINT uq_tipo_aplicacion_tratamiento_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_carencia (
    id_estado_carencia TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_carencia PRIMARY KEY (id_estado_carencia),
    CONSTRAINT uq_estado_carencia_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE tipo_servicio_reproductivo (
    id_tipo_servicio TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_tipo_servicio_reproductivo PRIMARY KEY (id_tipo_servicio),
    CONSTRAINT uq_tipo_servicio_reproductivo_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE tipo_control_reproductivo (
    id_tipo_control TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_tipo_control_reproductivo PRIMARY KEY (id_tipo_control),
    CONSTRAINT uq_tipo_control_reproductivo_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_prenez (
    id_estado_prenez TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_prenez PRIMARY KEY (id_estado_prenez),
    CONSTRAINT uq_estado_prenez_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_venta (
    id_estado_venta TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
    CONSTRAINT uq_estado_venta_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_notificacion (
    id_estado_notificacion TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_notificacion PRIMARY KEY (id_estado_notificacion),
    CONSTRAINT uq_estado_notificacion_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE estado_solicitud_correccion (
    id_estado_solicitud TINYINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    descripcion VARCHAR(150) NULL,
    CONSTRAINT pk_estado_solicitud_correccion PRIMARY KEY (id_estado_solicitud),
    CONSTRAINT uq_estado_solicitud_correccion_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

-- Valores definidos por las enumeraciones del diagrama de clases.
INSERT INTO estado_usuario (codigo, descripcion) VALUES
    ('ACTIVO', 'Usuario habilitado para acceder al sistema'),
    ('INACTIVO', 'Usuario desactivado sin eliminar su historial');

INSERT INTO estado_animal (codigo, descripcion) VALUES
    ('ACTIVO', 'Animal activo en el establecimiento'),
    ('VENDIDO', 'Animal registrado como vendido'),
    ('MUERTO', 'Animal dado de baja por muerte'),
    ('PERDIDO', 'Animal dado de baja por pérdida');

INSERT INTO tipo_baja (codigo, descripcion) VALUES
    ('MUERTE', 'Baja por muerte'),
    ('PERDIDA', 'Baja por pérdida'),
    ('DESCARTE', 'Baja por descarte'),
    ('OTRA', 'Otro motivo de baja');

INSERT INTO estado_alerta (codigo, descripcion) VALUES
    ('PENDIENTE', 'Alerta pendiente de atención'),
    ('ATENDIDA', 'Alerta revisada o atendida');

INSERT INTO tipo_aplicacion_tratamiento (codigo, descripcion) VALUES
    ('INDIVIDUAL', 'Tratamiento aplicado individualmente'),
    ('GRUPAL', 'Tratamiento aplicado a un grupo de animales');

INSERT INTO estado_carencia (codigo, descripcion) VALUES
    ('ACTIVA', 'El período de carencia se encuentra vigente'),
    ('FINALIZADA', 'El período de carencia ha finalizado');

INSERT INTO tipo_servicio_reproductivo (codigo, descripcion) VALUES
    ('INSEMINACION_ARTIFICIAL', 'Servicio mediante inseminación artificial'),
    ('REPASO_TORO', 'Servicio mediante repaso con toro');

INSERT INTO tipo_control_reproductivo (codigo, descripcion) VALUES
    ('TACTO', 'Control reproductivo mediante tacto'),
    ('ECOGRAFIA', 'Control reproductivo mediante ecografía'),
    ('OTRO', 'Otro tipo de control reproductivo');

INSERT INTO estado_prenez (codigo, descripcion) VALUES
    ('PRENADA', 'Hembra diagnosticada como preñada'),
    ('VACIA', 'Hembra diagnosticada como vacía'),
    ('PENDIENTE_DIAGNOSTICO', 'Estado pendiente de diagnóstico');

INSERT INTO estado_venta (codigo, descripcion) VALUES
    ('PENDIENTE', 'Venta registrada y pendiente de confirmación'),
    ('CONFIRMADA', 'Venta confirmada'),
    ('ANULADA', 'Venta anulada');

INSERT INTO estado_notificacion (codigo, descripcion) VALUES
    ('PENDIENTE', 'Notificación pendiente de atención'),
    ('ATENDIDA', 'Notificación atendida');

INSERT INTO estado_solicitud_correccion (codigo, descripcion) VALUES
    ('PENDIENTE', 'Solicitud pendiente de resolución'),
    ('APROBADA', 'Solicitud aprobada'),
    ('RECHAZADA', 'Solicitud rechazada');

-- ============================================================================
-- 2. USUARIOS, PERSONAS, ROLES Y PERMISOS
-- Usuario se implementa como una especialización de Persona mediante una
-- relación uno a uno. Dueño y Peón se cargan como registros de Rol.
-- ============================================================================

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

CREATE TABLE material_capacitacion (
    id_material_capacitacion BIGINT UNSIGNED AUTO_INCREMENT,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NULL,
    contenido LONGTEXT NULL,
    ubicacion_recurso VARCHAR(500) NULL,
    CONSTRAINT pk_material_capacitacion PRIMARY KEY (id_material_capacitacion)
) ENGINE = InnoDB;

CREATE TABLE usuario_material_capacitacion (
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_material_capacitacion BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_usuario_material_capacitacion
        PRIMARY KEY (id_usuario, id_material_capacitacion),
    CONSTRAINT fk_usuario_material_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_usuario_material_material
        FOREIGN KEY (id_material_capacitacion)
        REFERENCES material_capacitacion (id_material_capacitacion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

INSERT INTO rol (nombre, descripcion) VALUES
    ('DUENO', 'Rol con permisos de administración y control general'),
    ('PEON', 'Rol operativo sujeto a los permisos asignados');

-- ============================================================================
-- 3. ESTABLECIMIENTO Y POTREROS
-- ============================================================================

CREATE TABLE establecimiento (
    id_establecimiento BIGINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_establecimiento PRIMARY KEY (id_establecimiento)
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
-- 4. ANIMALES, LOTES, IDENTIFICACION Y TRAZABILIDAD
-- ============================================================================

CREATE TABLE categoria_animal (
    id_categoria_animal SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_categoria_animal PRIMARY KEY (id_categoria_animal),
    CONSTRAINT uq_categoria_animal_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE lote (
    id_lote BIGINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL,
    estado VARCHAR(40) NOT NULL,
    CONSTRAINT pk_lote PRIMARY KEY (id_lote),
    CONSTRAINT uq_lote_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE animal (
    id_animal BIGINT UNSIGNED AUTO_INCREMENT,
    id_categoria_animal SMALLINT UNSIGNED NOT NULL,
    id_estado_animal TINYINT UNSIGNED NOT NULL,
    id_lote_actual BIGINT UNSIGNED NULL,
    id_madre BIGINT UNSIGNED NULL,
    id_padre BIGINT UNSIGNED NULL,
    fecha_nacimiento DATE NOT NULL,
    CONSTRAINT pk_animal PRIMARY KEY (id_animal),
    CONSTRAINT ck_animal_madre_distinta CHECK (id_madre IS NULL OR id_madre <> id_animal),
    CONSTRAINT ck_animal_padre_distinto CHECK (id_padre IS NULL OR id_padre <> id_animal),
    CONSTRAINT ck_animal_progenitores_distintos
        CHECK (id_madre IS NULL OR id_padre IS NULL OR id_madre <> id_padre),
    CONSTRAINT fk_animal_categoria
        FOREIGN KEY (id_categoria_animal)
        REFERENCES categoria_animal (id_categoria_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_animal_estado
        FOREIGN KEY (id_estado_animal) REFERENCES estado_animal (id_estado_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_animal_lote_actual
        FOREIGN KEY (id_lote_actual) REFERENCES lote (id_lote)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_animal_madre
        FOREIGN KEY (id_madre) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_animal_padre
        FOREIGN KEY (id_padre) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_animal_categoria (id_categoria_animal),
    INDEX ix_animal_estado (id_estado_animal),
    INDEX ix_animal_lote_actual (id_lote_actual),
    INDEX ix_animal_fecha_nacimiento (fecha_nacimiento)
) ENGINE = InnoDB;

CREATE TABLE identificacion_animal (
    id_identificacion_animal BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    codigo_caravana VARCHAR(80) NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    codigo_caravana_activa VARCHAR(80)
        GENERATED ALWAYS AS (
            CASE WHEN activa = TRUE THEN codigo_caravana ELSE NULL END
        ) STORED,
    CONSTRAINT pk_identificacion_animal PRIMARY KEY (id_identificacion_animal),
    CONSTRAINT uq_identificacion_caravana_activa UNIQUE (codigo_caravana_activa),
    CONSTRAINT ck_identificacion_fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_asignacion),
    CONSTRAINT fk_identificacion_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX ix_identificacion_animal (id_animal),
    INDEX ix_identificacion_codigo (codigo_caravana)
) ENGINE = InnoDB;

CREATE TABLE fotografia_animal (
    id_fotografia_animal BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    nombre_archivo VARCHAR(255) NOT NULL,
    fecha_carga DATETIME NOT NULL,
    ruta VARCHAR(500) NOT NULL,
    CONSTRAINT pk_fotografia_animal PRIMARY KEY (id_fotografia_animal),
    CONSTRAINT fk_fotografia_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE pesaje (
    id_pesaje BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    peso DECIMAL(10,2) NOT NULL,
    motivo VARCHAR(255) NULL,
    CONSTRAINT pk_pesaje PRIMARY KEY (id_pesaje),
    CONSTRAINT ck_pesaje_peso CHECK (peso > 0),
    CONSTRAINT fk_pesaje_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX ix_pesaje_animal_fecha (id_animal, fecha)
) ENGINE = InnoDB;

CREATE TABLE baja_animal (
    id_baja_animal BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    id_tipo_baja TINYINT UNSIGNED NOT NULL,
    fecha DATETIME NOT NULL,
    motivo TEXT NULL,
    CONSTRAINT pk_baja_animal PRIMARY KEY (id_baja_animal),
    CONSTRAINT uq_baja_animal UNIQUE (id_animal),
    CONSTRAINT fk_baja_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_baja_tipo
        FOREIGN KEY (id_tipo_baja) REFERENCES tipo_baja (id_tipo_baja)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE historial_sanitario (
    id_historial_sanitario BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    fecha_actualizacion DATETIME NOT NULL,
    CONSTRAINT pk_historial_sanitario PRIMARY KEY (id_historial_sanitario),
    CONSTRAINT uq_historial_sanitario_animal UNIQUE (id_animal),
    CONSTRAINT fk_historial_sanitario_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- ============================================================================
-- 5. MOVIMIENTOS
-- Un movimiento puede registrar animales individuales y, opcionalmente, un
-- lote. Origen y destino son dos claves foráneas distintas hacia Potrero.
-- ============================================================================

CREATE TABLE movimiento (
    id_movimiento BIGINT UNSIGNED AUTO_INCREMENT,
    id_potrero_origen BIGINT UNSIGNED NOT NULL,
    id_potrero_destino BIGINT UNSIGNED NOT NULL,
    id_lote BIGINT UNSIGNED NULL,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    fecha DATETIME NOT NULL,
    CONSTRAINT pk_movimiento PRIMARY KEY (id_movimiento),
    CONSTRAINT ck_movimiento_potreros_distintos
        CHECK (id_potrero_origen <> id_potrero_destino),
    CONSTRAINT fk_movimiento_potrero_origen
        FOREIGN KEY (id_potrero_origen) REFERENCES potrero (id_potrero)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_potrero_destino
        FOREIGN KEY (id_potrero_destino) REFERENCES potrero (id_potrero)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimiento_lote
        FOREIGN KEY (id_lote) REFERENCES lote (id_lote)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_movimiento_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_movimiento_fecha (fecha),
    INDEX ix_movimiento_origen (id_potrero_origen),
    INDEX ix_movimiento_destino (id_potrero_destino)
) ENGINE = InnoDB;

CREATE TABLE movimiento_animal (
    id_movimiento BIGINT UNSIGNED NOT NULL,
    id_animal BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_movimiento_animal PRIMARY KEY (id_movimiento, id_animal),
    CONSTRAINT fk_movimiento_animal_movimiento
        FOREIGN KEY (id_movimiento) REFERENCES movimiento (id_movimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_movimiento_animal_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_movimiento_animal_animal (id_animal)
) ENGINE = InnoDB;

-- ============================================================================
-- 6. COSTOS, INVERSIONES Y SUPLEMENTACION
-- ============================================================================

CREATE TABLE categoria_gasto (
    id_categoria_gasto SMALLINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    CONSTRAINT pk_categoria_gasto PRIMARY KEY (id_categoria_gasto),
    CONSTRAINT uq_categoria_gasto_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE gasto (
    id_gasto BIGINT UNSIGNED AUTO_INCREMENT,
    id_categoria_gasto SMALLINT UNSIGNED NOT NULL,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    concepto VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    importe DECIMAL(14,2) NOT NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_gasto PRIMARY KEY (id_gasto),
    CONSTRAINT ck_gasto_importe CHECK (importe >= 0),
    CONSTRAINT fk_gasto_categoria
        FOREIGN KEY (id_categoria_gasto)
        REFERENCES categoria_gasto (id_categoria_gasto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_gasto_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_gasto_fecha (fecha),
    INDEX ix_gasto_categoria (id_categoria_gasto)
) ENGINE = InnoDB;

CREATE TABLE inversion (
    id_inversion BIGINT UNSIGNED AUTO_INCREMENT,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    concepto VARCHAR(200) NOT NULL,
    fecha DATE NOT NULL,
    importe DECIMAL(14,2) NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_inversion PRIMARY KEY (id_inversion),
    CONSTRAINT ck_inversion_importe CHECK (importe >= 0),
    CONSTRAINT fk_inversion_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_inversion_fecha (fecha)
) ENGINE = InnoDB;

CREATE TABLE suplementacion (
    id_suplementacion BIGINT UNSIGNED AUTO_INCREMENT,
    id_gasto BIGINT UNSIGNED NULL,
    fecha DATE NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_suplementacion PRIMARY KEY (id_suplementacion),
    CONSTRAINT uq_suplementacion_gasto UNIQUE (id_gasto),
    CONSTRAINT fk_suplementacion_gasto
        FOREIGN KEY (id_gasto) REFERENCES gasto (id_gasto)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE = InnoDB;

-- ============================================================================
-- 7. SANIDAD
-- ============================================================================

CREATE TABLE alerta_sanitaria (
    id_alerta_sanitaria BIGINT UNSIGNED AUTO_INCREMENT,
    id_animal BIGINT UNSIGNED NOT NULL,
    id_estado_alerta TINYINT UNSIGNED NOT NULL,
    fecha_generacion DATETIME NOT NULL,
    fecha_programada DATE NULL,
    descripcion TEXT NOT NULL,
    CONSTRAINT pk_alerta_sanitaria PRIMARY KEY (id_alerta_sanitaria),
    CONSTRAINT fk_alerta_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_alerta_estado
        FOREIGN KEY (id_estado_alerta) REFERENCES estado_alerta (id_estado_alerta)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_alerta_programada (fecha_programada),
    INDEX ix_alerta_estado (id_estado_alerta)
) ENGINE = InnoDB;

CREATE TABLE medicamento (
    id_medicamento BIGINT UNSIGNED AUTO_INCREMENT,
    nombre VARCHAR(150) NOT NULL,
    principio_activo VARCHAR(200) NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_medicamento PRIMARY KEY (id_medicamento),
    CONSTRAINT uq_medicamento_nombre_principio
        UNIQUE (nombre, principio_activo)
) ENGINE = InnoDB;

CREATE TABLE restriccion_sanitaria (
    id_restriccion_sanitaria BIGINT UNSIGNED AUTO_INCREMENT,
    id_medicamento BIGINT UNSIGNED NOT NULL,
    descripcion TEXT NOT NULL,
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_restriccion_sanitaria PRIMARY KEY (id_restriccion_sanitaria),
    CONSTRAINT fk_restriccion_medicamento
        FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE tratamiento_sanitario (
    id_tratamiento_sanitario BIGINT UNSIGNED AUTO_INCREMENT,
    id_tipo_aplicacion TINYINT UNSIGNED NOT NULL,
    id_gasto BIGINT UNSIGNED NULL,
    fecha DATE NOT NULL,
    descripcion TEXT NOT NULL,
    dosis DECIMAL(10,3) NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_tratamiento_sanitario PRIMARY KEY (id_tratamiento_sanitario),
    CONSTRAINT uq_tratamiento_gasto UNIQUE (id_gasto),
    CONSTRAINT ck_tratamiento_dosis CHECK (dosis IS NULL OR dosis > 0),
    CONSTRAINT fk_tratamiento_tipo_aplicacion
        FOREIGN KEY (id_tipo_aplicacion)
        REFERENCES tipo_aplicacion_tratamiento (id_tipo_aplicacion)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tratamiento_gasto
        FOREIGN KEY (id_gasto) REFERENCES gasto (id_gasto)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX ix_tratamiento_fecha (fecha)
) ENGINE = InnoDB;

CREATE TABLE tratamiento_animal (
    id_tratamiento_sanitario BIGINT UNSIGNED NOT NULL,
    id_animal BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_tratamiento_animal
        PRIMARY KEY (id_tratamiento_sanitario, id_animal),
    CONSTRAINT fk_tratamiento_animal_tratamiento
        FOREIGN KEY (id_tratamiento_sanitario)
        REFERENCES tratamiento_sanitario (id_tratamiento_sanitario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tratamiento_animal_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_tratamiento_animal_animal (id_animal)
) ENGINE = InnoDB;

CREATE TABLE tratamiento_medicamento (
    id_tratamiento_sanitario BIGINT UNSIGNED NOT NULL,
    id_medicamento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_tratamiento_medicamento
        PRIMARY KEY (id_tratamiento_sanitario, id_medicamento),
    CONSTRAINT fk_tratamiento_medicamento_tratamiento
        FOREIGN KEY (id_tratamiento_sanitario)
        REFERENCES tratamiento_sanitario (id_tratamiento_sanitario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tratamiento_medicamento_medicamento
        FOREIGN KEY (id_medicamento) REFERENCES medicamento (id_medicamento)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_tratamiento_medicamento_medicamento (id_medicamento)
) ENGINE = InnoDB;

CREATE TABLE periodo_carencia (
    id_periodo_carencia BIGINT UNSIGNED AUTO_INCREMENT,
    id_tratamiento_sanitario BIGINT UNSIGNED NOT NULL,
    id_estado_carencia TINYINT UNSIGNED NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT pk_periodo_carencia PRIMARY KEY (id_periodo_carencia),
    CONSTRAINT uq_periodo_carencia_tratamiento UNIQUE (id_tratamiento_sanitario),
    CONSTRAINT ck_periodo_carencia_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT fk_carencia_tratamiento
        FOREIGN KEY (id_tratamiento_sanitario)
        REFERENCES tratamiento_sanitario (id_tratamiento_sanitario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_carencia_estado
        FOREIGN KEY (id_estado_carencia) REFERENCES estado_carencia (id_estado_carencia)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ============================================================================
-- 8. REPRODUCCION Y GENEALOGIA
-- ============================================================================

CREATE TABLE material_genetico (
    id_material_genetico BIGINT UNSIGNED AUTO_INCREMENT,
    codigo VARCHAR(100) NOT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_material_genetico PRIMARY KEY (id_material_genetico),
    CONSTRAINT uq_material_genetico_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE servicio_reproductivo (
    id_servicio_reproductivo BIGINT UNSIGNED AUTO_INCREMENT,
    id_hembra BIGINT UNSIGNED NOT NULL,
    id_reproductor BIGINT UNSIGNED NOT NULL,
    id_material_genetico BIGINT UNSIGNED NULL,
    id_tipo_servicio TINYINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_servicio_reproductivo PRIMARY KEY (id_servicio_reproductivo),
    CONSTRAINT ck_servicio_animales_distintos CHECK (id_hembra <> id_reproductor),
    CONSTRAINT fk_servicio_hembra
        FOREIGN KEY (id_hembra) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_servicio_reproductor
        FOREIGN KEY (id_reproductor) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_servicio_material_genetico
        FOREIGN KEY (id_material_genetico)
        REFERENCES material_genetico (id_material_genetico)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_servicio_tipo
        FOREIGN KEY (id_tipo_servicio)
        REFERENCES tipo_servicio_reproductivo (id_tipo_servicio)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_servicio_fecha (fecha),
    INDEX ix_servicio_hembra (id_hembra),
    INDEX ix_servicio_reproductor (id_reproductor)
) ENGINE = InnoDB;

CREATE TABLE control_reproductivo (
    id_control_reproductivo BIGINT UNSIGNED AUTO_INCREMENT,
    id_hembra BIGINT UNSIGNED NOT NULL,
    id_tipo_control TINYINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    resultado VARCHAR(255) NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_control_reproductivo PRIMARY KEY (id_control_reproductivo),
    CONSTRAINT fk_control_hembra
        FOREIGN KEY (id_hembra) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_control_tipo
        FOREIGN KEY (id_tipo_control)
        REFERENCES tipo_control_reproductivo (id_tipo_control)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_control_hembra_fecha (id_hembra, fecha)
) ENGINE = InnoDB;

CREATE TABLE registro_estado_prenez (
    id_registro_estado_prenez BIGINT UNSIGNED AUTO_INCREMENT,
    id_control_reproductivo BIGINT UNSIGNED NOT NULL,
    id_estado_prenez TINYINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    CONSTRAINT pk_registro_estado_prenez PRIMARY KEY (id_registro_estado_prenez),
    CONSTRAINT uq_registro_control UNIQUE (id_control_reproductivo),
    CONSTRAINT fk_registro_prenez_control
        FOREIGN KEY (id_control_reproductivo)
        REFERENCES control_reproductivo (id_control_reproductivo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_registro_prenez_estado
        FOREIGN KEY (id_estado_prenez) REFERENCES estado_prenez (id_estado_prenez)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE nacimiento (
    id_nacimiento BIGINT UNSIGNED AUTO_INCREMENT,
    id_madre BIGINT UNSIGNED NOT NULL,
    id_ternero BIGINT UNSIGNED NOT NULL,
    id_padre BIGINT UNSIGNED NULL,
    id_servicio_reproductivo BIGINT UNSIGNED NULL,
    fecha_parto DATE NOT NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_nacimiento PRIMARY KEY (id_nacimiento),
    CONSTRAINT uq_nacimiento_ternero UNIQUE (id_ternero),
    CONSTRAINT uq_nacimiento_servicio UNIQUE (id_servicio_reproductivo),
    CONSTRAINT ck_nacimiento_madre_ternero CHECK (id_madre <> id_ternero),
    CONSTRAINT ck_nacimiento_padre_ternero
        CHECK (id_padre IS NULL OR id_padre <> id_ternero),
    CONSTRAINT ck_nacimiento_progenitores
        CHECK (id_padre IS NULL OR id_padre <> id_madre),
    CONSTRAINT fk_nacimiento_madre
        FOREIGN KEY (id_madre) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_nacimiento_ternero
        FOREIGN KEY (id_ternero) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_nacimiento_padre
        FOREIGN KEY (id_padre) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_nacimiento_servicio
        FOREIGN KEY (id_servicio_reproductivo)
        REFERENCES servicio_reproductivo (id_servicio_reproductivo)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX ix_nacimiento_fecha_parto (fecha_parto)
) ENGINE = InnoDB;

-- ============================================================================
-- 9. COMPRAS Y VENTAS
-- Persona participa como comprador; no se crea una clase o tabla Comprador.
-- ============================================================================

CREATE TABLE venta (
    id_venta BIGINT UNSIGNED AUTO_INCREMENT,
    id_comprador BIGINT UNSIGNED NOT NULL,
    id_estado_venta TINYINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    importe_total DECIMAL(14,2) NOT NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_venta PRIMARY KEY (id_venta),
    CONSTRAINT ck_venta_importe CHECK (importe_total >= 0),
    CONSTRAINT fk_venta_comprador
        FOREIGN KEY (id_comprador) REFERENCES persona (id_persona)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_venta_estado
        FOREIGN KEY (id_estado_venta) REFERENCES estado_venta (id_estado_venta)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_venta_fecha (fecha),
    INDEX ix_venta_comprador (id_comprador)
) ENGINE = InnoDB;

CREATE TABLE detalle_venta (
    id_detalle_venta BIGINT UNSIGNED AUTO_INCREMENT,
    id_venta BIGINT UNSIGNED NOT NULL,
    id_animal BIGINT UNSIGNED NOT NULL,
    precio_individual DECIMAL(14,2) NOT NULL,
    peso_venta DECIMAL(10,2) NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_detalle_venta PRIMARY KEY (id_detalle_venta),
    CONSTRAINT uq_detalle_venta_animal UNIQUE (id_venta, id_animal),
    CONSTRAINT ck_detalle_venta_precio CHECK (precio_individual >= 0),
    CONSTRAINT ck_detalle_venta_peso CHECK (peso_venta IS NULL OR peso_venta > 0),
    CONSTRAINT fk_detalle_venta_venta
        FOREIGN KEY (id_venta) REFERENCES venta (id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_venta_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_detalle_venta_animal (id_animal)
) ENGINE = InnoDB;

CREATE TABLE anulacion_venta (
    id_anulacion_venta BIGINT UNSIGNED AUTO_INCREMENT,
    id_venta BIGINT UNSIGNED NOT NULL,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    motivo TEXT NOT NULL,
    CONSTRAINT pk_anulacion_venta PRIMARY KEY (id_anulacion_venta),
    CONSTRAINT uq_anulacion_venta UNIQUE (id_venta),
    CONSTRAINT fk_anulacion_venta
        FOREIGN KEY (id_venta) REFERENCES venta (id_venta)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_anulacion_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE compra (
    id_compra BIGINT UNSIGNED AUTO_INCREMENT,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    fecha DATE NOT NULL,
    importe_total DECIMAL(14,2) NOT NULL,
    observacion TEXT NULL,
    CONSTRAINT pk_compra PRIMARY KEY (id_compra),
    CONSTRAINT ck_compra_importe CHECK (importe_total >= 0),
    CONSTRAINT fk_compra_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_compra_fecha (fecha)
) ENGINE = InnoDB;

CREATE TABLE detalle_compra (
    id_detalle_compra BIGINT UNSIGNED AUTO_INCREMENT,
    id_compra BIGINT UNSIGNED NOT NULL,
    id_animal BIGINT UNSIGNED NOT NULL,
    precio_individual DECIMAL(14,2) NOT NULL,
    peso_ingreso DECIMAL(10,2) NULL,
    CONSTRAINT pk_detalle_compra PRIMARY KEY (id_detalle_compra),
    CONSTRAINT uq_detalle_compra_animal UNIQUE (id_compra, id_animal),
    CONSTRAINT ck_detalle_compra_precio CHECK (precio_individual >= 0),
    CONSTRAINT ck_detalle_compra_peso CHECK (peso_ingreso IS NULL OR peso_ingreso > 0),
    CONSTRAINT fk_detalle_compra_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_compra_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_detalle_compra_animal (id_animal)
) ENGINE = InnoDB;

-- ============================================================================
-- 10. DOCUMENTOS Y OBSERVACIONES
-- Las tablas intermedias evitan duplicar Documento u Observacion y permiten
-- reutilizar sus clases canónicas desde distintos módulos.
-- ============================================================================

CREATE TABLE documento (
    id_documento BIGINT UNSIGNED AUTO_INCREMENT,
    id_usuario_cargado_por BIGINT UNSIGNED NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    tipo_archivo VARCHAR(100) NOT NULL,
    fecha_carga DATETIME NOT NULL,
    descripcion TEXT NULL,
    ubicacion_archivo VARCHAR(500) NOT NULL,
    CONSTRAINT pk_documento PRIMARY KEY (id_documento),
    CONSTRAINT fk_documento_usuario
        FOREIGN KEY (id_usuario_cargado_por) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_documento_fecha_carga (fecha_carga)
) ENGINE = InnoDB;

CREATE TABLE animal_documento (
    id_animal BIGINT UNSIGNED NOT NULL,
    id_documento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_animal_documento PRIMARY KEY (id_animal, id_documento),
    CONSTRAINT uq_animal_documento_documento UNIQUE (id_documento),
    CONSTRAINT fk_animal_documento_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_animal_documento_documento
        FOREIGN KEY (id_documento) REFERENCES documento (id_documento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE movimiento_documento (
    id_movimiento BIGINT UNSIGNED NOT NULL,
    id_documento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_movimiento_documento PRIMARY KEY (id_movimiento, id_documento),
    CONSTRAINT uq_movimiento_documento_documento UNIQUE (id_documento),
    CONSTRAINT fk_movimiento_documento_movimiento
        FOREIGN KEY (id_movimiento) REFERENCES movimiento (id_movimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_movimiento_documento_documento
        FOREIGN KEY (id_documento) REFERENCES documento (id_documento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE tratamiento_documento (
    id_tratamiento_sanitario BIGINT UNSIGNED NOT NULL,
    id_documento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_tratamiento_documento
        PRIMARY KEY (id_tratamiento_sanitario, id_documento),
    CONSTRAINT uq_tratamiento_documento_documento UNIQUE (id_documento),
    CONSTRAINT fk_tratamiento_documento_tratamiento
        FOREIGN KEY (id_tratamiento_sanitario)
        REFERENCES tratamiento_sanitario (id_tratamiento_sanitario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tratamiento_documento_documento
        FOREIGN KEY (id_documento) REFERENCES documento (id_documento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE venta_documento (
    id_venta BIGINT UNSIGNED NOT NULL,
    id_documento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_venta_documento PRIMARY KEY (id_venta, id_documento),
    CONSTRAINT uq_venta_documento_documento UNIQUE (id_documento),
    CONSTRAINT fk_venta_documento_venta
        FOREIGN KEY (id_venta) REFERENCES venta (id_venta)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_venta_documento_documento
        FOREIGN KEY (id_documento) REFERENCES documento (id_documento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE compra_documento (
    id_compra BIGINT UNSIGNED NOT NULL,
    id_documento BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_compra_documento PRIMARY KEY (id_compra, id_documento),
    CONSTRAINT uq_compra_documento_documento UNIQUE (id_documento),
    CONSTRAINT fk_compra_documento_compra
        FOREIGN KEY (id_compra) REFERENCES compra (id_compra)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_compra_documento_documento
        FOREIGN KEY (id_documento) REFERENCES documento (id_documento)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE observacion (
    id_observacion BIGINT UNSIGNED AUTO_INCREMENT,
    fecha_hora DATETIME NOT NULL,
    descripcion TEXT NOT NULL,
    CONSTRAINT pk_observacion PRIMARY KEY (id_observacion)
) ENGINE = InnoDB;

CREATE TABLE animal_observacion (
    id_animal BIGINT UNSIGNED NOT NULL,
    id_observacion BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_animal_observacion PRIMARY KEY (id_animal, id_observacion),
    CONSTRAINT uq_animal_observacion_observacion UNIQUE (id_observacion),
    CONSTRAINT fk_animal_observacion_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_animal_observacion_observacion
        FOREIGN KEY (id_observacion) REFERENCES observacion (id_observacion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE movimiento_observacion (
    id_movimiento BIGINT UNSIGNED NOT NULL,
    id_observacion BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_movimiento_observacion
        PRIMARY KEY (id_movimiento, id_observacion),
    CONSTRAINT uq_movimiento_observacion_observacion UNIQUE (id_observacion),
    CONSTRAINT fk_movimiento_observacion_movimiento
        FOREIGN KEY (id_movimiento) REFERENCES movimiento (id_movimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_movimiento_observacion_observacion
        FOREIGN KEY (id_observacion) REFERENCES observacion (id_observacion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE tratamiento_observacion (
    id_tratamiento_sanitario BIGINT UNSIGNED NOT NULL,
    id_observacion BIGINT UNSIGNED NOT NULL,
    CONSTRAINT pk_tratamiento_observacion
        PRIMARY KEY (id_tratamiento_sanitario, id_observacion),
    CONSTRAINT uq_tratamiento_observacion_observacion UNIQUE (id_observacion),
    CONSTRAINT fk_tratamiento_observacion_tratamiento
        FOREIGN KEY (id_tratamiento_sanitario)
        REFERENCES tratamiento_sanitario (id_tratamiento_sanitario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_tratamiento_observacion_observacion
        FOREIGN KEY (id_observacion) REFERENCES observacion (id_observacion)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

-- ============================================================================
-- 11. NOTIFICACIONES
-- ============================================================================

CREATE TABLE notificacion (
    id_notificacion BIGINT UNSIGNED AUTO_INCREMENT,
    id_establecimiento BIGINT UNSIGNED NOT NULL,
    id_usuario_destinatario BIGINT UNSIGNED NOT NULL,
    id_estado_notificacion TINYINT UNSIGNED NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha_generacion DATETIME NOT NULL,
    fecha_programada DATE NULL,
    CONSTRAINT pk_notificacion PRIMARY KEY (id_notificacion),
    CONSTRAINT fk_notificacion_establecimiento
        FOREIGN KEY (id_establecimiento)
        REFERENCES establecimiento (id_establecimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notificacion_destinatario
        FOREIGN KEY (id_usuario_destinatario) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_notificacion_estado
        FOREIGN KEY (id_estado_notificacion)
        REFERENCES estado_notificacion (id_estado_notificacion)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_notificacion_usuario_estado
        (id_usuario_destinatario, id_estado_notificacion),
    INDEX ix_notificacion_fecha_programada (fecha_programada)
) ENGINE = InnoDB;

-- ============================================================================
-- 12. AUDITORIA Y SOLICITUDES DE CORRECCION
-- tipo_registro e id_registro permanecen genéricos porque los requisitos no
-- determinan de forma cerrada qué tipos de registro pueden corregirse.
-- ============================================================================

CREATE TABLE solicitud_correccion (
    id_solicitud_correccion BIGINT UNSIGNED AUTO_INCREMENT,
    id_usuario_solicitante BIGINT UNSIGNED NOT NULL,
    id_usuario_resolutor BIGINT UNSIGNED NULL,
    id_estado_solicitud TINYINT UNSIGNED NOT NULL,
    fecha_solicitud DATETIME NOT NULL,
    motivo TEXT NOT NULL,
    descripcion_correccion TEXT NOT NULL,
    tipo_registro VARCHAR(80) NOT NULL,
    id_registro VARCHAR(100) NOT NULL,
    CONSTRAINT pk_solicitud_correccion PRIMARY KEY (id_solicitud_correccion),
    CONSTRAINT fk_solicitud_solicitante
        FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_resolutor
        FOREIGN KEY (id_usuario_resolutor) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_solicitud_estado
        FOREIGN KEY (id_estado_solicitud)
        REFERENCES estado_solicitud_correccion (id_estado_solicitud)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX ix_solicitud_estado_fecha (id_estado_solicitud, fecha_solicitud),
    INDEX ix_solicitud_registro (tipo_registro, id_registro)
) ENGINE = InnoDB;

CREATE TABLE historial_modificacion (
    id_historial_modificacion BIGINT UNSIGNED AUTO_INCREMENT,
    id_usuario_responsable BIGINT UNSIGNED NOT NULL,
    id_solicitud_correccion BIGINT UNSIGNED NULL,
    fecha_hora DATETIME NOT NULL,
    accion VARCHAR(100) NOT NULL,
    valor_anterior TEXT NULL,
    valor_nuevo TEXT NULL,
    descripcion TEXT NULL,
    CONSTRAINT pk_historial_modificacion PRIMARY KEY (id_historial_modificacion),
    CONSTRAINT uq_historial_solicitud UNIQUE (id_solicitud_correccion),
    CONSTRAINT fk_historial_responsable
        FOREIGN KEY (id_usuario_responsable) REFERENCES usuario (id_usuario)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_historial_solicitud
        FOREIGN KEY (id_solicitud_correccion)
        REFERENCES solicitud_correccion (id_solicitud_correccion)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX ix_historial_fecha_hora (fecha_hora)
) ENGINE = InnoDB;

-- ============================================================================
-- FIN DEL ESQUEMA
-- ServicioIndicadores no se convierte en tabla porque representa lógica de
-- aplicación. Sus resultados se calculan consultando las tablas anteriores.
-- ============================================================================

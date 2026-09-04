-- ============================================================================
-- SIGGAF - ACTUALIZACION PARA PERSONALIZACION VISUAL
-- Ejecutar una sola vez si la base gestion_ganadera ya fue creada anteriormente.
-- Compatible con MySQL 8.0 y MariaDB utilizados por XAMPP.
-- ============================================================================

USE gestion_ganadera;

CREATE TABLE IF NOT EXISTS configuracion_visual (
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

INSERT INTO configuracion_visual (
    id_configuracion_visual,
    logo_ruta,
    fondo_ruta
) VALUES (
    1,
    '/assets/img/logo-toro.png',
    '/assets/img/fondo-ganaderia.jpg'
)
ON DUPLICATE KEY UPDATE id_configuracion_visual = VALUES(id_configuracion_visual);


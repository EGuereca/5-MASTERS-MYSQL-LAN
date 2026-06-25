-- ============================================================
--  Nodo 1 — Inicialización PRINCIPAL
--  Este es el ÚNICO nodo que crea la BD, tablas y datos iniciales.
--  Los datos se propagarán al resto del anillo vía replicación GTID.
-- ============================================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS ring_db;
USE ring_db;

-- -----------------------------------------------------------
-- Usuarios de sistema (SIN binlog → evita conflictos GTID)
-- Cada nodo crea sus propios usuarios localmente.
-- -----------------------------------------------------------
SET sql_log_bin = 0;

CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'replpassword';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- Usuario administrador para conexión remota desde la LAN.
-- root permanece restringido a localhost por seguridad.
CREATE USER IF NOT EXISTS 'admin_lan'@'%' IDENTIFIED BY 'admin_secure_pass';
GRANT ALL PRIVILEGES ON *.* TO 'admin_lan'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
SET sql_log_bin = 1;

-- -----------------------------------------------------------
-- Tablas y datos iniciales (CON binlog → SE REPLICAN al anillo)
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS test_ring (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nodo_origen VARCHAR(50) NOT NULL,
    mensaje VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO test_ring (nodo_origen, mensaje) VALUES ('PC1', 'Registro inicial — propagado por el anillo');

-- Migración 001 · Práctica 4, ejercicio 1.1: tipos de dato y dominios
-- Se ejecuta DESPUÉS de esquema.sql (Práctica 3). Todo en una transacción:
-- si algo falla, no queda nada a medias.
BEGIN;

-- ---------- Dominios reutilizables ----------
-- Identificador positivo (se repite en 5 tablas y en las claves foráneas).
CREATE DOMAIN d_codigo AS INTEGER
    CONSTRAINT ck_d_codigo CHECK (VALUE > 0);

-- Nombres y apellidos: no pueden ser solo espacios en blanco.
CREATE DOMAIN d_nombre AS VARCHAR(60)
    CONSTRAINT ck_d_nombre CHECK (VALUE ~ '[^[:space:]]');
CREATE DOMAIN d_apellidos AS VARCHAR(80)
    CONSTRAINT ck_d_apellidos CHECK (VALUE ~ '[^[:space:]]');

-- ---------- Aplicar los dominios ----------
-- Para cambiar el tipo de columnas que forman parte de claves foráneas, se
-- quitan las claves foráneas, se cambia el tipo y se vuelven a crear idénticas.
ALTER TABLE mascota     DROP CONSTRAINT fk_mascota_dueno;
ALTER TABLE cita        DROP CONSTRAINT fk_cita_mascota;
ALTER TABLE cita        DROP CONSTRAINT fk_cita_veterinario;
ALTER TABLE tratamiento DROP CONSTRAINT fk_tratamiento_cita;

ALTER TABLE dueno       ALTER COLUMN codigo_dueno        TYPE d_codigo;
ALTER TABLE mascota     ALTER COLUMN codigo_mascota      TYPE d_codigo;
ALTER TABLE mascota     ALTER COLUMN codigo_dueno        TYPE d_codigo;
ALTER TABLE veterinario ALTER COLUMN codigo_veterinario  TYPE d_codigo;
ALTER TABLE cita        ALTER COLUMN codigo_mascota      TYPE d_codigo;
ALTER TABLE cita        ALTER COLUMN codigo_cita         TYPE d_codigo;
ALTER TABLE cita        ALTER COLUMN codigo_veterinario  TYPE d_codigo;
ALTER TABLE tratamiento ALTER COLUMN codigo_tratamiento  TYPE d_codigo;
ALTER TABLE tratamiento ALTER COLUMN codigo_mascota      TYPE d_codigo;
ALTER TABLE tratamiento ALTER COLUMN codigo_cita         TYPE d_codigo;

ALTER TABLE dueno       ALTER COLUMN nombre     TYPE d_nombre;
ALTER TABLE mascota     ALTER COLUMN nombre     TYPE d_nombre;
ALTER TABLE veterinario ALTER COLUMN nombre     TYPE d_nombre;
ALTER TABLE dueno       ALTER COLUMN apellidos  TYPE d_apellidos;
ALTER TABLE veterinario ALTER COLUMN apellidos  TYPE d_apellidos;

-- ck_cita_codigo (codigo_cita > 0) queda cubierta por d_codigo: se quita para
-- no tener la misma regla escrita dos veces.
ALTER TABLE cita DROP CONSTRAINT ck_cita_codigo;

-- Se recrean las claves foráneas exactamente como estaban.
ALTER TABLE mascota ADD CONSTRAINT fk_mascota_dueno FOREIGN KEY (codigo_dueno)
    REFERENCES dueno (codigo_dueno) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE cita ADD CONSTRAINT fk_cita_mascota FOREIGN KEY (codigo_mascota)
    REFERENCES mascota (codigo_mascota) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE cita ADD CONSTRAINT fk_cita_veterinario FOREIGN KEY (codigo_veterinario)
    REFERENCES veterinario (codigo_veterinario) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE tratamiento ADD CONSTRAINT fk_tratamiento_cita FOREIGN KEY (codigo_mascota, codigo_cita)
    REFERENCES cita (codigo_mascota, codigo_cita) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;

-- =============================================================================
-- Migración 002-referencias.sql
-- Declara con ALTER TABLE las claves foráneas del proyecto propio (Clínica Veterinaria)
-- y agrega la columna de estado para el borrado lógico del Ejercicio 2.4.3.
-- =============================================================================

BEGIN;

ALTER TABLE mascota
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE veterinario
    ADD COLUMN IF NOT EXISTS activo BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE mascota DROP CONSTRAINT IF EXISTS fk_mascota_dueno;
ALTER TABLE mascota
    ADD CONSTRAINT fk_mascota_dueno
    FOREIGN KEY (codigo_dueno) REFERENCES dueno (codigo_dueno)
    ON DELETE SET NULL
    ON UPDATE CASCADE;

ALTER TABLE cita DROP CONSTRAINT IF EXISTS fk_cita_mascota;
ALTER TABLE cita
    ADD CONSTRAINT fk_cita_mascota
    FOREIGN KEY (codigo_mascota) REFERENCES mascota (codigo_mascota)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

ALTER TABLE cita DROP CONSTRAINT IF EXISTS fk_cita_veterinario;
ALTER TABLE cita
    ADD CONSTRAINT fk_cita_veterinario
    FOREIGN KEY (codigo_veterinario) REFERENCES veterinario (codigo_veterinario)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

ALTER TABLE tratamiento DROP CONSTRAINT IF EXISTS fk_tratamiento_cita;
ALTER TABLE tratamiento
    ADD CONSTRAINT fk_tratamiento_cita
    FOREIGN KEY (codigo_mascota, codigo_cita) REFERENCES cita (codigo_mascota, codigo_cita)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

COMMIT;

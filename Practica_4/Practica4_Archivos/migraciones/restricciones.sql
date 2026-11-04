-- Migración 002 · Práctica 4, ejercicio 1.2: restricciones de columna
-- Se ejecuta DESPUÉS de dominios.sql.
BEGIN;

-- (Los DEFAULT es_dermatologo/es_cirujano = FALSE ya existen desde la Práctica 3.)

-- ---------- CHECK de formato ----------
-- Correo con una sola arroba, sin espacios, y un punto en el dominio.
ALTER TABLE dueno ADD CONSTRAINT ck_dueno_correo
    CHECK (correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$');

-- Un tratamiento sin descripción real no sirve de nada.
ALTER TABLE tratamiento ADD CONSTRAINT ck_tratamiento_descripcion
    CHECK (descripcion ~ '[^[:space:]]');

-- ---------- CHECK entre columnas ----------
-- Un diagnóstico, si existe, no puede estar en blanco.
ALTER TABLE cita ADD CONSTRAINT ck_cita_diagnostico
    CHECK (diagnostico IS NULL OR diagnostico ~ '[^[:space:]]');

-- ---------- UNIQUE compuesto ----------
-- Un veterinario no puede tener dos citas el mismo día a la misma hora.
ALTER TABLE cita ADD CONSTRAINT uq_cita_veterinario_fecha_hora
    UNIQUE (codigo_veterinario, fecha, hora);

COMMIT;
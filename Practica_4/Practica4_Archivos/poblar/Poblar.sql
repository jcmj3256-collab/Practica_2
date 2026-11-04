-- =====================================================================
-- poblar.sql · Práctica 4, ejercicio 1.4. Carga la base con un solo comando:
--
--   (desde la carpeta practica4)   psql -v ON_ERROR_STOP=1 -f poblar/poblar.sql
--
-- Conexión: variables de entorno estándar de PostgreSQL, sin contraseñas aquí:
--   PGHOST  PGPORT  PGDATABASE  PGUSER  PGPASSWORD
-- Opción para comparar tiempos:  psql -v vaciar=1 -f poblar/poblar.sql
--   (vacía las 5 tablas antes de cargar)
--
-- Ordenado:    dueno, veterinario, mascota, cita, tratamiento.
-- Repetible:   ON CONFLICT DO NOTHING (lo que ya existe se omite).
-- Todo o nada: una sola transacción; con ON_ERROR_STOP el primer error detiene
--              el script y se revierte todo (psql dice la línea y el motivo).
-- Con cuentas: tabla final con leídos / insertados / ya existían / rechazados.
-- Eficiente:   \copy (carga masiva) a una tabla temporal.
-- =====================================================================
\set ON_ERROR_STOP on
\set QUIET on
SELECT clock_timestamp() AS t0 \gset

BEGIN;

CREATE TEMP TABLE cuentas (tabla text, leidos int, insertados int) ON COMMIT DROP;

\if :{?vaciar}
  TRUNCATE tratamiento, cita, mascota, veterinario, dueno;
  \echo 'Tablas vaciadas.'
\endif

\echo '>> Cargando dueno'
CREATE TEMP TABLE stg (LIKE dueno) ON COMMIT DROP;
\copy stg (codigo_dueno,nombre,apellidos,correo,telefono,direccion) FROM 'datos/dueno.csv' WITH (FORMAT csv, HEADER true)
WITH ins AS (
  INSERT INTO dueno (codigo_dueno,nombre,apellidos,correo,telefono,direccion)
  SELECT codigo_dueno,nombre,apellidos,correo,telefono,direccion FROM stg
  ON CONFLICT DO NOTHING RETURNING 1)
INSERT INTO cuentas SELECT 'dueno', (SELECT count(*) FROM stg), (SELECT count(*) FROM ins);
DROP TABLE stg;

\echo '>> Cargando veterinario'
CREATE TEMP TABLE stg (LIKE veterinario) ON COMMIT DROP;
\copy stg (codigo_veterinario,nombre,apellidos,num_certificado,es_dermatologo,num_pacientes,es_cirujano,num_cirugias) FROM 'datos/veterinario.csv' WITH (FORMAT csv, HEADER true)
WITH ins AS (
  INSERT INTO veterinario (codigo_veterinario,nombre,apellidos,num_certificado,es_dermatologo,num_pacientes,es_cirujano,num_cirugias)
  SELECT codigo_veterinario,nombre,apellidos,num_certificado,es_dermatologo,num_pacientes,es_cirujano,num_cirugias FROM stg
  ON CONFLICT DO NOTHING RETURNING 1)
INSERT INTO cuentas SELECT 'veterinario', (SELECT count(*) FROM stg), (SELECT count(*) FROM ins);
DROP TABLE stg;

\echo '>> Cargando mascota'
CREATE TEMP TABLE stg (LIKE mascota) ON COMMIT DROP;
\copy stg (codigo_mascota,nombre,especie,raza,edad,sexo,notas,color_pelaje,peso_ideal,codigo_dueno) FROM 'datos/mascota.csv' WITH (FORMAT csv, HEADER true)
WITH ins AS (
  INSERT INTO mascota (codigo_mascota,nombre,especie,raza,edad,sexo,notas,color_pelaje,peso_ideal,codigo_dueno)
  SELECT codigo_mascota,nombre,especie,raza,edad,sexo,notas,color_pelaje,peso_ideal,codigo_dueno FROM stg
  ON CONFLICT DO NOTHING RETURNING 1)
INSERT INTO cuentas SELECT 'mascota', (SELECT count(*) FROM stg), (SELECT count(*) FROM ins);
DROP TABLE stg;

\echo '>> Cargando cita'
CREATE TEMP TABLE stg (LIKE cita) ON COMMIT DROP;
\copy stg (codigo_mascota,codigo_cita,fecha,hora,notas,diagnostico,codigo_veterinario) FROM 'datos/cita.csv' WITH (FORMAT csv, HEADER true)
WITH ins AS (
  INSERT INTO cita (codigo_mascota,codigo_cita,fecha,hora,notas,diagnostico,codigo_veterinario)
  SELECT codigo_mascota,codigo_cita,fecha,hora,notas,diagnostico,codigo_veterinario FROM stg
  ON CONFLICT DO NOTHING RETURNING 1)
INSERT INTO cuentas SELECT 'cita', (SELECT count(*) FROM stg), (SELECT count(*) FROM ins);
DROP TABLE stg;

\echo '>> Cargando tratamiento'
CREATE TEMP TABLE stg (LIKE tratamiento) ON COMMIT DROP;
\copy stg (codigo_tratamiento,descripcion,fecha_tratamiento,fecha_vencimiento,codigo_mascota,codigo_cita) FROM 'datos/tratamiento.csv' WITH (FORMAT csv, HEADER true)
WITH ins AS (
  INSERT INTO tratamiento (codigo_tratamiento,descripcion,fecha_tratamiento,fecha_vencimiento,codigo_mascota,codigo_cita)
  SELECT codigo_tratamiento,descripcion,fecha_tratamiento,fecha_vencimiento,codigo_mascota,codigo_cita FROM stg
  ON CONFLICT DO NOTHING RETURNING 1)
INSERT INTO cuentas SELECT 'tratamiento', (SELECT count(*) FROM stg), (SELECT count(*) FROM ins);
DROP TABLE stg;

\echo
SELECT tabla, leidos AS "leídos", insertados,
       leidos - insertados AS "ya existían", 0 AS rechazados
FROM cuentas ORDER BY array_position(ARRAY['dueno','veterinario','mascota','cita','tratamiento'], tabla);

COMMIT;

SELECT round(extract(epoch FROM clock_timestamp() - :'t0'::timestamptz)::numeric, 3) AS "segundos (COPY)";
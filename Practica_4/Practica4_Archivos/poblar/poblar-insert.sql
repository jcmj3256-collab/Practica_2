
-- poblar-insert.sql · SOLO para comparar tiempos con poblar.sql.
-- Carga lo mismo, pero con UN INSERT por renglón en lugar de \copy.
--   psql -v vaciar=1 -f poblar/poblar-insert.sql
-- Cada INSERT se ejecuta como una sentencia aparte (un viaje al servidor por
-- renglón). Los INSERT se generan con psql a partir de los mismos CSV.

\set ON_ERROR_STOP on
\set QUIET on
\pset tuples_only on
SELECT clock_timestamp() AS t0 \gset
BEGIN;
\if :{?vaciar}
  TRUNCATE tratamiento, cita, mascota, veterinario, dueno;
\endif
CREATE TEMP TABLE stg (LIKE dueno) ON COMMIT DROP;
\copy stg FROM 'datos/csv/dueno.csv' WITH (FORMAT csv, HEADER true)
\o /tmp/inserts_dueno.sql
SELECT format('INSERT INTO dueno SELECT * FROM jsonb_populate_record(NULL::dueno, %L) ON CONFLICT DO NOTHING;', to_jsonb(stg)::text) FROM stg;
\o
\i /tmp/inserts_dueno.sql
DROP TABLE stg;

CREATE TEMP TABLE stg (LIKE veterinario) ON COMMIT DROP;
\copy stg FROM 'datos/csv/veterinario.csv' WITH (FORMAT csv, HEADER true)
\o /tmp/inserts_veterinario.sql
SELECT format('INSERT INTO veterinario SELECT * FROM jsonb_populate_record(NULL::veterinario, %L) ON CONFLICT DO NOTHING;', to_jsonb(stg)::text) FROM stg;
\o
\i /tmp/inserts_veterinario.sql
DROP TABLE stg;

CREATE TEMP TABLE stg (LIKE mascota) ON COMMIT DROP;
\copy stg FROM 'datos/csv/mascota.csv' WITH (FORMAT csv, HEADER true)
\o /tmp/inserts_mascota.sql
SELECT format('INSERT INTO mascota SELECT * FROM jsonb_populate_record(NULL::mascota, %L) ON CONFLICT DO NOTHING;', to_jsonb(stg)::text) FROM stg;
\o
\i /tmp/inserts_mascota.sql
DROP TABLE stg;

CREATE TEMP TABLE stg (LIKE cita) ON COMMIT DROP;
\copy stg FROM 'datos/csv/cita.csv' WITH (FORMAT csv, HEADER true)
\o /tmp/inserts_cita.sql
SELECT format('INSERT INTO cita SELECT * FROM jsonb_populate_record(NULL::cita, %L) ON CONFLICT DO NOTHING;', to_jsonb(stg)::text) FROM stg;
\o
\i /tmp/inserts_cita.sql
DROP TABLE stg;

CREATE TEMP TABLE stg (LIKE tratamiento) ON COMMIT DROP;
\copy stg FROM 'datos/csv/tratamiento.csv' WITH (FORMAT csv, HEADER true)
\o /tmp/inserts_tratamiento.sql
SELECT format('INSERT INTO tratamiento SELECT * FROM jsonb_populate_record(NULL::tratamiento, %L) ON CONFLICT DO NOTHING;', to_jsonb(stg)::text) FROM stg;
\o
\i /tmp/inserts_tratamiento.sql
DROP TABLE stg;
COMMIT;
\pset tuples_only off
SELECT round(extract(epoch FROM clock_timestamp() - :'t0'::timestamptz)::numeric, 3) AS "segundos (INSERT por renglón)";
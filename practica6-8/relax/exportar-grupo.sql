-- =====================================================================
-- Ejercicio 2.1 · Exporta una muestra de la base al formato de grupo de RelaX.
-- Uso:  psql -q -X -A -t -v ON_ERROR_STOP=1 -f exportar-grupo.sql > grupo.txt
-- (o simplemente ./exportar-grupo.sh)
--
-- 1) Arma la muestra en el esquema `relax_muestra` (10 a 30 filas por tabla,
--    integridad referencial completa: cada FK apunta a una fila que SÍ está).
-- 2) Imprime esa muestra como texto de RelaX.
-- Las consultas SQL de la Parte 2 se ejecutan sobre ese MISMO esquema, así el
-- resultado de RelaX y el del gestor se pueden comparar fila por fila.
-- La selección es determinista (siempre las mismas filas mientras no cambien los datos).
-- =====================================================================
\set QUIET on
DROP SCHEMA IF EXISTS relax_muestra CASCADE;
CREATE SCHEMA relax_muestra;

-- Tratamientos: los 12 primeros por código.
CREATE TABLE relax_muestra.tratamiento AS
SELECT * FROM public.tratamiento ORDER BY codigo_tratamiento LIMIT 12;

-- Citas: las de esos tratamientos + 14 más (las primeras por clave).
CREATE TABLE relax_muestra.cita AS
SELECT * FROM public.cita c
WHERE (c.codigo_mascota, c.codigo_cita) IN
        (SELECT codigo_mascota, codigo_cita FROM relax_muestra.tratamiento)
   OR (c.codigo_mascota, c.codigo_cita) IN
        (SELECT codigo_mascota, codigo_cita FROM public.cita ORDER BY codigo_mascota, codigo_cita LIMIT 14);

-- Mascotas: las de esas citas + 3 sin citas en la muestra (para mostrar reuniones externas).
CREATE TABLE relax_muestra.mascota AS
SELECT * FROM public.mascota m
WHERE m.codigo_mascota IN (SELECT codigo_mascota FROM relax_muestra.cita)
   OR m.codigo_mascota IN (
        SELECT codigo_mascota FROM public.mascota
        WHERE codigo_mascota NOT IN (SELECT codigo_mascota FROM relax_muestra.cita)
          AND codigo_dueno IS NOT NULL
        ORDER BY codigo_mascota LIMIT 3);

-- Dueños: los de esas mascotas + 3 sin mascotas en la muestra.
CREATE TABLE relax_muestra.dueno AS
SELECT * FROM public.dueno d
WHERE d.codigo_dueno IN (SELECT codigo_dueno FROM relax_muestra.mascota)
   OR d.codigo_dueno IN (
        SELECT codigo_dueno FROM public.dueno
        WHERE codigo_dueno NOT IN (SELECT codigo_dueno FROM public.mascota
                                   WHERE codigo_mascota IN (SELECT codigo_mascota FROM relax_muestra.mascota)
                                     AND codigo_dueno IS NOT NULL)
        ORDER BY codigo_dueno LIMIT 3);

-- Veterinarios: los de esas citas + 3 sin citas en la muestra.
CREATE TABLE relax_muestra.veterinario AS
SELECT * FROM public.veterinario v
WHERE v.codigo_veterinario IN (SELECT codigo_veterinario FROM relax_muestra.cita)
   OR v.codigo_veterinario IN (
        SELECT codigo_veterinario FROM public.veterinario
        WHERE codigo_veterinario NOT IN (SELECT codigo_veterinario FROM relax_muestra.cita)
        ORDER BY codigo_veterinario LIMIT 3);

-- Comprobación: integridad referencial y tamaño (si falla, el script se detiene).
DO $$
DECLARE n INT; t TEXT;
BEGIN
  SELECT count(*) INTO n FROM relax_muestra.mascota m
   WHERE m.codigo_dueno IS NOT NULL AND m.codigo_dueno NOT IN (SELECT codigo_dueno FROM relax_muestra.dueno);
  IF n > 0 THEN RAISE EXCEPTION 'mascota apunta a dueño fuera de la muestra'; END IF;
  SELECT count(*) INTO n FROM relax_muestra.cita c
   WHERE (c.codigo_mascota NOT IN (SELECT codigo_mascota FROM relax_muestra.mascota))
      OR (c.codigo_veterinario NOT IN (SELECT codigo_veterinario FROM relax_muestra.veterinario));
  IF n > 0 THEN RAISE EXCEPTION 'cita apunta a mascota o veterinario fuera de la muestra'; END IF;
  SELECT count(*) INTO n FROM relax_muestra.tratamiento t
   WHERE (t.codigo_mascota, t.codigo_cita) NOT IN (SELECT codigo_mascota, codigo_cita FROM relax_muestra.cita);
  IF n > 0 THEN RAISE EXCEPTION 'tratamiento apunta a cita fuera de la muestra'; END IF;
  FOREACH t IN ARRAY ARRAY['dueno','mascota','veterinario','cita','tratamiento'] LOOP
    EXECUTE format('SELECT count(*) FROM relax_muestra.%I', t) INTO n;
    IF n < 10 OR n > 30 THEN RAISE EXCEPTION 'la tabla % tiene % filas (debe tener de 10 a 30)', t, n; END IF;
  END LOOP;
END $$;

-- Funciones auxiliares (temporales) para escribir valores en sintaxis de RelaX:
--   texto entre comillas simples (la comilla simple se cambia por ’ porque RelaX no documenta escape),
--   null sin comillas, fechas y números tal cual.
CREATE FUNCTION pg_temp.q(t text) RETURNS text LANGUAGE sql IMMUTABLE AS
$$ SELECT CASE WHEN t IS NULL THEN 'null' ELSE '''' || replace(replace(t, '''', '’'), E'\n', ' ') || '''' END $$;
CREATE FUNCTION pg_temp.v(t text) RETURNS text LANGUAGE sql IMMUTABLE AS
$$ SELECT coalesce(t, 'null') $$;

\t on
\pset format unaligned
\pset tuples_only on

SELECT 'group: Clinica veterinaria (muestra)';
SELECT 'description[[ Muestra generada por exportar-grupo.sql desde la base de la clinica. No editar a mano. ]]';
SELECT '';

SELECT 'dueno = { codigo_dueno:number, nombre:string, apellidos:string, correo:string, telefono:string, direccion:string';
SELECT pg_temp.v(codigo_dueno::text) || ', ' || pg_temp.q(nombre) || ', ' || pg_temp.q(apellidos) || ', ' ||
       pg_temp.q(correo) || ', ' || pg_temp.q(telefono) || ', ' || pg_temp.q(direccion)
FROM relax_muestra.dueno ORDER BY codigo_dueno;
SELECT '}';
SELECT '';

SELECT 'mascota = { codigo_mascota:number, nombre:string, especie:string, raza:string, edad:number, sexo:string, notas:string, color_pelaje:string, peso_ideal:number, codigo_dueno:number';
SELECT pg_temp.v(codigo_mascota::text) || ', ' || pg_temp.q(nombre) || ', ' || pg_temp.q(especie) || ', ' ||
       pg_temp.q(raza) || ', ' || pg_temp.v(edad::text) || ', ' || pg_temp.q(sexo) || ', ' || pg_temp.q(notas) || ', ' ||
       pg_temp.q(color_pelaje) || ', ' || pg_temp.v(peso_ideal::text) || ', ' || pg_temp.v(codigo_dueno::text)
FROM relax_muestra.mascota ORDER BY codigo_mascota;
SELECT '}';
SELECT '';

SELECT 'veterinario = { codigo_veterinario:number, nombre:string, apellidos:string, num_certificado:string, es_dermatologo:boolean, num_pacientes:number, es_cirujano:boolean, num_cirugias:number';
SELECT pg_temp.v(codigo_veterinario::text) || ', ' || pg_temp.q(nombre) || ', ' || pg_temp.q(apellidos) || ', ' ||
       pg_temp.q(num_certificado) || ', ' || pg_temp.v(es_dermatologo::text) || ', ' || pg_temp.v(num_pacientes::text) || ', ' ||
       pg_temp.v(es_cirujano::text) || ', ' || pg_temp.v(num_cirugias::text)
FROM relax_muestra.veterinario ORDER BY codigo_veterinario;
SELECT '}';
SELECT '';

SELECT 'cita = { codigo_mascota:number, codigo_cita:number, fecha:date, hora:string, notas:string, diagnostico:string, codigo_veterinario:number';
SELECT pg_temp.v(codigo_mascota::text) || ', ' || pg_temp.v(codigo_cita::text) || ', ' || pg_temp.v(fecha::text) || ', ' ||
       pg_temp.q(to_char(hora, 'HH24:MI')) || ', ' || pg_temp.q(notas) || ', ' || pg_temp.q(diagnostico) || ', ' ||
       pg_temp.v(codigo_veterinario::text)
FROM relax_muestra.cita ORDER BY codigo_mascota, codigo_cita;
SELECT '}';
SELECT '';

SELECT 'tratamiento = { codigo_tratamiento:number, descripcion:string, fecha_tratamiento:date, fecha_vencimiento:date, codigo_mascota:number, codigo_cita:number';
SELECT pg_temp.v(codigo_tratamiento::text) || ', ' || pg_temp.q(descripcion) || ', ' || pg_temp.v(fecha_tratamiento::text) || ', ' ||
       pg_temp.v(fecha_vencimiento::text) || ', ' || pg_temp.v(codigo_mascota::text) || ', ' || pg_temp.v(codigo_cita::text)
FROM relax_muestra.tratamiento ORDER BY codigo_tratamiento;
SELECT '}';

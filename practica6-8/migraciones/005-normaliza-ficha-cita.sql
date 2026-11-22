-- =====================================================================
-- Migración 005 · Práctica 6, ejercicio 1.3.4: llevar ficha_cita_legacy a 3FN/BCNF
-- Los renglones se MUEVEN con INSERT ... SELECT; no se vuelven a capturar.
-- Descomposición (ver normalizacion.md §3):
--   R1 cita(codigo_mascota, codigo_cita, fecha, hora, diagnostico, codigo_veterinario)
--   R2 mascota(codigo_mascota, nombre, especie, sexo, codigo_dueno)
--   R3 dueno(codigo_dueno, nombre, apellidos, correo, telefono, direccion)
--   R4 veterinario(codigo_veterinario, nombre, apellidos, num_certificado)
-- R1..R4 ya existen: son las tablas del esquema. Se insertan primero las
-- tablas "padre" para respetar las claves foráneas.
-- Todo en una transacción: si la comprobación final falla, no queda nada.
-- =====================================================================
BEGIN;

CREATE TEMP TABLE conteo_antes AS
SELECT (SELECT count(*) FROM dueno)       AS dueno,
       (SELECT count(*) FROM veterinario) AS veterinario,
       (SELECT count(*) FROM mascota)     AS mascota,
       (SELECT count(*) FROM cita)        AS cita;

INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
SELECT DISTINCT codigo_dueno, nombre_dueno, apellidos_dueno, correo_dueno, telefono_dueno, direccion_dueno
FROM ficha_cita_legacy;

INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
SELECT DISTINCT codigo_veterinario, nombre_vet, apellidos_vet, num_certificado
FROM ficha_cita_legacy;

INSERT INTO mascota (codigo_mascota, nombre, especie, sexo, codigo_dueno)
SELECT DISTINCT codigo_mascota, nombre_mascota, especie, sexo, codigo_dueno
FROM ficha_cita_legacy;

INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, diagnostico, codigo_veterinario)
SELECT codigo_mascota, codigo_cita, fecha, hora, diagnostico, codigo_veterinario
FROM ficha_cita_legacy;

-- Comprobación de reunión sin pérdida con los datos: reunir R1..R4 debe dar
-- exactamente la tabla original (ni filas de más ni de menos).
DO $$
DECLARE sobran INT; faltan INT;
BEGIN
  SELECT count(*) INTO sobran FROM (
    SELECT c.codigo_mascota, c.codigo_cita, c.fecha, c.hora, c.diagnostico,
           m.nombre, m.especie, m.sexo, d.codigo_dueno, d.nombre, d.apellidos,
           d.correo, d.telefono, d.direccion, v.codigo_veterinario, v.nombre,
           v.apellidos, v.num_certificado
    FROM cita c
    JOIN mascota m     ON m.codigo_mascota = c.codigo_mascota
    JOIN dueno d       ON d.codigo_dueno = m.codigo_dueno
    JOIN veterinario v ON v.codigo_veterinario = c.codigo_veterinario
    WHERE (c.codigo_mascota, c.codigo_cita) IN (SELECT codigo_mascota, codigo_cita FROM ficha_cita_legacy)
    EXCEPT
    SELECT * FROM ficha_cita_legacy) x;
  SELECT count(*) INTO faltan FROM (
    SELECT * FROM ficha_cita_legacy
    EXCEPT
    SELECT c.codigo_mascota, c.codigo_cita, c.fecha, c.hora, c.diagnostico,
           m.nombre, m.especie, m.sexo, d.codigo_dueno, d.nombre, d.apellidos,
           d.correo, d.telefono, d.direccion, v.codigo_veterinario, v.nombre,
           v.apellidos, v.num_certificado
    FROM cita c
    JOIN mascota m     ON m.codigo_mascota = c.codigo_mascota
    JOIN dueno d       ON d.codigo_dueno = m.codigo_dueno
    JOIN veterinario v ON v.codigo_veterinario = c.codigo_veterinario) y;
  IF sobran <> 0 OR faltan <> 0 THEN
    RAISE EXCEPTION 'La reunión no reproduce la tabla original (sobran %, faltan %)', sobran, faltan;
  END IF;
  RAISE NOTICE 'Reunión sin pérdida comprobada: 0 filas de más, 0 filas de menos.';
END $$;

-- La tabla vieja se sustituye por una vista con el mismo nombre de uso:
-- los reportes que la leían siguen funcionando, pero ya no guarda datos repetidos.
DROP TABLE ficha_cita_legacy;
CREATE VIEW ficha_cita AS
SELECT c.codigo_mascota, c.codigo_cita, c.fecha, c.hora, c.diagnostico,
       m.nombre AS nombre_mascota, m.especie, m.sexo,
       d.codigo_dueno, d.nombre AS nombre_dueno, d.apellidos AS apellidos_dueno,
       d.correo AS correo_dueno, d.telefono AS telefono_dueno, d.direccion AS direccion_dueno,
       v.codigo_veterinario, v.nombre AS nombre_vet, v.apellidos AS apellidos_vet, v.num_certificado
FROM cita c
JOIN mascota m      ON m.codigo_mascota = c.codigo_mascota
LEFT JOIN dueno d   ON d.codigo_dueno = m.codigo_dueno   -- una mascota puede no tener dueño
JOIN veterinario v  ON v.codigo_veterinario = c.codigo_veterinario;

SELECT 'dueno' AS tabla, a.dueno AS antes, (SELECT count(*) FROM dueno) AS despues FROM conteo_antes a
UNION ALL SELECT 'veterinario', a.veterinario, (SELECT count(*) FROM veterinario) FROM conteo_antes a
UNION ALL SELECT 'mascota', a.mascota, (SELECT count(*) FROM mascota) FROM conteo_antes a
UNION ALL SELECT 'cita', a.cita, (SELECT count(*) FROM cita) FROM conteo_antes a;

COMMIT;

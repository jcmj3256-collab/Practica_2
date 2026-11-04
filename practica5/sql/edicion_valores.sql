-- =============================================================================
-- Ejercicio 2.4: Edición de valores y transacciones
-- =============================================================================

-- 1a. INSERT que toma sus valores de una consulta
INSERT INTO tratamiento (
    codigo_tratamiento,
    descripcion,
    fecha_tratamiento,
    fecha_vencimiento,
    codigo_mascota,
    codigo_cita
)
SELECT
    1000 + (c.codigo_mascota * 10) + c.codigo_cita,
    'Desparasitación interna preventiva de amplio espectro',
    c.fecha,
    (c.fecha + INTERVAL '180 days')::DATE,
    c.codigo_mascota,
    c.codigo_cita
FROM cita c
LEFT JOIN tratamiento t
    ON c.codigo_mascota = t.codigo_mascota
   AND c.codigo_cita = t.codigo_cita
WHERE c.diagnostico ILIKE '%Control preventivo%'
  AND t.codigo_tratamiento IS NULL;

-- 1b. Inserción que resuelve el caso de que el renglón ya exista (ON CONFLICT)
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (1, 'Carlos', 'Mendoza Ríos', 'carlos.mendoza@correo.mx', '5512349999', 'Av. Politécnico 2508, GAM, CDMX')
ON CONFLICT (correo)
DO UPDATE SET
    telefono  = EXCLUDED.telefono,
    direccion = EXCLUDED.direccion;

-- 2a. UPDATE que depende de otra tabla
UPDATE mascota m
SET notas = 'Paciente en seguimiento postoperatorio (atendido por Dr. ' || v.apellidos || ')'
FROM cita c
JOIN veterinario v ON c.codigo_veterinario = v.codigo_veterinario
WHERE m.codigo_mascota = c.codigo_mascota
  AND v.es_cirujano = TRUE
  AND c.diagnostico ILIKE '%Cirug%';

-- 2b. UPDATE que clasifica con CASE
UPDATE mascota
SET notas = CASE
    WHEN edad IS NULL THEN 'Edad pendiente de valoración clínica'
    WHEN edad <= 1 THEN 'Etapa: Cachorro / Cría (esquema de vacunación inicial)'
    WHEN edad BETWEEN 2 AND 7 THEN 'Etapa: Adulto (revisión anual estándar)'
    WHEN edad >= 8 THEN 'Etapa: Geriátrico / Senior (perfil bioquímico semestral)'
END;

-- 3a. DELETE con subconsulta
DELETE FROM tratamiento
WHERE fecha_vencimiento < (CURRENT_DATE - INTERVAL '1 year')::DATE
  AND codigo_mascota IN (
      SELECT codigo_mascota
      FROM mascota
      WHERE codigo_dueno IS NULL
  );

-- 3b. Borrado lógico
UPDATE mascota
SET activo = FALSE,
    notas = COALESCE(notas, '') || ' [Baja lógica del padrón activo]'
WHERE codigo_mascota = 103;

-- 4. Transacción que toca dos o más tablas con SAVEPOINT, reversión parcial y COMMIT
BEGIN;

INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, notas, diagnostico, codigo_veterinario)
VALUES (101, 50, '2026-11-01', '11:00:00', 'Ingreso por infección dérmica', 'Dermatitis bacteriana aguda', 1);

INSERT INTO tratamiento (codigo_tratamiento, descripcion, fecha_tratamiento, fecha_vencimiento, codigo_mascota, codigo_cita)
VALUES (5001, 'Cefalexina 250mg cada 12 horas por 10 días', '2026-11-01', '2026-11-11', 101, 50);

SAVEPOINT sp_tratamiento_opcional;

INSERT INTO tratamiento (codigo_tratamiento, descripcion, fecha_tratamiento, fecha_vencimiento, codigo_mascota, codigo_cita)
VALUES (5002, 'Terapia láser dermatológica de 4 sesiones', '2026-11-01', '2026-11-30', 101, 50);

UPDATE mascota SET notas = 'En terapia láser' WHERE codigo_mascota = 101;

ROLLBACK TO SAVEPOINT sp_tratamiento_opcional;

COMMIT;

-- 5. Transacción que falla a la mitad por violar una restricción (ck_tratamiento_fechas)
BEGIN;

INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, notas, diagnostico, codigo_veterinario)
VALUES (101, 51, '2026-11-01', '12:00:00', 'Chequeo dental', 'Gingivitis leve', 1);

INSERT INTO tratamiento (codigo_tratamiento, descripcion, fecha_tratamiento, fecha_vencimiento, codigo_mascota, codigo_cita)
VALUES (5003, 'Antiséptico bucal canino', '2026-11-01', '2026-10-01', 101, 51);

ROLLBACK;

SELECT COUNT(*) AS citas_51_tras_rollback
FROM cita
WHERE codigo_mascota = 101 AND codigo_cita = 51;

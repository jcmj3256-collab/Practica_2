-- =============================================================================
-- Ejercicio 2.3: Pruebas de integridad referencial
-- =============================================================================

BEGIN;

INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion) VALUES
    (1,  'Carlos',  'Mendoza Ríos',   'carlos.mendoza@correo.mx',  '5511223344', 'Av. IPN 2580, GAM, CDMX'),
    (2,  'Elena',   'Soto Juárez',    'elena.soto@correo.mx',      '5522334455', 'Calle Lindavista 102, GAM, CDMX'),
    (10, 'Roberto', 'Vargas Pineda',  'roberto.vargas@correo.mx',  '5599887766', 'Av. Montevideo 45, GAM, CDMX')
ON CONFLICT (codigo_dueno) DO NOTHING;

INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado, es_dermatologo, num_pacientes, es_cirujano, num_cirugias) VALUES
    (1, 'Laura',   'Gómez Trejo',   'CED-VET-1001', TRUE,  45, TRUE,  20),
    (2, 'Andrés',  'Peralta Ruiz',  'CED-VET-1002', FALSE, NULL, TRUE, 35),
    (3, 'Mariana', 'Núñez Solís',   'CED-VET-1003', TRUE,  60, FALSE, NULL)
ON CONFLICT (codigo_veterinario) DO NOTHING;

INSERT INTO mascota (codigo_mascota, nombre, especie, raza, edad, sexo, notas, color_pelaje, peso_ideal, codigo_dueno) VALUES
    (101, 'Michi',   'Gato',  'Europeo doméstico', 3, 'M', 'Paciente regular',        'Atigrado gris', NULL, 10),
    (102, 'Thor',    'Perro', 'Pastor Alemán',     5, 'M', 'Paciente de prueba B',    NULL,            32,   1),
    (103, 'Luna',    'Gato',  'Siamés',            2, 'H', 'Rescatada en parque',     'Crema y café',  NULL, NULL),
    (104, 'Max',     'Perro', 'Labrador',          9, 'M', 'Seguimiento geriátrico',  NULL,            28,   2)
ON CONFLICT (codigo_mascota) DO NOTHING;

INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, notas, diagnostico, codigo_veterinario) VALUES
    (101, 1, '2026-10-10', '09:00:00', 'Revisión anual',          'Control preventivo',         1),
    (102, 1, '2026-10-12', '10:30:00', 'Dolor articular',         'Displasia leve',             1),
    (102, 2, '2026-10-20', '16:00:00', 'Control de dolor',        'Mejoría articular',          2),
    (103, 1, '2026-01-10', '11:00:00', 'Ingreso de rescate',      'Deshidratación leve',        2),
    (104, 1, '2026-10-25', '13:00:00', 'Intervención programada', 'Cirugía de lipoma benigno',  2)
ON CONFLICT (codigo_mascota, codigo_cita) DO NOTHING;

INSERT INTO tratamiento (codigo_tratamiento, descripcion, fecha_tratamiento, fecha_vencimiento, codigo_mascota, codigo_cita) VALUES
    (201, 'Condroprotector oral 1 tableta diaria', '2026-10-12', '2026-11-12', 102, 1),
    (202, 'Analgésico antiinflamatorio 5 días',    '2026-10-20', '2026-10-25', 102, 2),
    (203, 'Suero oral rehidratante',               '2025-01-10', '2025-01-15', 103, 1)
ON CONFLICT (codigo_tratamiento) DO NOTHING;

COMMIT;

-- 1A. Prueba ON DELETE SET NULL (dueno -> mascota)
SELECT 'ANTES ON DELETE SET NULL' AS etapa,
       (SELECT COUNT(*) FROM dueno WHERE codigo_dueno = 10) AS dueno_10,
       (SELECT COUNT(*) FROM mascota WHERE codigo_mascota = 101 AND codigo_dueno IS NULL) AS mascota_101_sin_dueno;

DELETE FROM dueno WHERE codigo_dueno = 10;

SELECT 'DESPUÉS ON DELETE SET NULL' AS etapa,
       (SELECT COUNT(*) FROM dueno WHERE codigo_dueno = 10) AS dueno_10,
       (SELECT COUNT(*) FROM mascota WHERE codigo_mascota = 101 AND codigo_dueno IS NULL) AS mascota_101_sin_dueno;

-- 1B. Prueba ON DELETE CASCADE (mascota -> cita -> tratamiento)
SELECT 'ANTES ON DELETE CASCADE' AS etapa,
       (SELECT COUNT(*) FROM mascota WHERE codigo_mascota = 102) AS mascota_102,
       (SELECT COUNT(*) FROM cita WHERE codigo_mascota = 102) AS citas_102,
       (SELECT COUNT(*) FROM tratamiento WHERE codigo_mascota = 102) AS tratamientos_102;

DELETE FROM mascota WHERE codigo_mascota = 102;

SELECT 'DESPUÉS ON DELETE CASCADE' AS etapa,
       (SELECT COUNT(*) FROM mascota WHERE codigo_mascota = 102) AS mascota_102,
       (SELECT COUNT(*) FROM cita WHERE codigo_mascota = 102) AS citas_102,
       (SELECT COUNT(*) FROM tratamiento WHERE codigo_mascota = 102) AS tratamientos_102;

-- 1C. Prueba ON DELETE RESTRICT (veterinario -> cita: debe ser rechazada)
DELETE FROM veterinario WHERE codigo_veterinario = 1;

-- 1D. Prueba ON UPDATE CASCADE (veterinario -> cita)
SELECT 'ANTES ON UPDATE CASCADE' AS etapa,
       (SELECT COUNT(*) FROM veterinario WHERE codigo_veterinario = 200) AS vet_200,
       (SELECT COUNT(*) FROM cita WHERE codigo_veterinario = 200) AS citas_vet_200;

UPDATE veterinario SET codigo_veterinario = 200 WHERE codigo_veterinario = 2;

SELECT 'DESPUÉS ON UPDATE CASCADE' AS etapa,
       (SELECT COUNT(*) FROM veterinario WHERE codigo_veterinario = 200) AS vet_200,
       (SELECT COUNT(*) FROM cita WHERE codigo_veterinario = 200) AS citas_vet_200;

UPDATE veterinario SET codigo_veterinario = 2 WHERE codigo_veterinario = 200;

-- 2. INSERT con clave foránea que no existe (debe fallar con fk_cita_veterinario)
INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, notas, diagnostico, codigo_veterinario)
VALUES (101, 99, '2026-11-02', '10:30:00', 'Revisión general', 'Pendiente', 9999);

-- 4. Comprobaciones que deben salir vacías (0 filas) en Clínica Veterinaria
SELECT 'mascota -> dueno' AS relacion, COUNT(*) AS huerfanos
FROM mascota m LEFT JOIN dueno d ON m.codigo_dueno = d.codigo_dueno
WHERE m.codigo_dueno IS NOT NULL AND d.codigo_dueno IS NULL
UNION ALL
SELECT 'cita -> mascota', COUNT(*)
FROM cita c LEFT JOIN mascota m ON c.codigo_mascota = m.codigo_mascota
WHERE m.codigo_mascota IS NULL
UNION ALL
SELECT 'cita -> veterinario', COUNT(*)
FROM cita c LEFT JOIN veterinario v ON c.codigo_veterinario = v.codigo_veterinario
WHERE v.codigo_veterinario IS NULL
UNION ALL
SELECT 'tratamiento -> cita', COUNT(*)
FROM tratamiento t LEFT JOIN cita c
  ON t.codigo_mascota = c.codigo_mascota AND t.codigo_cita = c.codigo_cita
WHERE c.codigo_mascota IS NULL;

SELECT 'dueno.correo' AS columna_unica, correo AS valor, COUNT(*) AS repeticiones
FROM dueno GROUP BY correo HAVING COUNT(*) > 1
UNION ALL
SELECT 'veterinario.num_certificado', num_certificado, COUNT(*)
FROM veterinario GROUP BY num_certificado HAVING COUNT(*) > 1;

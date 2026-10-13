-- =====================================================================
-- Pruebas de restricciones. Primero datos válidos, después INSERT que el
-- gestor debe rechazar. Ejecutar DESPUÉS de esquema.sql.
-- =====================================================================

-- ---------- Datos válidos ----------
INSERT INTO dueno VALUES (1, 'Ana', 'Torres Vega', 'ana.torres@correo.com', '5512345678', 'Calle Pino 12, CDMX');
INSERT INTO mascota (codigo_mascota, nombre, especie, raza, edad, sexo, notas, color_pelaje, codigo_dueno)
    VALUES (1, 'Luna', 'Gato', 'Siamés', 3, 'H', 'Alérgica al pollo', 'Crema', 1);
INSERT INTO mascota (codigo_mascota, nombre, especie, raza, edad, sexo, notas, peso_ideal, codigo_dueno)
    VALUES (2, 'Rocky', 'Perro', 'Criollo', 7, 'M', 'Rescatado', 22, NULL);                -- mascota sin dueño
INSERT INTO mascota (codigo_mascota, nombre, especie, raza, edad, sexo, codigo_dueno)
    VALUES (5, 'Copito', 'Conejo', 'Enano', 1, 'M', 1);                                   -- otra especie (jerarquía parcial)
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado, es_dermatologo, num_pacientes, es_cirujano, num_cirugias)
    VALUES (1, 'Sofía', 'Ríos', 'CERT-0001', TRUE, 0, TRUE, 0);                           -- ambas especialidades (solapada)
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
    VALUES (2, 'Marco', 'Lara', 'CERT-0002');                                             -- veterinario general
INSERT INTO cita VALUES (1, 1, '2026-10-08', '10:30', 'Revisión de piel', NULL, 1);
INSERT INTO tratamiento VALUES (1, 'Antihistamínico', '2026-10-08', '2026-10-18', 1, 1);


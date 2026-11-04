-- Pruebas de restricciones de dominio (ejercicio 1.5). Cada prueba va en su propia
-- transacción y termina en ROLLBACK: no cambian los datos. Ejecutar:
--   psql -f pruebas-dominio.sql

-- Caso 1: NOT NULL · Dueño sin correo
BEGIN;
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (900, 'Ana', 'Pérez Ruiz', NULL, '5511112222', 'Calle Hidalgo 10, CDMX');
ROLLBACK;

-- Caso 2: NOT NULL · Cita sin veterinario
BEGIN;
INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, codigo_veterinario)
VALUES (1, 900, '2026-12-01', '10:00', NULL);
ROLLBACK;

-- Caso 3: DEFAULT · Veterinario sin indicar especialidades
BEGIN;
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
VALUES (900, 'Laura', 'Gómez Díaz', 'CED-9000001')
RETURNING es_dermatologo, es_cirujano;
ROLLBACK;

-- Caso 4: UNIQUE simple · Dos dueños con el mismo correo
BEGIN;
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (901, 'Pedro', 'Luna Soto', 'miguel.lopez1@example.com', '5511112222', 'Calle Juárez 5, CDMX');
ROLLBACK;

-- Caso 5: UNIQUE simple · Dos veterinarios con el mismo certificado
BEGIN;
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
VALUES (901, 'Raúl', 'Mora Peña', 'CED-1000037');
ROLLBACK;

-- Caso 6: UNIQUE compuesta · Un veterinario con dos citas a la misma hora
BEGIN;
INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, codigo_veterinario)
VALUES (1, 900, '2026-03-22', '10:00', 6);
ROLLBACK;

-- Caso 7: CHECK de rango · Mascota de 41 años
BEGIN;
UPDATE mascota SET edad = 41 WHERE codigo_mascota = 1;
ROLLBACK;

-- Caso 8: CHECK de rango · Peso ideal de cero
BEGIN;
UPDATE mascota SET peso_ideal = 0 WHERE codigo_mascota = 1;
ROLLBACK;

-- Caso 9: CHECK de rango (dominio) · Código de dueño igual a 0
BEGIN;
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (0, 'Ana', 'Pérez Ruiz', 'ana0@example.com', '5511112222', 'Calle Hidalgo 10, CDMX');
ROLLBACK;

-- Caso 10: CHECK de lista · Sexo de la mascota fuera de la lista
BEGIN;
UPDATE mascota SET sexo = 'X' WHERE codigo_mascota = 1;
ROLLBACK;

-- Caso 11: CHECK de formato · Correo sin arroba
BEGIN;
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (902, 'Ana', 'Pérez Ruiz', 'ana.sin.arroba', '5511112222', 'Calle Hidalgo 10, CDMX');
ROLLBACK;

-- Caso 12: CHECK de formato (dominio) · Nombre en blanco
BEGIN;
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (903, '   ', 'Pérez Ruiz', 'ana903@example.com', '5511112222', 'Calle Hidalgo 10, CDMX');
ROLLBACK;

-- Caso 13: CHECK entre columnas · Tratamiento que vence antes de aplicarse
BEGIN;
UPDATE tratamiento SET fecha_vencimiento = fecha_tratamiento - 1 WHERE codigo_tratamiento = 1;
ROLLBACK;

-- Caso 14: CHECK entre columnas · Pacientes dermatológicos en un veterinario que no es dermatólogo
BEGIN;
UPDATE veterinario SET num_pacientes = 10 WHERE codigo_veterinario = 1;  -- el 1 no es dermatólogo
ROLLBACK;

-- Caso 15: CHECK entre columnas · Peso ideal en un gato
BEGIN;
UPDATE mascota SET peso_ideal = 4 WHERE codigo_mascota = 201;  -- la 201 es un gato
ROLLBACK;

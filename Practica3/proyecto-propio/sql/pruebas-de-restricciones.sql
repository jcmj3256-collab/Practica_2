-- ============================================================================
-- Practica 3 - Ejercicio 6.2: Pruebas de violacion de restricciones
-- Cada prueba debe ser rechazada por el motor PostgreSQL.
-- ============================================================================

-- INSERTS VALIDOS PREVIOS (Para tener datos base)
INSERT INTO dueno (nombre, telefono, correo, direccion) 
VALUES ('Carlos Sanchez', '5512345678', 'carlos@mail.com', 'Av. Politecnico 123');

INSERT INTO mascota (id_dueno, nombre, especie, raza, fecha_nacimiento, peso, sexo) 
VALUES (1, 'Max', 'Perro', 'Husky', '2023-01-10', 22.50, 'M');


-- ============================================================================
-- PRUEBA 1: Violacion de Integridad Referencial (FOREIGN KEY)
-- Intento de registrar una mascota asignada a un dueno inexistente (id_dueno = 999).
-- ============================================================================
INSERT INTO mascota (id_dueno, nombre, especie, raza, peso, sexo) 
VALUES (999, 'Firulais', 'Perro', 'Criollo', 10.0, 'M');
-- ERROR ESPERADO:
-- ERROR: insert or update on table "mascota" violates foreign key constraint "fk_mascota_dueno"
-- DETAIL: Key (id_dueno)=(999) is not present in table "dueno".


-- ============================================================================
-- PRUEBA 2: Violacion de Restriccion CHECK de Dominio
-- Intento de registrar un peso invalido (peso = -5.00).
-- ============================================================================
INSERT INTO mascota (id_dueno, nombre, especie, raza, peso, sexo) 
VALUES (1, 'Mimi', 'Gato', 'Siames', -5.00, 'H');
-- ERROR ESPERADO:
-- ERROR: new row for relation "mascota" violates check constraint "chk_mascota_peso"
-- DETAIL: Failing row contains (2, 1, Mimi, Gato, Siames, null, -5.00, H).


-- ============================================================================
-- PRUEBA 3: Violacion de Restriccion de Unicidad (UNIQUE)
-- Intento de registrar un dueno con un correo electronico duplicado.
-- ============================================================================
INSERT INTO dueno (nombre, telefono, correo, direccion) 
VALUES ('Laura Gomez', '5598765432', 'carlos@mail.com', 'Calle Norte 45');
-- ERROR ESPERADO:
-- ERROR: duplicate key value violates unique constraint "uq_dueno_correo"
-- DETAIL: Key (correo)=(carlos@mail.com) already exists.


-- ============================================================================
-- PRUEBA 4: Violacion de Clave Primaria Compuesta (Entidad Debil)
-- Intento de registrar dos veces la cita numero 1 para la misma mascota.
-- ============================================================================
INSERT INTO veterinario (cedula_vet, nombre, telefono, correo) 
VALUES ('VET-98765', 'Dra. Ana Lopez', '5588889999', 'ana@vet.com');

INSERT INTO cita (id_mascota, num_cita, cedula_vet, fecha_hora, motivo) 
VALUES (1, 1, 'VET-98765', '2026-10-15 10:00:00', 'Vacunacion antirrabica');

INSERT INTO cita (id_mascota, num_cita, cedula_vet, fecha_hora, motivo) 
VALUES (1, 1, 'VET-98765', '2026-10-16 11:00:00', 'Revision general');
-- ERROR ESPERADO:
-- ERROR: duplicate key value violates unique constraint "pk_cita"
-- DETAIL: Key (id_mascota, num_cita)=(1, 1) already exists.
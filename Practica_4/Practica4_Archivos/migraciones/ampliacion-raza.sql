-- Migración 003 · Práctica 4, ejercicio 1.4: la restricción estaba mal
-- El conjunto de Seattle trae razas de hasta 46 caracteres
-- ("Retriever, Labrador Mix"...) y mascota.raza era VARCHAR(40).
-- El dato es válido, así que se corrige la columna, no el dato.

BEGIN;
ALTER TABLE mascota ALTER COLUMN raza TYPE VARCHAR(50);
COMMIT;
 
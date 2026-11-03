# Ejercicio 2.6. Trabajo individual: Cambio de acción referencial

* **Integrante:** Fernando García Verduzco (`FERVERDZ18`)
* **Relación elegida:** `Atiende` (`veterinario` 1 : N `cita`, implementada mediante `fk_cita_veterinario`).
* **Cambio evaluado en copia:** De `ON DELETE RESTRICT` (original) a `ON DELETE CASCADE` (copia).

## 1. Script SQL de prueba sobre copia

```sql
DROP TABLE IF EXISTS copia_tratamiento CASCADE;
DROP TABLE IF EXISTS copia_cita CASCADE;
DROP TABLE IF EXISTS copia_veterinario CASCADE;

CREATE TABLE copia_veterinario AS TABLE veterinario;
ALTER TABLE copia_veterinario ADD CONSTRAINT pk_copia_vet PRIMARY KEY (codigo_veterinario);

CREATE TABLE copia_cita AS TABLE cita;
ALTER TABLE copia_cita ADD CONSTRAINT pk_copia_cita PRIMARY KEY (codigo_mascota, codigo_cita);

CREATE TABLE copia_tratamiento AS TABLE tratamiento;
ALTER TABLE copia_tratamiento ADD CONSTRAINT pk_copia_trat PRIMARY KEY (codigo_tratamiento);

ALTER TABLE copia_cita
    ADD CONSTRAINT fk_copia_cita_vet
    FOREIGN KEY (codigo_veterinario) REFERENCES copia_veterinario (codigo_veterinario)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_tratamiento
    ADD CONSTRAINT fk_copia_trat_cita
    FOREIGN KEY (codigo_mascota, codigo_cita) REFERENCES copia_cita (codigo_mascota, codigo_cita)
    ON DELETE CASCADE ON UPDATE CASCADE;

SELECT 'FERNANDO - ANTES' AS momento,
       (SELECT COUNT(*) FROM copia_veterinario) AS veterinarios,
       (SELECT COUNT(*) FROM copia_cita WHERE codigo_veterinario = 1) AS citas_vet_1,
       (SELECT COUNT(*) FROM copia_tratamiento t JOIN copia_cita c
         ON t.codigo_mascota = c.codigo_mascota AND t.codigo_cita = c.codigo_cita
        WHERE c.codigo_veterinario = 1) AS tratamientos_vet_1;

DELETE FROM copia_veterinario WHERE codigo_veterinario = 1;

SELECT 'FERNANDO - DESPUÉS' AS momento,
       (SELECT COUNT(*) FROM copia_veterinario) AS veterinarios,
       (SELECT COUNT(*) FROM copia_cita WHERE codigo_veterinario = 1) AS citas_vet_1,
       (SELECT COUNT(*) FROM copia_tratamiento t JOIN copia_cita c
         ON t.codigo_mascota = c.codigo_mascota AND t.codigo_cita = c.codigo_cita
        WHERE c.codigo_veterinario = 1) AS tratamientos_vet_1;
```

## 2. Análisis de resultados

* **¿Qué se pierde con `ON DELETE CASCADE`?** Al eliminar al veterinario `1`, se destruyen en cascada todas las citas que atendió en `copia_cita` (`2` citas) y, por efecto dominó de `fk_copia_trat_cita`, todos los tratamientos recetados en esas citas (`2` tratamientos).
* **¿Qué se conserva?** Solo permanecen los registros de dueños, mascotas y las citas atendidas por otros médicos.
* **¿Cuál de las dos opciones es la correcta para el dominio?** Es correcta **`ON DELETE RESTRICT`** (acompañada de borrado lógico `activo = FALSE` cuando un veterinario deja de laborar en la clínica), porque el historial clínico y las recetas de un paciente nunca deben desaparecer cuando un médico causa baja.

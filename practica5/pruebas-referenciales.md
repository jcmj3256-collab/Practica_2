# Ejercicio 2.3: Pruebas de integridad referencial

Todas las pruebas se ejecutaron sobre el contenedor `postgres173CV231AGO2026` (PostgreSQL 17) mediante el script `practica5/sql/pruebas_referenciales.sql`.

## 1. Prueba por cada acción referencial usada (con datos reales)

| Prueba y Acción Referencial | Clave foránea evaluada | Sentencia DML ejecutada | Renglones ANTES | Renglones DESPUÉS / Resultado |
| :--- | :--- | :--- | :--- | :--- |
| **Prueba A: `ON DELETE SET NULL`** | `fk_mascota_dueno` (`dueno` → `mascota`) | `DELETE FROM dueno WHERE codigo_dueno = 10;` | `dueno_10 = 1`, `mascota_101_sin_dueno = 0` | `dueno_10 = 0`, `mascota_101_sin_dueno = 1` (la mascota `101` se conservó con `codigo_dueno = NULL`) |
| **Prueba B: `ON DELETE CASCADE`** | `fk_cita_mascota` y `fk_tratamiento_cita` | `DELETE FROM mascota WHERE codigo_mascota = 102;` | `mascota_102 = 1`, `citas_102 = 2`, `tratamientos_102 = 2` | `mascota_102 = 0`, `citas_102 = 0`, `tratamientos_102 = 0` (borrado en cascada en 3 niveles) |
| **Prueba C: `ON DELETE RESTRICT`** | `fk_cita_veterinario` (`veterinario` → `cita`) | `DELETE FROM veterinario WHERE codigo_veterinario = 1;` | `veterinario = 3`, `citas_vet_1 = 1` | **Rechazado por el gestor:** se conservan los `3` veterinarios y sus citas |
| **Prueba D: `ON UPDATE CASCADE`** | `fk_cita_veterinario` (`veterinario` → `cita`) | `UPDATE veterinario SET codigo_veterinario = 200 WHERE codigo_veterinario = 2;` | `vet_200 = 0`, `citas_vet_200 = 0` (`2` citas con `codigo_veterinario = 2`) | `vet_200 = 1`, `citas_vet_200 = 2` (las citas hijas actualizaron su clave foránea a `200`) |

### Mensaje del gestor en `ON DELETE RESTRICT` (Prueba C)
```text
ERROR:  update or delete on table "veterinario" violates foreign key constraint "fk_cita_veterinario" on table "cita"
DETAIL:  Key (codigo_veterinario)=(1) is still referenced from table "cita".
```

## 2. `INSERT` con una clave foránea que no existe

* **Sentencia ejecutada:**
  ```sql
  INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, notas, diagnostico, codigo_veterinario)
  VALUES (101, 99, '2026-11-02', '10:30:00', 'Revisión general', 'Pendiente', 9999);
  ```
* **Mensaje de rechazo de PostgreSQL 17:**
  ```text
  ERROR:  insert or update on table "cita" violates foreign key constraint "fk_cita_veterinario"
  DETAIL:  Key (codigo_veterinario)=(9999) is not present in table "veterinario".
  ```

## 3. El orden de carga de las tablas

* **Qué ocurre si el script intenta cargar las tablas hijas antes que las padres:** Si se ejecuta un `INSERT` en `cita` o `tratamiento` antes de poblar `mascota` y `veterinario`, PostgreSQL aborta la inserción con `violates foreign key constraint "fk_cita_mascota"`.
* **Cómo se resuelve:** El script respeta el orden topológico de dependencias:
  1. `dueno` y `veterinario` (tablas padres sin claves foráneas).
  2. `mascota` (referencia opcionalmente a `dueno`).
  3. `cita` (referencia obligatoriamente a `mascota` y `veterinario`).
  4. `tratamiento` (referencia obligatoriamente a `cita`).

## 4. Comprobaciones que salen vacías (`0` huérfanos y `0` duplicados)

```sql
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
```
**Resultado obtenido en terminal:** `0` huérfanos en las cuatro relaciones y `0` duplicados en `dueno.correo` y `veterinario.num_certificado`.

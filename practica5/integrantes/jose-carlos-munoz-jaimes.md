# Ejercicio 2.6. Trabajo individual: Cambio de acción referencial

* **Integrante:** José Carlos Muñoz Jaimes (`jcmj3256-collab`)
* **Relación elegida:** `Tiene` (`dueno` 1 : N `mascota`, implementada mediante `fk_mascota_dueno`).
* **Cambio evaluado en copia:** De `ON DELETE SET NULL` (original) a `ON DELETE CASCADE` (copia).

## 1. Script SQL de prueba sobre copia

```sql
DROP TABLE IF EXISTS copia_m_tratamiento CASCADE;
DROP TABLE IF EXISTS copia_m_cita CASCADE;
DROP TABLE IF EXISTS copia_m_mascota CASCADE;
DROP TABLE IF EXISTS copia_m_dueno CASCADE;

CREATE TABLE copia_m_dueno AS TABLE dueno;
ALTER TABLE copia_m_dueno ADD CONSTRAINT pk_copia_m_dueno PRIMARY KEY (codigo_dueno);

CREATE TABLE copia_m_mascota AS TABLE mascota;
ALTER TABLE copia_m_mascota ADD CONSTRAINT pk_copia_m_mascota PRIMARY KEY (codigo_mascota);

CREATE TABLE copia_m_cita AS TABLE cita;
ALTER TABLE copia_m_cita ADD CONSTRAINT pk_copia_m_cita PRIMARY KEY (codigo_mascota, codigo_cita);

CREATE TABLE copia_m_tratamiento AS TABLE tratamiento;
ALTER TABLE copia_m_tratamiento ADD CONSTRAINT pk_copia_m_trat PRIMARY KEY (codigo_tratamiento);

ALTER TABLE copia_m_mascota
    ADD CONSTRAINT fk_copia_mascota_dueno
    FOREIGN KEY (codigo_dueno) REFERENCES copia_m_dueno (codigo_dueno)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_m_cita
    ADD CONSTRAINT fk_copia_m_cita_mascota
    FOREIGN KEY (codigo_mascota) REFERENCES copia_m_mascota (codigo_mascota)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_m_tratamiento
    ADD CONSTRAINT fk_copia_m_trat_cita
    FOREIGN KEY (codigo_mascota, codigo_cita) REFERENCES copia_m_cita (codigo_mascota, codigo_cita)
    ON DELETE CASCADE ON UPDATE CASCADE;

SELECT 'JOSE CARLOS - ANTES' AS momento,
       (SELECT COUNT(*) FROM copia_m_dueno WHERE codigo_dueno = 2) AS dueno_2,
       (SELECT COUNT(*) FROM copia_m_mascota WHERE codigo_dueno = 2) AS mascotas_dueno_2;

DELETE FROM copia_m_dueno WHERE codigo_dueno = 2;

SELECT 'JOSE CARLOS - DESPUÉS' AS momento,
       (SELECT COUNT(*) FROM copia_m_dueno WHERE codigo_dueno = 2) AS dueno_2,
       (SELECT COUNT(*) FROM copia_m_mascota WHERE codigo_dueno = 2) AS mascotas_dueno_2;
```

## 2. Análisis de resultados

* **¿Qué se pierde con `ON DELETE CASCADE`?** Al borrar al dueño `2`, se elimina su mascota (`Max`, `codigo_mascota = 104`) en `copia_m_mascota`, junto con sus citas y tratamientos asociados.
* **¿Qué se conserva con `ON DELETE SET NULL` (esquema original)?** Se conserva íntegro el expediente clínico de la mascota (`mascota`, `cita` y `tratamiento`), quedando únicamente `codigo_dueno = NULL` para permitir su reasignación a un nuevo adoptante o tutor.
* **¿Cuál de las dos opciones es la correcta para el dominio?** Es correcta **`ON DELETE SET NULL`**, ya que la relación `Tiene` admite mascotas sin dueño `(0,1)` y la clínica no debe destruir el expediente médico de un animal si su propietario cambia o solicita la baja de sus datos personales.

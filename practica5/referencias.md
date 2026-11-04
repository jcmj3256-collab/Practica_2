# Ejercicios 2.1 y 2.2: Claves foráneas y acciones referenciales del proyecto propio

## Ejercicio 2.1. Las claves foráneas del proyecto propio (Clínica Veterinaria)

En el modelo Entidad-Relación Extendido (EER) de la **Clínica Veterinaria** (transformado en `Practica3/Ejercicio6/Esquema.sql`), se definieron cuatro relaciones binarias y dos jerarquías de especialización:

| Nombre de la restricción (`CONSTRAINT`) | Relación del modelo EER que implementa | Cardinalidad EER `(mín, máx)` | Tabla y columna hija (origen) | Tabla y columna padre (referenciada) | ¿Admite nulos (`NULL`)? | Justificación según la cardinalidad mínima |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `fk_mascota_dueno` | **Tiene** (`Dueño` — `Mascota`) | `Dueño (1, N)` — `Mascota (0, 1)` | `mascota (codigo_dueno)` | `dueno (codigo_dueno)` | **Sí (`NULL`)** | La cardinalidad mínima de `Mascota` hacia `Dueño` es `0`: la clínica atiende mascotas rescatadas o comunitarias sin dueño registrado. |
| `fk_cita_mascota` | **Agenda** (`Mascota` — `Cita`, identificadora) | `Mascota (0, N)` — `Cita (1, 1)` | `cita (codigo_mascota)` | `mascota (codigo_mascota)` | **No (`NOT NULL`)** | `Cita` es entidad débil por identificación y su cardinalidad mínima hacia `Mascota` es `1`; forma parte de `PRIMARY KEY (codigo_mascota, codigo_cita)`. |
| `fk_cita_veterinario` | **Atiende** (`Veterinario` — `Cita`) | `Veterinario (0, N)` — `Cita (1, 1)` | `cita (codigo_veterinario)` | `veterinario (codigo_veterinario)` | **No (`NOT NULL`)** | La cardinalidad mínima de `Cita` hacia `Veterinario` es `1`: toda cita requiere un médico veterinario responsable asignado. |
| `fk_tratamiento_cita` | **Da** (`Cita` — `Tratamiento`, existencia) | `Cita (0, N)` — `Tratamiento (1, 1)` | `tratamiento (codigo_mascota, codigo_cita)` | `cita (codigo_mascota, codigo_cita)` | **No (`NOT NULL`)** | `Tratamiento` es entidad débil por existencia respecto a `Cita` con cardinalidad mínima `1`: todo tratamiento nace de una cita diagnosticada. |

### Relaciones del modelo EER que no generaron clave foránea adicional

1. **Jerarquía `Mascota` → `Gato`, `Perro` (disjunta, parcial):** Se transformó mediante la **Estrategia B (una sola tabla)** usando el discriminador `especie` y las restricciones `ck_mascota_color_gato` y `ck_mascota_peso_perro`. Al concentrar supertipo y subtipos en la tabla `mascota`, no existen tablas hijas adicionales que requieran clave foránea.
2. **Jerarquía `Veterinario` → `Dermatólogo`, `Cirujano` (solapada, parcial):** Se transformó mediante la **Estrategia B (una sola tabla)** con las banderas booleanas `es_dermatologo` y `es_cirujano` protegidas por `ck_vet_pacientes` y `ck_vet_cirugias`, evitando tablas separadas.

## Ejercicio 2.2. Acciones referenciales

| Clave foránea | Tabla hija → Tabla padre | Acción `ON DELETE` | Acción `ON UPDATE` | Regla del dominio que justifica la elección (en una línea) |
| :--- | :--- | :--- | :--- | :--- |
| `fk_mascota_dueno` | `mascota` → `dueno` | `ON DELETE SET NULL` | `ON UPDATE CASCADE` | Si un dueño se da de baja administrativa, el expediente clínico de la mascota sobrevive sin titular (`NULL`), y si cambia el código del dueño, sus mascotas siguen el nuevo identificador. |
| `fk_cita_mascota` | `cita` → `mascota` | `ON DELETE CASCADE` | `ON UPDATE CASCADE` | `Cita` es una entidad débil identificada por `Mascota`; no tiene sentido clínico conservar citas de una mascota eliminada. |
| `fk_cita_veterinario` | `cita` → `veterinario` | `ON DELETE RESTRICT` | `ON UPDATE CASCADE` | Por norma de responsabilidad médica y trazabilidad clínica, un veterinario no puede borrarse mientras tenga citas asociadas. |
| `fk_tratamiento_cita` | `tratamiento` → `cita` | `ON DELETE CASCADE` | `ON UPDATE CASCADE` | `Tratamiento` es entidad débil por existencia respecto a `Cita`; si una cita se elimina, sus prescripciones carecen de validez médica y desaparecen con ella. |

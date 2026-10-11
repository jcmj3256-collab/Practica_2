# Ejercicio 6. Esquema relacional, DDL ejecutado y diccionario

**Proyecto propio: Clínica Veterinaria.** Gestor: PostgreSQL 16 (contenedor Docker). Archivos: `sql/esquema.sql` y `sql/pruebas-de-restricciones.sql`.
---

## 6.1 Esquema completo

Estrategia de jerarquías: **B** (tabla única). Resultado: 5 tablas.

### `dueno`
| Columna | Tipo | PK / FK | Restricciones |
|---|---|---|---|
| `codigo_dueno` | INT | **PK** | NOT NULL |
| `nombre` | VARCHAR(60) | | NOT NULL |
| `apellidos` | VARCHAR(80) | | NOT NULL |
| `correo` | VARCHAR(120) | | NOT NULL, UNIQUE (`uq_dueno_correo`) |
| `telefono` | VARCHAR(25) | | NOT NULL |
| `direccion` | VARCHAR(160) | | NOT NULL |

### `mascota`
| Columna | Tipo | PK / FK | Restricciones |
|---|---|---|---|
| `codigo_mascota` | INT | **PK** | NOT NULL |
| `nombre` | VARCHAR(60) | | NOT NULL |
| `especie` | VARCHAR(30) | | NOT NULL. Discriminador de la jerarquía |
| `raza` | VARCHAR(40) | | Admite NULL |
| `edad` | INT | | CHECK entre 0 y 40 (`ck_mascota_edad`), admite NULL |
| `sexo` | CHAR(1) | | NOT NULL, CHECK IN ('M','H') (`ck_mascota_sexo`) |
| `notas` | VARCHAR(100) | | Admite NULL |
| `color_pelaje` | VARCHAR(40) | | Solo si `especie = 'Gato'` (`ck_mascota_color_gato`) |
| `peso_ideal` | INT | | > 0 (`ck_mascota_peso`); solo si `especie = 'Perro'` (`ck_mascota_peso_perro`) |
| `codigo_dueno` | INT | **FK** → `dueno` | Admite NULL. `ON DELETE SET NULL`, `ON UPDATE CASCADE` |

### `veterinario`
| Columna | Tipo | PK / FK | Restricciones |
|---|---|---|---|
| `codigo_veterinario` | INT | **PK** | NOT NULL |
| `nombre` | VARCHAR(60) | | NOT NULL |
| `apellidos` | VARCHAR(80) | | NOT NULL |
| `num_certificado` | VARCHAR(30) | | NOT NULL, UNIQUE (`uq_veterinario_certificado`) |
| `es_dermatologo` | BOOLEAN | | NOT NULL, DEFAULT FALSE |
| `num_pacientes` | INT | | Solo si `es_dermatologo` y ≥ 0 (`ck_vet_pacientes`) |
| `es_cirujano` | BOOLEAN | | NOT NULL, DEFAULT FALSE |
| `num_cirugias` | INT | | Solo si `es_cirujano` y ≥ 0 (`ck_vet_cirugias`) |

### `cita` (entidad débil por identificación de `mascota`)
| Columna | Tipo | PK / FK | Restricciones |
|---|---|---|---|
| `codigo_mascota` | INT | **PK** (parte 1) y **FK** → `mascota` | NOT NULL. `ON DELETE CASCADE`, `ON UPDATE CASCADE` |
| `codigo_cita` | INT | **PK** (parte 2). Discriminador | NOT NULL, CHECK > 0 (`ck_cita_codigo`) |
| `fecha` | DATE | | NOT NULL |
| `hora` | TIME | | NOT NULL |
| `notas` | TEXT | | Admite NULL |
| `diagnostico` | TEXT | | Admite NULL |
| `codigo_veterinario` | INT | **FK** → `veterinario` | NOT NULL. `ON DELETE RESTRICT`, `ON UPDATE CASCADE` |

### `tratamiento` (entidad débil por existencia de `cita`)
| Columna | Tipo | PK / FK | Restricciones |
|---|---|---|---|
| `codigo_tratamiento` | INT | **PK** | NOT NULL |
| `descripcion` | TEXT | | NOT NULL |
| `fecha_tratamiento` | DATE | | NOT NULL |
| `fecha_vencimiento` | DATE | | Admite NULL; si existe, ≥ `fecha_tratamiento` (`ck_tratamiento_fechas`) |
| `codigo_mascota`, `codigo_cita` | INT, INT | **FK compuesta** → `cita (codigo_mascota, codigo_cita)` | NOT NULL. `ON DELETE CASCADE`, `ON UPDATE CASCADE` |

---

## 6.2 Script de definición de datos

Archivo: `sql/esquema.sql`. Pruebas: `sql/pruebas-de-restricciones.sql`.

**Evidencia obligatoria (guardar en `evidencias/`):**
-  Captura de la ejecución de `esquema.sql` sin errores.
-  Captura del listado de tablas creadas (por ejemplo, `\dt` en `psql` o el árbol de tablas en pgAdmin). Deben aparecer las 5 tablas.
-  Captura de al menos tres `INSERT` rechazados, con el mensaje de error.

**INSERT rechazados** (los mensajes son de referencia; reemplázalos por tus capturas):

| # | Qué viola | INSERT | Mensaje del gestor |
|---|---|---|---|
| 1 | UNIQUE | Dueño con un correo repetido | `duplicate key value violates unique constraint "uq_dueno_correo"` |
| 2 | FOREIGN KEY | Mascota con el dueño 99, que no existe | `insert or update on table "mascota" violates foreign key constraint "fk_mascota_dueno"` |
| 3 | CHECK | Mascota con sexo 'X' | `new row for relation "mascota" violates check constraint "ck_mascota_sexo"` |
| 4 | PRIMARY KEY compuesta | Segunda cita 1 de la misma mascota | `duplicate key value violates unique constraint "pk_cita"` |
| 5 | NOT NULL | Cita sin veterinario | `null value in column "codigo_veterinario" of relation "cita" violates not-null constraint` |
| 6 | FOREIGN KEY compuesta | Tratamiento de una cita que no existe | `insert or update on table "tratamiento" violates foreign key constraint "fk_tratamiento_cita"` |
| 7 | CHECK | Tratamiento que vence antes de aplicarse | `new row for relation "tratamiento" violates check constraint "ck_tratamiento_fechas"` |
| 8 | CHECK de jerarquía | Color de pelaje en un perro | `new row for relation "mascota" violates check constraint "ck_mascota_color_gato"` |
| 9 | CHECK de jerarquía | `num_cirugias` en un veterinario que no es cirujano | `new row for relation "veterinario" violates check constraint "ck_vet_cirugias"` |

---

## 6.3 Diagrama relacional

Genéralo con dbdiagram.io, draw.io, DBeaver o ChartDB y guárdalo como `diagrama-relacional.png`. Debe mostrar las 5 tablas, sus claves y una línea de cada clave foránea a su clave primaria.

Para dbdiagram.io, pega este código (DBML) y exporta la imagen:

```dbml
Table dueno {
  codigo_dueno int [pk]
  nombre varchar(60) [not null]
  apellidos varchar(80) [not null]
  correo varchar(120) [not null, unique]
  telefono varchar(25) [not null]
  direccion varchar(160) [not null]
}

Table mascota {
  codigo_mascota int [pk]
  nombre varchar(60) [not null]
  especie varchar(30) [not null]
  raza varchar(40)
  edad int
  sexo char(1) [not null]
  notas varchar(100)
  color_pelaje varchar(40)
  peso_ideal int
  codigo_dueno int
}

Table veterinario {
  codigo_veterinario int [pk]
  nombre varchar(60) [not null]
  apellidos varchar(80) [not null]
  num_certificado varchar(30) [not null, unique]
  es_dermatologo boolean [not null, default: false]
  num_pacientes int
  es_cirujano boolean [not null, default: false]
  num_cirugias int
}

Table cita {
  codigo_mascota int [not null]
  codigo_cita int [not null]
  fecha date [not null]
  hora time [not null]
  notas text
  diagnostico text
  codigo_veterinario int [not null]
  indexes {
    (codigo_mascota, codigo_cita) [pk]
  }
}

Table tratamiento {
  codigo_tratamiento int [pk]
  descripcion text [not null]
  fecha_tratamiento date [not null]
  fecha_vencimiento date
  codigo_mascota int [not null]
  codigo_cita int [not null]
}

Ref: mascota.codigo_dueno > dueno.codigo_dueno [delete: set null, update: cascade]
Ref: cita.codigo_mascota > mascota.codigo_mascota [delete: cascade, update: cascade]
Ref: cita.codigo_veterinario > veterinario.codigo_veterinario [delete: restrict, update: cascade]
Ref: tratamiento.(codigo_mascota, codigo_cita) > cita.(codigo_mascota, codigo_cita) [delete: cascade, update: cascade]
```

---

## 6.4 Diccionario de datos

| Tabla | Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|---|
| dueno | codigo_dueno | INT | PK | Identificador del dueño |
| dueno | nombre | VARCHAR(60) | NOT NULL | Nombre(s) del dueño |
| dueno | apellidos | VARCHAR(80) | NOT NULL | Apellidos del dueño |
| dueno | correo | VARCHAR(120) | NOT NULL, UNIQUE | Correo electrónico; evita dueños duplicados |
| dueno | telefono | VARCHAR(25) | NOT NULL | Teléfono de contacto |
| dueno | direccion | VARCHAR(160) | NOT NULL | Domicilio del dueño |
| mascota | codigo_mascota | INT | PK | Identificador de la mascota |
| mascota | nombre | VARCHAR(60) | NOT NULL | Nombre de la mascota |
| mascota | especie | VARCHAR(30) | NOT NULL | Especie (Gato, Perro, Conejo...). Discriminador de la jerarquía |
| mascota | raza | VARCHAR(40) | NULL | Raza, si se conoce |
| mascota | edad | INT | CHECK 0–40, NULL | Edad aproximada en años al momento del registro |
| mascota | sexo | CHAR(1) | NOT NULL, CHECK 'M' o 'H' | Sexo: M (macho) o H (hembra) |
| mascota | notas | VARCHAR(100) | NULL | Observaciones, por ejemplo alergias o datos para identificarla |
| mascota | color_pelaje | VARCHAR(40) | CHECK solo si es gato | Color del pelaje (atributo de Gato) |
| mascota | peso_ideal | INT | CHECK > 0, solo si es perro | Peso ideal en kilogramos (atributo de Perro) |
| mascota | codigo_dueno | INT | FK → dueno, NULL | Dueño de la mascota; NULL si es callejera |
| veterinario | codigo_veterinario | INT | PK | Identificador del veterinario |
| veterinario | nombre | VARCHAR(60) | NOT NULL | Nombre(s) del veterinario |
| veterinario | apellidos | VARCHAR(80) | NOT NULL | Apellidos del veterinario |
| veterinario | num_certificado | VARCHAR(30) | NOT NULL, UNIQUE | Número de certificado profesional |
| veterinario | es_dermatologo | BOOLEAN | NOT NULL, DEFAULT FALSE | Verdadero si tiene la especialidad de dermatología |
| veterinario | num_pacientes | INT | CHECK ≥ 0, solo si es dermatólogo | Número de pacientes atendidos como dermatólogo |
| veterinario | es_cirujano | BOOLEAN | NOT NULL, DEFAULT FALSE | Verdadero si tiene la especialidad de cirugía |
| veterinario | num_cirugias | INT | CHECK ≥ 0, solo si es cirujano | Número de cirugías realizadas |
| cita | codigo_mascota | INT | PK (parte 1), FK → mascota | Mascota a la que pertenece la cita |
| cita | codigo_cita | INT | PK (parte 2), CHECK > 0 | Número de cita dentro de la mascota (1, 2, 3...). Discriminador |
| cita | fecha | DATE | NOT NULL | Fecha de la cita |
| cita | hora | TIME | NOT NULL | Hora de la cita |
| cita | notas | TEXT | NULL | Notas de la consulta |
| cita | diagnostico | TEXT | NULL | Diagnóstico de la consulta |
| cita | codigo_veterinario | INT | FK → veterinario, NOT NULL | Veterinario que atiende la cita |
| tratamiento | codigo_tratamiento | INT | PK | Identificador del tratamiento |
| tratamiento | descripcion | TEXT | NOT NULL | Descripción del tratamiento |
| tratamiento | fecha_tratamiento | DATE | NOT NULL | Fecha en que se receta o aplica |
| tratamiento | fecha_vencimiento | DATE | CHECK ≥ fecha_tratamiento, NULL | Fecha en que termina o vence |
| tratamiento | codigo_mascota, codigo_cita | INT, INT | FK compuesta → cita, NOT NULL | Cita en la que se recetó el tratamiento |

---

## 6.5 Preservación del significado

### Entidades, relaciones y jerarquías del inventario

| Elemento del inventario (Ej. 2) | Dónde quedó en el esquema | ¿Se conserva? |
|---|---|---|
| Entidad fuerte Dueño, con su PK | Tabla `dueno`, PK `codigo_dueno` | Sí |
| Entidad fuerte Mascota | Tabla `mascota`, PK `codigo_mascota` | Sí |
| Entidad fuerte Veterinario | Tabla `veterinario`, PK `codigo_veterinario` | Sí |
| Entidad débil Cita (identificación) | Tabla `cita`, PK (`codigo_mascota`, `codigo_cita`) | Sí |
| Entidad débil Tratamiento (existencia) | Tabla `tratamiento`, PK propia, FK compuesta a `cita` | Sí |
| Relación Tiene | FK `mascota.codigo_dueno` | Sí |
| Relación Agenda | FK `cita.codigo_mascota`, parte de la PK | Sí |
| Relación Atiende | FK `cita.codigo_veterinario` | Sí |
| Relación Da | FK compuesta en `tratamiento` | Sí |
| Jerarquía Mascota → Gato, Perro | Columnas `color_pelaje` y `peso_ideal` en `mascota`; discriminador `especie` | Sí |
| Jerarquía Veterinario → Dermatólogo, Cirujano | Banderas `es_dermatologo`, `es_cirujano` y sus atributos en `veterinario` | Sí |
| Compuesto Nombre_Completo | Columnas `nombre` y `apellidos` | Sí |
| Multivaluados, ternarias | No había | No aplica |

### Cardinalidades reflejadas en restricciones

| Relación | Cardinalidad | Restricción que la implementa |
|---|---|---|
| Tiene, lado Mascota | (0,1) | `codigo_dueno` admite NULL: una mascota puede no tener dueño; y es una sola columna: tiene como máximo uno |
| Tiene, lado Dueño | (1,N) | Una FK sin UNIQUE permite varias mascotas por dueño. **El mínimo 1 no se puede garantizar** (ver abajo) |
| Agenda, lado Cita | (1,1) | `codigo_mascota` NOT NULL y parte de la PK |
| Agenda, lado Mascota | (0,N) | Sin restricción: puede no tener citas |
| Atiende, lado Cita | (1,1) | `codigo_veterinario` NOT NULL |
| Atiende, lado Veterinario | (0,N) | Sin restricción: puede no tener citas |
| Da, lado Tratamiento | (1,1) | FK compuesta NOT NULL |
| Da, lado Cita | (0,N) | Sin restricción: puede no dar tratamientos |

### Reglas del modelo EER implementadas

| Regla del modelo | Cómo se implementa |
|---|---|
| La numeración de citas se reinicia por mascota | PK compuesta (`codigo_mascota`, `codigo_cita`) |
| Borrar una mascota borra sus citas y tratamientos | `ON DELETE CASCADE` en `cita` y en `tratamiento` |
| No se borra un veterinario con citas | `ON DELETE RESTRICT` en `cita.codigo_veterinario` |
| Borrar un dueño no borra la mascota | `ON DELETE SET NULL` en `mascota.codigo_dueno` |
| Mascota disjunta | Cada fila tiene una sola `especie` |
| Veterinario solapado | Dos banderas independientes |
| Jerarquías parciales | Otras especies y veterinarios generales usan las mismas tablas con las columnas propias en NULL o FALSE |
| Atributos propios solo del subtipo | `CHECK` en `mascota` y en `veterinario` |
| Un tratamiento no vence antes de aplicarse | `ck_tratamiento_fechas` |

### Lo que el esquema no garantiza (limitaciones)

- **Mínimo (1,N) de Dueño en Tiene.** Un dueño podría registrarse sin mascotas, porque una restricción declarativa no puede exigir que existan filas hijas. Se resolvería con un trigger o desde la aplicación.
- **`especie` es texto libre.** "gato" y "Gato" serían valores distintos, y los `CHECK` comparan con 'Gato' y 'Perro' exactos.
- **Un veterinario sin ninguna especialidad pero con `num_pacientes`** se rechaza, pero uno con la bandera activa y sin número se acepta (el valor es opcional).

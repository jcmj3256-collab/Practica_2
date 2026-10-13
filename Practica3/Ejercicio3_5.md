# Ejercicios 3 a 5. Reglas de transformación aplicadas al modelo EER

**Proyecto propio: Clínica Veterinaria.** Las referencias `esquema.sql:N` indican la línea del script donde se aplica cada decisión. El inventario de partida está en `inventario-eer.md` (Ejercicio 2).

Resultado: **5 tablas** (`dueno`, `mascota`, `veterinario`, `cita`, `tratamiento`).

---

## Ejercicio 3. Reglas de transformación básicas

### Regla 1. Entidades fuertes → una tabla cada una

| Entidad | Tabla | Clave primaria | Restricciones | Referencia |
|---|---|---|---|---|
| Dueño | `dueno` | `codigo_dueno` | `correo` UNIQUE (evita dueños duplicados); el resto de los atributos, NOT NULL | `esquema.sql:9-17` |
| Mascota | `mascota` | `codigo_mascota` | `sexo` CHECK ('M','H'); `edad` CHECK entre 0 y 40; `raza`, `edad` y `notas` admiten NULL | `esquema.sql:28-52` |
| Veterinario | `veterinario` | `codigo_veterinario` | `num_certificado` NOT NULL y UNIQUE | `esquema.sql:57-72` |

El nombre de la tabla `dueno` no lleva ñ para evitar problemas de codificación en el gestor.

### Regla 2. Atributos compuestos → una columna por componente

| Atributo compuesto | Entidades | Columnas resultantes | Referencia |
|---|---|---|---|
| Nombre_Completo | Dueño | `nombre`, `apellidos` | `esquema.sql:11-12` |
| Nombre_Completo | Veterinario | `nombre`, `apellidos` | `esquema.sql:59-60` |

El atributo padre desaparece, como pide la regla.

### Regla 3. Atributos multivaluados → tabla aparte

**No aplica.** El modelo no tiene atributos multivaluados. Las alergias se registran como texto en `Notas` de Mascota (decisión documentada en la sección 5 del inventario). Si en el futuro fueran multivaluadas, se crearía `alergia (codigo_mascota, alergia)` con PK compuesta.

---

## Ejercicio 4. Transformación de relaciones

### Regla 4. Relaciones uno a muchos → la PK del lado uno viaja como FK al lado muchos

| Relación | Lado uno | Lado muchos | Mínimo del lado muchos | Clave foránea | ¿NULL? | Referencia |
|---|---|---|---|---|---|---|
| Tiene | Dueño | Mascota | 0 (mascota sin dueño) | `mascota.codigo_dueno` | **Sí** | `esquema.sql:45-48` |
| Atiende | Veterinario | Cita | 1 (toda cita tiene veterinario) | `cita.codigo_veterinario` | **No** | `esquema.sql:91-94` |

Acciones referenciales:
- `mascota.codigo_dueno`: `ON DELETE SET NULL`, para que borrar un dueño no borre sus mascotas, que quedan sin dueño. `ON UPDATE CASCADE`.
- `cita.codigo_veterinario`: `ON DELETE RESTRICT`, para no borrar un veterinario con citas registradas. `ON UPDATE CASCADE`.

### Regla 5. Relaciones muchos a muchos → tabla propia

**No aplica.** El modelo no tiene relaciones muchos a muchos.

### Regla 6. Relaciones uno a uno

**No aplica.** No hay relaciones uno a uno. La relación Da (Cita–Tratamiento) es 1:N, no 1:1, y se trata con la Regla 8.

### Regla 7. Relaciones de orden superior

**No aplica.** No hay relaciones ternarias. La agregación de la Práctica 2 se descartó, porque cada cita tiene un solo veterinario (ver sección 6 del inventario).

### Resumen: cada relación, su regla y su tabla resultante

| Relación | Cardinalidad | Regla | Tabla resultante |
|---|---|---|---|
| Tiene (Dueño–Mascota) | 1:N | 4 | FK `codigo_dueno` en `mascota` |
| Atiende (Veterinario–Cita) | 1:N | 4 | FK `codigo_veterinario` en `cita` |
| Agenda (Mascota–Cita) | 1:N, identificadora | 8 | PK compuesta de `cita` |
| Da (Cita–Tratamiento) | 1:N, de existencia | 8 | FK compuesta en `tratamiento` |

---

## Ejercicio 5. Entidades débiles y jerarquías

### Regla 8. Entidades débiles

| Entidad débil | Tipo de dependencia | Propietaria | Clave primaria | Clave foránea | Referencia |
|---|---|---|---|---|---|
| Cita | **Identificación** (Agenda) | Mascota | Compuesta: (`codigo_mascota`, `codigo_cita`). `codigo_cita` es el discriminador | `codigo_mascota`, NOT NULL, `ON DELETE CASCADE` | `esquema.sql:77-96` |
| Tratamiento | **Existencia** (Da) | Cita | Propia: `codigo_tratamiento` | (`codigo_mascota`, `codigo_cita`) → `cita`, NOT NULL, `ON DELETE CASCADE` | `esquema.sql:99-112` |

- La numeración de citas se reinicia por mascota (1, 2, 3...), por eso Cita no puede identificarse sola.
- Un tratamiento se identifica con su propio código, pero no puede existir sin su cita. Como la PK de Cita es compuesta, la clave foránea también lo es.
- Restricciones adicionales: `codigo_cita > 0`; `fecha_vencimiento` no puede ser anterior a `fecha_tratamiento`.

### Regla 9. Jerarquías

#### 1. Clasificación

| Jerarquía | Disyunción | Completitud |
|---|---|---|
| Mascota → Gato, Perro | **Disjunta**: una mascota no es gato y perro a la vez | **Parcial**: hay otras especies (conejos, aves...) |
| Veterinario → Dermatólogo, Cirujano | **Solapada**: puede tener ambas especialidades | **Parcial**: hay veterinarios generales |

#### 2. Estrategia elegida y justificación: **B (tabla única con discriminador)** en las dos

- **Pocos atributos propios.** Cada subtipo tiene uno (`color_pelaje`, `peso_ideal`, `num_pacientes`, `num_cirugias`). Según la tabla de la práctica, B conviene en ese caso.
- **No sirve C.** C pide especialización total y disjunta, y las dos jerarquías son parciales: quedarían mascotas y veterinarios sin tabla donde registrarse. En Veterinario tampoco es disjunta.
- **Por qué no A.** Daría 9 tablas, y cada consulta de un gato o un perro necesitaría un `JOIN`.
- **Patrones de consulta esperados.** El uso principal es ver la ficha de una mascota o de un veterinario con todos sus datos, buscar por especie y consultar citas. Con B, un solo `SELECT` sin `JOIN` basta.
- **Desventaja aceptada.** Las columnas propias quedan en NULL para las mascotas de otra especie y para los veterinarios sin esa especialidad. Se controlan con `CHECK`.
- **Ventaja en Mascota.** La propia fila garantiza lo disyunto, porque cada mascota tiene una sola `especie`. Con A, la BD no lo impedía.

#### 3. Tablas resultantes, discriminador y restricciones

**Mascota** (`esquema.sql:28-52`)
- Discriminador: **`especie`** (no se agrega una columna `tipo`, porque `especie` ya existe).
- Columnas agregadas: `color_pelaje` (propia de Gato) y `peso_ideal` (propia de Perro).
- `ck_mascota_color_gato`: `color_pelaje` solo se llena si `especie = 'Gato'`.
- `ck_mascota_peso_perro`: `peso_ideal` solo se llena si `especie = 'Perro'`.
- Otras especies usan la misma tabla con esas dos columnas en NULL.

**Veterinario** (`esquema.sql:57-72`)
- Como es solapada, un solo discriminador no sirve: se usan **dos banderas booleanas**, `es_dermatologo` y `es_cirujano`, ambas `NOT NULL DEFAULT FALSE`.
- Las dos en FALSE significan veterinario general.
- Columnas agregadas: `num_pacientes` (propia de Dermatólogo) y `num_cirugias` (propia de Cirujano).
- `ck_vet_pacientes`: `num_pacientes` solo se llena si `es_dermatologo` es verdadero y debe ser ≥ 0.
- `ck_vet_cirugias`: `num_cirugias` solo se llena si `es_cirujano` es verdadero y debe ser ≥ 0.

**Limitación.** `especie` es texto libre, así que "gato" y "Gato" serían valores distintos. Si se quisiera controlar, habría que normalizar los valores (por ejemplo, una tabla de especies), cosa que queda fuera del alcance de esta versión.

---

## Fuentes

Las estrategias de la Regla 9 corresponden a las opciones de mapeo de jerarquías de Elmasri y Navathe. Cita (APA 7), verificando la edición que usa el profesor:

Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7th ed.). Pearson.

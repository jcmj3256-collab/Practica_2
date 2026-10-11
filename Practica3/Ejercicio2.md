# Inventario del modelo EER: Clínica Veterinaria

**Práctica 3, Ejercicio 2.** Fuente: el EER final del equipo y el `Ejercicio4.md` de la Práctica 2.


---

## 1. Entidades fuertes

| Entidad | Atributos | Clave primaria |
|---|---|---|
| Mascota | Nombre, Especie, Raza, Edad, Sexo, Notas | CodigoMascota |
| Dueño | Nombre_Completo (compuesto: nombre y apellidos), Correo, Telefono, Direccion | Codigo_Dueño |
| Veterinario | Nombre_Completo (compuesto: nombre y apellidos), num_certificado | Codigo_Veterinario |

**Subtipos** (no tienen clave propia: usan la de su supertipo)

| Subtipo | Supertipo | Atributo propio |
|---|---|---|
| Gato | Mascota | Color_Pelaje |
| Perro | Mascota | Peso_Ideal |
| Dermatólogo | Veterinario | num_pacientes |
| Cirujano | Veterinario | num_cirugias |

---

## 2. Entidades débiles

| Entidad débil | Dependencia | Propietaria | Relación | Clave | Atributos |
|---|---|---|---|---|---|
| Cita | Identificación | Mascota | Agenda (identificadora) | Discriminador `Codigo_Cita`. Clave completa: (CodigoMascota, Codigo_Cita) | Diagnostico, Notas, Fecha, Hora |
| Tratamiento | Existencia | Cita | Da | Clave propia `Codigo_Tratamiento` | Descripcion, Fecha_Tratamiento, Fecha_Vencimiento |

- La numeración de citas se reinicia por mascota (1, 2, 3...), por eso Cita necesita a Mascota para identificarse.
- Un tratamiento no puede registrarse sin la cita en la que se recetó, pero se identifica con su propio código.

---

## 3. Relaciones y cardinalidades

| Relación | Entre | Cardinalidad (mín, máx) | Tipo | Significado |
|---|---|---|---|---|
| Tiene | Dueño – Mascota | Dueño **(1,N)** · Mascota **(0,1)** | 1:N | El dueño se registra solo si trae al menos una mascota. Una mascota puede no tener dueño (callejeras) |
| Agenda | Mascota – Cita | Mascota **(0,N)** · Cita **(1,1)** | 1:N, identificadora | Toda cita pertenece a una sola mascota |
| Atiende | Veterinario – Cita | Veterinario **(0,N)** · Cita **(1,1)** | 1:N | Toda cita la atiende exactamente un veterinario |
| Da | Cita – Tratamiento | Cita **(0,N)** · Tratamiento **(1,1)** | 1:N, de existencia | Una cita puede no dar tratamientos o dar varios |

No hay relaciones muchos a muchos ni uno a uno.

---

## 4. Jerarquías

| Supertipo | Subtipos | Origen | Disyunción | Completitud |
|---|---|---|---|---|
| Mascota | Gato, Perro | Generalización | **Disjunta** (nunca es perro y gato a la vez) | **Parcial** (puede haber otras especies: conejos, aves...) |
| Veterinario | Dermatólogo, Cirujano | Especialización | **Solapada** (puede tener ambas especialidades) | **Parcial** (hay veterinarios generales) |

---

## 5. Atributos compuestos, multivaluados y derivados

| Tipo | Atributos |
|---|---|
| Compuestos | Nombre_Completo (en Dueño y en Veterinario) = nombre + apellidos |
| Multivaluados y Derivados| No se modeló ningún atributo multivaluado. Las alergias se registran como texto en Notas de Mascota, porque son una característica permanente de la mascota y el sistema no necesita consultarlas por separado. La edad se guarda como atributo simple, porque en mascotas callejeras o rescatadas solo se conoce de forma aproximada y no se tiene fecha de nacimiento; se interpreta como la edad al momento del registro. En una versión futura, las alergias podrían ser una tabla propia y la edad podría derivarse de una fecha de nacimiento. |


---

## 6. Relaciones ternarias o de orden superior

Ninguna. El `Ejercicio4.md` de la Práctica 2 proponía una agregación (Atiende–Cita → Tratamiento), pero no estaba dibujada y se descartó: Tratamiento depende de Cita, y como cada cita tiene un solo veterinario, el tratamiento ya queda ligado a "ese veterinario en esa cita".

---

## 8. Preguntas antes de transformar

> Borrador: reescríbelo con tus palabras antes de entregar.

### 1. ¿Qué elementos van a requerir una tabla adicional?

El modelo termina en **9 tablas**:

| Origen | Tablas |
|---|---|
| Entidades fuertes | Dueño, Mascota, Veterinario |
| Entidades débiles | Cita, Tratamiento |
| Subtipos (estrategia A) | Gato, Perro, Dermatólogo, Cirujano |

Las relaciones no necesitan tabla propia: todas son 1:N y se resuelven con una clave foránea. Tampoco hay relaciones muchos a muchos, atributos multivaluados ni relaciones ternarias que pidan una tabla adicional.

### 2. ¿Qué atributos se convertirán en claves foráneas?

| Clave foránea | Referencia | Regla | ¿Admite NULL? |
|---|---|---|---|
| `Mascota.codigo_dueno` | Dueño | 4 (Tiene) | Sí, porque el mínimo del lado Mascota es 0 |
| `Cita.codigo_mascota` | Mascota | 8 (Agenda); forma parte de la PK | No |
| `Cita.codigo_veterinario` | Veterinario | 4 (Atiende) | No |
| `Tratamiento.(codigo_mascota, codigo_cita)` | Cita | 8 (Da); compuesta | No |
| `Gato.codigo_mascota`, `Perro.codigo_mascota` | Mascota | 9 (jerarquía); también es PK | No |
| `Dermatologo.codigo_veterinario`, `Cirujano.codigo_veterinario` | Veterinario | 9 (jerarquía); también es PK | No |

### 3. ¿Qué decisión tendrás que tomar en cada jerarquía?

Las estrategias A, B y C son las de la Regla 9 del Ejercicio 5 de la Práctica 3. En las dos jerarquías hay que elegir una y justificarla. La estrategia C no sirve en ninguna, porque las dos son **parciales**: quedarían mascotas y veterinarios sin tabla donde registrarse.

| Jerarquía | Clasificación | Estrategia | Justificación |
|---|---|---|---|
| Mascota → Gato, Perro | Disjunta, parcial | **A** | La tabla de la Práctica 3 indica que B conviene con pocos atributos propios, y cada subtipo tiene uno. ⚠ Escribe aquí por qué eliges A. Otras especies (conejos, aves) quedan solo en Mascota. Que una mascota no sea Gato y Perro a la vez no lo garantizan la PK ni la FK, así que se documenta como limitación |
| Veterinario → Dermatólogo, Cirujano | Solapada, parcial | **A** | Un veterinario puede ser ambos. Con B haría falta una columna o bandera por especialidad, en lugar de un solo discriminador. Con A aparece en una tabla, en las dos o en ninguna |

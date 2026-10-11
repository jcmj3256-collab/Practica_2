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
| Multivaluados | Ninguno en el diagrama final. ⚠ **Alergias** salió en la entrevista y en los requerimientos de la Práctica 1, pero no está en el EER. Confirma si se omite a propósito (por ejemplo, porque vive en `Notas`) |
| Derivados | ⚠ **Edad** (cambia con el tiempo y se podría calcular a partir de una fecha de nacimiento). En el diagrama está como atributo simple; decide si se queda almacenada o se dibuja punteada |

---

## 6. Relaciones ternarias o de orden superior

Ninguna. El `Ejercicio4.md` de la Práctica 2 proponía una agregación (Atiende–Cita → Tratamiento), pero no estaba dibujada y se descartó: Tratamiento depende de Cita, y como cada cita tiene un solo veterinario, el tratamiento ya queda ligado a "ese veterinario en esa cita".

---

## 7. Cambios respecto al EER de la Práctica 2 (para el README)

El Ejercicio 2 pide anotar qué cambió y por qué. La columna "Por qué" es una propuesta: ajústala con tus palabras.

| Cambio | Por qué |
|---|---|
| Tratamiento ahora depende de **Cita** (relación **Da**). Antes el diagrama lo colgaba de Mascota con "Recibe", aunque el texto decía Cita | El diagrama y el texto se contradecían. Un tratamiento se receta dentro de una consulta |
| Se descartó la **agregación** del texto | No estaba dibujada y no hace falta, porque cada cita tiene un solo veterinario |
| La relación Mascota–Cita pasó de "Tiene" a **Agenda** | Había dos relaciones llamadas "Tiene" |
| Fecha, Fecha_Tratamiento y Fecha_Vencimiento ya no se descomponen en Día, Mes y Año | Se guardan como una sola fecha, más simple para consultar |
| `num_certificado` pasó a **Veterinario**. Dermatólogo ahora tiene `num_pacientes` | ⚠ Escribe aquí tu razón |
| Atributos de los subtipos: el texto de la Práctica 2 listaba otros (por ejemplo `raza_especifica`, `nivel_actividad` en Perro; `es_domestico` en Gato). El diagrama usa Color_Pelaje, Peso_Ideal, num_pacientes y num_cirugias | ⚠ Escribe aquí tu razón |
| Se agregaron las **cardinalidades** al diagrama | El EER anterior no las mostraba y el texto sí |

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

# Práctica 6 · Parte 1 — Dependencias funcionales y normalización
**Proyecto propio: Clínica Veterinaria** · BORRADOR (ver «Pendientes» al final)

> **Cómo se obtuvo todo esto.** Las dependencias salen de las **reglas del negocio** (lo que la clínica exige), no de mirar filas de ejemplo. Los resultados que se citan de la base (conteos de nulos, filas movidas) son los que devolvió PostgreSQL. Los cierres y la cobertura mínima se hicieron a mano y se **comprobaron** con `herramientas/fd_tools.py`.

**Abreviaturas** (solo para que las dependencias quepan en una línea):

| Tabla | Atributos |
|---|---|
| `dueno` | cód_dueño, nombre, apellidos, correo, teléfono, dirección |
| `mascota` | cód_mascota, nombre, especie, raza, edad, sexo, notas, color_pelaje, peso_ideal, cód_dueño |
| `veterinario` | cód_vet, nombre, apellidos, num_certificado, es_dermatólogo, num_pacientes, es_cirujano, num_cirugías |
| `cita` | cód_mascota, cód_cita, fecha, hora, notas, diagnóstico, cód_vet |
| `tratamiento` | cód_tratamiento, descripción, fecha_tratamiento, fecha_vencimiento, cód_mascota, cód_cita |

---

## Ejercicio 1.1 · Pautas de diseño

Las cuatro pautas: **(S)** semántica clara, **(A)** sin anomalías, **(N)** pocos nulos, **(E)** sin tuplas espurias.

| Tabla | «Cada fila es…» | S | A | N | E |
|---|---|---|---|---|---|
| `dueno` | una persona responsable de una o más mascotas de la clínica | ✅ | ✅ | ✅ ningún atributo admite nulo | ✅ |
| `mascota` | un animal registrado en la clínica | ⚠️ mezcla datos de dos subtipos | ✅ | ❌ **falla** | ✅ |
| `veterinario` | un profesional con cédula que trabaja en la clínica | ⚠️ mezcla datos de dos especialidades | ✅ | ❌ **falla** | ✅ |
| `cita` | una consulta de una mascota con un veterinario, en una fecha y hora | ✅ | ✅ | ⚠️ notas/diagnóstico opcionales | ✅ |
| `tratamiento` | un tratamiento recetado dentro de una cita | ✅ | ✅ | ⚠️ `fecha_vencimiento` opcional | ✅ |

**Dónde falla y por qué**

- **`mascota` (pauta N).** `color_pelaje` solo se llena para gatos y `peso_ideal` solo para perros (así quedó la estrategia B de la jerarquía en la Práctica 3). Con los datos cargados: 400 mascotas, 200 gatos y 200 perros → **200 nulos en `color_pelaje` y 200 en `peso_ideal`** (la mitad de cada columna). Los nulos no son «dato desconocido», son «no aplica», que es justo lo que la pauta desaconseja.
- **`veterinario` (pauta N).** `num_pacientes` solo existe para dermatólogos (7 de 20) y `num_cirugias` solo para cirujanos (6 de 20): **13 y 14 nulos** de 20. Misma causa: estrategia B en la jerarquía solapada.
- **`cita` y `tratamiento`.** Nulos legítimos (dato que aún no existe): el diagnóstico se captura después de la consulta (554 de 800 citas lo tienen, 246 no), y la fecha de vencimiento solo aplica a tratamientos con caducidad (138 de 300). No es una falla de diseño, pero se anota.
- **Anomalías (pauta A).** Ninguna tabla del esquema actual repite datos de otra: el dueño se guarda una vez en `dueno`, y la mascota solo guarda su código. Por eso el esquema no sufre anomalías de inserción, actualización ni borrado. (Sí las sufre la tabla desnormalizada de la §3, que justo se construyó para demostrarlas.)
- **Tuplas espurias (pauta E).** Todas las reuniones del esquema se hacen por clave foránea contra clave primaria, así que no generan tuplas de más. Se comprueba formalmente en 1.3.3.

**Decisión sobre los nulos de `mascota` y `veterinario`.** Se mantienen. Quitarlos obligaría a crear `mascota_gato`, `mascota_perro`, `vet_dermatologo`, `vet_cirujano` (estrategia A de la Práctica 3), y cada consulta de «todas las mascotas» tendría que unirlas. No hay ninguna dependencia funcional violada, así que no es un problema de forma normal; es un compromiso de diseño que ya se justificó en la Práctica 3.

---

## Ejercicio 1.2 · Las dependencias funcionales

### 1.2.1 El conjunto F (con la regla que justifica cada una)

| # | Dependencia | Regla del negocio |
|---|---|---|
| D1 | cód_dueño → nombre, apellidos, correo, teléfono, dirección | Cada dueño tiene un código único asignado por la clínica |
| D2 | correo → cód_dueño | Dos dueños no pueden compartir correo (el correo identifica a la persona) |
| M1 | cód_mascota → nombre, especie, raza, edad, sexo, notas, color_pelaje, peso_ideal, cód_dueño | Cada mascota tiene un código único; una mascota tiene un solo dueño a la vez |
| V1 | cód_vet → nombre, apellidos, num_certificado, es_dermatólogo, num_pacientes, es_cirujano, num_cirugías | Cada veterinario tiene un código único |
| V2 | num_certificado → cód_vet | La cédula profesional es única por persona |
| C1 | (cód_mascota, cód_cita) → fecha, hora, notas, diagnóstico, cód_vet | El número de cita es consecutivo **por mascota**; el par identifica la consulta |
| C2 | (cód_vet, fecha, hora) → cód_mascota, cód_cita | Un veterinario no puede atender dos citas a la misma hora (restricción `uq_cita_veterinario_fecha_hora`, migración 002) |
| T1 | cód_tratamiento → descripción, fecha_tratamiento, fecha_vencimiento, cód_mascota, cód_cita | Cada tratamiento tiene un código único y se receta en una sola cita |

**Dependencias que NO se incluyeron, a propósito** (porque la regla del negocio no las respalda, aunque los datos de ejemplo pudieran sugerirlas):

- teléfono → dueño, o dirección → dueño: una familia comparte teléfono y domicilio.
- (nombre, apellidos) → dueño: puede haber homónimos.
- raza → especie: una raza genérica como «Mestizo» se usa en perros y en gatos. *Si la clínica decidiera lo contrario, esta dependencia entraría a F y `mascota` dejaría de estar en 3FN (especie dependería de raza, que no es llave).*
- es_dermatólogo → num_pacientes: dos dermatólogos no tienen el mismo número de pacientes.
- (cód_mascota, fecha, hora) → cód_cita: es plausible (una mascota no puede estar en dos consultas a la vez), pero la base no lo impone. Si el equipo lo acuerda, se agrega como regla nueva.

### 1.2.2 Cierres de atributos y claves candidatas (paso a paso)

Método: se parte del conjunto; en cada ronda se aplica toda dependencia cuyo lado izquierdo ya esté contenido en el cierre, y se agregan sus lados derechos; se detiene cuando no cambia.

**`dueno`** — atributos: cód_dueño, nombre, apellidos, correo, teléfono, dirección

- {cód_dueño}⁺: inicio {cód_dueño} → D1 agrega nombre, apellidos, correo, teléfono, dirección → **todos (6/6)**. Es llave.
- {correo}⁺: inicio {correo} → D2 agrega cód_dueño → D1 ya aplica y agrega los otros cuatro → **todos**. Es llave.
- Ningún otro atributo solo determina nada ({nombre}⁺ = {nombre}, etc.).
- **Claves candidatas: {cód_dueño}, {correo}.** Primaria elegida: cód_dueño.

**`mascota`** — cód_mascota nunca aparece del lado derecho de ninguna dependencia, así que **está en toda clave**.

- {cód_mascota}⁺: M1 agrega los otros 9 → **todos (10/10)**.
- **Clave candidata única: {cód_mascota}.**

**`veterinario`**

- {cód_vet}⁺: V1 agrega los otros 7 → **todos (8/8)**. Es llave.
- {num_certificado}⁺: V2 agrega cód_vet → V1 agrega el resto → **todos**. Es llave.
- **Claves candidatas: {cód_vet}, {num_certificado}.** Primaria: cód_vet.

**`cita`**

- {cód_mascota, cód_cita}⁺: C1 agrega fecha, hora, notas, diagnóstico, cód_vet → **todos (7/7)**.
  ¿Es mínima? {cód_mascota}⁺ = {cód_mascota} y {cód_cita}⁺ = {cód_cita} (ninguna dependencia tiene un lado izquierdo contenido en ellos) → **sí es mínima**.
- {cód_vet, fecha, hora}⁺: C2 agrega cód_mascota, cód_cita → C1 ya aplica y agrega notas, diagnóstico → **todos**.
  ¿Es mínima? {cód_vet, fecha}⁺, {cód_vet, hora}⁺ y {fecha, hora}⁺ no crecen → **sí**.
- **Claves candidatas: {cód_mascota, cód_cita}, {cód_vet, fecha, hora}.** Primaria: la primera.

**`tratamiento`** — cód_tratamiento nunca aparece a la derecha, así que está en toda clave.

- {cód_tratamiento}⁺: T1 agrega los otros 5 → **todos (6/6)**.
- **Clave candidata única: {cód_tratamiento}.** (Ojo: {cód_mascota, cód_cita} **no** es llave: una cita puede tener varios tratamientos.)

### 1.2.3 Cobertura mínima

Los tres pasos, aplicados a cada tabla:

1. **Lados derechos simples.** Cada dependencia se parte en una por atributo: D1 → 5, M1 → 9, V1 → 7, C1 → 5, T1 → 5; D2, V2 se quedan igual y C2 se parte en 2.
2. **Sin atributos sobrantes en el lado izquierdo.** Solo importa donde el lado izquierdo tiene más de un atributo:
   - En C1: ¿sobra cód_cita? {cód_mascota}⁺ = {cód_mascota}, no contiene fecha, hora, notas, diagnóstico ni cód_vet → **no sobra**. ¿Sobra cód_mascota? {cód_cita}⁺ = {cód_cita}, tampoco → **no sobra**.
   - En C2: {cód_vet, fecha}⁺, {cód_vet, hora}⁺, {fecha, hora}⁺ no contienen cód_mascota ni cód_cita → **no sobra ninguno**.
3. **Sin dependencias redundantes.** Se quita una dependencia y se calcula el cierre de su lado izquierdo con las demás; si todavía llega al lado derecho, era redundante.
   - *Atajo:* si un atributo aparece a la derecha en **una sola** dependencia, esa dependencia no se puede quitar (nada más lo produce). Esto cubre todo `mascota`, `tratamiento`, y de `cita`: fecha, hora, notas, diagnóstico (solo C1), cód_vet (solo C1), cód_mascota y cód_cita (solo C2).
   - `dueno`: ¿se puede quitar cód_dueño → correo? Sin ella, {cód_dueño}⁺ = {cód_dueño, nombre, apellidos, teléfono, dirección}; no contiene correo → **necesaria**. ¿Se puede quitar correo → cód_dueño? Sin ella, {correo}⁺ = {correo} → **necesaria**. Las otras cuatro (→ nombre, apellidos, teléfono, dirección) las produce solo D1.
   - `veterinario`: igual. cód_vet → num_certificado y num_certificado → cód_vet son necesarias por la misma razón.

**Resultado:** no hay dependencias redundantes ni atributos sobrantes; el conjunto ya es mínimo.

| Tabla | Dependencias simples en la cobertura mínima |
|---|---|
| `dueno` | 6 |
| `mascota` | 9 |
| `veterinario` | 8 |
| `cita` | 7 |
| `tratamiento` | 5 |

**Nota:** la cobertura mínima no es única. En `dueno` se podría haber escrito la otra cobertura {correo → nombre, apellidos, teléfono, dirección, cód_dueño; cód_dueño → correo}; es equivalente (se demuestra abajo).

### 1.2.4 Equivalencia con el F de otro equipo

**Pendiente: falta el F real del otro equipo.** Cuando lo tengamos, el método es: F y G son equivalentes si **cada dependencia de G se puede derivar de F** y **cada una de F se puede derivar de G**; derivar `X → Y` significa que Y ⊆ X⁺ calculado con el otro conjunto.

Ejemplo ya trabajado con una versión alternativa de `dueno`, G = {correo → nombre, apellidos, teléfono, dirección, cód_dueño; cód_dueño → correo}:

- G ⊆ F⁺: {correo}⁺ con F = {correo, cód_dueño, nombre, apellidos, teléfono, dirección} ⊇ el lado derecho de la primera. {cód_dueño}⁺ con F contiene correo ✓.
- F ⊆ G⁺: {cód_dueño}⁺ con G: cód_dueño → correo, luego correo → todo lo demás ✓. {correo}⁺ con G contiene cód_dueño ✓.
- **Equivalentes** (comprobado también con `fd_tools.equivalentes`).
- *Contraejemplo útil:* si el otro equipo olvidara «correo → cód_dueño», G′ = {correo → nombre, apellidos, teléfono, dirección; cód_dueño → correo} **no** es equivalente: {correo}⁺ con G′ no contiene cód_dueño.

---

## Ejercicio 1.3 · Las formas normales

### 1.3.1 Forma normal de cada tabla actual

Criterios: **1FN** valores atómicos y llave; **2FN** sin dependencias parciales de una llave compuesta; **3FN** sin dependencias transitivas; **BCNF** todo determinante es superllave.

| Tabla | Determinantes (lados izquierdos) | ¿Son superllaves? | Forma normal |
|---|---|---|---|
| `dueno` | cód_dueño, correo | ambos son llaves candidatas | **BCNF** |
| `mascota` | cód_mascota | llave | **BCNF** |
| `veterinario` | cód_vet, num_certificado | ambos llaves | **BCNF** |
| `cita` | {cód_mascota, cód_cita}, {cód_vet, fecha, hora} | ambos llaves | **BCNF** |
| `tratamiento` | cód_tratamiento | llave | **BCNF** |

(`dueno.direccion` es un solo texto; se trata como atómico porque la clínica nunca consulta por calle o colonia por separado.)

**Conclusión: el esquema ya estaba en BCNF.** Siguiendo la indicación de la práctica, se demuestra con las dependencias y los cierres (1.2.2 y la tabla anterior) y se normaliza **una tabla desnormalizada a propósito**, construida con datos del dominio.

### 1.3.2 La tabla desnormalizada: `ficha_cita_legacy`

Es la «ficha de cita» de una hoja de cálculo de una clínica anterior: cada fila trae los datos de la cita, de la mascota, de su dueño y del veterinario. Se crea en `migraciones/004-ficha-cita-legacy.sql` con 12 fichas de ejemplo (códigos que no existen en la base de las Prácticas 4 y 5: dueños 201–203, mascotas 401–405, veterinarios 21–22).

**Atributos (18):** cód_mascota, cód_cita, fecha, hora, diagnóstico, nombre_mascota, especie, sexo, cód_dueño, nombre_dueño, apellidos_dueño, correo_dueño, teléfono_dueño, dirección_dueño, cód_vet, nombre_vet, apellidos_vet, num_certificado.

**Anomalías que sufre** (con las 12 filas reales):

| Anomalía | Ejemplo |
|---|---|
| Actualización | Paola (dueña 203) aparece en **5** filas. Si cambia su teléfono hay que corregir las 5; si se corrigen 4, la base se contradice. |
| Inserción | No se puede registrar un veterinario nuevo (ni un dueño) hasta que tenga una cita. |
| Borrado | Si se borra la única cita de una mascota, también se pierde el teléfono y dirección de su dueño. |
| Redundancia | El veterinario 21 y el 22 repiten nombre y cédula en **6** filas cada uno. |

**Dependencias (de las reglas del negocio, mismas que en 1.2.1):**

| # | Dependencia |
|---|---|
| L1 | (cód_mascota, cód_cita) → fecha, hora, diagnóstico, cód_vet |
| L2 | cód_mascota → nombre_mascota, especie, sexo, cód_dueño |
| L3 | cód_dueño → nombre_dueño, apellidos_dueño, correo_dueño, teléfono_dueño, dirección_dueño |
| L4 | correo_dueño → cód_dueño |
| L5 | cód_vet → nombre_vet, apellidos_vet, num_certificado |
| L6 | num_certificado → cód_vet |
| L7 | (cód_vet, fecha, hora) → cód_mascota, cód_cita |

**Cierres.**

- {cód_mascota, cód_cita}⁺: L1 agrega fecha, hora, diagnóstico, cód_vet → L2 (cód_mascota ya está) agrega nombre_mascota, especie, sexo, cód_dueño → L3 agrega los 5 datos del dueño → L5 agrega los 3 del veterinario → **18/18**. Llave.
- {cód_mascota}⁺ = {cód_mascota, nombre_mascota, especie, sexo, cód_dueño, nombre_dueño, apellidos_dueño, correo_dueño, teléfono_dueño, dirección_dueño} (10/18) → **no** es llave: de aquí sale la dependencia parcial.
- {cód_dueño}⁺ = cód_dueño + los 5 datos del dueño (6/18). {cód_vet}⁺ = cód_vet + 3 datos (4/18).
- {cód_vet, fecha, hora}⁺: L7 agrega cód_mascota y cód_cita → todo lo demás como arriba → **18/18**. Llave.
- **Claves candidatas: {cód_mascota, cód_cita}, {cód_vet, fecha, hora}, {num_certificado, fecha, hora}** (la tercera porque num_certificado ↔ cód_vet).

**Forma normal actual: 1FN.**

- **1FN ✅**: valores atómicos y tiene llave.
- **2FN ❌**: L2 depende solo de **cód_mascota**, parte de la llave {cód_mascota, cód_cita} (dependencia parcial). Lo mismo L5: cód_vet es solo parte de la llave {cód_vet, fecha, hora}.
- **3FN ❌**: L3 es transitiva: (cód_mascota, cód_cita) → cód_mascota → cód_dueño → nombre_dueño, … (cód_dueño no es llave y los datos del dueño no son atributos primos).

### 1.3.3 Normalización paso a paso

Cada paso elimina **una** dependencia y se verifica con la prueba de reunión sin pérdida: *los atributos comunes de los dos pedazos deben ser llave de al menos uno.*

| Paso | Dependencia que se elimina | Descomposición | Atributos comunes | ¿Reunión sin pérdida? |
|---|---|---|---|---|
| 1 | L2 (parcial) | **R_a** = {cód_mascota}⁺ (10 atributos) y **R_b** = ficha − (R_a − cód_mascota) | cód_mascota | ✅ cód_mascota es llave de R_a |
| 2 | L5 (parcial) | de R_b: **R4** = {cód_vet}⁺ = (cód_vet, nombre_vet, apellidos_vet, num_certificado) y **R1** = (cód_mascota, cód_cita, fecha, hora, diagnóstico, cód_vet) | cód_vet | ✅ llave de R4 |
| 3 | L3 (transitiva) | de R_a: **R3** = {cód_dueño}⁺ = (cód_dueño, nombre_dueño, apellidos_dueño, correo_dueño, teléfono_dueño, dirección_dueño) y **R2** = (cód_mascota, nombre_mascota, especie, sexo, cód_dueño) | cód_dueño | ✅ llave de R3 |

**Resultado: R1 … R4, que son exactamente las tablas `cita`, `mascota`, `dueno` y `veterinario`.** O sea: el esquema real es lo que se obtiene al normalizar la ficha.

| Relación | Atributos | Llaves candidatas | Determinantes | BCNF |
|---|---|---|---|---|
| R1 `cita` | cód_mascota, cód_cita, fecha, hora, diagnóstico, cód_vet | {cód_mascota, cód_cita}, {cód_vet, fecha, hora} | L1, L7 | ✅ |
| R2 `mascota` | cód_mascota, nombre, especie, sexo, cód_dueño | {cód_mascota} | L2 | ✅ |
| R3 `dueno` | cód_dueño, nombre, apellidos, correo, teléfono, dirección | {cód_dueño}, {correo} | L3, L4 | ✅ |
| R4 `veterinario` | cód_vet, nombre, apellidos, num_certificado | {cód_vet}, {num_certificado} | L5, L6 | ✅ |

**Preservación de dependencias.** L1 y L7 quedan dentro de R1; L2 en R2; L3 y L4 en R3; L5 y L6 en R4. **Las 7 se conservan sin tener que calcular cierres** (cada una cabe completa en algún pedazo).

**Reunión sin pérdida.** Los tres pasos cumplieron la prueba de atributos comunes (tabla de arriba), así que la reunión R1 ⋈ R2 ⋈ R3 ⋈ R4 reconstruye la ficha original. Además se comprueba **con los datos** dentro de la migración (abajo).

**Quedarse en BCNF no pierde nada**: no hubo que elegir entre BCNF y preservación de dependencias.

### 1.3.4 Migración con los datos

- `migraciones/004-ficha-cita-legacy.sql` crea y llena `ficha_cita_legacy`.
- `migraciones/005-normaliza-ficha-cita.sql`, en **una transacción**:
  1. guarda los conteos de antes;
  2. **mueve** los renglones con `INSERT … SELECT DISTINCT` (primero `dueno` y `veterinario`, luego `mascota`, al final `cita`, para respetar las claves foráneas);
  3. reúne las cuatro tablas y compara con la ficha original usando `EXCEPT` en los dos sentidos; si sobra o falta una fila, lanza una excepción y **todo se deshace**;
  4. reemplaza la tabla vieja por la vista `ficha_cita` (los reportes antiguos siguen funcionando, pero ya no hay datos repetidos).

**Resultado real** (ejecutada sobre la base poblada de las Prácticas 4 y 5, PostgreSQL 16):

```
NOTICE:  Reunión sin pérdida comprobada: 0 filas de más, 0 filas de menos.

    tabla    | antes | despues
-------------+-------+---------
 dueno       |   200 |     203
 veterinario |    20 |      22
 mascota     |   400 |     405
 cita        |   800 |     812
```

Se movieron 3 dueños, 2 veterinarios, 5 mascotas y 12 citas; los datos de antes quedaron intactos.

---

## Ejercicio 1.4 · El almacén asignado frente a las formas normales

**Pendiente.** Necesita el esquema del almacén dimensional del proyecto asignado (sismos); va en `almacen-y-formas-normales.md`.

---

## Pendientes

- [ ] **1.2.4**: intercambiar F con otro equipo y demostrar equivalencia (arriba hay el método y un ejemplo).
- [ ] **1.4**: almacén del proyecto asignado.
- [ ] Revisar con Fernando que las **reglas del negocio** de 1.2.1 sean las que quieren (sobre todo las que se dejaron fuera a propósito).
- [ ] Numeración de migraciones: aquí se usaron `004` y `005`; si el repositorio ya tiene esos números, renombrar.
- [ ] Rama `practica6-8`, Pull Request revisado por otro integrante, y confirmaciones de cada integrante en días distintos.
- [ ] Declarar en el README el uso de IA generativa.
- [ ] **Individual:** cada integrante explica con sus palabras una de las descomposiciones (la de la §1.3.3 sirve) y se le pedirá modificar una consulta en clase.

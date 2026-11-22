# Práctica 7 y 8 · Parte 2 — Álgebra relacional (Clínica Veterinaria)

**Datos:** muestra de la base real generada por `relax/exportar-grupo.sql` (esquema `relax_muestra`). Filas por tabla: dueno 23, mascota 20, veterinario 19, cita 26, tratamiento 12.
**Cómo repetirlo:** `sh ejecutar-consultas.sh` regenera la muestra y el grupo `relax/grupo.txt` y ejecuta las 13 consultas. Los resultados de abajo son los que devolvió PostgreSQL.
**Cómo verlo en RelaX:** abrir RelaX → pestaña *Editor de Grupo* → pegar `relax/grupo.txt` → *Usar este grupo* → pegar la expresión de la línea «RelaX» en la pestaña de álgebra relacional.

Las consultas SQL se ejecutan sobre **el mismo esquema** del que sale el grupo, así que el resultado de RelaX y el del gestor deben ser las mismas filas.

**Cobertura exigida:** σ y π (3) · ∪ − ∩ (3) · × (1) · reunión natural, theta y externa (3) · γ (2) · ÷ (1) = **13 consultas**.

> Pendiente: la captura de RelaX (árbol + resultado) de cada consulta, en `evidencias/` con el nombre `qNN.png`. No se pudo generar desde aquí; se toma al pegar la expresión en RelaX.

---

## Consulta 01 · σ Selección

**Pregunta:** ¿Qué mascotas son perros?

**Expresión en álgebra:**
```
σ especie = 'Perro' (mascota)
```
**Para RelaX:**
```
sigma especie = 'Perro' (mascota)
```
**Captura de RelaX:** `evidencias/q01.png` *(pendiente)*

**SQL equivalente** (`consultas/01-seleccion.sql`):
```sql
SELECT * FROM mascota WHERE especie = 'Perro' ORDER BY codigo_mascota;
```
**Resultado que devolvió el gestor:**
```
 codigo_mascota | nombre  | especie |                      raza                      | edad | sexo | notas | color_pelaje | peso_ideal | codigo_dueno 
----------------+---------+---------+------------------------------------------------+------+------+-------+--------------+------------+--------------
              1 | Phoebe  | Perro   | Welsh Corgi, Pembroke                          |   14 | H    |       |              |         31 |           65
              2 | Maple   | Perro   | Poodle, Standard                               |    5 | H    |       |              |         45 |           29
              3 | Neko    | Perro   | Siberian Husky                                 |    8 | M    |       |              |         23 |          101
              4 | Lenny   | Perro   | Retriever, Golden                              |    5 | H    |       |              |         26 |           49
              5 | Sadie   | Perro   | Shepherd                                       |   16 | H    |       |              |         19 |           69
              6 | Memphis | Perro   | Retriever, Golden                              |    0 | H    |       |              |          7 |          176
              7 | Maude   | Perro   | Mixed Breed, Medium (up to 44 lbs fully grown) |   13 | M    |       |              |         11 |          167
              8 | Yukon   | Perro   | Bulldog, American                              |   12 | M    |       |              |         32 |          154
              9 | Captain | Perro   | Mixed Breed, Small (under 24 lbs fully grown)  |   18 | M    |       |              |         17 |          158
             31 | Molly   | Perro   | Mixed Breed, Medium (up to 44 lbs fully grown) |   13 | H    |       |              |         43 |           63
             41 | Josie   | Perro   | Retriever, Nova Scotia Duck Tolling            |    1 | M    |       |              |         39 |          132
             51 | Inari   | Perro   | Mixed Breed, Medium (up to 44 lbs fully grown) |   17 | M    |       |              |         21 |           87
             76 | Memphis | Perro   | Australian Shepherd, Miniature                 |   11 | H    |       |              |         20 |           44
            132 | Tucker  | Perro   | Bichon Frise                                   |    7 | M    |       |              |         38 |          131
(14 rows)
```
**Qué demuestra:** Filtra **filas**: solo las que cumplen la condición; todas las columnas se conservan.

---

## Consulta 02 · π Proyección

**Pregunta:** ¿Qué combinaciones de especie y sexo existen entre las mascotas? (20 filas se reducen porque π elimina duplicados)

**Expresión en álgebra:**
```
π especie, sexo (mascota)
```
**Para RelaX:**
```
pi especie, sexo (mascota)
```
**Captura de RelaX:** `evidencias/q02.png` *(pendiente)*

**SQL equivalente** (`consultas/02-proyeccion.sql`):
```sql
SELECT DISTINCT especie, sexo FROM mascota ORDER BY especie, sexo;
```
**Resultado que devolvió el gestor:**
```
 especie | sexo 
---------+------
 Gato    | H
 Gato    | M
 Perro   | H
 Perro   | M
(4 rows)
```
**Qué demuestra:** Filtra **columnas** y elimina duplicados: las 20 mascotas se reducen a las combinaciones distintas.

---

## Consulta 03 · σ + π compuestos

**Pregunta:** ¿Cómo se llaman los veterinarios cirujanos con más de 100 cirugías?

**Expresión en álgebra:**
```
π nombre, apellidos (σ es_cirujano = true ∧ num_cirugias > 100 (veterinario))
```
**Para RelaX:**
```
pi nombre, apellidos (sigma es_cirujano = true and num_cirugias > 100 (veterinario))
```
**Captura de RelaX:** `evidencias/q03.png` *(pendiente)*

**SQL equivalente** (`consultas/03-seleccion-proyeccion.sql`):
```sql
SELECT DISTINCT nombre, apellidos FROM veterinario WHERE es_cirujano AND num_cirugias > 100 ORDER BY 1, 2;
```
**Resultado que devolvió el gestor:**
```
 nombre  |   apellidos    
---------+----------------
 Iván    | López Mendoza
 Iván    | Vázquez Pérez
 Ricardo | Ortiz Martínez
(3 rows)
```
**Qué demuestra:** Compone los dos: primero σ (filas) y luego π (columnas). El orden importa: π antes de σ perdería `es_cirujano` y `num_cirugias`.

---

## Consulta 04 · ∪ Unión

**Pregunta:** ¿Qué mascotas tienen al menos una cita o al menos un tratamiento? (compatibles: una columna codigo_mascota en ambos lados)

**Expresión en álgebra:**
```
π codigo_mascota (cita) ∪ π codigo_mascota (tratamiento)
```
**Para RelaX:**
```
pi codigo_mascota (cita) union pi codigo_mascota (tratamiento)
```
**Captura de RelaX:** `evidencias/q04.png` *(pendiente)*

**SQL equivalente** (`consultas/04-union.sql`):
```sql
SELECT codigo_mascota FROM cita UNION SELECT codigo_mascota FROM tratamiento ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 codigo_mascota 
----------------
              1
              3
              4
              5
              6
              7
             31
             41
             51
             76
            132
            248
            275
            284
            301
            391
            393
(17 rows)
```
**Qué demuestra:** Compatibilidad de unión: los dos lados tienen **una columna del mismo tipo y nombre** (`codigo_mascota`). Sin la proyección previa no serían compatibles (cita y tratamiento tienen columnas distintas).

---

## Consulta 05 · − Diferencia

**Pregunta:** ¿Qué mascotas han tenido cita pero ningún tratamiento?

**Expresión en álgebra:**
```
π codigo_mascota (cita) − π codigo_mascota (tratamiento)
```
**Para RelaX:**
```
pi codigo_mascota (cita) \ pi codigo_mascota (tratamiento)
```
**Captura de RelaX:** `evidencias/q05.png` *(pendiente)*

**SQL equivalente** (`consultas/05-diferencia.sql`):
```sql
SELECT codigo_mascota FROM cita EXCEPT SELECT codigo_mascota FROM tratamiento ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 codigo_mascota 
----------------
              1
              3
              4
              5
              6
              7
(6 rows)
```
**Qué demuestra:** Misma compatibilidad. La diferencia **no es conmutativa**: `tratamiento − cita` daría otra respuesta (vacía, porque todo tratamiento está dentro de una cita).

---

## Consulta 06 · ∩ Intersección

**Pregunta:** ¿Qué mascotas han tenido cita Y también tratamiento?

**Expresión en álgebra:**
```
π codigo_mascota (cita) ∩ π codigo_mascota (tratamiento)
```
**Para RelaX:**
```
pi codigo_mascota (cita) intersect pi codigo_mascota (tratamiento)
```
**Captura de RelaX:** `evidencias/q06.png` *(pendiente)*

**SQL equivalente** (`consultas/06-interseccion.sql`):
```sql
SELECT codigo_mascota FROM cita INTERSECT SELECT codigo_mascota FROM tratamiento ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 codigo_mascota 
----------------
             31
             41
             51
             76
            132
            248
            275
            284
            301
            391
            393
(11 rows)
```
**Qué demuestra:** Misma compatibilidad. Equivale a la intersección de los dos conjuntos de mascotas.

---

## Consulta 07 · × Producto cartesiano

**Pregunta:** ¿Qué pasaría si emparejáramos cada gato con cada veterinario dermatólogo SIN condición? (6 gatos × 6 dermatólogos = 36 parejas, ninguna con sentido: por eso casi nunca se usa solo)

**Expresión en álgebra:**
```
π mascota.nombre, veterinario.nombre (σ especie = 'Gato' (mascota) × σ es_dermatologo = true (veterinario))
```
**Para RelaX:**
```
pi mascota.nombre, veterinario.nombre (sigma especie = 'Gato' (mascota) cross join sigma es_dermatologo = true (veterinario))
```
**Captura de RelaX:** `evidencias/q07.png` *(pendiente)*

**SQL equivalente** (`consultas/07-producto-cartesiano.sql`):
```sql
SELECT m.nombre AS nombre_mascota, v.nombre AS nombre_veterinario
FROM mascota m CROSS JOIN veterinario v
WHERE m.especie = 'Gato' AND v.es_dermatologo
ORDER BY 1, 2;
```
**Resultado que devolvió el gestor:**
```
 nombre_mascota | nombre_veterinario 
----------------+--------------------
 Blanket        | Elena
 Blanket        | Jorge
 Blanket        | Renata
 Blanket        | Ricardo
 Blanket        | Ricardo
 Blanket        | Sergio
 Boo            | Elena
 Boo            | Jorge
 Boo            | Renata
 Boo            | Ricardo
 Boo            | Ricardo
 Boo            | Sergio
 Cinna          | Elena
 Cinna          | Jorge
 Cinna          | Renata
 Cinna          | Ricardo
 Cinna          | Ricardo
 Cinna          | Sergio
 Lorenzo        | Elena
 Lorenzo        | Jorge
 Lorenzo        | Renata
 Lorenzo        | Ricardo
 Lorenzo        | Ricardo
 Lorenzo        | Sergio
 Smokey         | Elena
 Smokey         | Jorge
 Smokey         | Renata
 Smokey         | Ricardo
 Smokey         | Ricardo
 Smokey         | Sergio
 Talia          | Elena
 Talia          | Jorge
 Talia          | Renata
 Talia          | Ricardo
 Talia          | Ricardo
 Talia          | Sergio
(36 rows)
```
**Qué demuestra:** El producto cartesiano empareja **todo con todo**: aquí solo gatos × dermatólogos ya da **36 filas** (6 × 6), y ninguna significa algo (el gato no tiene relación con ese veterinario). Solo sirve como paso previo a una selección, que es justo lo que hace la reunión.

---

## Consulta 08 · ⋈ Reunión natural

**Pregunta:** ¿Con qué veterinario es cada cita (nombre, fecha y hora)? Solo aparecen veterinarios que tienen citas.

**Expresión en álgebra:**
```
π nombre, apellidos, fecha, hora (veterinario ⋈ cita)
```
**Para RelaX:**
```
pi nombre, apellidos, fecha, hora (veterinario natural join cita)
```
**Captura de RelaX:** `evidencias/q08.png` *(pendiente)*

**SQL equivalente** (`consultas/08-reunion-natural.sql`):
```sql
SELECT v.nombre, v.apellidos, c.fecha, to_char(c.hora,'HH24:MI') AS hora
FROM veterinario v NATURAL JOIN cita c
ORDER BY 1, 2, 3, 4;
```
**Resultado que devolvió el gestor:**
```
  nombre  |     apellidos      |   fecha    | hora  
----------+--------------------+------------+-------
 Ana      | Ortiz Gutiérrez    | 2026-02-25 | 17:30
 Ana      | Ortiz Gutiérrez    | 2026-10-22 | 14:00
 Elena    | Hernández Ramírez  | 2026-06-08 | 09:00
 Emilio   | Cruz González      | 2026-02-19 | 08:00
 Fernanda | Reyes Cruz         | 2026-06-27 | 14:00
 Gabriela | Gutiérrez López    | 2026-07-05 | 14:30
 Gabriela | Gutiérrez López    | 2026-10-16 | 18:30
 Iván     | López Mendoza      | 2026-05-19 | 12:30
 Iván     | López Mendoza      | 2026-09-08 | 18:30
 Iván     | López Mendoza      | 2026-09-24 | 17:30
 Iván     | Vázquez Pérez      | 2026-04-11 | 19:00
 Jorge    | Jiménez Morales    | 2026-04-10 | 15:00
 Paola    | Hernández Castillo | 2026-05-19 | 11:30
 Paola    | Hernández Castillo | 2026-08-02 | 18:00
 Raúl     | González Reyes     | 2026-02-10 | 11:00
 Renata   | Cruz Ramírez       | 2026-05-16 | 18:00
 Renata   | Cruz Ramírez       | 2026-09-03 | 15:30
 Renata   | Cruz Ramírez       | 2026-10-09 | 17:30
 Renata   | Morales Aguilar    | 2026-02-04 | 19:30
 Ricardo  | Aguilar Ramírez    | 2026-09-06 | 18:30
 Ricardo  | Ortiz Martínez     | 2026-09-10 | 08:30
 Sergio   | Aguilar Flores     | 2026-02-26 | 16:00
 Sergio   | Aguilar Flores     | 2026-04-10 | 10:30
 Sergio   | Aguilar Flores     | 2026-08-19 | 12:00
 Sergio   | Ruiz Ramírez       | 2026-08-21 | 16:30
 Sergio   | Ruiz Ramírez       | 2026-08-22 | 15:00
(26 rows)
```
**Qué demuestra:** Reunión natural: empareja por `codigo_veterinario`, el único atributo común. Resultado: **26 filas**. Los veterinarios sin citas (2, 6, 8) **se pierden**.

---

## Consulta 09 · ⋈θ Reunión theta

**Pregunta:** ¿Cómo se llama cada mascota y quién es su dueño? (condición explícita: la reunión natural también igualaría `nombre`, que existe en las dos tablas, y devolvería 0 filas)

**Expresión en álgebra:**
```
π mascota.nombre, dueno.nombre, dueno.apellidos (mascota ⋈ mascota.codigo_dueno = dueno.codigo_dueno dueno)
```
**Para RelaX:**
```
pi mascota.nombre, dueno.nombre, dueno.apellidos (mascota join mascota.codigo_dueno = dueno.codigo_dueno dueno)
```
**Captura de RelaX:** `evidencias/q09.png` *(pendiente)*

**SQL equivalente** (`consultas/09-reunion-theta.sql`):
```sql
SELECT m.nombre AS nombre_mascota, d.nombre AS nombre_dueno, d.apellidos
FROM mascota m JOIN dueno d ON m.codigo_dueno = d.codigo_dueno
ORDER BY 1, 2, 3;
```
**Resultado que devolvió el gestor:**
```
 nombre_mascota | nombre_dueno |     apellidos     
----------------+--------------+-------------------
 Blanket        | Fernanda     | Torres Hernández
 Boo            | Fernanda     | Martínez Cruz
 Captain        | Paola        | González Mendoza
 Cinna          | Héctor       | Castillo Castillo
 Inari          | Pablo        | Reyes Martínez
 Josie          | Óscar        | Sánchez Torres
 Lenny          | Fernanda     | Cruz Jiménez
 Lorenzo        | Daniela      | Morales Reyes
 Maple          | Carlos       | Hernández Flores
 Maude          | Paola        | Aguilar Morales
 Memphis        | Emilio       | Ramírez Vázquez
 Memphis        | Jorge        | Castillo Díaz
 Molly          | Carlos       | Cruz Vázquez
 Neko           | Ricardo      | Vázquez Gutiérrez
 Phoebe         | Pablo        | López Martínez
 Sadie          | Ricardo      | López Mendoza
 Smokey         | Paola        | Aguilar Pérez
 Talia          | Diego        | Pérez Gutiérrez
 Tucker         | Sergio       | Flores Vázquez
 Yukon          | Jorge        | Ortiz Díaz
(20 rows)
```
**Qué demuestra:** Reunión theta con condición explícita: **20 filas**. Si se usara la reunión natural, también igualaría `nombre` (existe en `mascota` y en `dueno`) y devolvería **0 filas**: un error clásico.

---

## Consulta 10 · ⟕ Reunión externa izquierda

**Pregunta:** ¿Cuántas filas aparecen para cada veterinario si queremos conservar también a los que no han atendido citas? (los de la izquierda sin pareja salen con null)

**Expresión en álgebra:**
```
π codigo_veterinario, nombre, codigo_cita, fecha (veterinario ⟕ cita)
```
**Para RelaX:**
```
pi codigo_veterinario, nombre, codigo_cita, fecha (veterinario left outer join cita)
```
**Captura de RelaX:** `evidencias/q10.png` *(pendiente)*

**SQL equivalente** (`consultas/10-reunion-externa.sql`):
```sql
SELECT v.codigo_veterinario, v.nombre, c.codigo_cita, c.fecha
FROM veterinario v LEFT JOIN cita c ON v.codigo_veterinario = c.codigo_veterinario
ORDER BY 1, 3;
```
**Resultado que devolvió el gestor:**
```
 codigo_veterinario |  nombre  | codigo_cita |   fecha    
--------------------+----------+-------------+------------
                  1 | Iván     |           2 | 2026-04-11
                  2 | Renata   |             | 
                  3 | Emilio   |           3 | 2026-02-19
                  4 | Renata   |           1 | 2026-10-09
                  4 | Renata   |           1 | 2026-05-16
                  4 | Renata   |           3 | 2026-09-03
                  5 | Fernanda |           2 | 2026-06-27
                  6 | Valeria  |             | 
                  7 | Ricardo  |           3 | 2026-09-06
                  8 | Carlos   |             | 
                  9 | Elena    |           2 | 2026-06-08
                 10 | Paola    |           2 | 2026-05-19
                 10 | Paola    |           2 | 2026-08-02
                 11 | Renata   |           1 | 2026-02-04
                 12 | Ana      |           1 | 2026-02-25
                 12 | Ana      |           2 | 2026-10-22
                 13 | Sergio   |           1 | 2026-08-22
                 13 | Sergio   |           2 | 2026-08-21
                 14 | Sergio   |           1 | 2026-02-26
                 14 | Sergio   |           2 | 2026-04-10
                 14 | Sergio   |           2 | 2026-08-19
                 15 | Iván     |           1 | 2026-05-19
                 15 | Iván     |           3 | 2026-09-24
                 15 | Iván     |           4 | 2026-09-08
                 16 | Gabriela |           1 | 2026-07-05
                 16 | Gabriela |           2 | 2026-10-16
                 17 | Jorge    |           2 | 2026-04-10
                 18 | Raúl     |           3 | 2026-02-10
                 19 | Ricardo  |           2 | 2026-09-10
(29 rows)
```
**Qué demuestra:** Reunión externa izquierda: **29 filas** contra 26 de la reunión interna. Se **conservan** los veterinarios sin citas (2, 6, 8), con `null` en las columnas de `cita`.

---

## Consulta 11 · γ Agrupación (conteo)

**Pregunta:** ¿Cuántas citas atendió cada veterinario?

**Expresión en álgebra:**
```
γ codigo_veterinario; count(codigo_cita) → num_citas (cita)
```
**Para RelaX:**
```
gamma codigo_veterinario; count(codigo_cita) -> num_citas (cita)
```
**Captura de RelaX:** `evidencias/q11.png` *(pendiente)*

**SQL equivalente** (`consultas/11-agrupacion-conteo.sql`):
```sql
SELECT codigo_veterinario, count(codigo_cita) AS num_citas
FROM cita GROUP BY codigo_veterinario ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 codigo_veterinario | num_citas 
--------------------+-----------
                  1 |         1
                  3 |         1
                  4 |         3
                  5 |         1
                  7 |         1
                  9 |         1
                 10 |         2
                 11 |         1
                 12 |         2
                 13 |         2
                 14 |         3
                 15 |         3
                 16 |         2
                 17 |         1
                 18 |         1
                 19 |         1
(16 rows)
```
**Qué demuestra:** Un renglón por grupo (veterinario). Los veterinarios sin citas **no aparecen**: no hay filas que agrupar (comparar con la consulta 10).

---

## Consulta 12 · γ Agrupación (promedio)

**Pregunta:** ¿Cuántas mascotas hay por especie y cuál es su edad promedio?

**Expresión en álgebra:**
```
γ especie; count(codigo_mascota) → mascotas, avg(edad) → edad_promedio (mascota)
```
**Para RelaX:**
```
gamma especie; count(codigo_mascota) -> mascotas, avg(edad) -> edad_promedio (mascota)
```
**Captura de RelaX:** `evidencias/q12.png` *(pendiente)*

**SQL equivalente** (`consultas/12-agrupacion-promedio.sql`):
```sql
SELECT especie, count(codigo_mascota) AS mascotas, round(avg(edad), 4) AS edad_promedio
FROM mascota GROUP BY especie ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 especie | mascotas | edad_promedio 
---------+----------+---------------
 Gato    |        6 |        7.5000
 Perro   |       14 |       10.0000
(2 rows)
```
**Qué demuestra:** Dos agregaciones por grupo. `avg` en PostgreSQL devuelve numeric; se redondea a 4 decimales solo para mostrarlo (RelaX da 7.5 y 10).

---

## Consulta 13 · ÷ División

**Pregunta:** ¿Qué veterinarios han atendido a TODAS las especies de mascota que hay en la clínica?

**Expresión en álgebra:**
```
especies = π especie (mascota)
atendidas = π codigo_veterinario, especie (cita ⋈ mascota)
atendidas ÷ especies
```
**Para RelaX:**
```
especies = pi especie (mascota)
atendidas = pi codigo_veterinario, especie (cita natural join mascota)
atendidas / especies
```
**Captura de RelaX:** `evidencias/q13.png` *(pendiente)*

**SQL equivalente** (`consultas/13-division.sql`):
```sql
SELECT DISTINCT c.codigo_veterinario
FROM cita c
WHERE NOT EXISTS (
    SELECT e.especie FROM (SELECT DISTINCT especie FROM mascota) e
    WHERE NOT EXISTS (
        SELECT 1 FROM cita c2 JOIN mascota m ON m.codigo_mascota = c2.codigo_mascota
        WHERE c2.codigo_veterinario = c.codigo_veterinario AND m.especie = e.especie))
ORDER BY 1;
```
**Resultado que devolvió el gestor:**
```
 codigo_veterinario 
--------------------
                  4
                 15
(2 rows)
```
**Qué demuestra:** Pregunta con «**todos**»: veterinarios cuyo conjunto de especies atendidas **contiene** al conjunto de todas las especies. En SQL se escribe con doble `NOT EXISTS`; se comprobó que da lo mismo que la definición con diferencia de conjuntos.

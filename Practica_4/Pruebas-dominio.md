# Ejercicio 1.5 · Pruebas de restricciones de dominio

Se ejecutaron sobre la base cargada con `poblar.sql`. Cada prueba va dentro de una transacción con `ROLLBACK`, así que no modifica los datos. El mensaje es la salida real de PostgreSQL. Las sentencias están también en `pruebas-dominio.sql`.

## Caso 1. NOT NULL: Dueño sin correo

**Operación:**
```sql
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (900, 'Ana', 'Pérez Ruiz', NULL, '5511112222', 'Calle Hidalgo 10, CDMX');
```
**Resultado esperado:** Rechazada: el correo es obligatorio.

**Mensaje del gestor:**
```
ERROR:  null value in column "correo" of relation "dueno" violates not-null constraint
DETAIL:  Failing row contains (900, Ana, Pérez Ruiz, null, 5511112222, Calle Hidalgo 10, CDMX).
```
**Regla del dominio que protege:** Todo dueño tiene un correo con el que se le contacta y se le identifica (también es UNIQUE).

## Caso 2. NOT NULL: Cita sin veterinario

**Operación:**
```sql
INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, codigo_veterinario)
VALUES (1, 900, '2026-12-01', '10:00', NULL);
```
**Resultado esperado:** Rechazada: toda cita la atiende un veterinario.

**Mensaje del gestor:**
```
ERROR:  null value in column "codigo_veterinario" of relation "cita" violates not-null constraint
DETAIL:  Failing row contains (1, 900, 2026-12-01, 10:00:00, null, null, null).
```
**Regla del dominio que protege:** Una cita sin veterinario no tiene quién la atienda (cardinalidad mínima 1 hacia veterinario).

## Caso 3. DEFAULT: Veterinario sin indicar especialidades

**Operación:**
```sql
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
VALUES (900, 'Laura', 'Gómez Díaz', 'CED-9000001')
RETURNING es_dermatologo, es_cirujano;
```
**Resultado esperado:** Aceptada: es_dermatologo y es_cirujano toman FALSE.

**Mensaje del gestor:**
```
 es_dermatologo | es_cirujano 
----------------+-------------
 f              | f
(1 row)

INSERT 0 1
```
**Regla del dominio que protege:** Un veterinario nuevo no es dermatólogo ni cirujano mientras no se indique lo contrario.

## Caso 4. UNIQUE simple: Dos dueños con el mismo correo

**Operación:**
```sql
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (901, 'Pedro', 'Luna Soto', 'miguel.lopez1@example.com', '5511112222', 'Calle Juárez 5, CDMX');
```
**Resultado esperado:** Rechazada: el correo ya existe.

**Mensaje del gestor:**
```
ERROR:  duplicate key value violates unique constraint "uq_dueno_correo"
DETAIL:  Key (correo)=(miguel.lopez1@example.com) already exists.
```
**Regla del dominio que protege:** Un correo identifica a un solo dueño; evita registros duplicados.

## Caso 5. UNIQUE simple: Dos veterinarios con el mismo certificado

**Operación:**
```sql
INSERT INTO veterinario (codigo_veterinario, nombre, apellidos, num_certificado)
VALUES (901, 'Raúl', 'Mora Peña', 'CED-1000037');
```
**Resultado esperado:** Rechazada: el certificado ya existe.

**Mensaje del gestor:**
```
ERROR:  duplicate key value violates unique constraint "uq_veterinario_certificado"
DETAIL:  Key (num_certificado)=(CED-1000037) already exists.
```
**Regla del dominio que protege:** La cédula profesional es única por persona.

## Caso 6. UNIQUE compuesta: Un veterinario con dos citas a la misma hora

**Operación:**
```sql
INSERT INTO cita (codigo_mascota, codigo_cita, fecha, hora, codigo_veterinario)
VALUES (1, 900, '2026-03-22', '10:00', 6);
```
**Resultado esperado:** Rechazada: el veterinario 6 ya tiene cita el 2026-03-22 a las 10:00.

**Mensaje del gestor:**
```
ERROR:  duplicate key value violates unique constraint "uq_cita_veterinario_fecha_hora"
DETAIL:  Key (codigo_veterinario, fecha, hora)=(6, 2026-03-22, 10:00:00) already exists.
```
**Regla del dominio que protege:** Un veterinario no puede atender dos citas al mismo tiempo.

## Caso 7. CHECK de rango: Mascota de 41 años

**Operación:**
```sql
UPDATE mascota SET edad = 41 WHERE codigo_mascota = 1;
```
**Resultado esperado:** Rechazada: la edad va de 0 a 40.

**Mensaje del gestor:**
```
ERROR:  new row for relation "mascota" violates check constraint "ck_mascota_edad"
DETAIL:  Failing row contains (1, Phoebe, Perro, Welsh Corgi, Pembroke, 41, H, null, null, 31, 65).
```
**Regla del dominio que protege:** Ningún animal de compañía pasa de 40 años.

## Caso 8. CHECK de rango: Peso ideal de cero

**Operación:**
```sql
UPDATE mascota SET peso_ideal = 0 WHERE codigo_mascota = 1;
```
**Resultado esperado:** Rechazada: el peso debe ser mayor que cero.

**Mensaje del gestor:**
```
ERROR:  new row for relation "mascota" violates check constraint "ck_mascota_peso"
DETAIL:  Failing row contains (1, Phoebe, Perro, Welsh Corgi, Pembroke, 14, H, null, null, 0, 65).
```
**Regla del dominio que protege:** Un peso ideal de 0 o negativo no existe.

## Caso 9. CHECK de rango (dominio): Código de dueño igual a 0

**Operación:**
```sql
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (0, 'Ana', 'Pérez Ruiz', 'ana0@example.com', '5511112222', 'Calle Hidalgo 10, CDMX');
```
**Resultado esperado:** Rechazada: los códigos son enteros positivos.

**Mensaje del gestor:**
```
ERROR:  value for domain d_codigo violates check constraint "ck_d_codigo"
```
**Regla del dominio que protege:** Los identificadores son mayores que cero (dominio d_codigo).

## Caso 10. CHECK de lista: Sexo de la mascota fuera de la lista

**Operación:**
```sql
UPDATE mascota SET sexo = 'X' WHERE codigo_mascota = 1;
```
**Resultado esperado:** Rechazada: solo 'M' o 'H'.

**Mensaje del gestor:**
```
ERROR:  new row for relation "mascota" violates check constraint "ck_mascota_sexo"
DETAIL:  Failing row contains (1, Phoebe, Perro, Welsh Corgi, Pembroke, 14, X, null, null, 31, 65).
```
**Regla del dominio que protege:** El sexo de la mascota es macho (M) o hembra (H).

## Caso 11. CHECK de formato: Correo sin arroba

**Operación:**
```sql
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (902, 'Ana', 'Pérez Ruiz', 'ana.sin.arroba', '5511112222', 'Calle Hidalgo 10, CDMX');
```
**Resultado esperado:** Rechazada: el correo debe tener forma algo@algo.algo.

**Mensaje del gestor:**
```
ERROR:  new row for relation "dueno" violates check constraint "ck_dueno_correo"
DETAIL:  Failing row contains (902, Ana, Pérez Ruiz, ana.sin.arroba, 5511112222, Calle Hidalgo 10, CDMX).
```
**Regla del dominio que protege:** Un correo sin arroba no sirve para contactar al dueño.

## Caso 12. CHECK de formato (dominio): Nombre en blanco

**Operación:**
```sql
INSERT INTO dueno (codigo_dueno, nombre, apellidos, correo, telefono, direccion)
VALUES (903, '   ', 'Pérez Ruiz', 'ana903@example.com', '5511112222', 'Calle Hidalgo 10, CDMX');
```
**Resultado esperado:** Rechazada: el nombre no puede ser solo espacios.

**Mensaje del gestor:**
```
ERROR:  value for domain d_nombre violates check constraint "ck_d_nombre"
```
**Regla del dominio que protege:** Un nombre vacío no identifica a nadie (dominio d_nombre).

## Caso 13. CHECK entre columnas: Tratamiento que vence antes de aplicarse

**Operación:**
```sql
UPDATE tratamiento SET fecha_vencimiento = fecha_tratamiento - 1 WHERE codigo_tratamiento = 1;
```
**Resultado esperado:** Rechazada: el vencimiento no puede ser anterior al tratamiento.

**Mensaje del gestor:**
```
ERROR:  new row for relation "tratamiento" violates check constraint "ck_tratamiento_fechas"
DETAIL:  Failing row contains (1, Antialérgico, 2026-05-19, 2026-05-18, 51, 2).
```
**Regla del dominio que protege:** Un tratamiento no puede vencer antes del día en que se aplica.

## Caso 14. CHECK entre columnas: Pacientes dermatológicos en un veterinario que no es dermatólogo

**Operación:**
```sql
UPDATE veterinario SET num_pacientes = 10 WHERE codigo_veterinario = 1;  -- el 1 no es dermatólogo
```
**Resultado esperado:** Rechazada: num_pacientes solo aplica a dermatólogos.

**Mensaje del gestor:**
```
ERROR:  new row for relation "veterinario" violates check constraint "ck_vet_pacientes"
DETAIL:  Failing row contains (1, Iván, Vázquez Pérez, CED-1000037, f, 10, t, 271).
```
**Regla del dominio que protege:** El número de pacientes dermatológicos solo existe si el veterinario es dermatólogo.

## Caso 15. CHECK entre columnas: Peso ideal en un gato

**Operación:**
```sql
UPDATE mascota SET peso_ideal = 4 WHERE codigo_mascota = 201;  -- la 201 es un gato
```
**Resultado esperado:** Rechazada: el peso ideal solo se registra para perros.

**Mensaje del gestor:**
```
ERROR:  new row for relation "mascota" violates check constraint "ck_mascota_peso_perro"
DETAIL:  Failing row contains (201, George, Gato, American Shorthair, 0, H, null, Calicó, 4, 68).
```
**Regla del dominio que protege:** El peso ideal es un dato propio de los perros en este modelo.

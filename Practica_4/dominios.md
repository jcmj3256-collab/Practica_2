# Práctica 4 · Ejercicios 1.1 y 1.2 — Clínica Veterinaria (PostgreSQL)

Dominios y restricciones nuevas. Probadas sobre `esquema.sql` de la Práctica 3.

## 1.1 Tipos de dato por columna

| Tabla | Columna | Tipo final | Razón |
|---|---|---|---|
| dueno | codigo_dueno | `d_codigo` (INTEGER > 0) | Identificador entero, nunca negativo ni cero |
| dueno | nombre | `d_nombre` (VARCHAR(60)) | Texto corto; no puede ser solo espacios |
| dueno | apellidos | `d_apellidos` (VARCHAR(80)) | Dos apellidos caben en 80 |
| dueno | correo | VARCHAR(120) | Texto de longitud variable |
| dueno | telefono | VARCHAR(25) | Es texto, no número: no se suma y puede empezar con 0 o llevar + |
| dueno | direccion | VARCHAR(160) | Texto libre acotado |
| mascota | codigo_mascota, codigo_dueno | `d_codigo` | Igual que los demás códigos |
| mascota | nombre | `d_nombre` | — |
| mascota | especie / raza / color_pelaje | VARCHAR(30) / (40) / (40) | Texto corto |
| mascota | edad | INTEGER (0–40) | Años enteros |
| mascota | sexo | CHAR(1) ('M','H') | Un solo carácter fijo |
| mascota | peso_ideal | INTEGER (> 0) | Peso en kg, tal como está en el esquema |
| veterinario | codigo_veterinario | `d_codigo` | — |
| veterinario | nombre / apellidos | `d_nombre` / `d_apellidos` | — |
| veterinario | num_certificado | VARCHAR(30) UNIQUE | Puede traer letras |
| veterinario | es_dermatologo, es_cirujano | BOOLEAN (default FALSE) | Sí/no |
| veterinario | num_pacientes, num_cirugias | INTEGER (≥0) | Conteos |
| cita | codigo_mascota, codigo_cita, codigo_veterinario | `d_codigo` | — |
| cita | fecha / hora | DATE / TIME | Separadas, como en el diseño |
| cita | notas / diagnostico | TEXT | Longitud no acotada |
| tratamiento | codigo_tratamiento, codigo_mascota, codigo_cita | `d_codigo` | — |
| tratamiento | descripcion | TEXT | Longitud libre |
| tratamiento | fecha_tratamiento / fecha_vencimiento | DATE | — |

**Dinero:** el esquema no tiene columnas de precio. Si se agregan, se usará `NUMERIC(10,2)`, nunca FLOAT.

**Qué se gana con los dominios:** la regla se escribe una vez (por ejemplo, que un nombre no sea solo espacios) y se aplica a todas las columnas que lo usan; cambiarla es un solo `ALTER DOMAIN`.

## 1.2 Restricciones

| # | Tabla | Restricción | Tipo | Regla de dominio |
|---|---|---|---|---|
| 1 | dueno | uq_dueno_correo | UNIQUE | No hay dos dueños con el mismo correo |
| 2 | dueno | ck_dueno_correo | CHECK (formato) | El correo tiene forma `algo@algo.algo` |
| 4 | dueno/mascota/veterinario | d_nombre / d_apellidos | CHECK en dominio | No vacío ni solo espacios |
| 5 | todas | d_codigo | CHECK en dominio | Código > 0 |
| 6 | mascota | ck_mascota_sexo | CHECK (lista) | Solo 'M' o 'H' |
| 7 | mascota | ck_mascota_edad | CHECK (rango) | Edad entre 0 y 40 |
| 8 | mascota | ck_mascota_peso | CHECK (rango) | Peso ideal > 0 |
| 9 | mascota | ck_mascota_color_gato | CHECK (entre columnas) | Solo los gatos tienen color de pelaje |
| 10 | mascota | ck_mascota_peso_perro | CHECK (entre columnas) | Solo los perros tienen peso ideal |
| 11 | veterinario | uq_veterinario_certificado | UNIQUE | Certificado irrepetible |
| 12 | veterinario | ck_vet_pacientes | CHECK (entre columnas) | `num_pacientes` solo si es dermatólogo, y ≥ 0 |
| 13 | veterinario | ck_vet_cirugias | CHECK (entre columnas) | `num_cirugias` solo si es cirujano, y ≥ 0 |
| 16 | cita | ck_cita_diagnostico | CHECK (formato) | El diagnóstico, si existe, no está en blanco |
| 17 | cita | uq_cita_veterinario_fecha_hora | UNIQUE | Un veterinario no tiene dos citas a la misma hora |
| 18 | tratamiento | ck_tratamiento_descripcion | CHECK (formato) | Descripción no vacía |
| 19 | tratamiento | ck_tratamiento_fechas | CHECK (entre columnas) | Vencimiento ≥ fecha del tratamiento |

Además: NOT NULL en las columnas obligatorias, DEFAULT en `es_dermatologo`, `es_cirujano`, y las 4 claves foráneas (recreadas igual tras el cambio de tipo).

# Carga de datos (ejercicio 1.4)

Un solo comando llena la base. Solo necesita `psql`. La base ya debe tener el esquema y las migraciones.

## Orden de ejecución (desde la carpeta `practica4`)

```
1. esquema.sql                      (Práctica 3)
2. dominios.sql
3. restricciones.sql
4. amplia-raza.sql
5. psql -v ON_ERROR_STOP=1 -f poblar/poblar.sql
```

`php poblar/preparar_datos.php` limpia el CSV de Seattle y genera los datos sintéticos en `datos/csv/`. Los CSV ya están incluidos; solo se corre si se quieren regenerar (usa semilla fija, siempre produce lo mismo).

## Conexión (variables de entorno, sin contraseñas en el código)

PowerShell:
```
$env:PGHOST="localhost"; $env:PGPORT="5432"; $env:PGDATABASE="veterinaria_p4"
$env:PGUSER="postgres"; $env:PGPASSWORD="<tu contraseña>"
psql -v ON_ERROR_STOP=1 -f poblar/poblar.sql
```
Bash:
```
export PGHOST=localhost PGPORT=5432 PGDATABASE=veterinaria_p4 PGUSER=postgres PGPASSWORD='<tu contraseña>'
psql -v ON_ERROR_STOP=1 -f poblar/poblar.sql
```

## Qué cumple

| Requisito | Cómo |
|---|---|
| Repetible | `ON CONFLICT DO NOTHING`: lo que ya existe se omite. La segunda corrida inserta 0 (`evidencias/carga-2-segunda.txt`). |
| Ordenado | dueno → veterinario → mascota → cita → tratamiento. |
| Todo o nada | Una transacción y `ON_ERROR_STOP`: al primer error se detiene y no se guarda nada. El mensaje trae la línea del CSV y el motivo (`evidencias/carga-0-falla.txt`). |
| Con cuentas | Tabla final: leídos, insertados, ya existían, rechazados. |
| Sin credenciales | Variables de entorno `PG*`. |
| Eficiente | `\copy` a una tabla temporal y luego `INSERT … SELECT`. |

## Comparación de tiempos (1 700 renglones, base local)

| Modo | Tiempo |
|---|---|
| `\copy` (`poblar.sql`) | 0.04 s y 0.07 s |
| Un `INSERT` por renglón (`poblar-insert.sql`) | 0.24 s y 0.27 s |

`\copy` fue unas 4 veces más rápido. Con 1 700 renglones la diferencia absoluta es pequeña; crece con el volumen. `-v vaciar=1` vacía las tablas antes de cargar y solo sirve para comparar (`evidencias/carga-3-comparacion.txt`).

## Lo que rechazaron las restricciones

| Restricción | Dónde | Causa | Decisión |
|---|---|---|---|
| `mascota.raza` `VARCHAR(40)` | Primera corrida, línea 8 del CSV: "Mixed Breed, Medium (up to 44 lbs fully grown)" (en el conjunto completo, 1 958 razas pasan de 40 caracteres) | El dato es válido; el límite de la columna era demasiado corto | Se corrige la restricción con `migraciones/003-amplia-raza.sql` (`VARCHAR(50)`) |

Después de la migración no hubo más rechazos. Lo que se limpia antes de cargar (sin nombre, otras especies, duplicados) está en `fuente.md`.

## Datos sintéticos

Dueños, veterinarios, citas y tratamientos son **sintéticos** (ver `fuente.md`). Las mascotas son reales (Seattle), salvo `sexo`, `edad`, `peso_ideal`, `color_pelaje` y `codigo_dueno`, que se generan.

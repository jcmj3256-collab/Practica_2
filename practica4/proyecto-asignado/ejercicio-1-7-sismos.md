# Ejercicio 1.7. El proyecto asignado: sus datos y sus dominios (Sismos)

* **Proyecto asignado:** Sistema de visualización de datos sísmicos de México ([`gabrielhuav/Seismic-Data-Visualization-System`](https://github.com/gabrielhuav/Seismic-Data-Visualization-System))
* **Fork del equipo:** [`FERVERDZ18/Seismic-Data-Visualization-System`](https://github.com/FERVERDZ18/Seismic-Data-Visualization-System)
* **Artículo de referencia:** Villa Vargas, J. M., Hurtado Avilés, G., y Climent Hernández, J. A. (2026). *Cuando México tiembla: la historia contada por los datos*. AZCATL Revista de Divulgación en Ciencias, Ingeniería e Innovación, 4(6), 28–33. [https://doi.org/10.24275/AZC2026E1004](https://doi.org/10.24275/AZC2026E1004)
* **Fuentes verificables:** Catálogo público del Servicio Sismológico Nacional (SSN - UNAM), Censo de Población y Vivienda 2020 (INEGI) y Censos Económicos 2024 (INEGI).

## 1.7.1. Script de carga del almacén de Sismos con los requisitos del Ejercicio 1.4

El almacén de datos se puebla mediante el script [`poblar_sismos.sh`](poblar_sismos.sh) y el archivo SQL transaccional [`pruebas_dominio_sismos.sql`](pruebas_dominio_sismos.sql), cumpliendo los 6 criterios del Ejercicio 1.4:

1. **Repetible:** Utiliza `TRUNCATE TABLE fact_impacto_sismos_imputed, dim_zonas, dim_tiempo, dim_sismos, dim_economia RESTART IDENTITY CASCADE;` e inserciones idempotentes (`ON CONFLICT DO NOTHING`), por lo que ejecutarlo dos o más veces consecutivas produce exactamente el mismo estado sin duplicar renglones ni arrojar error.
2. **Ordenado:** Carga primero las cuatro tablas de dimensiones independientes (`01-dim_zonas.sql`, `02-dim_tiempo.sql`, `03-dim_sismos.sql`, `04-dim_economia.sql`) y al final la tabla de hechos (`05-fact_impacto_sismos_imputed.sql`) que depende referencialmente de ellas.
3. **Todo o nada (Atomicidad):** Ejecuta la carga dentro de un bloque `BEGIN ... COMMIT` con `-v ON_ERROR_STOP=1` en `psql`. Si cualquier fila viola una restricción o formato, la transacción completa hace `ROLLBACK` e informa qué renglón y qué restricción fallaron.
4. **Con cuentas:** Al concluir la transacción, ejecuta una consulta resumen que informa cuántos renglones quedaron insertados y cuántos fueron rechazados en cada una de las 5 tablas del almacén.
5. **Sin credenciales adentro:** La conexión lee exclusivamente las variables de entorno `$PGHOST`, `$PGPORT`, `$PGUSER`, `$PGPASSWORD` y `$PGDATABASE` (o las variables internas del contenedor `$POSTGRES_USER` y `$POSTGRES_DB`).
6. **Eficiente:** Emplea carga masiva por lotes (`\copy` / bloques multi-tupla en un único `BEGIN...COMMIT`) en lugar de abrir una transacción `INSERT` individual por renglón, reduciendo el tiempo de carga de los archivos de `dim_sismos` (69.4 MB), `dim_tiempo` (41.9 MB) y `fact_impacto_sismos_imputed` (56.4 MB) de varios minutos a pocos segundos.

## 1.7.2. Comparación entre los datos obtenidos y lo que reporta el artículo

| Tabla del almacén (`sql/00-datawarehouse_tables.sql`) | Fuente original reportada en el artículo | Renglones obtenidos en la carga | Comparación con el artículo y explicación de diferencias |
| :--- | :--- | :--- | :--- |
| **`dim_zonas`** (`01-dim_zonas.sql`) | INEGI — Censo de Población y Vivienda (CPV 2020) | **32 renglones** | Coincide exactamente con las **32 entidades federativas** de la República Mexicana (`entidad` 1 a 32 con `pobtot`, `pobfem` y `pobmas`). |
| **`dim_economia`** (`04-dim_economia.sql`) | INEGI — Censos Económicos (CE 2024) | **32 renglones** | Coincide exactamente con los indicadores macroeconómicos agregados por cada una de las **32 entidades federativas**. |
| **`dim_tiempo`** (`02-dim_tiempo.sql`) | Marcas temporales UTC del catálogo del SSN | **Volcado estático (41.9 MB / muestra verificada)** | Contiene el desglose calendárico (`fecha`, `hora_utc`, `anio`, `mes`, `dia`, `trimestre`) de los instantes en que ocurrieron los eventos sísmicos del corte del repositorio. |
| **`dim_sismos`** (`03-dim_sismos.sql`) | Servicio Sismológico Nacional (SSN - UNAM) | **Volcado estático (69.4 MB / muestra verificada)** | El catálogo público vivo del SSN aumenta diariamente; el repositorio congela el recorte histórico hasta la fecha de extracción del proyecto (2025) y descarta registros con magnitud `"no calculable"` o sin coordenadas válidas. |
| **`fact_impacto_sismos_imputed`** (`05-fact_impacto_sismos_imputed.sql`) | Cruce SSN + INEGI con imputación estadística | **Volcado estático (56.4 MB / muestra verificada)** | Su conteo difiere del catálogo crudo del SSN porque solo conserva eventos que pudieron asociarse a una de las 32 entidades federativas y a los cuales se les aplicó imputación de `impacto_economico` e `indice_zscore`. |

### ¿Por qué los números de un corte nuevo del SSN no son idénticos al volcado del artículo?
1. **Periodo de corte de los datos:** El catálogo del SSN es una serie de tiempo continua; el repositorio congela los archivos SQL estáticos al corte de construcción del almacén.
2. **Limpieza de magnitudes no numéricas:** En los archivos crudos del SSN existen microsismos cuya magnitud aparece como texto `"no calculable"` o vacío; el proceso ETL del artículo los filtra o imputa antes de poblar `dim_sismos`, pues la columna `magnitud DOUBLE PRECISION` solo admite valores numéricos.
3. **Mapeo geoadministrativo estatal:** Los sismos con epicentro marítimo lejano que no contienen abreviatura de estado válida en `referencia_de_localizacion` se recodifican o excluyen al cruzar con las 32 entidades de `dim_zonas` y `dim_economia`.

## 1.7.3. Revisión de restricciones de dominio del esquema y propuesta de 3 nuevas restricciones en copia

### A. Qué declara actualmente el esquema (`sql/00-datawarehouse_tables.sql`) y qué le falta

Al inspeccionar `sql/00-datawarehouse_tables.sql` en el repositorio oficial del proyecto asignado:

```sql
CREATE TABLE dim_sismos (
    id_sismo INT PRIMARY KEY,
    magnitud DOUBLE PRECISION,
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    profundidad DOUBLE PRECISION,
    referencia_de_localizacion VARCHAR(100),
    estado VARCHAR(100),
    nombre_estado VARCHAR(100)
);
```

* **Lo que sí declara:** Únicamente las claves primarias (`PRIMARY KEY`) en las 4 dimensiones y las 4 claves foráneas (`FOREIGN KEY`) en `fact_impacto_sismos_imputed`.
* **Lo que le falta (huecos de dominio detectados):**
  1. **Ausencia de `NOT NULL`:** Ninguna columna no clave tiene `NOT NULL`, permitiendo insertar sismos sin magnitud, sin coordenadas o fechas vacías en `dim_tiempo`.
  2. **Uso de punto flotante (`DOUBLE PRECISION`) en montos económicos:** En `dim_economia`, columnas monetarias como `produccion_bruta_total`, `insumos_utilizados` y `valor_agregado` usan `DOUBLE PRECISION` en lugar de `NUMERIC(18,2)`, exponiendo el almacén a errores de redondeo binario.
  3. **Cero restricciones `CHECK`:** No valida que la magnitud o profundidad sean positivas, que el mes esté entre 1 y 12, ni que la suma de población femenina y masculina coincida con la población total.

### B. Tres restricciones de dominio propuestas y probadas en una copia con datos reales

En el script [`pruebas_dominio_sismos.sql`](pruebas_dominio_sismos.sql) creamos copias de las tablas del almacén de Sismos (`copia_17_dim_sismos`, `copia_17_dim_tiempo`, `copia_17_dim_zonas`) y aplicamos con `ALTER TABLE` tres restricciones `CHECK` justificadas por su regla del dominio:

| # | Tabla copia | Nombre de la restricción | Declaración SQL (`CHECK`) | Regla del dominio en una línea | ¿Los datos reales del repositorio la cumplen? |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | `copia_17_dim_sismos` | `ck_sismos_magnitud_profundidad` | `CHECK (magnitud > 0 AND magnitud <= 10.0 AND profundidad >= 0)` | Todo sismo instrumentado por el SSN debe tener magnitud positiva en escala sismológica (`0 < M <= 10`) y profundidad focal no negativa (`>= 0 km`). | **Sí la cumplen** los datos limpios del almacén; rechaza de inmediato cualquier intento de insertar profundidad negativa (`-5.0 km`) o magnitud `0`. |
| **2** | `copia_17_dim_tiempo` | `ck_tiempo_calendario_valido` | `CHECK (mes BETWEEN 1 AND 12 AND dia BETWEEN 1 AND 31 AND trimestre BETWEEN 1 AND 4 AND anio >= 1900)` | Los componentes calendáricos de un registro sísmico deben corresponder a un mes (`1–12`), día (`1–31`), trimestre (`1–4`) y año instrumental válidos. | **Sí la cumplen** todos los registros de `02-dim_tiempo.sql`; bloquea errores de parseo de fechas (como `mes = 13` o `trimestre = 5`). |
| **3** | `copia_17_dim_zonas` | `ck_zonas_coherencia_censal` | `CHECK (pobtot > 0 AND pobfem >= 0 AND pobmas >= 0 AND (pobfem + pobmas) = pobtot)` | En el Censo de Población y Vivienda del INEGI, la población de cada entidad federativa es positiva y la suma de mujeres más hombres debe igualar la población total (`pobtot`). | **Sí la cumplen** las 32 entidades de `01-dim_zonas.sql` (p. ej., Aguascalientes: `728,924 + 696,683 = 1,425,607`); rechaza filas con sumas demográficas descuadradas. |

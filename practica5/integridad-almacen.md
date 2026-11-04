# Ejercicio 2.5: Integridad referencial en el almacén asignado (Sismos)

## 1. Tabla de hechos, dimensiones y granularidad

En el almacén dimensional del proyecto asignado (**Sistema de Visualización de Datos Sísmicos de México** — `Seismic-Data-Visualization-System`):

* **Tabla de hechos:** `fact_impacto_sismos_imputed` (`id_hecho`, `id_sismo`, `id_zona`, `id_tiempo`, `id_economia`, `magnitud`, `profundidad`, `pga_estimado`, `indice_impacto`).
* **Dimensiones:**
  1. `dim_sismos`: Datos epicentrales del evento (`id_sismo`, `latitud`, `longitud`, `referencia`).
  2. `dim_zonas`: Ubicación geoadministrativa (`id_zona`, `cve_ent`, `nom_ent`, `cve_mun`, `nom_mun`).
  3. `dim_tiempo`: Jerarquía temporal (`id_tiempo`, `fecha`, `hora`, `anio`, `mes`, `trimestre`).
  4. `dim_economia`: Indicadores socioeconómicos (`id_economia`, `pib_municipal`, `grado_marginacion`, `poblacion_expuesta`).
* **Granularidad:** Un renglón de la tabla de hechos representa **el impacto físico y socioeconómico de un evento sísmico único ocurrido en una fecha/hora determinada sobre un municipio específico de México**.

## 2. Revisión de claves foráneas y búsqueda de hechos huérfanos

El esquema analítico original **no declara restricciones `FOREIGN KEY`** explícitas entre la tabla de hechos y las dimensiones. Mediante `practica5/sql/integridad_almacen.sql` se verifica la existencia de huérfanos con `LEFT JOIN`:

```sql
SELECT 'hechos -> dim_zonas' AS relacion, COUNT(*) AS huerfanos
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_zonas z ON f.id_zona = z.id_zona
WHERE f.id_zona IS NOT NULL AND z.id_zona IS NULL
UNION ALL
SELECT 'hechos -> dim_tiempo', COUNT(*)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_tiempo t ON f.id_tiempo = t.id_tiempo
WHERE f.id_tiempo IS NOT NULL AND t.id_tiempo IS NULL
UNION ALL
SELECT 'hechos -> dim_sismos', COUNT(*)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_sismos s ON f.id_sismo = s.id_sismo
WHERE f.id_sismo IS NOT NULL AND s.id_sismo IS NULL
UNION ALL
SELECT 'hechos -> dim_economia', COUNT(*)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_economia e ON f.id_economia = e.id_economia
WHERE f.id_economia IS NOT NULL AND e.id_economia IS NULL;
```

## 3. Declaración de claves foráneas en una copia y explicación arquitectónica

Al crear las copias (`copia_fact_impacto_sismos` y `copia_dim_*`) y ejecutar `ALTER TABLE copia_fact_impacto_sismos ADD CONSTRAINT ... FOREIGN KEY`, los datos limpios cumplen las 4 restricciones referenciales con `ON DELETE RESTRICT`.

* **¿Por qué un almacén de datos a veces omite las claves foráneas a propósito?**
  1. **Velocidad de carga masiva (ETL/ELT):** Durante la ingesta por lotes de cientos de miles de registros sísmicos, validar cada fila contra 4 índices B-Tree de dimensiones ralentiza significativamente la escritura.
  2. **Dimensiones de llegada tardía (*Late-Arriving Dimensions*):** El registro instrumental del sismo (SSN) llega en tiempo real antes de que se actualicen o crucen los catálogos socioeconómicos y municipales del INEGI.
* **¿Qué riesgo corre al omitirlas?**
  1. **Hechos huérfanos e invisibles en consultas:** Si un hecho apunta a un `id_zona` inexistente, cualquier reporte con `INNER JOIN` descarta silenciosamente ese sismo, alterando las estadísticas y sumas por estado o municipio.

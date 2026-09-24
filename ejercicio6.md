# Ejercicio 6. Propuestas de Mejora

- **Proyecto asignado:** Seismic-Data-Visualization-System
- **Repositorio de trabajo:** https://github.com/jcmj3256-collab/Practica_2
- **Materia:** Bases de Datos — Práctica 2

---

## Propuestas Individuales

### Propuesta 1: Ingesta en tiempo real y consumo de alertas sísmicas del SSN
- **Autor / Asignado:** Garcia Verduzco Fernando
- **Issue en GitHub:** [Ver Issue #1](https://github.com/jcmj3256-collab/Practica_2/issues/1)

1. **Título breve y problema que atiende:**  
   *Ingesta en tiempo real y consumo de alertas sísmicas del SSN.*  
   *Problema:* El sistema actual es meramente histórico y estático; depende de datos cargados previamente en el almacén analítico y no permite visualizar eventos telúricos recientes ni alertar a usuarios sobre sismos que acaban de ocurrir.
2. **Descripción de la funcionalidad (perspectiva del usuario):**  
   Un analista de protección civil o ciudadano podrá acceder a una pestaña interactiva de "Monitoreo en Vivo" donde observará un mapa con los sismos ocurridos en las últimas 24 horas actualizados automáticamente vía API/Websockets, visualizando indicadores destacados para eventos con magnitud $\ge 5.0$.
3. **Cambios en el modelo de datos (sobre el modelo del Ejercicio 5):**  
   - Se añade a la entidad `EVENTO_SISMICO` los atributos `en_tiempo_real` (booleano) y `estatus_revision` (cadena: preliminar / verificado).
   - Se crea una nueva entidad `ESTACION_MONITOREO` (atributos: `id_estacion`, `nombre_estacion`, `coordenadas_gps`, `estado_operativo`) vinculada a `EVENTO_SISMICO` mediante la relación `DETECTA` con cardinalidad `(1, N)`.
4. **En qué se apoya:**  
   Hallazgo al poner en funcionamiento el sistema con Docker: la base de datos solo almacena series históricas e imputadas (`fact_impacto_sismos_imputed`), careciendo de un pipeline de ingesta continua para eventos vigentes.
5. **Dificultad estimada y justificación:**  
   **Media:** Requiere configurar un microservicio o tarea programada (worker/cron) en Python que consuma periódicamente la API pública del SSN y actualice la base de datos sin degradar el rendimiento del contenedor.

---

### Propuesta 2: Desagregación geoespacial del impacto sísmico a nivel municipal
- **Autor / Asignado:** Garcia Verduzco Fernando
- **Issue en GitHub:** [Ver Issue #2](https://github.com/jcmj3256-collab/Practica_2/issues/2)

1. **Título breve y problema que atiende:**  
   *Desagregación geoespacial del impacto sísmico a nivel municipal.*  
   *Problema:* La dimensión territorial actual está agregada únicamente a nivel estatal (`dim_zonas`), lo que distorsiona el análisis de riesgo, ya que un sismo de gran magnitud suele afectar severamente municipios costeros pero no impacta con la misma intensidad a municipios del interior del mismo estado.
2. **Descripción de la funcionalidad (perspectiva del usuario):**  
   Un investigador o tomador de decisiones gubernamentales podrá aplicar zoom sobre el mapa y seleccionar municipios individuales para consultar el índice de marginación local, densidad demográfica y el historial de daños específicos en esa localidad ante sismos históricos.
3. **Cambios en el modelo de datos (sobre el modelo del Ejercicio 5):**  
   - Se introduce una nueva entidad `MUNICIPIO_LOCALIDAD` (atributos: `id_municipio`, `nombre_municipio`, `clave_inegi`, `geometria_poligono`).
   - Se modela una relación `COMPONE` entre `ESTADO_ZONA` y `MUNICIPIO_LOCALIDAD` con cardinalidad `(1, N)`.
   - La entidad débil `IMPACTO_TERRITORIAL` se conecta ahora a `MUNICIPIO_LOCALIDAD` en lugar de estar acoplada únicamente a nivel macroestatal.
4. **En qué se apoya:**  
   Limitación identificada en el proyecto asignado: la pérdida de granularidad espacial al construir la tabla dimensional `dim_zonas` impide evaluar la vulnerabilidad real de las comunidades locales más afectadas.
5. **Dificultad estimada y justificación:**  
   **Baja:** La cartografía municipal y datos de censo están disponibles en formato abierto por INEGI; solo requiere ampliar el pipeline ETL e incorporar geometrías GeoJSON a la capa de visualización.

---

### Propuesta 3: Módulo de simulación predictiva de pérdidas económicas e infraestructura
- **Autor / Asignado:** Garcia Verduzco Fernando
- **Issue en GitHub:** [Ver Issue #3](https://github.com/jcmj3256-collab/Practica_2/issues/3)

1. **Título breve y problema que atiende:**  
   *Módulo de simulación predictiva de pérdidas económicas e infraestructura mediante Machine Learning.*  
   *Problema:* El sistema actual muestra únicamente métricas descriptivas e imputadas del pasado (`pib_estatal`, `poblacion`), pero no provee capacidades analíticas predictivas para estimar los costos económicos ni el daño de futuros eventos de gran magnitud.
2. **Descripción de la funcionalidad (perspectiva del usuario):**  
   El usuario podrá ingresar parámetros hipotéticos en un formulario web (magnitud esperada, coordenadas de epicentro y profundidad) y el sistema generará una proyección probabilística de los daños económicos estimados, infraestructura crítica en riesgo (hospitales, escuelas) y población vulnerable afectada.
3. **Cambios en el modelo de datos (sobre el modelo del Ejercicio 5):**  
   - Se crea la entidad `ESCENARIO_SIMULACION` (atributos: `id_simulacion`, `fecha_creacion`, `modelo_ml_version`, `costo_estimado_danos`, `intervalo_confianza`).
   - Se modela la relación `SIMULA` entre la subentidad `SISMO_MAYOR` y `ESCENARIO_SIMULACION` con cardinalidad `(1, N)`.
4. **En qué se apoya:**  
   Línea de trabajo futuro usualmente destacada en la literatura de visualización de riesgos naturales: transicionar de un análisis descriptivo retrospectivo (OLAP tradicional) hacia modelos predictivos y de evaluación de escenarios para mitigación de desastres.
5. **Dificultad estimada y justificación:**  
   **Alta:** Implica entrenar y validar modelos de regresión multivariable con datos de CONAPO, CENAPRED e INEGI, así como desplegar un endpoint de inferencia en el contenedor web.
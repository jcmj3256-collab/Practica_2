# Ejercicio 6. Propuestas de Mejora

- **Proyecto asignado:** Seismic-Data-Visualization-System
- **Repositorio de trabajo:** https://github.com/jcmj3256-collab/Practica_2
- **Materia:** Bases de Datos — Práctica 2

---

## Propuestas Individuales

### Propuesta 1: Ingesta en tiempo real y consumo de alertas sísmicas del SSN
- **Autor / Asignado:** Garcia Verduzco Fernando
- **Issue en GitHub:** [Ver Issue #2](https://github.com/jcmj3256-collab/Practica_2/issues/2)

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
- **Issue en GitHub:** [Ver Issue #3](https://github.com/jcmj3256-collab/Practica_2/issues/3)

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
- **Issue en GitHub:** [Ver Issue #4](https://github.com/jcmj3256-collab/Practica_2/issues/4)

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
---
## Propuesta 1: Visualización tridimensional de eventos sísmicos

Issue: [https://github.com/jcmj3256-collab/Practica_2/issues/6] 

El sistema actual solo representa los sismos en mapas bidimensionales, lo que dificulta percibir de forma intuitiva la relación entre profundidad del epicentro y su impacto en superficie, dos variables que en la realidad interactúan de forma tridimensional.

Un investigador o usuario interesado podrá activar una vista "3D" dentro del mapa interactivo, donde los sismos se representen como esferas o columnas cuya altura/profundidad en el eje Z corresponda a la profundidad real del hipocentro, y cuyo tamaño o color represente la magnitud, permitiendo comparar visualmente sismos superficiales (más destructivos) contra sismos profundos de la misma magnitud.

Cambios en el modelo de datos (sobre el modelo del Ejercicio 5):
Se crea una nueva entidad MODELO_3D (atributos: id_modelo, tipo_proyeccion, escala_profundidad) relacionada con la tabla de hechos fact_impacto_sismos_imputed mediante la relación RENDERIZA con cardinalidad (1,N), reutilizando el atributo de profundidad ya existente en el modelo para alimentar esta nueva capa de visualización.

En qué se apoya:
Trabajo futuro declarado explícitamente por los autores: "como trabajo futuro se plantea habilitar visualizaciones en 3D".

Para implementarlo se requiere integrar una librería de renderizado 3D (como Three.js) en el frontend y adaptar el backend para exponer las coordenadas de profundidad en el formato que esa librería necesita.

---
## Propuesta 2: Historial de daños reportados por sismo

Issue: [https://github.com/jcmj3256-collab/Practica_2/issues/7] 

El sistema actual solo almacena magnitud, profundidad y ubicación de los sismos, pero no registra qué daños concretos (materiales, humanos o económicos) causó cada evento, limitando su utilidad para análisis de impacto real.

Un investigador podrá seleccionar un sismo específico en el mapa y consultar, además de sus datos técnicos, un resumen de los daños reportados oficialmente (viviendas afectadas, costo estimado, número de reportes), permitiendo comparar el impacto real entre sismos de magnitud similar.

Se crea una nueva entidad débil DAÑO_REPORTADO (dependencia de existencia respecto a fact_impacto_sismos_imputed), con atributos tipo_dano, costo_estimado, fuente_reporte, vinculada mediante la relación GENERA con cardinalidad (1,N).

Una necesidad identificada por el equipo: el artículo no menciona esta limitación explícitamente, pero al revisar el modelo de datos del Ejercicio 5 notamos que no existe forma de registrar el impacto real de un sismo más allá de sus datos técnicos, lo cual sería una adición valiosa usando datos abiertos del CENAPRED.

Para implementarlo se requieren los reportes del CENAPRED que no siempre están estructurados de forma consistente, por lo que se necesitaría trabajo adicional de limpieza en el proceso ETL.

---
## Propuesta 3: Guías de prevención por zona

Issue: [https://github.com/jcmj3256-collab/Practica_2/issues/8] 

El sistema actual muestra datos técnicos y estadísticos de los sismos, pero no ofrece ninguna orientación práctica al usuario sobre qué hacer o cómo prepararse ante el riesgo sísmico de su zona.

Un ciudadano que consulte el mapa de su colonia o municipio podrá ver, junto a los datos sísmicos de esa zona, una lista de recursos recomendados (videos, infografías o guías de protocolo civil) relacionados con el nivel de riesgo detectado ahí, ayudando a traducir los datos técnicos en acciones concretas de prevención.

Se crea una nueva entidad RECURSO_EDUCATIVO (atributos: id_recurso, titulo, tipo [video/infografía/guía], url_recurso) relacionada con dim_zonas mediante la relación RECOMENDADO_PARA con cardinalidad (N,N), ya que un mismo recurso puede aplicar a varias zonas, y una zona puede tener varios recursos recomendados.

Uso previsto declarado por los autores: el artículo menciona explícitamente que el sistema "está diseñado para emplearse... en el ámbito de la educación y en la concientización pública, donde se pueden proporcionar mapas regionales que muestren a las comunidades locales el riesgo latente en su territorio y así arraigar en ellas la cultura de la prevención ante los desastres sísmicos".

No requiere procesamiento de datos complejo, solo una tabla de contenido curado manualmente y su relación con las zonas existentes.

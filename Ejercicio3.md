# Artículo 1 
## 1. Qué problema aborda y por qué importa.

Se aborda el problema de los sismos, que son
un fenómeno natural que sucede a menudo en México. El estudio de estos
fenómenos ayuda a la concientización del público general para la prevención y
preparación para posibles afectaciones de estos fenómenos.  

## 2. De dónde provienen los datos, en qué
formato estaban y qué tuvo que hacerse para poder usarlos.

Los datos fueron extraídos del SSN (Servicio Sismológico Nacional), estos llevaban un formato muy técnico el cual no podía
ser entendido por personas que no tuvieran relación con el tema, por lo que se desarrolló un sistema con el cual las personas pudieran interactuar y además
obtener información más visual e intuitiva. 

## 3. Cómo se modeló la información: qué entidades o dimensiones se identificaron, qué hechos se miden y cómo se relacionan.

Se identificaron principalmente las siguientes
dimensiones o entidades:

- **Sismos:** contiene información como magnitud, profundidad, ubicación, fecha y coordenadas del evento.

- **Población:** contiene información demográfica de las localidades, como el número de habitantes.

- **Economía:** contiene información económica de las zonas, relacionada con su producción económica.

- **Ubicación geográfica:** permite relacionar los sismos con estados, localidades y coordenadas donde ocurrieron.

El principal hecho que se mide es la actividad
sísmica, utilizando datos como la magnitud, profundidad, ubicación y periodo de
ocurrencia. Estos datos pueden analizarse junto con medidas demográficas, como
el número de habitantes, y económicas, como la producción de una zona. El
sistema permite filtrar la información por tiempo, magnitud, localidad,
profundidad, habitantes y producción económica.

Las relaciones se establecen principalmente
mediante la ubicación geográfica y el periodo de tiempo: los eventos sísmicos
pueden relacionarse con las poblaciones cercanas y con la información económica
de esas zonas. Esto permite analizar, por ejemplo, qué localidades densamente
pobladas se encuentran cerca de los epicentros y estudiar el posible impacto
sísmico sobre una región.

En términos generales, el modelo integra datos
sísmicos + datos demográficos + datos económicos, permitiendo analizarlos
conjuntamente para generar mapas, estadísticas, mapas de calor y reportes
personalizados.

## 4. Qué preguntas concretas puede responder el sistema resultante.

Donde han ocurrido sismo de cierta magnitud,
mapas que muestran que lugares son los más propensos a sufrir sismos, lugares
densamente poblados, entre otros filtros como periodo de tiempo.

## 5. Qué limitaciones reconocen los autores y qué trabajo futuro proponen.

La mayor limitación propuesta por los autores es que este tipo de fenómenos no se pueden predecir, a diferencia del clima o
la temperatura durante el día. En el futuro se podría habilitar visualizaciones en 3D, otras fuentes de datos oficiales y un sistema de alerta temprana. 


# Articulo 2 
## 1. Qué problema aborda y por qué importa.

Este articulo aborda el uso desmedido del agua en la CDMX, y de como esta empezando a haber un crisis por la sobreexplotación
de acuíferos, causado por fugas de agua y la sobrepoblación. Esto es importante ya que aunque existe escasez de agua en varias colonias, todavía no es un caso
generalizado, y se puede prevenir. 
## 2. De dónde provienen los datos, en qué formato estaban y qué tuvo que hacerse para poder usarlos.

Los datos fueron conseguidos del Sistema de Aguas de la Ciudad de México (SACMEX). Esta estaba en formatos poco accesibles
(CSV), además de no contar con herramientas de consulta para organizar la información o buscar datos específicos. Los datos se almacenaron en un
repositorio en el cual, se crearon otras herramientas para hacer mas intuitiva la información, como métodos de consulta o por medio de mapas. 
## 3. Cómo se modeló la información: qué entidades o dimensiones se identificaron, qué hechos se miden y cómo se relacionan.

La información se modeló mediante un esquema en estrella dentro de un data warehouse. Se
identificaron dos tablas de hechos: fact_consumo_agua, que mide el volumen de
consumo de agua (analizado de forma agregada por alcaldía y por bimestre), y
fact_clima, que mide variables climáticas (el artículo no detalla cuáles
específicamente).

Ambas tablas de hechos
se relacionan entre sí a través de la dimensión temporal compartida dim_tiempo
(fecha, año, bimestre), lo cual permite cruzar el consumo de agua con las
condiciones climáticas de un mismo periodo. El artículo no confirma explícitamente
que dim_ubicacion y dim_indice_des también sean compartidas por ambas tablas de
hechos, por lo que es posible que estas dos apliquen únicamente a
fact_consumo_agua.

Las dimensiones
identificadas son:
- dim_tiempo: fecha, año y bimestre — mide  el momento temporal del registro.
- dim_ubicacion: alcaldía, colonia, latitud y longitud — identifica la ubicación geográfica del consumo.
- dim_indice_des: nivel de desarrollo — mide qué tan desarrollada es la infraestructura de la zona.
## 4. Qué preguntas concretas puede responder el sistema resultante.

Que alcaldías tienen mayor consumo de agua, como varia el consumo por el año,
como afecta el desarrollo de la zona con el consumo de agua, como se ve este
consumo en un mapa, etc. 

## 5. Qué limitaciones reconocen los autores y qué trabajo futuro proponen.

Para el futuro los autores proponen mejorar la precisión de los datos, poder conectar con otros tipos de bases de datos, que
sea mas fácil detectar anomalías y poder aplicarlo a otros problemas urbanos. 


# Resumen: Obra pública municipal (González Casiano et al.)
## 1. Qué problema aborda y por qué importa

Aborda la falta de transparencia, trazabilidad histórica y fragmentación de la información en la
gestión de obra pública a nivel municipal en México. 

En los municipios rurales y pequeños, la administración suele depender de hojas de cálculo
aisladas, sistemas de archivos locales o sistemas transaccionales que impiden
auditar modificaciones en los presupuestos, detectar retrasos de manera
temprana o integrar la participación ciudadana. 

Es importante porque las plataformas analíticas empresariales o implementaciones comerciales de *Data
Lakehouse* resultan económica y técnicamente inviables para los presupuestos
de municipios pequeños. Resolver esto mediante una arquitectura accesible
permite una rendición de cuentas efectiva, auditable y abierta a la ciudadanía.

## 2. De dónde provienen los datos, en qué formato estaban y qué tuvo que hacerse para poder usarlos

Origen: Los datos utilizados en el prototipo son de naturaleza sintética, simulando las
características demográficas y territoriales del municipio de Temascaltepec,
Estado de México (64,844 habitantes y 55 comunidades). Se emplearon generadores
sintéticos basados en la librería *Faker* debido a que las restricciones
de privacidad impiden la publicación directa de expedientes municipales reales.


Formatos de entrada: La aplicación web de captura recibe tanto datos estructurados (montos,
coordenadas geográficas, textos de contratos) como evidencias no estructuradas
y binarias (fotografías en formatos JPG/PNG e informes en archivos PDF). 

Tratamiento y procesamiento: Los datos estructurados se envían a través de una API REST
(Flask/Python) hacia una base transaccional en PostgreSQL/Supabase. Las
evidencias binarias se ingieren directamente hacia un almacenamiento de objetos
compatible con S3 (Cloudflare R2), organizadas mediante particionamiento Hive
(works/{work_id}/reports/{year}-{month}/...). En lugar de un proceso ETL
externo por lotes, se configuraron disparadores internos (*triggers*) en
la base de datos que sincronizan y transforman de forma transaccional los
registros hacia el esquema dimensional, aplicando versionado temporal e
insertando eventos de auditoría. 

## 3. Cómo se modeló la información: entidades, dimensiones, hechos y relaciones

Esquema: Se implementó un modelo dimensional en estrella (*star schema*) compuesto por 10
dimensiones y 2 tablas de hechos: 

Dimensiones (10):

*Dimensiones de Cambio Lento Tipo 2 (SCD 2):* dim_work (obras), dim_region (comunidades/zonas), dim_company (contratistas),
dim_staff (personal supervisor/directivo) y dim_budget (presupuestos). Conservan el historial mediante intervalos de vigencia temporal
(effective_date, expiration_date, is_current) para permitir auditorías retroactivas. 

*Dimensiones de Tipo 1 (SCD 1):* dim_source (fuentes de financiamiento), dim_citizen (ciudadanos) y dim_proposal (propuestas
ciudadanas), donde los datos se sobreescriben al no requerir preservación histórica. 

*Dimensiones de Tipo 0 (SCD 0):* dim_time (tiempo) y dim_event_type (catálogo estático de 17 tipos de eventos). 

Tablas de hechos (2):

fact_audit_events: Grano de una fila por cada evento atómico de auditoría (creación de obra,
asignación, modificaciones de contrato, cargas de evidencia fotográfica, votos
ciudadanos), con particionamiento por rango de año. 

fact_work_monthly: Grano periódico mensual de una fila por obra y mes calendario; registra
métricas acumuladas como presupuesto total, costo devengado, saldo, avance
físico, avance financiero, días de desfase y una bandera booleana de retraso. 

Relaciones: Ambas tablas de hechos se interconectan con las dimensiones mediante claves
subrogadas (*surrogate keys*). Se definieron seis vistas analíticas en SQL
encargadas de calcular retrasos, alertas de auditoría, trazabilidad SCD 2,
agregaciones de presupuesto ejecutado y detección de anomalías. 
## 4. Qué preguntas concretas puede responder el sistema resultante

El sistema y sus
vistas analíticas responden consultas operativas, históricas y geoespaciales
como: 

¿Cuál era el presupuesto autorizado vigente de una obra exactamente en la fecha en que se
emitió un pago modificado, en lugar del monto actual? 

Si un contratista fue reemplazado a mitad de un proyecto, ¿qué porcentaje de avance físico
corresponde a la empresa original y cuál a la nueva? 

¿Qué obras públicas presentan retrasos críticos superiores a 120 días respecto a su calendario
contractual? 

¿Existen obras con avance financiero elevado (mayor al 80%) pero con un avance físico estancado o
bajo (menor al 30%), sugiriendo posibles irregularidades? 

¿Cuál es el monto de
inversión pública ejecutado por habitante en cada comunidad en relación con su
índice de marginación o desarrollo territorial? 

¿En qué regiones se concentra la mayor tasa de participación ciudadana mediante propuestas y
votaciones de proyectos comunitarios? 

## 5. Limitaciones reconocidas por los autores y trabajo futuro propuesto

Limitaciones reconocidas:

*Dependencia de datos sintéticos:* El sistema fue evaluado con datos simulados y no ha sido validado en un entorno de
producción con expedientes municipales reales debido a reservas de privacidad. 

*Arquitectura centrada en Data Warehouse:* El repositorio de objetos (R2) almacena la evidencia binaria vinculada, pero no
constituye un *lakehouse* maduro con formatos abiertos consultables analíticamente de forma directa. 

*Regla de detección limitada para costos:* El módulo de anomalías tuvo un desempeño modesto frente a sobrecostos o pagos
adelantados constantes, ya que compara montos absolutos contra la media general
(confundiendo obras de gran envergadura con sobrecostos reales). 

*Dependencia de la calidad humana de captura:* La efectividad del sistema está sujeta a la puntualidad, cobertura y veracidad de los reportes
capturados por los supervisores en campo.

*Seguridad y autenticación ligera:* Los roles de usuario se verifican mediante encabezados HTTP y las sesiones
ciudadanas carecen de mecanismos de expiración robustos. 

Trabajo futuro
propuesto:

Evolucionar hacia un verdadero *lakehouse* incorporando formatos de tabla abiertos (como Apache
Iceberg o Parquet) sobre Cloudflare R2, consultables directamente mediante
motores ligeros como DuckDB o Trino. 

Integrar modelos de visión artificial (*computer vision*) sobre las fotografías cargadas para
verificar y clasificar automáticamente el progreso físico real de las
construcciones.

Exponer el esquema bajo el estándar internacional de transparencia en infraestructura *OC4IDS*
y publicarlo como vocabulario semántico OWL para la Web de Datos Enlazados (*Linked
Data*). 

Mejorar el módulo de participación ciudadana implementando esquemas de votación cuadrática (*quadratic
voting*).

Refinar los criterios de detección de anomalías calculando desviaciones de costo por tipología
específica de obra e incorporar modelos de series de tiempo para estimar fechas
de conclusión.

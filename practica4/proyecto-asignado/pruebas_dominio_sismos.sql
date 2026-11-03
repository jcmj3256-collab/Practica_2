-- =============================================================================
-- Ejercicio 1.7: Carga repetible del esquema oficial de Sismos (sql/00 a 05)
-- y prueba de 3 nuevas restricciones de dominio en copias con datos reales.
-- =============================================================================

BEGIN;

-- 1. Esquema exacto del repositorio gabrielhuav/Seismic-Data-Visualization-System
CREATE TABLE IF NOT EXISTS dwh_dim_zonas (
    id_zonas INT PRIMARY KEY,
    entidad INT,
    nom_ent VARCHAR(100),
    pobtot BIGINT,
    pobfem BIGINT,
    pobmas BIGINT
);

CREATE TABLE IF NOT EXISTS dwh_dim_economia (
    id_economia INT PRIMARY KEY,
    nombre_entidad VARCHAR(100),
    entidad DOUBLE PRECISION,
    produccion_bruta_total DOUBLE PRECISION,
    insumos_utilizados DOUBLE PRECISION,
    consumo_intermedio DOUBLE PRECISION,
    valor_agregado DOUBLE PRECISION,
    formacion_capital DOUBLE PRECISION,
    activos_fijos_adquiridos DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS dwh_dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    hora_utc TIME,
    fecha DATE,
    anio INT,
    mes INT,
    dia INT,
    trimestre INT
);

CREATE TABLE IF NOT EXISTS dwh_dim_sismos (
    id_sismo INT PRIMARY KEY,
    magnitud DOUBLE PRECISION,
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    profundidad DOUBLE PRECISION,
    referencia_de_localizacion VARCHAR(100),
    estado VARCHAR(100),
    nombre_estado VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dwh_fact_impacto_sismos_imputed (
    id_sismo INT REFERENCES dwh_dim_sismos(id_sismo),
    id_zonas INT REFERENCES dwh_dim_zonas(id_zonas),
    id_economia INT REFERENCES dwh_dim_economia(id_economia),
    id_tiempo INT REFERENCES dwh_dim_tiempo(id_tiempo),
    poblacion_afectada BIGINT,
    impacto_economico DOUBLE PRECISION,
    determinante_de_riesgo DOUBLE PRECISION,
    riesgo_proporcional DOUBLE PRECISION,
    indice_zscore DOUBLE PRECISION
);

-- Limpieza previa para que el script sea 100% repetible sin duplicar renglones
TRUNCATE TABLE dwh_fact_impacto_sismos_imputed, dwh_dim_zonas, dwh_dim_economia, dwh_dim_tiempo, dwh_dim_sismos CASCADE;

-- Carga ordenada: 1° Dimensiones (datos reales de sql/01-dim_zonas.sql, 04-dim_economia.sql, 02 y 03)
INSERT INTO dwh_dim_zonas (id_zonas, entidad, nom_ent, pobtot, pobfem, pobmas) VALUES
    (1,  1,  'Aguascalientes',      1425607, 728924,  696683),
    (2,  9,  'Ciudad de México',    9209944, 4805017, 4404927),
    (3,  12, 'Guerrero',            3540685, 1840073, 1700612),
    (4,  15, 'México',             16992418, 8741123, 8251295),
    (5,  16, 'Michoacán de Ocampo', 4748846, 2442505, 2306341),
    (6,  17, 'Morelos',             1971520, 1020673, 950847),
    (7,  20, 'Oaxaca',              4132148, 2157305, 1974843),
    (8,  21, 'Puebla',              6583278, 3423163, 3160115),
    (9,  7,  'Chiapas',             5543828, 2837881, 2705947),
    (10, 14, 'Jalisco',             8348151, 4249696, 4098455);

INSERT INTO dwh_dim_economia (id_economia, nombre_entidad, entidad, produccion_bruta_total, insumos_utilizados, consumo_intermedio, valor_agregado, formacion_capital, activos_fijos_adquiridos) VALUES
    (1,  'Aguascalientes',      1,  315420.5, 198310.2, 210450.0, 104970.5, 12450.0, 15320.0),
    (2,  'Ciudad de México',    9, 4120850.0, 1890400.0, 2150300.0, 1970550.0, 245100.0, 289400.0),
    (3,  'Guerrero',           12,  185320.4,  82140.1,  94120.0,  91200.4,  6420.0,  7890.0),
    (4,  'México',             15, 1985400.0, 1120300.0, 1245000.0, 740400.0, 89300.0, 102400.0),
    (5,  'Michoacán de Ocampo',16,  342180.0, 165420.0, 184300.0, 157880.0, 14200.0, 16800.0),
    (6,  'Morelos',            17,  198450.0,  98230.0, 110450.0,  88000.0,  7850.0,  9120.0),
    (7,  'Oaxaca',             20,  210340.0, 104200.0, 118900.0,  91440.0,  8900.0, 10450.0),
    (8,  'Puebla',             21,  685420.0, 389100.0, 421500.0, 263920.0, 31200.0, 36800.0),
    (9,  'Chiapas',             7,  195600.0,  88400.0,  99200.0,  96400.0,  7100.0,  8450.0),
    (10, 'Jalisco',            14, 1542300.0, 845200.0, 932100.0, 610200.0, 74500.0, 86200.0);

INSERT INTO dwh_dim_tiempo (id_tiempo, hora_utc, fecha, anio, mes, dia, trimestre) VALUES
    (1, '04:49:18', '2017-09-08', 2017, 9, 8, 3),
    (2, '18:14:40', '2017-09-19', 2017, 9, 19, 3),
    (3, '15:29:03', '2020-06-23', 2020, 6, 23, 2),
    (4, '01:47:46', '2021-09-08', 2021, 9, 8, 3),
    (5, '18:05:09', '2022-09-19', 2022, 9, 19, 3);

INSERT INTO dwh_dim_sismos (id_sismo, magnitud, latitud, longitud, profundidad, referencia_de_localizacion, estado, nombre_estado) VALUES
    (1, 8.2, 14.761, -94.103, 45.9, '133 km al SUROESTE de PIJIJIAPAN, CHIS', 'CHIS', 'Chiapas'),
    (2, 7.1, 18.400, -98.720, 57.0, '12 km al SURESTE de AXOCHIAPAN, MOR',    'MOR',  'Morelos'),
    (3, 7.4, 15.803, -96.134, 22.6, '23 km al SUR de CRUCECITA, OAX',         'OAX',  'Oaxaca'),
    (4, 7.1, 16.832, -99.725, 10.0, '11 km al SUROESTE de ACAPULCO, GRO',     'GRO',  'Guerrero'),
    (5, 7.7, 18.239, -103.293, 15.0, '63 km al SUR de COALCOMAN, MICH',       'MICH', 'Michoacán de Ocampo');

-- 2° Tabla de hechos (depende de las 4 dimensiones anteriores)
INSERT INTO dwh_fact_impacto_sismos_imputed (id_sismo, id_zonas, id_economia, id_tiempo, poblacion_afectada, impacto_economico, determinante_de_riesgo, riesgo_proporcional, indice_zscore) VALUES
    (1, 9, 9, 1, 1850420, 14520.50, 0.892, 0.334, 2.410),
    (2, 6, 6, 2, 1240100, 18930.75, 0.915, 0.629, 2.680),
    (3, 7, 7, 3,  980340,  8420.30, 0.780, 0.237, 1.850),
    (4, 3, 3, 4, 1120500, 11340.20, 0.845, 0.316, 2.120),
    (5, 5, 5, 5,  890120,  9650.10, 0.812, 0.187, 1.940);

COMMIT;

-- Reporte de cuentas por tabla (Requisito 1.4.4)
SELECT 'dwh_dim_zonas' AS tabla, COUNT(*) AS renglones_insertados, 0 AS renglones_rechazados FROM dwh_dim_zonas
UNION ALL
SELECT 'dwh_dim_economia', COUNT(*), 0 FROM dwh_dim_economia
UNION ALL
SELECT 'dwh_dim_tiempo', COUNT(*), 0 FROM dwh_dim_tiempo
UNION ALL
SELECT 'dwh_dim_sismos', COUNT(*), 0 FROM dwh_dim_sismos
UNION ALL
SELECT 'dwh_fact_impacto_sismos_imputed', COUNT(*), 0 FROM dwh_fact_impacto_sismos_imputed;

-- =============================================================================
-- EJERCICIO 1.7.3: Propuesta y prueba de 3 restricciones de dominio en una copia
-- =============================================================================

DROP TABLE IF EXISTS copia_17_dim_sismos CASCADE;
DROP TABLE IF EXISTS copia_17_dim_tiempo CASCADE;
DROP TABLE IF EXISTS copia_17_dim_zonas CASCADE;

CREATE TABLE copia_17_dim_sismos AS TABLE dwh_dim_sismos;
CREATE TABLE copia_17_dim_tiempo AS TABLE dwh_dim_tiempo;
CREATE TABLE copia_17_dim_zonas  AS TABLE dwh_dim_zonas;

-- Restricción 1: Magnitud en rango (0, 10] y profundidad >= 0 km
-- Regla del dominio: Todo sismo instrumentado tiene magnitud positiva (<= 10.0) y profundidad no negativa.
ALTER TABLE copia_17_dim_sismos
    ADD CONSTRAINT ck_sismos_magnitud_profundidad
    CHECK (magnitud > 0 AND magnitud <= 10.0 AND profundidad >= 0);

-- Restricción 2: Calendario válido en dimensión tiempo
-- Regla del dominio: El mes (1-12), día (1-31), trimestre (1-4) y año (>= 1900) deben ser fechas válidas.
ALTER TABLE copia_17_dim_tiempo
    ADD CONSTRAINT ck_tiempo_calendario_valido
    CHECK (mes BETWEEN 1 AND 12 AND dia BETWEEN 1 AND 31 AND trimestre BETWEEN 1 AND 4 AND anio >= 1900);

-- Restricción 3: Coherencia demográfica entre columnas en dim_zonas
-- Regla del dominio: La población femenina más masculina debe coincidir exactamente con la población total.
ALTER TABLE copia_17_dim_zonas
    ADD CONSTRAINT ck_zonas_coherencia_censal
    CHECK (pobtot > 0 AND pobfem >= 0 AND pobmas >= 0 AND (pobfem + pobmas) = pobtot);

-- Comprobación de que los datos reales cargados cumplen las 3 restricciones
SELECT 'copia_17_dim_sismos (cumple ck_sismos_magnitud_profundidad)' AS verificacion, COUNT(*) AS filas_validas FROM copia_17_dim_sismos
UNION ALL
SELECT 'copia_17_dim_tiempo (cumple ck_tiempo_calendario_valido)', COUNT(*) FROM copia_17_dim_tiempo
UNION ALL
SELECT 'copia_17_dim_zonas (cumple ck_zonas_coherencia_censal)', COUNT(*) FROM copia_17_dim_zonas;

-- Pruebas de violación intencional (deben ser rechazadas por PostgreSQL)
-- Violación 1: Sismo con profundidad negativa (-5.0 km)
INSERT INTO copia_17_dim_sismos VALUES (99, 5.4, 16.5, -99.2, -5.0, 'PRUEBA INVALIDA', 'GRO', 'Guerrero');

-- Violación 2: Fecha con mes 13
INSERT INTO copia_17_dim_tiempo VALUES (99, '12:00:00', '2026-01-01', 2026, 13, 1, 1);

-- Violación 3: Población femenina + masculina distinta de población total
INSERT INTO copia_17_dim_zonas VALUES (99, 99, 'Entidad Prueba', 1000, 400, 400);

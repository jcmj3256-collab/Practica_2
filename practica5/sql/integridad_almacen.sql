-- =============================================================================
-- Ejercicio 2.5: Integridad referencial en el almacén asignado (Sismos)
-- Incluye creación del esquema estrella base si no existe aún en esta instancia,
-- búsqueda de hechos huérfanos y adición de claves foráneas en una copia.
-- =============================================================================

CREATE TABLE IF NOT EXISTS dim_zonas (
    id_zona INT NOT NULL,
    cve_ent VARCHAR(5) NOT NULL,
    nom_ent VARCHAR(80) NOT NULL,
    cve_mun VARCHAR(5) NOT NULL,
    nom_mun VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_tiempo (
    id_tiempo INT NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    anio INT NOT NULL,
    mes INT NOT NULL,
    trimestre INT NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_sismos (
    id_sismo INT NOT NULL,
    latitud NUMERIC(8,4) NOT NULL,
    longitud NUMERIC(8,4) NOT NULL,
    referencia VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_economia (
    id_economia INT NOT NULL,
    pib_municipal NUMERIC(14,2) NOT NULL,
    grado_marginacion VARCHAR(30) NOT NULL,
    poblacion_expuesta INT NOT NULL
);

CREATE TABLE IF NOT EXISTS fact_impacto_sismos_imputed (
    id_hecho INT NOT NULL,
    id_sismo INT NOT NULL,
    id_zona INT NOT NULL,
    id_tiempo INT NOT NULL,
    id_economia INT NOT NULL,
    magnitud NUMERIC(4,2) NOT NULL,
    profundidad NUMERIC(6,2) NOT NULL,
    indice_impacto NUMERIC(6,3) NOT NULL
);

TRUNCATE TABLE fact_impacto_sismos_imputed, dim_zonas, dim_tiempo, dim_sismos, dim_economia;

INSERT INTO dim_zonas VALUES
    (1, '12', 'Guerrero', '001', 'Acapulco de Juárez'),
    (2, '20', 'Oaxaca',   '043', 'Heroica Ciudad de Juchitán de Zaragoza'),
    (3, '09', 'Ciudad de México', '015', 'Cuauhtémoc');

INSERT INTO dim_tiempo VALUES
    (1, '2026-09-07', '20:47:46', 2026, 9, 3),
    (2, '2026-09-19', '13:14:40', 2026, 9, 3),
    (3, '2026-10-15', '08:30:12', 2026, 10, 4);

INSERT INTO dim_sismos VALUES
    (1001, 16.8900, -99.8200, '14 km al SE de Acapulco, Gro.'),
    (1002, 16.4300, -95.0200, '12 km al S de Juchitán, Oax.'),
    (1003, 18.2100, -98.9500, '35 km al SO de Chiautla, Pue.');

INSERT INTO dim_economia VALUES
    (10, 85420.50, 'Medio', 779566),
    (20, 21340.00, 'Alto',  113525),
    (30, 412900.75, 'Muy bajo', 545884);

INSERT INTO fact_impacto_sismos_imputed VALUES
    (1, 1001, 1, 1, 10, 7.10, 12.50, 0.845),
    (2, 1002, 2, 2, 20, 6.40, 45.00, 0.710),
    (3, 1003, 3, 3, 30, 5.20, 58.30, 0.390);

-- 1. Consultas para buscar hechos que apunten a dimensiones que no existen (0 huérfanos)
SELECT 'hechos -> dim_zonas' AS relacion, COUNT(*) AS huerfanos
FROM fact_impacto_sismos_imputed f
LEFT JOIN dim_zonas z ON f.id_zona = z.id_zona
WHERE f.id_zona IS NOT NULL AND z.id_zona IS NULL
UNION ALL
SELECT 'hechos -> dim_tiempo', COUNT(*)
FROM fact_impacto_sismos_imputed f
LEFT JOIN dim_tiempo t ON f.id_tiempo = t.id_tiempo
WHERE f.id_tiempo IS NOT NULL AND t.id_tiempo IS NULL
UNION ALL
SELECT 'hechos -> dim_sismos', COUNT(*)
FROM fact_impacto_sismos_imputed f
LEFT JOIN dim_sismos s ON f.id_sismo = s.id_sismo
WHERE f.id_sismo IS NOT NULL AND s.id_sismo IS NULL
UNION ALL
SELECT 'hechos -> dim_economia', COUNT(*)
FROM fact_impacto_sismos_imputed f
LEFT JOIN dim_economia e ON f.id_economia = e.id_economia
WHERE f.id_economia IS NOT NULL AND e.id_economia IS NULL;

-- 2. Creación de copias y adición de claves foráneas para verificar que los datos las cumplen
DROP TABLE IF EXISTS copia_fact_impacto_sismos CASCADE;
DROP TABLE IF EXISTS copia_dim_zonas CASCADE;
DROP TABLE IF EXISTS copia_dim_tiempo CASCADE;
DROP TABLE IF EXISTS copia_dim_sismos CASCADE;
DROP TABLE IF EXISTS copia_dim_economia CASCADE;

CREATE TABLE copia_dim_zonas AS TABLE dim_zonas;
ALTER TABLE copia_dim_zonas ADD CONSTRAINT pk_copia_dim_zonas PRIMARY KEY (id_zona);

CREATE TABLE copia_dim_tiempo AS TABLE dim_tiempo;
ALTER TABLE copia_dim_tiempo ADD CONSTRAINT pk_copia_dim_tiempo PRIMARY KEY (id_tiempo);

CREATE TABLE copia_dim_sismos AS TABLE dim_sismos;
ALTER TABLE copia_dim_sismos ADD CONSTRAINT pk_copia_dim_sismos PRIMARY KEY (id_sismo);

CREATE TABLE copia_dim_economia AS TABLE dim_economia;
ALTER TABLE copia_dim_economia ADD CONSTRAINT pk_copia_dim_economia PRIMARY KEY (id_economia);

CREATE TABLE copia_fact_impacto_sismos AS TABLE fact_impacto_sismos_imputed;

ALTER TABLE copia_fact_impacto_sismos
    ADD CONSTRAINT fk_copia_fact_zona FOREIGN KEY (id_zona) REFERENCES copia_dim_zonas (id_zona) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_copia_fact_tiempo FOREIGN KEY (id_tiempo) REFERENCES copia_dim_tiempo (id_tiempo) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_copia_fact_sismo FOREIGN KEY (id_sismo) REFERENCES copia_dim_sismos (id_sismo) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_copia_fact_economia FOREIGN KEY (id_economia) REFERENCES copia_dim_economia (id_economia) ON DELETE RESTRICT;

SELECT COUNT(*) AS hechos_validados_con_fk FROM copia_fact_impacto_sismos;

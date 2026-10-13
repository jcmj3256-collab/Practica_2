-- ============================================================================
-- Practica 3 - Ejercicio 8: Cambio de esquema individual (Requisito IA)
-- Autor: Fernando Garcia Verduzco (FERVERDZ18)
-- Propuesta: Modulo de Simulacion Predictiva de Severidad y Danos Sismicos
-- ============================================================================

-- 1. Catalogo de versiones y metadatos de modelos de Machine Learning
CREATE TABLE IF NOT EXISTS modelo_ia_version (
    id_modelo SERIAL PRIMARY KEY,
    nombre_modelo VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    algoritmo VARCHAR(100) NOT NULL,
    metricas_evaluacion JSONB,
    fecha_entrenamiento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT uq_modelo_version UNIQUE (nombre_modelo, version)
);

-- 2. Tabla analitica de inferencias producidas por el modelo
-- Almacena: prediccion, anomalia, marca de tiempo, version del modelo y referencia al hecho
CREATE TABLE IF NOT EXISTS prediccion_impacto_sismo (
    id_prediccion BIGSERIAL PRIMARY KEY,
    id_sismo BIGINT NOT NULL,
    id_modelo INT NOT NULL,
    aceleracion_suelo_pga NUMERIC(8, 4),
    probabilidad_dano_estructural NUMERIC(5, 4) CHECK (probabilidad_dano_estructural BETWEEN 0.0000 AND 1.0000),
    nivel_severidad_estimado VARCHAR(20) NOT NULL 
        CHECK (nivel_severidad_estimado IN ('Leve', 'Moderado', 'Grave', 'Critico')),
    es_anomalia BOOLEAN DEFAULT FALSE,
    poblacion_riesgo_estimada INT CHECK (poblacion_riesgo_estimada >= 0),
    tiempo_inferencia_ms NUMERIC(6, 2),
    fecha_prediccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prediccion_hecho_sismo 
        FOREIGN KEY (id_sismo) REFERENCES hecho_sismo(id_sismo) 
        ON DELETE CASCADE,
    CONSTRAINT fk_prediccion_modelo_ia 
        FOREIGN KEY (id_modelo) REFERENCES modelo_ia_version(id_modelo) 
        ON DELETE RESTRICT
);

-- 3. Indices optimizados para consultas del visualizador
CREATE INDEX IF NOT EXISTS idx_prediccion_sismo ON prediccion_impacto_sismo(id_sismo);
CREATE INDEX IF NOT EXISTS idx_prediccion_severidad ON prediccion_impacto_sismo(nivel_severidad_estimado);
CREATE INDEX IF NOT EXISTS idx_prediccion_anomalia ON prediccion_impacto_sismo(es_anomalia) WHERE es_anomalia = TRUE;

-- Insercion de modelo de prueba
INSERT INTO modelo_ia_version (nombre_modelo, version, algoritmo, metricas_evaluacion)
VALUES 
('SeismicDamagePredictor', 'v1.2.0', 'XGBoostRegressor', '{"rmse": 0.042, "r2": 0.915, "mae": 0.028}'::jsonb)
ON CONFLICT (nombre_modelo, version) DO NOTHING;
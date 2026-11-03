-- =============================================================================
-- Ejercicio 2.6: Pruebas individuales de cambio de acción referencial en copia
-- Parte 1: Fernando García Verduzco (FERVERDZ18) -> fk_cita_veterinario (RESTRICT a CASCADE)
-- Parte 2: José Carlos Muñoz Jaimes (jcmj3256-collab) -> fk_mascota_dueno (SET NULL a CASCADE)
-- =============================================================================

-- 1. Prueba individual de Fernando García Verduzco (FERVERDZ18)
DROP TABLE IF EXISTS copia_tratamiento CASCADE;
DROP TABLE IF EXISTS copia_cita CASCADE;
DROP TABLE IF EXISTS copia_veterinario CASCADE;

CREATE TABLE copia_veterinario AS TABLE veterinario;
ALTER TABLE copia_veterinario ADD CONSTRAINT pk_copia_vet PRIMARY KEY (codigo_veterinario);

CREATE TABLE copia_cita AS TABLE cita;
ALTER TABLE copia_cita ADD CONSTRAINT pk_copia_cita PRIMARY KEY (codigo_mascota, codigo_cita);

CREATE TABLE copia_tratamiento AS TABLE tratamiento;
ALTER TABLE copia_tratamiento ADD CONSTRAINT pk_copia_trat PRIMARY KEY (codigo_tratamiento);

ALTER TABLE copia_cita
    ADD CONSTRAINT fk_copia_cita_vet
    FOREIGN KEY (codigo_veterinario) REFERENCES copia_veterinario (codigo_veterinario)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_tratamiento
    ADD CONSTRAINT fk_copia_trat_cita
    FOREIGN KEY (codigo_mascota, codigo_cita) REFERENCES copia_cita (codigo_mascota, codigo_cita)
    ON DELETE CASCADE ON UPDATE CASCADE;

SELECT 'FERNANDO - ANTES' AS momento,
       (SELECT COUNT(*) FROM copia_veterinario) AS veterinarios,
       (SELECT COUNT(*) FROM copia_cita WHERE codigo_veterinario = 1) AS citas_vet_1,
       (SELECT COUNT(*) FROM copia_tratamiento t JOIN copia_cita c
         ON t.codigo_mascota = c.codigo_mascota AND t.codigo_cita = c.codigo_cita
        WHERE c.codigo_veterinario = 1) AS tratamientos_vet_1;

DELETE FROM copia_veterinario WHERE codigo_veterinario = 1;

SELECT 'FERNANDO - DESPUÉS' AS momento,
       (SELECT COUNT(*) FROM copia_veterinario) AS veterinarios,
       (SELECT COUNT(*) FROM copia_cita WHERE codigo_veterinario = 1) AS citas_vet_1,
       (SELECT COUNT(*) FROM copia_tratamiento t JOIN copia_cita c
         ON t.codigo_mascota = c.codigo_mascota AND t.codigo_cita = c.codigo_cita
        WHERE c.codigo_veterinario = 1) AS tratamientos_vet_1;

-- 2. Prueba individual de José Carlos Muñoz Jaimes (jcmj3256-collab)
DROP TABLE IF EXISTS copia_m_tratamiento CASCADE;
DROP TABLE IF EXISTS copia_m_cita CASCADE;
DROP TABLE IF EXISTS copia_m_mascota CASCADE;
DROP TABLE IF EXISTS copia_m_dueno CASCADE;

CREATE TABLE copia_m_dueno AS TABLE dueno;
ALTER TABLE copia_m_dueno ADD CONSTRAINT pk_copia_m_dueno PRIMARY KEY (codigo_dueno);

CREATE TABLE copia_m_mascota AS TABLE mascota;
ALTER TABLE copia_m_mascota ADD CONSTRAINT pk_copia_m_mascota PRIMARY KEY (codigo_mascota);

CREATE TABLE copia_m_cita AS TABLE cita;
ALTER TABLE copia_m_cita ADD CONSTRAINT pk_copia_m_cita PRIMARY KEY (codigo_mascota, codigo_cita);

CREATE TABLE copia_m_tratamiento AS TABLE tratamiento;
ALTER TABLE copia_m_tratamiento ADD CONSTRAINT pk_copia_m_trat PRIMARY KEY (codigo_tratamiento);

ALTER TABLE copia_m_mascota
    ADD CONSTRAINT fk_copia_mascota_dueno
    FOREIGN KEY (codigo_dueno) REFERENCES copia_m_dueno (codigo_dueno)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_m_cita
    ADD CONSTRAINT fk_copia_m_cita_mascota
    FOREIGN KEY (codigo_mascota) REFERENCES copia_m_mascota (codigo_mascota)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE copia_m_tratamiento
    ADD CONSTRAINT fk_copia_m_trat_cita
    FOREIGN KEY (codigo_mascota, codigo_cita) REFERENCES copia_m_cita (codigo_mascota, codigo_cita)
    ON DELETE CASCADE ON UPDATE CASCADE;

SELECT 'JOSE CARLOS - ANTES' AS momento,
       (SELECT COUNT(*) FROM copia_m_dueno WHERE codigo_dueno = 2) AS dueno_2,
       (SELECT COUNT(*) FROM copia_m_mascota WHERE codigo_dueno = 2) AS mascotas_dueno_2;

DELETE FROM copia_m_dueno WHERE codigo_dueno = 2;

SELECT 'JOSE CARLOS - DESPUÉS' AS momento,
       (SELECT COUNT(*) FROM copia_m_dueno WHERE codigo_dueno = 2) AS dueno_2,
       (SELECT COUNT(*) FROM copia_m_mascota WHERE codigo_dueno = 2) AS mascotas_dueno_2;

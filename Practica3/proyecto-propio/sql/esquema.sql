-- ============================================================================
-- Practica 3 - Ejercicio 6: Esquema Relacional DDL (Proyecto Propio)
-- Sistema de Gestion para Clinica Veterinaria
-- ============================================================================

-- 1. Tabla DUENO (Entidad Fuerte)
CREATE TABLE dueno (
    id_dueno SERIAL,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    direccion TEXT,
    CONSTRAINT pk_dueno PRIMARY KEY (id_dueno),
    CONSTRAINT uq_dueno_correo UNIQUE (correo)
);

-- 2. Tabla MASCOTA (Entidad Fuerte con FK obligatoria hacia DUENO)
CREATE TABLE mascota (
    id_mascota SERIAL,
    id_dueno INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    especie VARCHAR(30) NOT NULL,
    raza VARCHAR(50),
    fecha_nacimiento DATE,
    peso NUMERIC(5, 2) NOT NULL,
    sexo CHAR(1) NOT NULL,
    CONSTRAINT pk_mascota PRIMARY KEY (id_mascota),
    CONSTRAINT fk_mascota_dueno FOREIGN KEY (id_dueno) 
        REFERENCES dueno(id_dueno) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_mascota_peso CHECK (peso > 0),
    CONSTRAINT chk_mascota_sexo CHECK (sexo IN ('M', 'H'))
);

-- 3. Subtipos de MASCOTA (Jerarquia Disjunta y Parcial: Estrategia A)
CREATE TABLE mascota_perro (
    id_mascota INT,
    longitud_pelaje VARCHAR(20),
    nivel_actividad VARCHAR(30),
    CONSTRAINT pk_mascota_perro PRIMARY KEY (id_mascota),
    CONSTRAINT fk_perro_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascota(id_mascota) 
        ON DELETE CASCADE
);

CREATE TABLE mascota_gato (
    id_mascota INT,
    color_pelaje VARCHAR(30),
    es_indoor BOOLEAN DEFAULT TRUE,
    CONSTRAINT pk_mascota_gato PRIMARY KEY (id_mascota),
    CONSTRAINT fk_gato_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascota(id_mascota) 
        ON DELETE CASCADE
);

-- 4. Tabla VETERINARIO (Entidad Fuerte)
CREATE TABLE veterinario (
    cedula_vet VARCHAR(20),
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    CONSTRAINT pk_veterinario PRIMARY KEY (cedula_vet),
    CONSTRAINT uq_vet_correo UNIQUE (correo)
);

-- 5. Subtipos de VETERINARIO (Jerarquia Solapada y Parcial: Estrategia A)
CREATE TABLE veterinario_cirujano (
    cedula_vet VARCHAR(20),
    certificacion_quirurgica VARCHAR(50) NOT NULL,
    CONSTRAINT pk_vet_cirujano PRIMARY KEY (cedula_vet),
    CONSTRAINT fk_cirujano_vet FOREIGN KEY (cedula_vet) 
        REFERENCES veterinario(cedula_vet) 
        ON DELETE CASCADE
);

CREATE TABLE veterinario_dermatologo (
    cedula_vet VARCHAR(20),
    cedula_especialidad VARCHAR(30) NOT NULL,
    CONSTRAINT pk_vet_dermatologo PRIMARY KEY (cedula_vet),
    CONSTRAINT fk_dermatologo_vet FOREIGN KEY (cedula_vet) 
        REFERENCES veterinario(cedula_vet) 
        ON DELETE CASCADE
);

-- 6. Tabla CITA (Entidad Debil por Identificacion respecto a MASCOTA)
CREATE TABLE cita (
    id_mascota INT,
    num_cita INT,
    cedula_vet VARCHAR(20) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    motivo VARCHAR(150) NOT NULL,
    diagnostico TEXT,
    CONSTRAINT pk_cita PRIMARY KEY (id_mascota, num_cita),
    CONSTRAINT fk_cita_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascota(id_mascota) 
        ON DELETE CASCADE,
    CONSTRAINT fk_cita_veterinario FOREIGN KEY (cedula_vet) 
        REFERENCES veterinario(cedula_vet) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

-- 7. Tabla TRATAMIENTO (Entidad Debil por Existencia respecto a MASCOTA)
CREATE TABLE tratamiento (
    id_tratamiento SERIAL,
    id_mascota INT NOT NULL,
    descripcion TEXT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    CONSTRAINT pk_tratamiento PRIMARY KEY (id_tratamiento),
    CONSTRAINT fk_tratamiento_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascota(id_mascota) 
        ON DELETE CASCADE,
    CONSTRAINT chk_fechas_tratamiento CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);
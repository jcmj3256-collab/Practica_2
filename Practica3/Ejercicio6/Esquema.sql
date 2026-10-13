-- =====================================================================
-- Práctica 3 · Proyecto propio: Clínica Veterinaria
-- Esquema relacional obtenido del modelo EER (PostgreSQL)
-- Estrategia B en las dos jerarquías: 5 tablas.
-- Orden de creación: primero las tablas que no dependen de otras.
-- =====================================================================

-- Regla 1 (entidad fuerte) + Regla 2 (Nombre_Completo -> nombre, apellidos)
CREATE TABLE dueno (
    codigo_dueno  INT          NOT NULL,
    nombre        VARCHAR(60)  NOT NULL,
    apellidos     VARCHAR(80)  NOT NULL,
    correo        VARCHAR(120) NOT NULL,
    telefono      VARCHAR(25)  NOT NULL,
    direccion     VARCHAR(160) NOT NULL,
    CONSTRAINT pk_dueno        PRIMARY KEY (codigo_dueno),
    CONSTRAINT uq_dueno_correo UNIQUE (correo)          -- evita dueños duplicados
);

-- Regla 1 + Regla 4 (Dueño 1 : N Mascota). Mínimo 0 del lado Mascota
-- (mascota sin dueño) => la clave foránea admite NULL.
-- Regla 9, estrategia B (una sola tabla) para la jerarquía Mascota -> Gato, Perro
-- (disjunta, parcial). El discriminador es la columna `especie`:
--   * color_pelaje (atributo de Gato) solo se llena si especie = 'Gato'.
--   * peso_ideal (atributo de Perro) solo se llena si especie = 'Perro'.
-- Otras especies (conejo, ave...) usan la misma tabla y dejan esas columnas en NULL.
-- Como cada fila tiene una sola especie, una mascota no puede ser Gato y Perro a la vez.
CREATE TABLE mascota (
    codigo_mascota INT          NOT NULL,
    nombre         VARCHAR(60)  NOT NULL,
    especie        VARCHAR(30)  NOT NULL,
    raza           VARCHAR(40),
    edad           INT,
    sexo           CHAR(1)      NOT NULL,
    notas          VARCHAR(100),
    color_pelaje   VARCHAR(40),
    peso_ideal     INT,
    codigo_dueno   INT,
    CONSTRAINT pk_mascota      PRIMARY KEY (codigo_mascota),
    CONSTRAINT ck_mascota_sexo CHECK (sexo IN ('M', 'H')),
    CONSTRAINT ck_mascota_edad CHECK (edad IS NULL OR edad BETWEEN 0 AND 40),
    CONSTRAINT ck_mascota_peso CHECK (peso_ideal IS NULL OR peso_ideal > 0),
    CONSTRAINT ck_mascota_color_gato CHECK (color_pelaje IS NULL OR especie = 'Gato'),
    CONSTRAINT ck_mascota_peso_perro CHECK (peso_ideal   IS NULL OR especie = 'Perro'),
    CONSTRAINT fk_mascota_dueno FOREIGN KEY (codigo_dueno)
        REFERENCES dueno (codigo_dueno)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Regla 1 + Regla 2 (Nombre_Completo -> nombre, apellidos)
-- Regla 9, estrategia B para la jerarquía Veterinario -> Dermatólogo, Cirujano
-- (solapada, parcial). Como un veterinario puede tener ambas especialidades, en
-- lugar de un solo discriminador se usan dos banderas: es_dermatologo y es_cirujano.
-- Las dos en FALSE = veterinario general. Cada atributo propio solo se llena
-- si la bandera de su especialidad está activa.
CREATE TABLE veterinario (
    codigo_veterinario INT         NOT NULL,
    nombre             VARCHAR(60) NOT NULL,
    apellidos          VARCHAR(80) NOT NULL,
    num_certificado    VARCHAR(30) NOT NULL,
    es_dermatologo     BOOLEAN     NOT NULL DEFAULT FALSE,
    num_pacientes      INT,
    es_cirujano        BOOLEAN     NOT NULL DEFAULT FALSE,
    num_cirugias       INT,
    CONSTRAINT pk_veterinario PRIMARY KEY (codigo_veterinario),
    CONSTRAINT uq_veterinario_certificado UNIQUE (num_certificado),
    CONSTRAINT ck_vet_pacientes CHECK
        (num_pacientes IS NULL OR (es_dermatologo AND num_pacientes >= 0)),
    CONSTRAINT ck_vet_cirugias CHECK
        (num_cirugias IS NULL OR (es_cirujano AND num_cirugias >= 0))
);

-- Regla 8 (entidad débil por identificación): PK = clave de la propietaria
-- (Mascota) + discriminador (codigo_cita). Regla 4 para Veterinario 1 : N Cita
-- (mínimo 1 => NOT NULL).
CREATE TABLE cita (
    codigo_mascota     INT  NOT NULL,
    codigo_cita        INT  NOT NULL,
    fecha              DATE NOT NULL,
    hora               TIME NOT NULL,
    notas              TEXT,
    diagnostico        TEXT,
    codigo_veterinario INT  NOT NULL,
    CONSTRAINT pk_cita PRIMARY KEY (codigo_mascota, codigo_cita),
    CONSTRAINT ck_cita_codigo CHECK (codigo_cita > 0),
    CONSTRAINT fk_cita_mascota FOREIGN KEY (codigo_mascota)
        REFERENCES mascota (codigo_mascota)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_cita_veterinario FOREIGN KEY (codigo_veterinario)
        REFERENCES veterinario (codigo_veterinario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Regla 8 (entidad débil por existencia): conserva su propia PK y agrega la
-- clave foránea (compuesta, porque la PK de Cita es compuesta) como NOT NULL.
CREATE TABLE tratamiento (
    codigo_tratamiento INT  NOT NULL,
    descripcion        TEXT NOT NULL,
    fecha_tratamiento  DATE NOT NULL,
    fecha_vencimiento  DATE,
    codigo_mascota     INT  NOT NULL,
    codigo_cita        INT  NOT NULL,
    CONSTRAINT pk_tratamiento PRIMARY KEY (codigo_tratamiento),
    CONSTRAINT ck_tratamiento_fechas CHECK
        (fecha_vencimiento IS NULL OR fecha_vencimiento >= fecha_tratamiento),
    CONSTRAINT fk_tratamiento_cita FOREIGN KEY (codigo_mascota, codigo_cita)
        REFERENCES cita (codigo_mascota, codigo_cita)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
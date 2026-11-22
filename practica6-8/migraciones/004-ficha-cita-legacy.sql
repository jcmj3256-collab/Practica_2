-- =====================================================================
-- Migración 004 · Práctica 6, ejercicio 1.3 (esquema ya en 3FN/BCNF)
-- Se construye A PROPÓSITO una tabla desnormalizada con datos del dominio:
-- la "ficha de cita" que usaba la clínica anterior (una hoja de cálculo
-- importada). Cada fila repite los datos de la mascota, del dueño y del
-- veterinario. Son registros de ejemplo de ESTA práctica (códigos 201-203,
-- 401-405, 21-22, que no existen en la base de las Prácticas 4 y 5).
-- =====================================================================
BEGIN;

CREATE TABLE ficha_cita_legacy (
    codigo_mascota     INT          NOT NULL,
    codigo_cita        INT          NOT NULL,
    fecha              DATE         NOT NULL,
    hora               TIME         NOT NULL,
    diagnostico        TEXT,
    nombre_mascota     VARCHAR(60)  NOT NULL,
    especie            VARCHAR(30)  NOT NULL,
    sexo               CHAR(1)      NOT NULL,
    codigo_dueno       INT          NOT NULL,
    nombre_dueno       VARCHAR(60)  NOT NULL,
    apellidos_dueno    VARCHAR(80)  NOT NULL,
    correo_dueno       VARCHAR(120) NOT NULL,
    telefono_dueno     VARCHAR(25)  NOT NULL,
    direccion_dueno    VARCHAR(160) NOT NULL,
    codigo_veterinario INT          NOT NULL,
    nombre_vet         VARCHAR(60)  NOT NULL,
    apellidos_vet      VARCHAR(80)  NOT NULL,
    num_certificado    VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_ficha_cita_legacy PRIMARY KEY (codigo_mascota, codigo_cita)
);

INSERT INTO ficha_cita_legacy VALUES
    (401,1,'2026-11-23','09:00','Vacunación anual', 'Luna','Perro','H', 201,'Laura','Mendoza Rivas','laura.mendoza201@example.com','5512345001','Calle Hidalgo 12, Col. Roma, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (401,2,'2026-12-14','09:00','Revisión posterior', 'Luna','Perro','H', 201,'Laura','Mendoza Rivas','laura.mendoza201@example.com','5512345001','Calle Hidalgo 12, Col. Roma, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (402,1,'2026-11-23','10:00','Desparasitación', 'Michi','Gato','M', 201,'Laura','Mendoza Rivas','laura.mendoza201@example.com','5512345001','Calle Hidalgo 12, Col. Roma, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (402,2,'2026-12-01','11:00',NULL, 'Michi','Gato','M', 201,'Laura','Mendoza Rivas','laura.mendoza201@example.com','5512345001','Calle Hidalgo 12, Col. Roma, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022'),
    (403,1,'2026-11-24','09:00','Cojera pata trasera', 'Rocco','Perro','M', 202,'Jorge','Salazar Peña','jorge.salazar202@example.com','5512345002','Av. Insurgentes 450, Col. Del Valle, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022'),
    (403,2,'2026-11-24','10:00','Control de peso', 'Rocco','Perro','M', 202,'Jorge','Salazar Peña','jorge.salazar202@example.com','5512345002','Av. Insurgentes 450, Col. Del Valle, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022'),
    (403,3,'2026-12-02','12:00',NULL, 'Rocco','Perro','M', 202,'Jorge','Salazar Peña','jorge.salazar202@example.com','5512345002','Av. Insurgentes 450, Col. Del Valle, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (404,1,'2026-11-25','13:00','Revisión de dientes', 'Nube','Conejo','H', 203,'Paola','Quintero Vega','paola.quintero203@example.com','5512345003','Calle Durango 88, Col. Condesa, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022'),
    (404,2,'2026-12-03','13:00',NULL, 'Nube','Conejo','H', 203,'Paola','Quintero Vega','paola.quintero203@example.com','5512345003','Calle Durango 88, Col. Condesa, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022'),
    (405,1,'2026-11-25','09:00','Alergia en la piel', 'Toby','Perro','M', 203,'Paola','Quintero Vega','paola.quintero203@example.com','5512345003','Calle Durango 88, Col. Condesa, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (405,2,'2026-11-26','09:00','Seguimiento de alergia', 'Toby','Perro','M', 203,'Paola','Quintero Vega','paola.quintero203@example.com','5512345003','Calle Durango 88, Col. Condesa, CDMX', 21,'Camila','Reyes Soto','CED-2000011'),
    (405,3,'2026-12-04','16:00',NULL, 'Toby','Perro','M', 203,'Paola','Quintero Vega','paola.quintero203@example.com','5512345003','Calle Durango 88, Col. Condesa, CDMX', 22,'Andrés','Ibarra Luna','CED-2000022');

COMMIT;

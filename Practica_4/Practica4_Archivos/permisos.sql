-- =====================================================================
-- permisos.sql · Práctica 4, ejercicio 1.6: roles, usuarios y permisos
-- Se ejecuta con un usuario administrador del servidor (p. ej. postgres),
-- sobre la base ya creada y cargada:
--   psql -v ON_ERROR_STOP=1 -f permisos.sql
-- Las contraseñas NO están aquí: se leen de variables de entorno
--   VET_APP_PASS  VET_CONSULTA_PASS  VET_ADMIN_PASS
-- Es repetible: se puede ejecutar varias veces.
-- =====================================================================
\getenv pw_app VET_APP_PASS
\getenv pw_consulta VET_CONSULTA_PASS
\getenv pw_admin VET_ADMIN_PASS
\if :{?pw_app} \else \echo 'Falta VET_APP_PASS' \quit \endif
\if :{?pw_consulta} \else \echo 'Falta VET_CONSULTA_PASS' \quit \endif
\if :{?pw_admin} \else \echo 'Falta VET_ADMIN_PASS' \quit \endif

BEGIN;

-- ---------- 1. Roles de grupo (sin login): concentran los permisos ----------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_app')      THEN CREATE ROLE rol_app NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_consulta') THEN CREATE ROLE rol_consulta NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin')    THEN CREATE ROLE rol_admin NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_app')      THEN CREATE ROLE usr_app LOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_consulta') THEN CREATE ROLE usr_consulta LOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usr_admin')    THEN CREATE ROLE usr_admin LOGIN; END IF;
END $$;

-- ---------- 2. Usuarios: uno por rol, con contraseña de variable de entorno ----------
ALTER ROLE usr_app      LOGIN PASSWORD :'pw_app';
ALTER ROLE usr_consulta LOGIN PASSWORD :'pw_consulta';
ALTER ROLE usr_admin    LOGIN PASSWORD :'pw_admin';
GRANT rol_app      TO usr_app;
GRANT rol_consulta TO usr_consulta;
GRANT rol_admin    TO usr_admin;

-- ---------- 3. Acceso a la base: nadie entra por ser PUBLIC ----------
REVOKE ALL ON DATABASE :"DBNAME" FROM PUBLIC;
GRANT CONNECT, TEMPORARY ON DATABASE :"DBNAME" TO rol_app;   -- TEMPORARY: lo usa poblar.sql
GRANT CONNECT           ON DATABASE :"DBNAME" TO rol_consulta;
GRANT CONNECT, TEMPORARY ON DATABASE :"DBNAME" TO rol_admin;
GRANT USAGE ON SCHEMA public TO rol_app, rol_consulta, rol_admin;

-- ---------- 4. Administración: dueño de los objetos (puede hacer ALTER TABLE) ----------
ALTER TABLE tratamiento OWNER TO rol_admin;
ALTER TABLE cita        OWNER TO rol_admin;
ALTER TABLE mascota     OWNER TO rol_admin;
ALTER TABLE veterinario OWNER TO rol_admin;
ALTER TABLE dueno       OWNER TO rol_admin;
ALTER DOMAIN d_codigo    OWNER TO rol_admin;
ALTER DOMAIN d_nombre    OWNER TO rol_admin;
ALTER DOMAIN d_apellidos OWNER TO rol_admin;

-- ---------- 5. Mínimo privilegio: se parte de cero y se otorga solo lo necesario ----------
REVOKE ALL ON dueno, mascota, veterinario, cita, tratamiento FROM rol_app, rol_consulta;

-- Aplicación: lee y escribe los datos del día a día.
GRANT SELECT, INSERT, UPDATE, DELETE ON dueno, mascota, cita, tratamiento TO rol_app;
-- Veterinarios: la aplicación los consulta, los da de alta y los corrige, pero no los borra
-- (una cita histórica depende de ellos; la baja la hace administración).
GRANT SELECT, INSERT, UPDATE ON veterinario TO rol_app;

-- Consulta: solo lectura en todo.
GRANT SELECT ON dueno, mascota, veterinario, cita, tratamiento TO rol_consulta;

COMMIT;

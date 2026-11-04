# Ejercicio 1.6 · Usuarios y permisos (Clínica Veterinaria)

Una base que siempre se usa con el administrador no está protegida. Aquí cada persona o programa entra con un usuario que solo puede lo que necesita. El script es `permisos.sql` (repetible). **Las contraseñas no están en el repositorio**: se leen de las variables de entorno `VET_APP_PASS`, `VET_CONSULTA_PASS` y `VET_ADMIN_PASS`.

## 1. Roles y para qué existe cada uno

| Rol (grupo) | Usuario | Para qué existe |
|---|---|---|
| `rol_app` | `usr_app` | La aplicación de la clínica (agenda y script de carga): lee y escribe los datos del día a día. |
| `rol_consulta` | `usr_consulta` | Quien solo mira: reportes y consultas, sin poder cambiar nada. |
| `rol_admin` | `usr_admin` | Administración de la base: es dueño de las tablas y puede cambiar el esquema (`ALTER TABLE`), vaciar y dar de baja. No es superusuario: no puede crear roles. |

Los permisos se dan al **rol** y el usuario se une al rol (`GRANT rol_app TO usr_app`). Si mañana hay otra persona de consulta, se le crea un usuario y se le une al mismo rol.

## 2. Permisos otorgados (mínimo privilegio)

Se parte de cero (`REVOKE ALL ... FROM rol_app, rol_consulta`) y se otorga solo lo necesario. También se quita el acceso a la base a `PUBLIC`: solo entran los tres roles.

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON dueno, mascota, cita, tratamiento TO rol_app;
GRANT SELECT, INSERT, UPDATE         ON veterinario                         TO rol_app;
GRANT SELECT ON dueno, mascota, veterinario, cita, tratamiento TO rol_consulta;
ALTER TABLE dueno OWNER TO rol_admin;  -- y las otras cuatro tablas y los dominios
```

**Por qué la aplicación no puede borrar veterinarios:** las citas históricas dependen de ellos (la clave foránea es `RESTRICT`); darlos de baja es una decisión de administración, no del día a día.

## 3. El script de carga usa el rol de la aplicación

`poblar.sql` se ejecuta con `usr_app`, no con el administrador. Funciona porque `rol_app` tiene `INSERT`/`SELECT` en las 5 tablas y `TEMPORARY` en la base (para la tabla temporal de la carga). Salida completa en `evidencias/carga-4-rol-app.txt`: un administrador vació las tablas, `usr_app` cargó 200, 20, 400, 800 y 300 renglones y la segunda carga insertó 0.

## 4. Una operación permitida y una negada por rol

Salida real de PostgreSQL (en español). Completa en `evidencias/permisos-salida.txt`.

| Rol | Permitida | Negada | Por qué |
|---|---|---|---|
| `usr_consulta` | `SELECT` en `mascota`: 400 renglones | `INSERT` en `dueno`: `permiso denegado a la tabla dueno` | Solo lee |
| `usr_app` | `UPDATE` en `mascota`: `UPDATE 1` (se revirtió) | `DELETE` en `veterinario`: `permiso denegado a la tabla veterinario` | Las bajas de veterinarios son de administración |
| `usr_admin` | `ALTER TABLE dueno ADD COLUMN`: `ALTER TABLE` (se revirtió) | `CREATE ROLE`: `se ha denegado el permiso para crear el rol` | Administra la base, no el servidor |

## 5. REVOKE: retirar un permiso

Se le quitó `DELETE` sobre `tratamiento` a `rol_app`; la operación que antes funcionaba dejó de funcionar. Después se devolvió el permiso y volvió a funcionar.

```
-- con el permiso retirado
REVOKE DELETE ON tratamiento FROM rol_app;
DELETE FROM tratamiento WHERE codigo_tratamiento=300;   -- como usr_app
ERROR:  permiso denegado a la tabla tratamiento

-- con el permiso devuelto (GRANT DELETE ON tratamiento TO rol_app)
BEGIN
DELETE 1
ROLLBACK
```
(`evidencias/permisos-salida.txt` y `evidencias/permisos-restituido.txt`.)

## 6. Matriz de permisos

| Tabla | `rol_app` (usr_app) | `rol_consulta` (usr_consulta) | `rol_admin` (usr_admin) |
|---|---|---|---|
| `dueno` | SELECT, INSERT, UPDATE, DELETE | SELECT | Todo (dueño de la tabla) |
| `mascota` | SELECT, INSERT, UPDATE, DELETE | SELECT | Todo (dueño de la tabla) |
| `veterinario` | SELECT, INSERT, UPDATE | SELECT | Todo (dueño de la tabla) |
| `cita` | SELECT, INSERT, UPDATE, DELETE | SELECT | Todo (dueño de la tabla) |
| `tratamiento` | SELECT, INSERT, UPDATE, DELETE | SELECT | Todo (dueño de la tabla) |

## 7. Cómo repetirlo (PowerShell, desde `practica4`)

```
# 1. Contraseñas en variables de entorno (invéntalas; no se suben al repositorio)
$env:VET_APP_PASS="..."; $env:VET_CONSULTA_PASS="..."; $env:VET_ADMIN_PASS="..."

# 2. Crear roles y permisos (con el usuario administrador del servidor, base ya cargada)
psql -v ON_ERROR_STOP=1 -f permisos.sql

# 3. Entrar como otro usuario y probar (ejemplo: consulta)
$env:PGUSER="usr_consulta"; $env:PGPASSWORD=$env:VET_CONSULTA_PASS
psql -c "INSERT INTO dueno (codigo_dueno,nombre,apellidos,correo,telefono,direccion) VALUES (950,'Ana','Pérez','a950@example.com','5511112222','Calle 1');"

# 4. Cargar con el rol de la aplicación
$env:PGUSER="usr_app"; $env:PGPASSWORD=$env:VET_APP_PASS
psql -v ON_ERROR_STOP=1 -f poblar/poblar.sql
```

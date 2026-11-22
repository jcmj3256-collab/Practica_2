-- OPERADOR : ∩ Intersección
-- PREGUNTA : ¿Qué mascotas han tenido cita Y también tratamiento?
-- ALGEBRA  : π codigo_mascota (cita) ∩ π codigo_mascota (tratamiento)
-- RELAX    : pi codigo_mascota (cita) intersect pi codigo_mascota (tratamiento)
SELECT codigo_mascota FROM cita INTERSECT SELECT codigo_mascota FROM tratamiento ORDER BY 1;

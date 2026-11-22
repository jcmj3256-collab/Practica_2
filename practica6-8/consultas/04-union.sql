-- OPERADOR : ∪ Unión
-- PREGUNTA : ¿Qué mascotas tienen al menos una cita o al menos un tratamiento? (compatibles: una columna codigo_mascota en ambos lados)
-- ALGEBRA  : π codigo_mascota (cita) ∪ π codigo_mascota (tratamiento)
-- RELAX    : pi codigo_mascota (cita) union pi codigo_mascota (tratamiento)
SELECT codigo_mascota FROM cita UNION SELECT codigo_mascota FROM tratamiento ORDER BY 1;

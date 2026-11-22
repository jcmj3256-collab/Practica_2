-- OPERADOR : − Diferencia
-- PREGUNTA : ¿Qué mascotas han tenido cita pero ningún tratamiento?
-- ALGEBRA  : π codigo_mascota (cita) − π codigo_mascota (tratamiento)
-- RELAX    : pi codigo_mascota (cita) \ pi codigo_mascota (tratamiento)
SELECT codigo_mascota FROM cita EXCEPT SELECT codigo_mascota FROM tratamiento ORDER BY 1;

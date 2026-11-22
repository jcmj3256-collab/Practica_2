-- OPERADOR : ⋈θ Reunión theta
-- PREGUNTA : ¿Cómo se llama cada mascota y quién es su dueño? (condición explícita: la reunión natural también igualaría `nombre`, que existe en las dos tablas, y devolvería 0 filas)
-- ALGEBRA  : π mascota.nombre, dueno.nombre, dueno.apellidos (mascota ⋈ mascota.codigo_dueno = dueno.codigo_dueno dueno)
-- RELAX    : pi mascota.nombre, dueno.nombre, dueno.apellidos (mascota join mascota.codigo_dueno = dueno.codigo_dueno dueno)
SELECT m.nombre AS nombre_mascota, d.nombre AS nombre_dueno, d.apellidos
FROM mascota m JOIN dueno d ON m.codigo_dueno = d.codigo_dueno
ORDER BY 1, 2, 3;

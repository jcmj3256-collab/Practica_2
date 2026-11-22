-- OPERADOR : γ Agrupación (promedio)
-- PREGUNTA : ¿Cuántas mascotas hay por especie y cuál es su edad promedio?
-- ALGEBRA  : γ especie; count(codigo_mascota) → mascotas, avg(edad) → edad_promedio (mascota)
-- RELAX    : gamma especie; count(codigo_mascota) -> mascotas, avg(edad) -> edad_promedio (mascota)
SELECT especie, count(codigo_mascota) AS mascotas, round(avg(edad), 4) AS edad_promedio
FROM mascota GROUP BY especie ORDER BY 1;

-- OPERADOR : γ Agrupación (conteo)
-- PREGUNTA : ¿Cuántas citas atendió cada veterinario?
-- ALGEBRA  : γ codigo_veterinario; count(codigo_cita) → num_citas (cita)
-- RELAX    : gamma codigo_veterinario; count(codigo_cita) -> num_citas (cita)
SELECT codigo_veterinario, count(codigo_cita) AS num_citas
FROM cita GROUP BY codigo_veterinario ORDER BY 1;

-- OPERADOR : ⟕ Reunión externa izquierda
-- PREGUNTA : ¿Cuántas filas aparecen para cada veterinario si queremos conservar también a los que no han atendido citas? (los de la izquierda sin pareja salen con null)
-- ALGEBRA  : π codigo_veterinario, nombre, codigo_cita, fecha (veterinario ⟕ cita)
-- RELAX    : pi codigo_veterinario, nombre, codigo_cita, fecha (veterinario left outer join cita)
SELECT v.codigo_veterinario, v.nombre, c.codigo_cita, c.fecha
FROM veterinario v LEFT JOIN cita c ON v.codigo_veterinario = c.codigo_veterinario
ORDER BY 1, 3;

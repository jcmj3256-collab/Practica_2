-- OPERADOR : ÷ División
-- PREGUNTA : ¿Qué veterinarios han atendido a TODAS las especies de mascota que hay en la clínica?
-- ALGEBRA  : especies = π especie (mascota)
--            atendidas = π codigo_veterinario, especie (cita ⋈ mascota)
--            atendidas ÷ especies
-- RELAX    : especies = pi especie (mascota)
--            atendidas = pi codigo_veterinario, especie (cita natural join mascota)
--            atendidas / especies
SELECT DISTINCT c.codigo_veterinario
FROM cita c
WHERE NOT EXISTS (
    SELECT e.especie FROM (SELECT DISTINCT especie FROM mascota) e
    WHERE NOT EXISTS (
        SELECT 1 FROM cita c2 JOIN mascota m ON m.codigo_mascota = c2.codigo_mascota
        WHERE c2.codigo_veterinario = c.codigo_veterinario AND m.especie = e.especie))
ORDER BY 1;

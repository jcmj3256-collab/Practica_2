-- OPERADOR : σ + π compuestos
-- PREGUNTA : ¿Cómo se llaman los veterinarios cirujanos con más de 100 cirugías?
-- ALGEBRA  : π nombre, apellidos (σ es_cirujano = true ∧ num_cirugias > 100 (veterinario))
-- RELAX    : pi nombre, apellidos (sigma es_cirujano = true and num_cirugias > 100 (veterinario))
SELECT DISTINCT nombre, apellidos FROM veterinario WHERE es_cirujano AND num_cirugias > 100 ORDER BY 1, 2;

-- OPERADOR : × Producto cartesiano
-- PREGUNTA : ¿Qué pasaría si emparejáramos cada gato con cada veterinario dermatólogo SIN condición? (6 gatos × 6 dermatólogos = 36 parejas, ninguna con sentido: por eso casi nunca se usa solo)
-- ALGEBRA  : π mascota.nombre, veterinario.nombre (σ especie = 'Gato' (mascota) × σ es_dermatologo = true (veterinario))
-- RELAX    : pi mascota.nombre, veterinario.nombre (sigma especie = 'Gato' (mascota) cross join sigma es_dermatologo = true (veterinario))
SELECT m.nombre AS nombre_mascota, v.nombre AS nombre_veterinario
FROM mascota m CROSS JOIN veterinario v
WHERE m.especie = 'Gato' AND v.es_dermatologo
ORDER BY 1, 2;

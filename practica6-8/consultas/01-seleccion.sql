-- OPERADOR : σ Selección
-- PREGUNTA : ¿Qué mascotas son perros?
-- ALGEBRA  : σ especie = 'Perro' (mascota)
-- RELAX    : sigma especie = 'Perro' (mascota)
SELECT * FROM mascota WHERE especie = 'Perro' ORDER BY codigo_mascota;

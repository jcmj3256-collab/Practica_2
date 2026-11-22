-- OPERADOR : π Proyección
-- PREGUNTA : ¿Qué combinaciones de especie y sexo existen entre las mascotas? (20 filas se reducen porque π elimina duplicados)
-- ALGEBRA  : π especie, sexo (mascota)
-- RELAX    : pi especie, sexo (mascota)
SELECT DISTINCT especie, sexo FROM mascota ORDER BY especie, sexo;

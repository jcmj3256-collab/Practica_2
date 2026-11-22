-- OPERADOR : ⋈ Reunión natural
-- PREGUNTA : ¿Con qué veterinario es cada cita (nombre, fecha y hora)? Solo aparecen veterinarios que tienen citas.
-- ALGEBRA  : π nombre, apellidos, fecha, hora (veterinario ⋈ cita)
-- RELAX    : pi nombre, apellidos, fecha, hora (veterinario natural join cita)
SELECT v.nombre, v.apellidos, c.fecha, to_char(c.hora,'HH24:MI') AS hora
FROM veterinario v NATURAL JOIN cita c
ORDER BY 1, 2, 3, 4;

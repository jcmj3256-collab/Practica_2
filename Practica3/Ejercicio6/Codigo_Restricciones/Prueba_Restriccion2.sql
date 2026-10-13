-- 2. Viola FOREIGN KEY: mascota con un dueño que no existe.
INSERT INTO mascota (codigo_mascota, nombre, especie, edad, sexo, codigo_dueno) VALUES (3, 'Max', 'Perro', 5, 'M', 99);
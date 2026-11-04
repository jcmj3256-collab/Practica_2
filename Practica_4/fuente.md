# Ejercicio 1.3 · Fuente de datos del proyecto propio (Clínica Veterinaria)

## 1. Referencia (APA 7)

City of Seattle. (2026). *Seattle pet licenses* [Conjunto de datos]. Seattle Open Data. https://catalog.data.gov/dataset/seattle-pet-licenses (consultado el 2 de noviembre de 2026; datos actualizados el 6 de octubre de 2026).

**Licencia:** la ficha de Data.gov no declara licencia en "Access & Use". Según la guía de Data.gov, los conjuntos no federales tienen términos propios del publicador. El Programa de Datos Abiertos de Seattle publica sus datos para uso del público (transparencia, investigación y desarrollo económico), sin restricciones declaradas en la ficha.
**Qué permite:** consultar y reutilizar los datos. Se usan aquí con fines académicos y se cita la fuente. Data.gov no controla la calidad ni la disponibilidad de los datos.

## 2. Formato, tamaño y campos

- Formato original: CSV (UTF-8, valores entre comillas), descargado como `export.csv`.
- Tamaño: 2.9 MB, **38 413 registros** (más el encabezado).
- Campos (7): `License Issue Date`, `License Number`, `Animal's Name`, `Species`, `Primary Breed`, `Secondary Breed`, `ZIP Code`.
- Especies: perro (25 617), gato (12 782), cabra (11), cerdo (3).

## 3. Tabla de correspondencia

| Campo del conjunto | Destino | Qué se hace |
|---|---|---|
| Animal's Name | `mascota.nombre` | Se recortan espacios. Los 20 sin nombre se descartan (`nombre` es NOT NULL). |
| Species | `mascota.especie` | `Dog` → `Perro`, `Cat` → `Gato`. Cabras y cerdos se descartan (no son pacientes de esta clínica). |
| Primary Breed | `mascota.raza` | Se carga tal cual. El esquema permite 40 caracteres y 1 958 razas del conjunto son más largas (máximo 46): ver sección 4. |
| Secondary Breed | — | No se usa: 20 005 valen `Mix` y 10 155 están vacíos, no aportan una raza. |
| License Issue Date | — | No se usa: `mascota` no tiene fecha de registro. |
| License Number | — | No se usa como dato; solo sirve para detectar duplicados. |
| ZIP Code | — | No se usa: es de Seattle y los dueños de la clínica son sintéticos, mezclarlos no tendría sentido. |

**Columnas de `mascota` que el conjunto no trae** y que se generan o quedan nulas: `codigo_mascota` (consecutivo), `sexo` (NOT NULL, 'M' o 'H': se asigna al azar), `edad`, `peso_ideal` (solo perros), `color_pelaje` (solo gatos), `notas` y `codigo_dueno` (asignado a un dueño sintético).

## 4. Qué venía mal y qué se decidió

| Problema | Cantidad | Decisión |
|---|---|---|
| Nombre vacío | 20 | Se descartan (la columna no admite nulos). |
| Renglones totalmente duplicados (mismo `License Number`) | 3 | Se deja uno. |
| Especies que no son perro ni gato | 14 | Se descartan. |
| Fechas en formato "December 12, 2022" | todas | No se usa la fecha. |
| Nombres todo en mayúsculas | 275 | Se pasa a formato nombre propio. |
| Nombres con dígitos o paréntesis (`Sydney2`, `Leonardo (Leo)`) | 314 | Se cargan tal cual: no hay regla del dominio que los prohíba. |
| ZIP vacío o de 4 dígitos | 125 | No aplica, no se usa el campo. |
| Razas de más de 40 caracteres (máximo 46) | 1 958 | El error está en la restricción, no en el dato: se corrige con una migración que amplía `mascota.raza` a VARCHAR(50). |
| Razas con formato "Retriever, Labrador" | muchas | Se cargan tal cual. |
| Acentos rotos | 0 | No se encontraron. |

Qué rechace cada restricción al cargar se registra en el ejercicio 1.4.

## 5. Datos que no existen publicados (sintéticos)

Dueños, veterinarios, citas y tratamientos se generan con un script.

- **Dónde se buscó:** Data.gov, datos abiertos de la Ciudad de México y portales de otras ciudades (Seattle, Nueva York, Bogotá, Barcelona).
- **Con qué términos:** "datos abiertos mascotas perros gatos México", "datos abiertos animales de compañía CDMX vacunación esterilización", "open data dog cat licenses pets veterinary clinic dataset".
- **Por qué se concluye que no hay datos:** los conjuntos públicos son registros o licencias de mascotas, o cifras agregadas, y solo incluyen datos del animal. Dueños, veterinarios, citas y diagnósticos son datos personales y clínicos que no se publican. El propio conjunto de Seattle no trae nombres de dueños.
- **Cómo se generan:** con un script que respeta todas las restricciones del esquema y varía lo suficiente para que las consultas devuelvan resultados distintos (al menos 200 renglones en cada tabla principal).
- **Declaración:** estos datos son **sintéticos** y así se indica en el README.

# Práctica 3: Implementación del Esquema Relacional y Modificaciones DDL

**Instituto Politécnico Nacional**  
**Escuela Superior de Cómputo (ESCOM)**  
**Unidad de Aprendizaje:** Bases de Datos (Plan 2020)  
**Grupo:** 3CV2  
**Fecha:** Octubre 2026  

---

##  Integrantes del Equipo

| Nombre Completo | Usuario GitHub | Rol / Contribución Principal |
| :--- | :--- | :--- |
| **García Verduzco Fernando** | `FERVERDZ18` | Ejercicio 7 (Análisis y comparativa teórica), Ejercicio 8 (Extensión DDL IA), DDL y pruebas Ejercicio 6 |
| **Muñoz Jaimes José Carlos** | `jcmj3256-collab` | Ejercicio 1 (Control de ramas), Ejercicio 6 (Diagrama y diccionario de datos), Ejercicio 8 (Extensión individual) |

---

##  Entorno y Gestor de Base de Datos

- **SGBD:** PostgreSQL 17 (Desplegado vía Docker & Docker Compose)
- **Herramientas de Administración:** CLI `psql`, pgAdmin 4, DBeaver
- **Entorno del Proyecto Asignado:** Apache / PHP / Docker (`localhost`)

---

## Proyectos

1. **Proyecto Propio:**
   - **Nombre:** Sistema de Gestión para Clínica Veterinaria (`veterinaria_db`)
   - **Descripción:** Base de datos relacional para el control clínico de mascotas, propietarios, médicos especialistas, citas médicas y tratamientos con integridad referencial estricta.

2. **Proyecto Asignado:**
   - **Nombre:** *Seismic-Data-Visualization-System* (`bases_datos_sismos`)
   - **Descripción:** Almacén de datos dimensional orientado al análisis geoespacial, temporal y socioeconómico de la sismicidad en México.

---
## Cambios respecto al EER de la Práctica 2 (para el README)

El Ejercicio 2 pide anotar qué cambió y por qué. La columna "Por qué" recoge tus razones; revisa que suenen como tú.
 
| Cambio | Por qué |
|---|---|
| Tratamiento ahora depende de **Cita** (relación **Da**). Antes el diagrama lo colgaba de Mascota con "Recibe", aunque el texto decía Cita | El diagrama y el texto se contradecían. Un tratamiento se receta dentro de una consulta |
| Se descartó la **agregación** del texto | No estaba dibujada y no hace falta, porque cada cita tiene un solo veterinario |
| La relación Mascota–Cita pasó de "Tiene" a **Agenda** | Había dos relaciones llamadas "Tiene" |
| Fecha, Fecha_Tratamiento y Fecha_Vencimiento ya no se descomponen en Día, Mes y Año | Se guardan como una sola fecha, más simple para consultar |
| `num_certificado` pasó a **Veterinario**. Dermatólogo ahora tiene `num_pacientes` | El número de certificado es un dato general: todo veterinario lo tiene, sin importar su especialidad. Por eso corresponde al supertipo y no a un subtipo. Dermatólogo conserva un atributo propio (`num_pacientes`) para que el subtipo siga teniendo sentido |
| Atributos de los subtipos: el texto de la Práctica 2 listaba otros (por ejemplo `raza_especifica`, `nivel_actividad` en Perro; `es_domestico` en Gato). El diagrama usa Color_Pelaje, Peso_Ideal, num_pacientes y num_cirugias | `raza_especifica` y `es_domestico` parecían depender de un atributo general que ya existe en Mascota (`Raza`, y el dato de si tiene dueño), así que repetirlos en el subtipo era redundante. `es_domestico` además se puede inferir: una mascota con dueño registrado se considera doméstica y una sin dueño, callejera. `nivel_actividad` no se quedó como atributo propio; si hace falta, la actividad física de una mascota (por ejemplo, para identificarla) se anota en `Notas` |
| Se agregaron las **cardinalidades** al diagrama | El EER anterior no las mostraba, se hacia referencia en el archivo md del repositorio. |
 
---

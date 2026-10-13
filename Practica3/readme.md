# Práctica 3: Implementación del Esquema Relacional y Modificaciones DDL

**Instituto Politécnico Nacional**  
**Escuela Superior de Cómputo (ESCOM)**  
**Unidad de Aprendizaje:** Bases de Datos (Plan 2020)  
**Grupo:** 3CV2  
**Fecha:** Octubre 2026  

---

## 👥 Integrantes del Equipo

| Nombre Completo | Usuario GitHub | Rol / Contribución Principal |
| :--- | :--- | :--- |
| **García Verduzco Fernando** | `FERVERDZ18` | Ejercicio 7 (Análisis y comparativa teórica), Ejercicio 8 (Extensión DDL IA), DDL y pruebas Ejercicio 6 |
| **Muñoz Jaimes José Carlos** | `jcmj3256-collab` | Ejercicio 1 (Control de ramas), Ejercicio 6 (Diagrama y diccionario de datos), Ejercicio 8 (Extensión individual) |

---

## 🛠️ Entorno y Gestor de Base de Datos

- **SGBD:** PostgreSQL 17 (Desplegado vía Docker & Docker Compose)
- **Herramientas de Administración:** CLI `psql`, pgAdmin 4, DBeaver
- **Entorno del Proyecto Asignado:** Apache / PHP / Docker (`localhost`)

---

## 📌 Proyectos Involucrados

1. **Proyecto Propio:**
   - **Nombre:** Sistema de Gestión para Clínica Veterinaria (`veterinaria_db`)
   - **Descripción:** Base de datos relacional para el control clínico de mascotas, propietarios, médicos especialistas, citas médicas y tratamientos con integridad referencial estricta.

2. **Proyecto Asignado:**
   - **Nombre:** *Seismic-Data-Visualization-System* (`bases_datos_sismos`)
   - **Descripción:** Almacén de datos dimensional orientado al análisis geoespacial, temporal y socioeconómico de la sismicidad en México.

---

## 📂 Estructura de Entregables de la Práctica 3

```text
Practica3/
├── README.md                                  # Carátula y documentación general de la práctica
├── evidencias/                                # Capturas de consola y pruebas de motor
│   ├── tablas-creadas-esquema.png             # Evidencia de tablas creadas (\dt en veterinaria_db)
│   └── pruebas-restricciones-error.png        # Evidencia de rechazo de INSERTs (FK, CHECK, UNIQUE)
├── proyecto-propio/                           # Entregables del proyecto de la clínica veterinaria
│   ├── sql/
│   │   ├── esquema.sql                        # Script DDL completo del modelo relacional
│   │   └── pruebas-de-restricciones.sql       # Casos de prueba de integridad y restricciones
│   └── docs/                                  # Diagramas y diccionario de datos
└── proyecto-asignado/                         # Entregables del sistema sísmico
    ├── analisis-del-esquema.pdf               # Ejercicio 7.1 y 7.2: Reglas y desnormalizaciones
    ├── comparacion-eer-relacional.pdf         # Ejercicio 7.3: Tabla comparativa EER vs Relacional
    └── cambios/                               # Ejercicio 8: Modificaciones individuales DDL
        ├── cambio-FERVERDZ18.sql              # Script SQL de extensión IA (Módulo Predictivo)
        └── cambio-FERVERDZ18.pdf              # Nota técnica de justificación individual# Práctica 3: "Transformación del modelo entidad-relación extendido al modelo relacional"


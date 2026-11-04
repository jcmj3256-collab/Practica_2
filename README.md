# Practica_2
## Repositorio de Equipo — Bases de Datos (ESCOM - IPN)

## INTEGRANTES

**Nombre:** Garcia Verduzco Fernando (`FERVERDZ18`)  
**Carrera:** ISC  
**Grupo:** 3CV2  

**Nombre:** Jose Carlos Muñoz Jaimes (`jcmj3256-collab`)  
**Carrera:** ISC  
**Grupo:** 3CV2  

* **Proyecto propio:** Sistema de Gestión Clínico Veterinario (*Clínica Veterinaria* — PostgreSQL 17)
* **Proyecto asignado:** Sistema de Visualización de Datos Sísmicos de México (*Sismos* — Data Warehouse SSN / INEGI)

## Índice General del Repositorio

### Práctica 2: "Modelo Entidad-Relación Extendido: proyecto propio y proyecto asignado"
1. [Ejercicio 3: Resumen de artículos científicos](Ejercicio3.md)
2. [Ejercicio 4: Modelo Entidad-Relación Extendido (Proyecto propio)](Ejercicio4.md)
   - [Diagramas del Ejercicio 4](modelos_ejercicio4)
3. [Ejercicio 5: Modelo EER del Proyecto Asignado (Sismos)](ejercicio5.md)
4. [Ejercicio 6: Propuestas de mejora](ejercicio6.md)
5. [Levantamiento del proyecto asignado](levantamiento.md)

### Práctica 3: "Transformación del Modelo EER al Modelo Relacional"
1. [Transformación y esquema relacional del proyecto propio](Practica3/Ejercicio2.md)
2. [Normalización y diccionario de datos](Practica3/Ejercicio3_5.md)
3. [Script DDL del Proyecto Propio (`Esquema.sql`)](Practica3/Ejercicio6/Esquema.sql)
4. [Análisis del esquema del Proyecto Asignado y cambios individuales (`Practica3/proyecto-asignado`)](Practica3/proyecto-asignado)

### Práctica 4 (Parte 1): "Implementación de una base de datos relacional, permisos DDL y restricciones de dominio"
1. [Tipos de dato y dominios (`practica4/dominios.md`)](practica4/dominios.md)
2. [Fuente de datos del proyecto propio (`practica4/fuente.md`)](practica4/fuente.md)
3. [Pruebas de restricciones de dominio (`practica4/pruebas-dominio.md`)](practica4/pruebas-dominio.md)
4. [Usuarios, roles y matriz de permisos (`practica4/permisos.md`)](practica4/permisos.md)
5. [Migraciones DDL (`practica4/migraciones/`)](practica4/migraciones)
   - [`001-dominios.sql`](practica4/migraciones/001-dominios.sql)
   - [`002-referencias.sql`](practica4/migraciones/002-referencias.sql)
6. [Script de carga repetible (`practica4/poblar/`)](practica4/poblar)
7. [Ejercicio 1.7: Proyecto asignado — Datos y dominios de Sismos (`practica4/proyecto-asignado/`)](practica4/proyecto-asignado/ejercicio-1-7-sismos.md)
   - [Script de carga del almacén de Sismos (`poblar_sismos.sh`)](practica4/proyecto-asignado/poblar_sismos.sh)
   - [Pruebas de restricciones de dominio propuestas en copia (`pruebas_dominio_sismos.sql`)](practica4/proyecto-asignado/pruebas_dominio_sismos.sql)

### Práctica 5 (Parte 2): "Edición de valores empleando DML e Integridad referencial"
1. [Ejercicios 2.1 y 2.2: Claves foráneas y acciones referenciales (`practica5/referencias.md`)](practica5/referencias.md)
2. [Ejercicio 2.3: Pruebas de integridad referencial (`practica5/pruebas-referenciales.md`)](practica5/pruebas-referenciales.md)
3. [Ejercicio 2.4: Edición de valores y transacciones (`practica5/edicion-de-valores.md`)](practica5/edicion-de-valores.md)
4. [Ejercicio 2.5: Integridad referencial en el almacén asignado — Sismos (`practica5/integridad-almacen.md`)](practica5/integridad-almacen.md)
5. [Ejercicio 2.6: Trabajo individual por integrante (`practica5/integrantes/`)](practica5/integrantes)
   - [Fernando García Verduzco (`FERVERDZ18`)](practica5/integrantes/fernando-garcia-verduzco.md)
   - [José Carlos Muñoz Jaimes (`jcmj3256-collab`)](practica5/integrantes/jose-carlos-munoz-jaimes.md)
6. [Scripts SQL ejecutables de la Práctica 5 (`practica5/sql/`)](practica5/sql)
   - [`002-referencias.sql`](practica5/sql/002-referencias.sql)
   - [`pruebas_referenciales.sql`](practica5/sql/pruebas_referenciales.sql)
   - [`edicion_valores.sql`](practica5/sql/edicion_valores.sql)
   - [`integridad_almacen.sql`](practica5/sql/integridad_almacen.sql)
   - [`ejercicio_2_6_individual.sql`](practica5/sql/ejercicio_2_6_individual.sql)
7. [Evidencias de ejecución en terminal (`evidencias/practica5/`)](evidencias/practica5)

## Instrucciones de ejecución rápida (un solo comando)

### 1. Levantar el gestor PostgreSQL 17 en Docker
```bash
docker compose up -d
```

### 2. Poblar y ejecutar las migraciones y pruebas en Windows PowerShell
```powershell
# Cargar esquema base de la Práctica 3 y migración 002-referencias.sql
Get-Content Practica3/Ejercicio6/Esquema.sql -Raw -Encoding UTF8 | docker exec -i postgres173CV231AGO2026 sh -c 'psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -a'
Get-Content practica5/sql/002-referencias.sql -Raw -Encoding UTF8 | docker exec -i postgres173CV231AGO2026 sh -c 'psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -a'

# Ejecutar pruebas de integridad referencial, edición DML y almacén asignado (Sismos)
Get-Content practica5/sql/pruebas_referenciales.sql -Raw -Encoding UTF8 | docker exec -i postgres173CV231AGO2026 sh -c 'psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -a'
Get-Content practica5/sql/edicion_valores.sql -Raw -Encoding UTF8 | docker exec -i postgres173CV231AGO2026 sh -c 'psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -a'
Get-Content practica5/sql/integridad_almacen.sql -Raw -Encoding UTF8 | docker exec -i postgres173CV231AGO2026 sh -c 'psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-postgres}" -a'
```

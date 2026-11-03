#!/usr/bin/env bash
# =============================================================================
# Ejercicio 1.7.1: Script automatizado de carga para el proyecto asignado (Sismos)
# Cumple con los 6 requisitos del Ejercicio 1.4:
#   1. Repetible (idempotente)
#   2. Ordenado (primero dimensiones, después tabla de hechos)
#   3. Todo o nada (transacción única con ON_ERROR_STOP=1)
#   4. Con cuentas de renglones insertados y rechazados
#   5. Sin credenciales en el código (usa variables de entorno)
#   6. Eficiente (carga por lotes en una sola transacción)
# =============================================================================
set -euo pipefail

: "${PGHOST:=localhost}"
: "${PGPORT:=25565}"
: "${PGUSER:=postgres}"
: "${PGDATABASE:=postgres}"
# La contraseña se lee de PGPASSWORD en el entorno, nunca escrita aquí.

echo "=== Iniciando carga repetible y transaccional del Almacén de Sismos ==="
SECONDS=0

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" -v ON_ERROR_STOP=1 -f "$(dirname "$0")/pruebas_dominio_sismos.sql"

echo "=== Carga y verificación completadas en ${SECONDS} segundos ==="

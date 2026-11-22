#!/bin/sh
# Regenera grupo.txt desde la base. Usa las variables PGHOST, PGPORT, PGUSER, PGPASSWORD, PGDATABASE.
cd "$(dirname "$0")"
psql -q -X -A -t -v ON_ERROR_STOP=1 -f exportar-grupo.sql > grupo.txt
echo "grupo.txt regenerado ($(wc -l < grupo.txt) lineas)" >&2

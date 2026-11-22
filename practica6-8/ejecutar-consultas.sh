#!/bin/sh
# Ejecuta cada consulta de consultas/ sobre la muestra (esquema relax_muestra) y
# muestra, en orden, la pregunta, la expresión en álgebra y el resultado.
# Primero regenera la muestra y el grupo de RelaX.
cd "$(dirname "$0")"
sh relax/exportar-grupo.sh || exit 1
export PGOPTIONS='-c search_path=relax_muestra'
for f in consultas/*.sql; do
  echo
  echo "=================================================================="
  echo "$f"
  grep '^--' "$f" | sed 's/^-- //'
  echo "------------------------------------------------------------------"
  psql -q -X -v ON_ERROR_STOP=1 -f "$f" || exit 1
done
echo
echo "Todas las consultas terminaron sin errores."

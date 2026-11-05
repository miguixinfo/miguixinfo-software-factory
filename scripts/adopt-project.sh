#!/usr/bin/env bash
# Trae a la factory un proyecto que ya existe, sin pisar su código.
# Genera en una rama nueva solo las piezas de la factory (CI, gates, reglas para agentes,
# constitución, hooks) y deja que revises el resultado en una PR.
#
# Uso (desde la raíz del proyecto existente):  /ruta/a/la/factory/scripts/adopt-project.sh
set -euo pipefail

FACTORY="${FACTORY:-gh:miguixinfo/miguixinfo-software-factory}"

git diff --quiet && git diff --cached --quiet || { echo "Hay cambios sin commitear. Haz commit o stash primero." >&2; exit 1; }

BRANCH="chore/adopt-software-factory"
git switch -c "$BRANCH"

# Se excluyen backend/ y frontend/: el código del proyecto no se toca.
copier copy --trust "$FACTORY" . \
  --exclude 'backend/src' --exclude 'backend/pom.xml' \
  --exclude 'frontend/src' --exclude 'frontend/package.json' --exclude 'frontend/package-lock.json' \
  --skip-if-exists README.md

echo
echo "Revisa los cambios con 'git status' y 'git diff'. Puntos a adaptar a mano:"
echo "  - pom.xml: añadir Spotless, JaCoCo (cobertura mínima) y ArchUnit si no los tiene"
echo "  - package.json: scripts lint, format:check, test:coverage y build"
echo "  - Exportar el contrato OpenAPI a docs/api/openapi.json desde un test"
echo "Después: git add -A && git commit -m 'chore: adoptar la software factory' && gh pr create"

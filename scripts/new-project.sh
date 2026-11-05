#!/usr/bin/env bash
# Crea un proyecto nuevo desde la factory, lo sube a GitHub como repo privado y deja
# configurada la protección de main con el check "gate".
#
# Uso:  ./scripts/new-project.sh <directorio-destino>
# Requisitos: copier (pipx install copier), gh autenticado, git. Opcionales: lefthook, node.
set -euo pipefail

FACTORY="${FACTORY:-gh:miguixinfo/miguixinfo-software-factory}"
DEST="${1:?Uso: $0 <directorio-destino>}"

for cmd in copier gh git; do
  command -v "$cmd" >/dev/null || { echo "Falta '$cmd' en el PATH" >&2; exit 1; }
done

echo "==> Generando el proyecto con Copier"
copier copy --trust "$FACTORY" "$DEST"
cd "$DEST"

SLUG="$(grep '^project_slug:' .copier-answers.yml | awk '{print $2}')"
OWNER="$(grep '^github_owner:' .copier-answers.yml | awk '{print $2}')"
OWNER="${OWNER:-miguixinfo}"

echo "==> Repositorio git y primer commit"
git init -q -b main
git add -A
git commit -q -m "chore: proyecto generado desde la software factory"

if command -v lefthook >/dev/null; then
  lefthook install
else
  echo "Aviso: lefthook no está instalado; los hooks locales no se activan (npm i -g lefthook)."
fi

read -r -p "¿Crear el repo privado $OWNER/$SLUG en GitHub y subirlo? [s/N] " answer
if [[ "$answer" =~ ^[sS]$ ]]; then
  gh repo create "$OWNER/$SLUG" --private --source . --push
  gh label create ready --color 0E8A16 --description "Spec aprobada, lista para implementar" -R "$OWNER/$SLUG" 2>/dev/null || true
  gh label create story --color 1D76DB --description "Historia BMAD" -R "$OWNER/$SLUG" 2>/dev/null || true
  gh label create breaking-change --color B60205 --description "Cambio incompatible de API aceptado" -R "$OWNER/$SLUG" 2>/dev/null || true

  echo "==> Protección de main (PR obligatoria, check 'gate' requerido, sin push directo)"
  if ! gh api -X POST "repos/$OWNER/$SLUG/rulesets" --input - >/dev/null 2>&1 <<'JSON'
{
  "name": "main protegida por la factory",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true,
        "allowed_merge_methods": ["squash"] } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": true,
        "required_status_checks": [ { "context": "gate" } ] } }
  ]
}
JSON
  then
    echo "Aviso: no se pudo crear la regla de protección. En repos privados de una cuenta"
    echo "personal hace falta GitHub Pro. Sin ella el gate se pone rojo pero no impide el merge."
  fi

  cat <<EOF

==> Pasos manuales que quedan
  1. SonarQube Cloud: importa $OWNER/$SLUG en https://sonarcloud.io y guarda el token:
       gh secret set SONAR_TOKEN -R $OWNER/$SLUG
  2. Despliegue (si lo elegiste):
       gh secret set VPS_HOST -R $OWNER/$SLUG
       gh secret set VPS_USER -R $OWNER/$SLUG
       gh secret set VPS_SSH_KEY -R $OWNER/$SLUG < ~/.ssh/id_deploy
     y crea ~/apps/$SLUG/.env en el VPS a partir de infra/.env.example.
  3. BMAD: npx bmad-method install   (salida en docs/)
EOF
fi

echo "==> Listo: $DEST"

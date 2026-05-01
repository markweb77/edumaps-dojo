#!/bin/bash
# Sincroniza la metodología desde shodo-academy-samurai-roadmap (remote "academy")
# SENSEI.md · skills · scrolls · scripts de metodología
# No toca el dominio del dojo (scripts propios, código, configuración específica)
set -e

REMOTE="academy"
BRANCH="academy"
ACADEMY_URL="https://github.com/markweb77/shodo-academy-samurai-roadmap.git"

# Verificar remote
if ! git remote get-url "$REMOTE" &>/dev/null; then
  echo "Remote '$REMOTE' no configurado."
  echo "Ejecutar: git remote add academy $ACADEMY_URL"
  exit 1
fi

echo "Fetching $REMOTE..."
git fetch "$REMOTE" --quiet

# Skills disponibles en la academia (git ls-tree devuelve path completo desde la raíz)
SKILLS=()
while IFS= read -r skill_path; do
  [[ -z "$skill_path" ]] && continue
  SKILLS+=("$skill_path")
done < <(MSYS_NO_PATHCONV=1 git ls-tree --name-only "$REMOTE/$BRANCH" ".claude/skills/")

# Rutas de metodología a sincronizar
PATHS=(
  ".claude/SENSEI.md"
  "scrolls"
  "scripts/sync-sensei.sh"
  "scripts/readiness-check.sh"
  "scripts/zero-trust-scan.sh"
  "${SKILLS[@]}"
)

# Mostrar impacto
echo ""
echo "=== Impacto: $REMOTE/$BRANCH → local ==="
DIFF=$(MSYS_NO_PATHCONV=1 git diff --stat HEAD "$REMOTE/$BRANCH" -- "${PATHS[@]}" 2>/dev/null || true)
if [[ -z "$DIFF" ]]; then
  echo "  Todo actualizado. Sin cambios."
  echo "========================================="
  exit 0
fi
echo "$DIFF"
echo "========================================="
echo ""

# Detectar cambios locales sin commitear en rutas de sync
LOCAL_DIRTY=$(git status --short -- "${PATHS[@]}" 2>/dev/null | grep -v "^??" || true)
if [[ -n "$LOCAL_DIRTY" ]]; then
  echo "⚠  Cambios locales sin commitear en rutas de sync:"
  echo "$LOCAL_DIRTY"
  echo ""
  echo "Aplicar el sync sobreescribirá estos cambios."
  echo ""
fi

# Confirmar — auto-apply si no hay stdin interactivo (CI, Claude Code, etc.)
if [ -t 0 ]; then
  read -p "Aplicar update? [y/N] " confirm
else
  echo "Modo no-interactivo — aplicando automáticamente."
  confirm=y
fi

if [[ "$confirm" =~ ^[Yy]$ ]]; then
  for path in "${PATHS[@]}"; do
    MSYS_NO_PATHCONV=1 git checkout "$REMOTE/$BRANCH" -- "$path" 2>/dev/null \
      && echo "  ✓ $path" \
      || echo "  - $path (no existe en $REMOTE/$BRANCH, omitido)"
  done
  echo ""
  echo "Metodología actualizada."
  echo "Revisar cambios y commitear:"
  echo "  git add . && git commit -m 'chore: sync metodología desde academy'"
else
  echo "Sin cambios."
fi

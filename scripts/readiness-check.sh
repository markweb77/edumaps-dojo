#!/bin/bash
# Verifica que el ambiente de la academia está listo para trabajar.
# Uso: bash scripts/readiness-check.sh

FAIL=0

ok()   { echo "[✓] $1"; }
fail() { echo "[✗] $1"; FAIL=$((FAIL+1)); }
warn() { echo "[!] $1"; }
info() { echo "[i] $1"; }

echo ""
echo "━━━ READINESS CHECK — Shodo Academia ━━━"
echo ""

# 1. Repositorio git válido
if git rev-parse --git-dir &>/dev/null; then
  ok "Git: repositorio válido"
else
  fail "Git: no es un repositorio git — asegurate de correr esto desde la raíz de la academia"
  echo ""
  echo "━━━ NO LISTO — $FAIL item(s) requieren atención ━━━"
  echo ""
  exit 1
fi

# 2. Remote origin accesible
if git ls-remote origin &>/dev/null 2>&1; then
  ok "Remote origin: accesible"
else
  fail "Remote origin: no accesible — verificar conexión o credenciales de GitHub"
fi

# 3. SENSEI.md presente
if [[ -f ".claude/SENSEI.md" ]]; then
  ok "SENSEI.md: presente"
else
  fail "SENSEI.md: falta en .claude/SENSEI.md"
fi

# 4. Skills base presentes
SKILLS=("project-init" "session-start" "session-end")
MISSING=()
for skill in "${SKILLS[@]}"; do
  [[ ! -f ".claude/skills/$skill/SKILL.md" ]] && MISSING+=("$skill")
done
if [[ ${#MISSING[@]} -eq 0 ]]; then
  ok "Skills base: project-init, session-start, session-end"
else
  fail "Skills base: faltan — ${MISSING[*]}"
fi

# 5. Memory index presente
if [[ -f "memory/MEMORY.md" ]]; then
  ok "Memory index: presente"
else
  warn "Memory index: no encontrado (memory/MEMORY.md) — puede afectar continuidad de sesión"
fi

# 6. Estado de main vs origin/main
LOCAL_MAIN=$(git rev-parse main 2>/dev/null)
REMOTE_MAIN=$(git rev-parse origin/main 2>/dev/null)
if [[ -n "$LOCAL_MAIN" && -n "$REMOTE_MAIN" ]]; then
  if [[ "$LOCAL_MAIN" == "$REMOTE_MAIN" ]]; then
    ok "main: sincronizado con origin/main"
  else
    warn "main: diverge de origin/main — correr 'git fetch origin main' para actualizar"
  fi
fi

# 7. Rama actual y working tree
echo ""
BRANCH=$(git branch --show-current)
info "Rama actual: $BRANCH"

DIRTY=$(git status --porcelain)
if [[ -z "$DIRTY" ]]; then
  ok "Working tree: limpio"
else
  DIRTY_COUNT=$(echo "$DIRTY" | wc -l | tr -d ' ')
  warn "Cambios sin commitear: $DIRTY_COUNT archivo(s)"
fi

# Resumen
echo ""
if [[ $FAIL -eq 0 ]]; then
  echo "━━━ OK — listo para trabajar ━━━"
  echo ""
  exit 0
else
  echo "━━━ NO LISTO — $FAIL item(s) requieren atención [✗] ━━━"
  echo ""
  exit 1
fi

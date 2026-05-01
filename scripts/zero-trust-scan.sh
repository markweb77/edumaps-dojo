#!/bin/bash
# scripts/zero-trust-scan.sh — auditoría de seguridad zero-trust del dojo
#
# Template base. Adaptarlo a los servicios del proyecto:
#   1. Agregar patrones específicos en la sección "Patrones del proyecto"
#   2. Agregar los servicios en la sección "Rotación por servicio"
#
# USO:
#   bash scripts/zero-trust-scan.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_FILE="$REPO_ROOT/tmp/zero-trust-report.md"
BACKLOG_FILE="$REPO_ROOT/memory/project_backlog.md"

RED="\033[0;31m"
YELLOW="\033[0;33m"
GREEN="\033[0;32m"
BOLD="\033[1m"
RESET="\033[0m"

FINDINGS=0
declare -a REPORT_LINES=()

finding() {
  local severity="$1" title="$2" detail="$3" fix="$4" rotation="$5"
  FINDINGS=$((FINDINGS + 1))
  echo -e "  ${RED}✗${RESET}  ${BOLD}[$severity]${RESET} $title"
  echo "       Detalle:  $detail"
  echo "       Fix:      $fix"
  echo "       Rotación: $rotation"
  REPORT_LINES+=("### [$severity] $title")
  REPORT_LINES+=("")
  REPORT_LINES+=("**Detalle:** $detail")
  REPORT_LINES+=("")
  REPORT_LINES+=("**Fix:** $fix")
  REPORT_LINES+=("")
  REPORT_LINES+=("**Procedimiento de rotación:**")
  REPORT_LINES+=("$rotation")
  REPORT_LINES+=("")
  REPORT_LINES+=("---")
  REPORT_LINES+=("")
}

warn() { echo -e "  ${YELLOW}~${RESET}  $1"; }
ok()   { echo -e "  ${GREEN}✓${RESET}  $1"; }

scan_pattern() {
  local label="$1" pattern="$2" fix="$3" rotation="$4"
  local matches
  matches=$(git -C "$REPO_ROOT" grep -lP "$pattern" -- $TRACKED 2>/dev/null || true)
  if [[ -n "$matches" ]]; then
    finding "CRITICAL" "$label" "Detectado en: $matches" "$fix" "$rotation"
  else
    ok "$label — limpio"
  fi
}

echo ""
echo -e "${BOLD}=== Zero Trust Scan ===${RESET}"
echo "Escaneando archivos trackeados en git..."
echo ""

# Archivos trackeados (sin secrets/, binarios, grafos)
TRACKED=$(git -C "$REPO_ROOT" ls-files \
  | grep -v "^secrets/" \
  | grep -v "^graphify-out/" \
  | grep -v "\.png$" | grep -v "\.jpg$" | grep -v "\.ico$" \
  || true)

# ──────────────────────────────────────────────────────────────
echo "=== Cobertura de .gitignore ==="

if git -C "$REPO_ROOT" check-ignore -q secrets/ 2>/dev/null; then
  ok "secrets/ está en .gitignore"
else
  finding "CRITICAL" "secrets/ NO está en .gitignore" \
    "La carpeta secrets/ podría commitearse accidentalmente" \
    "Agregar 'secrets/' a .gitignore" \
    "N/A — acción preventiva"
fi

ENV_IGNORED=$(grep -c "\.env" "$REPO_ROOT/.gitignore" 2>/dev/null || echo 0)
if [[ "$ENV_IGNORED" -gt 0 ]]; then
  ok ".env cubierto en .gitignore"
else
  finding "HIGH" ".env no cubierto en .gitignore" \
    "Archivos .env pueden commitearse accidentalmente" \
    "Agregar '.env' y '*.env' a .gitignore (excepto *.env.example)" \
    "N/A — acción preventiva"
fi

# ──────────────────────────────────────────────────────────────
echo ""
echo "=== Archivos sensibles trackeados ==="

TRACKED_ENV=$(echo "$TRACKED" | grep -E "(^|/)\.env$|(^|/)\.env\." | grep -v "\.example" || true)
if [[ -n "$TRACKED_ENV" ]]; then
  finding "CRITICAL" "Archivo .env trackeado en git" \
    "Archivo(s): $TRACKED_ENV" \
    "git rm --cached <archivo> && git commit -m 'fix: remover .env del tracking'" \
    "Rotar TODAS las credenciales del archivo inmediatamente"
else
  ok "No hay archivos .env trackeados"
fi

CRED_FILES=$(echo "$TRACKED" | grep -iE "(credential|service.account|private.key|api.key|token)s?\.(json|yaml|yml|key|pem|p12|pfx)$" || true)
if [[ -n "$CRED_FILES" ]]; then
  finding "CRITICAL" "Archivos de credenciales trackeados" \
    "Archivos: $CRED_FILES" \
    "git rm --cached <archivo> && agregar al .gitignore" \
    "Revocar y generar nuevas credenciales para cada servicio afectado"
else
  ok "No hay archivos de credenciales trackeados"
fi

# ──────────────────────────────────────────────────────────────
echo ""
echo "=== Patrones universales ==="

# JWT tokens
scan_pattern \
  "JWT token hardcodeado" \
  "eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}" \
  "Mover el JWT a secrets/.env y leerlo desde variable de entorno" \
  "Revocar en el servicio emisor → generar nuevo → actualizar secrets/.env"

# Google API keys
scan_pattern \
  "Google API Key (AIza...)" \
  "AIza[A-Za-z0-9_\-]{35}" \
  "Mover a secrets/.env como GOOGLE_API_KEY o GEMINI_API_KEY" \
  "console.cloud.google.com → APIs → Credentials → Delete → Create new → actualizar secrets/.env"

# Generic high-entropy token (32+ hex chars between quotes)
scan_pattern \
  "Token de alta entropía (posible API key)" \
  "['\"][a-fA-F0-9]{32,}['\"]" \
  "Verificar si es una credencial real. Si lo es, mover a secrets/.env" \
  "Identificar el servicio propietario del token → revocar → generar nuevo"

# ──────────────────────────────────────────────────────────────
echo ""
echo "=== Patrones del proyecto ==="
# ↓ ADAPTAR: agregar patrones específicos de los servicios del dojo
#
# Ejemplo:
# scan_pattern \
#   "Mi Servicio API Key" \
#   "ms_[a-zA-Z0-9]{32,}" \
#   "Mover a secrets/.env como MI_SERVICIO_KEY" \
#   "mi-servicio.com → Settings → API → Revocar → Generar nueva → actualizar secrets/.env"
#
warn "Sin patrones de proyecto configurados — editar esta sección en scripts/zero-trust-scan.sh"

# ──────────────────────────────────────────────────────────────
echo ""
echo "=== Resultado ==="

if [[ "$FINDINGS" -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}Scan limpio — no se detectaron exposiciones.${RESET}"
  echo ""
  exit 0
fi

echo -e "${RED}${BOLD}$FINDINGS finding(s) de seguridad detectados.${RESET}"
echo ""

mkdir -p "$REPO_ROOT/tmp"
{
  echo "# Zero Trust Scan Report"
  echo ""
  echo "Generado: $(date '+%Y-%m-%d %H:%M')"
  echo "Findings: $FINDINGS"
  echo ""
  echo "---"
  echo ""
  for line in "${REPORT_LINES[@]}"; do echo "$line"; done
} > "$REPORT_FILE"

echo "Reporte completo: tmp/zero-trust-report.md"
echo ""

read -p "¿Agregar findings al backlog (memory/project_backlog.md)? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  {
    echo ""
    echo "## Zero Trust Findings — $(date '+%Y-%m-%d')"
    echo ""
    for line in "${REPORT_LINES[@]}"; do echo "$line"; done
  } >> "$BACKLOG_FILE"
  echo "Findings agregados a memory/project_backlog.md"
  echo "Commitear: git add memory/project_backlog.md && git commit -m 'chore: zero trust findings $(date +%Y-%m-%d)'"
fi

echo ""
exit 1

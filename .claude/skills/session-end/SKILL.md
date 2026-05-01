# /session-end

Cierre de sesión Kata Samurai: log → memoria → seed → commit.

Trigger: `/session-end`

---

## Qué hace

Automatiza la fase CERRAR del loop INGESTAR → ANALIZAR → PLANIFICAR → EJECUTAR → **CERRAR**:

1. Lee el estado git para entender qué cambió
2. Pregunta al usuario por completions y learnings
3. Actualiza `memory/` (backlog + entradas nuevas)
4. Escribe el seed de próxima sesión
5. Ofrece `/graphify-update` si corresponde
6. Commitea los cambios de memoria

---

## Steps

### Step 1 — Leer contexto de la sesión

Ejecutar:

```bash
git log --oneline -15
git diff --stat HEAD
git status --short
```

Buscar el último commit que contenga "session close" para acotar el scope de la sesión actual. Si no existe, usar los últimos 10 commits como contexto.

Construir internamente un resumen de 2-3 líneas: qué se commitó, qué está sin commitear, qué archivos cambiaron.

### Step 2 — Preguntar al usuario

Si el usuario ya pasó una descripción al invocar el skill (e.g., `/session-end construimos el skill X`), usar esa como base y saltar esta pregunta.

Si no, presentar el resumen del Step 1 y preguntar:

> "Esta sesión: [resumen]. ¿Qué se completó y hay algún learning, decisión o feedback que guardar en memoria?"

Esperar la respuesta antes de continuar.

### Step 3 — Actualizar memory/

Basado en la respuesta del usuario y el git diff:

**Backlog** (`memory/project_backlog.md`):
- Abrir el archivo y marcar con ~~tachado~~ los ítems completados esta sesión
- Agregar nuevos ítems pendientes si emergieron
- Actualizar la fecha del encabezado de estado

**BTW → Clasificar**:
- Leer la sección "BTW / Sin clasificar"
- Si tiene ítems, por cada uno determinar en qué sección del backlog activo encaja mejor: usar el contenido del ítem y los títulos de las secciones existentes como referencia
- Mover cada ítem clasificado a su sección destino y quitarlo de BTW
- Solo dejar un ítem en BTW si genuinamente no hay sección donde encaje — es la excepción, no la regla
- Ítems que bloquean trabajo → mover a "Tareas críticas pendientes" independientemente de su etiqueta original

**Nuevas entradas de memoria** (solo si hay información genuinamente nueva):
- `feedback_*.md` — si el usuario mencionó algo que Claude hizo bien o mal
- `project_*.md` — si hubo decisiones de dirección, arquitectura o metodología
- `reference_*.md` — si apareció un recurso externo nuevo

**Índice** (`memory/MEMORY.md`):
- Actualizar una línea por cada archivo que se agregó o modificó

Regla: no crear entradas vacías ni redundantes. Si ya existe una entrada relevante, actualizarla en lugar de crear una nueva.

**Documentación navegable** (`RUNBOOK.md`, `README.md`, `docs/`):
- Revisar si los cambios de la sesión introducen desincronía: nuevo skill no listado en RUNBOOK, script nuevo sin documentar, configuración cambiada sin reflejo en README.
- Si hay desincronía concreta, proponer el update específico y aplicarlo antes de continuar.
- Si todo está en sync, pasar en silencio — no mencionar este check.

### Step 4 — Escribir seed de próxima sesión

Mostrar en la respuesta este bloque exacto:

```
━━━ SEED PRÓXIMA SESIÓN ━━━
Estado:       [1 línea — qué está en pie ahora mismo]
Próximo paso: [1 línea — ítem más accionable del backlog, específico]
Contexto:     [1-2 líneas — lo no-obvio que el próximo Claude necesita saber]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4b — Verificar tareas críticas pendientes

Antes de escribir el seed, revisar si quedaron herramientas o pasos del loop que fallaron en esta sesión (reintentos agotados, APIs no disponibles, scripts rotos).

Si hay fallos sin resolver:
- Confirmar que están registrados en `memory/project_backlog.md` bajo **Tareas críticas pendientes**
- Incluirlos en el seed como primer ítem del **Próximo paso** — no como contexto opcional
- El seed debe dejar claro que la próxima sesión arranca normalizando esa situación antes de cualquier otro trabajo

### Step 5 — /graphify-update

Si en el diff hay archivos `.md`, `.json`, `.sql`, `.py`, `.js`, `.ts`, o archivos en `workflows/`, ejecutar `/graphify-update` directamente — no pedir confirmación. El KB asimila todo conocimiento nuevo generado en sesión.

### Step 5b — Captura de glosario

Antes de preguntar, derivar candidatos del contexto de la sesión: commits, archivos creados/modificados, skills nuevos, decisiones de arquitectura, nombres de entidades o convenciones que aparecieron en el diff o en los mensajes de commit.

Leer `GLOSSARY.md` para filtrar términos que ya están documentados.

Si hay candidatos nuevos, presentarlos al usuario:
> "¿Emergió algún término nuevo? Detecté estos candidatos — confirmá los que aplican o descartá los que no:
> - **[término A]** — [categoría sugerida: Entidad / Alias / Convención] — [definición tentativa en una línea]
> - **[término B]** — ...
>
> ¿Agregamos alguno, los modificás, o hay otros que no detecté?"

Si no hay candidatos obvios, preguntar directamente:
> "¿Emergió algún término, alias o convención nueva durante esta sesión?"

Con lo que el usuario confirme → abrir `GLOSSARY.md` y agregar bajo la sección correspondiente (Entidades / Aliases / Convenciones).
Si no hay nada → continuar al commit sin fricción.

NEVER bloquear el cierre por este paso — si el usuario dice que no hay nada, seguir.
NEVER agregar términos que el usuario no confirmó explícitamente.

### Step 6 — Commit

Stagear y commitear los cambios de memoria:

```bash
git add memory/
git status
```

Commitear con:

```
chore: session close YYYY-MM-DD — [qué se logró esta sesión]
```

Usar la fecha actual. El resumen después del `—` debe describir el outcome principal: qué se construyó, qué se resolvió, qué se decidió.

Si el usuario tiene otros archivos sin commitear que quiere incluir (workflows/, scripts/, .claude/), preguntar antes de agregarlos al stage.

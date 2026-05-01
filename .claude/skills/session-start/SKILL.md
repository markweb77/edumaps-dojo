# /session-start

Punto de entrada de sesión Kata Samurai: INGESTAR → ANALIZAR → PLANIFICAR.

Trigger: `/session-start`

---

## Qué hace

Lee el estado del proyecto, identifica críticos y propone el foco de la sesión. No ejecuta nada — orienta y espera confirmación del usuario antes de arrancar.

---

## Constraints — NUNCA violar

- **NEVER** leer archivos fuera de los 5 especificados en Step 1, aunque parezcan relevantes
- **NEVER** iniciar ejecución de ninguna tarea sin que el usuario confirme explícitamente con una acción clara (ej: "sí", "vamos", "arrancá"). Respuestas ambiguas ("ok", "bien", "dale") requieren reconfirmar: "¿Arrancamos con [opción X]?"
- **NEVER** continuar sin confirmación si la opción elegida implica modificar archivos, correr scripts, o invocar otros skills
- El bloque de síntesis (Step 3) tiene un límite de **12 líneas** — sin elaboración ni contexto adicional
- Step 4 tiene un máximo de **3 intercambios** de descubrimiento. Si al tercer intercambio no hay dirección, presentar 3 opciones concretas y detenerse: "No surge una dirección clara. Elegí una: [A] / [B] / [C]"

---

## Steps

### Step 1 — Leer contexto (silencioso, en paralelo)

Leer sin mostrar output intermedio:

1. `memory/project_backlog.md` — estado actual, tareas críticas pendientes, backlog general
2. `memory/MEMORY.md` — índice de memoria para entender el estado global
3. `git log --oneline -20` — buscar el último commit con "session close" para extraer el seed de la sesión anterior
4. `git status --short` — detectar archivos sin commitear
5. `GLOSSARY.md` — vocabulario del dominio establecido en sesiones anteriores.
   Si no existe, ignorar sin error — no es bloqueante.
   Leer antes de cualquier análisis: condiciona la terminología de la sesión.

No mostrar el contenido crudo de estos archivos al usuario.

### Step 2 — Detectar críticos

Antes de cualquier síntesis, verificar:

- ¿Hay ítems bajo **Tareas críticas pendientes** en `memory/project_backlog.md`? Si sí, marcarlos como prioritarios — van primero en la propuesta sin excepción.
- ¿Hay archivos sin commitear según `git status`? Si sí, mencionarlo en la síntesis.
- ¿El último "session close" tiene un seed con "Próximo paso" definido? Extraerlo como punto de partida.

### Step 3 — Presentar síntesis

Mostrar este bloque exacto (adaptar contenido, no estructura):

```
━━━ SESSION START ━━━
Estado:        [1 línea — qué está en pie ahora mismo]
Última sesión: [seed extraído del último "session close", o "sin seed previo" si no existe]
Sin commitear: [archivos pendientes, o "limpio" si no hay nada]
Críticos:      [ítems críticos pendientes, o "ninguno"]
━━━━━━━━━━━━━━━━━━━━━

Propuesta para esta sesión:
1. [opción más accionable — basada en críticos o seed]
2. [segunda opción del backlog si corresponde]

¿Arrancamos con esto o tenés otra prioridad?
```

Reglas del bloque:
- Máximo 2 opciones en la propuesta — no listar todo el backlog
- Si hay críticos, la opción 1 siempre es el crítico
- Si no hay críticos, usar el seed de la sesión anterior como opción 1
- Si no hay seed, usar el ítem más accionable del backlog
- La pregunta final es obligatoria — no empezar a ejecutar sin confirmación del usuario

### Step 4 — Flujo sin dirección clara

Activar este paso si se cumple cualquiera de estas condiciones:
- El usuario no indica explícitamente con qué continuar después del bloque de síntesis
- No hay backlog (archivo vacío, inexistente, o sin ítems pendientes)
- No hay seed de sesión anterior y el backlog no tiene ítems accionables

En ese caso, no quedarse en silencio ni repetir la propuesta. Encauzar activamente:

**Si hay proyecto pero sin backlog claro** — proponer construirlo:
> "No hay backlog definido. Puedo ayudarte a construir uno: ¿cuál es el objetivo principal del proyecto en este momento?"

Esperar la respuesta. Con ella, generar 3-5 ítems concretos para el backlog y preguntar si los agregamos.

**Si es sesión inicial (sin memoria, sin commits de sesión)** — iniciar el camino de descubrimiento:

Este es el modo de onboarding. El objetivo no es arrancar a ejecutar sino construir el mapa desde el cual ejecutar. Guiar al usuario en una conversación de descubrimiento que cubra estas dimensiones, de a una o dos por vez, en el orden que fluya naturalmente:

- **Objetivo** — ¿qué problema resuelve este proyecto? ¿para quién?
- **Tecnologías** — ¿qué stack, servicios, APIs, herramientas están en juego o se planean usar?
- **Entregables** — ¿qué tiene que existir al final? ¿un producto, un informe, un sistema, un proceso?
- **Historias / casos de uso** — ¿qué hace un usuario típico? ¿cuáles son los flujos principales?
- **Componentes** — ¿qué partes tiene el sistema? ¿ya existen, o hay que construirlas?
- **Documentos y scripts existentes** — ¿hay archivos, repos, planillas, diagramas, manuales ya creados?
- **Conocimientos y supuestos** — ¿qué se da por sabido? ¿qué restricciones existen? ¿qué está fuera del alcance?

No lanzar todas las preguntas de golpe. Empezar con:
> "Primera sesión detectada. Para trazar el camino, necesito entender el proyecto. ¿Cuál es el objetivo principal y para quién?"

Con cada respuesta, extraer lo que corresponda a cada dimensión y continuar con la siguiente que falte. Cuando las dimensiones críticas (objetivo, entregables, componentes) estén cubiertas, sintetizar:

```
━━━ MAPA INICIAL ━━━
Objetivo:      [síntesis del objetivo]
Entregables:   [lista breve]
Componentes:   [partes identificadas]
Tecnologías:   [stack conocido]
Supuestos:     [restricciones o acuerdos base]
━━━━━━━━━━━━━━━━━━━━

Próximos pasos sugeridos:
1. [primer ítem de backlog concreto derivado del mapa]
2. [segundo ítem — puede ser /graphify si hay archivos, o definir estructura base]

¿Arrancamos con esto?
```

Si hay archivos en el repo, sugerir `/graphify` para ingestar el corpus existente antes de planificar — el grafo puede revelar componentes que el usuario no mencionó.

Guardar el mapa en `memory/project_context.md` si el usuario confirma que está bien.

**Si el usuario responde con algo distinto a las opciones propuestas** — pivotar sin friccción:
Tomar la nueva dirección como el foco de la sesión y confirmar:
> "Entendido, arrancamos con [lo que dijo el usuario]. ¿Algún contexto adicional antes de empezar?"

La regla general: el skill nunca termina dejando al usuario sin un paso claro. Si no hay backlog, el objetivo del skill pasa a ser construirlo. Si no hay contexto, construir el mapa es la sesión.

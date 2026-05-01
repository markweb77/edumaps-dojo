# /btw-add-feature

Captura una feature pendiente sin interrumpir el flujo de trabajo actual.

Trigger: `/btw-add-feature <descripción>`

---

## Qué hace

Anota una feature en `backlog.md` del proyecto actual y vuelve inmediatamente al trabajo en curso. El objetivo es capturar sin desviar — cero fricción, cero pérdida de foco.

---

## Steps

### Step 1 — Leer la descripción

Si el usuario pasó una descripción al invocar el skill (e.g., `/btw-add-feature agregar filtro por fecha`), usarla directamente.

Si no hay descripción, preguntar en una línea:
> "¿Qué feature querés anotar?"

Esperar la respuesta antes de continuar.

### Step 2 — Agregar al backlog

Buscar `backlog.md` en el directorio raíz del repo. Si no existe, buscarlo en el directorio actual.

Leer el archivo y encontrar la sección `## BTW / Sin clasificar`. Si no existe, crearla al final del archivo:

```markdown

---

## BTW / Sin clasificar

```

Agregar la nueva entrada al final de esa sección:

```markdown
- [ ] **<descripción>** — anotado /btw-add-feature, pendiente de clasificar
```

### Step 3 — Confirmar y continuar

Responder con exactamente una línea:

```
✓ Anotado en backlog: "<descripción>"
```

Luego continuar sin comentario adicional con lo que se estaba haciendo antes de la invocación. Si no había nada en curso, no agregar nada más.

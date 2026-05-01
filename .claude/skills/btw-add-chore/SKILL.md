# /btw-add-chore

Captura una tarea puntual (chore) pendiente sin interrumpir el flujo de trabajo actual.

Trigger: `/btw-add-chore <descripción>`

---

## Qué hace

Anota una tarea puntual en `backlog.md` del proyecto actual y vuelve inmediatamente al trabajo en curso. Igual que `/btw-add-feature` pero para tareas de mantenimiento, limpieza o ajustes que no son features nuevas.

---

## Steps

### Step 1 — Leer la descripción

Si el usuario pasó una descripción al invocar el skill (e.g., `/btw-add-chore limpiar tmp/`), usarla directamente.

Si no hay descripción, preguntar en una línea:
> "¿Qué chore querés anotar?"

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
- [ ] ~~chore~~ **<descripción>** — anotado /btw-add-chore, pendiente de clasificar
```

### Step 3 — Confirmar y continuar

Responder con exactamente una línea:

```
✓ Chore anotado: "<descripción>"
```

Luego continuar sin comentario adicional con lo que se estaba haciendo antes de la invocación. Si no había nada en curso, no agregar nada más.

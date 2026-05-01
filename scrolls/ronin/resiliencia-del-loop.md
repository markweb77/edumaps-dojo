# Resiliencia del loop: los fallos dejan constancia

**Fecha:** 2026-04-27
**Dojo origen:** [privado]

## Patrón

Cuando una herramienta falla a mitad de sesión, el sistema no puede recuperarse en la próxima sesión si no hay rastro del fallo. La convención: tool failure → entrada en backlog bajo "Críticos" → mención explícita en el seed de cierre. El loop no colapsa por un fallo — colapsa por un fallo silencioso.

## Contexto

En una sesión de trabajo intenso, `/graphify-update` falló después de varios reintentos — Gemini no disponible. La sesión cerró con el grafo desactualizado pero sin registro explícito de ese estado.

La siguiente sesión arrancó asumiendo que el grafo estaba al día. Se tomaron decisiones de arquitectura basadas en un conocimiento desactualizado. El error no fue el fallo de Gemini — fue la ausencia de rastro.

## El patrón de resiliencia

Cualquier fallo que deje el sistema en estado inconsistente merece dos registros:

**1. Backlog — sección "Críticos":**
```markdown
## Tareas críticas pendientes
- **[CRÍTICO] graphify-update incompleto** — Gemini no disponible al cierre YYYY-MM-DD.
  Reejecutar antes de cualquier otro trabajo en la próxima sesión.
```

**2. Seed de sesión:**
```
Próximo paso: reejecutar /graphify-update — falló al cierre anterior, grafo desactualizado.
```

El backlog captura el estado. El seed lo pone en primer plano. Los dos juntos garantizan que la próxima sesión arranque con la información correcta.

## Por qué ambos

Solo el backlog: fácil de ignorar si no se lee primero.
Solo el seed: se pierde cuando el seed es largo o hay muchas cosas.
Los dos juntos: el seed lleva la atención al crítico, el backlog tiene el detalle.

## La versión automatizada

Una vez establecido el patrón, el skill `/graphify-update` lo incorporó directamente: si Gemini falla después de todos los reintentos, el skill mismo escribe la entrada en el backlog y la menciona en el reporte final. El samurai no tiene que recordar hacerlo.

```
Si Gemini falló después de todos los reintentos:
- Agregar entrada en backlog bajo "Críticos"
- Reportar explícitamente al usuario
- Mencionar en seed de próxima sesión
```

## Generalización

Este patrón aplica a cualquier herramienta o paso del loop que puede quedar en estado inconsistente:

- Script de dump que falló a mitad
- Migración de BD que no completó
- Push a repositorio remoto que no llegó

La regla: si el fallo deja el sistema en un estado que la próxima sesión va a asumir como correcto — registrarlo explícitamente.

## Regla canonizada

> Los fallos silenciosos son el peor tipo de fallo. Cualquier tool failure que deje estado inconsistente merece entrada en backlog (Críticos) + mención en seed. Los dos juntos. El loop es resiliente no porque nunca falle, sino porque los fallos son visibles.

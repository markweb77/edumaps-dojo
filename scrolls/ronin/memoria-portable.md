# Memoria portable: de ~/.claude al repo

**Fecha:** 2026-04-27
**Dojo origen:** [privado]

## Patrón

La memoria de Claude Code vive en rutas locales de la máquina (`~/.claude/projects/...`). Si cambiás de equipo, clonás el repo en otro lado, o abre otro colaborador — el contexto acumulado desaparece. La solución: versionar `memory/` dentro del repo.

## Contexto

En las primeras sesiones del dojo, Claude guardaba memoria en:

```
~/.claude/projects/<hash-del-path>/memory/
```

El hash se deriva del path absoluto del proyecto en esa máquina específica. Cambiar de máquina = hash diferente = nueva carpeta vacía = contexto perdido.

Después de varias sesiones acumulando contexto sobre la arquitectura, los servicios y las decisiones del dojo, quedó claro que ese conocimiento era demasiado valioso para dejarlo en un path no versionado.

## La decisión

Mover `memory/` al repo. Git lo versiona, lo hace portable y lo hace parte del historial del proyecto.

```
repo/
  memory/
    MEMORY.md          ← índice (se carga automáticamente)
    project_*.md       ← contexto del proyecto
    feedback_*.md      ← aprendizajes sobre cómo trabajar
    reference_*.md     ← punteros a recursos externos
```

El `MEMORY.md` como índice permite que Claude lo lea en cada sesión sin leer todos los archivos — carga solo los relevantes según el contexto.

## Reglas que emergieron

**Paths relativos siempre.** Si una memoria dice `C:\Users\fulano\proyecto\...`, es inútil en otra máquina. Todo path en memoria debe ser relativo al repo.

**Nunca escribir en `~/.claude/` desde el dojo.** Si Claude intenta guardar en rutas locales, redirigir a `memory/` del repo.

**El índice es el contrato.** `MEMORY.md` es lo que se lee al inicio. Si una memoria no está en el índice, no existe para la próxima sesión.

## Consecuencia no obvia

Al versionar la memoria, los `git diff` de sesión incluyen el estado cognitivo del proyecto — no solo los cambios de código. El historial de `memory/` es la historia de cómo evolucionó el entendimiento del dojo.

## Regla canonizada

> La memoria de Claude es local a la máquina. Para que sea portable y sobreviva entre equipos y colaboradores, versionar `memory/` dentro del repo con paths relativos. El índice `MEMORY.md` es la interfaz — sin entrada en el índice, la memoria no se carga.

# CLAUDE.md — edumaps-dojo

Leer `.claude/SENSEI.md` — contiene la guía metodológica completa.

## Proyecto

**Edumaps** (edumaps.ar) es un atlas histórico mundial interactivo. Permite navegar hechos históricos en el mapa y en el tiempo, con fronteras dinámicas, sistema de lecciones secuenciales y creación de contenido por usuarios (docentes, alumnos, público general).

Desarrollado y mantenido por **Andrés** (Buenos Aires) — proyecto unipersonal de varios años.

## Modo del dojo

**Orquestador.** El código vive en los repos de Andrés. Este dojo gestiona sesiones de trabajo, memoria de decisiones técnicas y evolución de la plataforma. Los repos externos se relevan en el onboarding con Andrés.

## Stack (por confirmar con Andrés)

- Backend: PHP (sospechado)
- Base de datos: Elasticsearch (sospechado)
- Frontend, infra, CI/CD: por descubrir

## Usuarios de la plataforma

- **Docentes** — crean lecciones, limitan contexto para clases
- **Alumnos** — investigan, crean lecciones propias
- **Público general** — navegan libremente por categorías (arte, ciencia, deportes)

## Antecedente crítico

La plataforma sufrió sobrecarga tras exposición en Vorterix. La escalabilidad (balanceo de carga, consultas geoespaciales, alta concurrencia) es una prioridad técnica a revisar.

## Nomenclatura y formalismo

Por descubrir con Andrés. Encontrar su kata de trabajo es parte del onboarding inicial.

## Memoria

Leer `memory/MEMORY.md` al iniciar cada sesión.
Guardar memoria en `memory/` — paths relativos, sin rutas absolutas de máquina.

## Skills disponibles

- `/session-start` — iniciar sesión de trabajo
- `/session-end` — cerrar sesión y actualizar memoria
- `/btw-add-feature` — anotar feature en backlog
- `/btw-add-chore` — anotar tarea técnica en backlog

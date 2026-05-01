---
name: Contexto inicial del proyecto Edumaps
description: Mapa del dojo generado en project-init — plataforma, modo, stack, usuarios, antecedentes
type: project
---

# Edumaps — Contexto inicial

**Plataforma:** Atlas histórico mundial interactivo (edumaps.ar)
**Developer / key user:** Andrés (Buenos Aires) — proyecto unipersonal, varios años
**Dojo:** Orquestador — repos externos a relevar con Andrés

## Funcionalidades core

- Navegación espacio-temporal en mapa interactivo
- Fronteras dinámicas según época seleccionada
- Motor de búsqueda integrado (navega a coordenadas + año del evento)
- Sistema de filtros por categoría (política, deportes, arte, ciencias)
- **Lecciones** — narrativa secuencial de eventos con sync de UI; el diferencial del producto
- UGC — docentes y alumnos crean sus propias lecciones

## Usuarios

- Docentes: arman lecciones para clase
- Alumnos: investigan y crean lecciones
- Público general / curiosos: navegan libremente

## Stack (por confirmar con Andrés)

- Backend: PHP (sospechado)
- BD: Elasticsearch (sospechado)
- Frontend / infra / CI-CD: por descubrir

## Antecedente crítico

Exposición en Vorterix → sobrecarga de servidores.
**Why:** pico de tráfico superior al esperado.
**How to apply:** priorizar revisión de arquitectura cloud, balanceo de carga y optimización de consultas geoespaciales antes de cualquier nueva exposición pública.

## Ecosistema de repos

Por relevar con Andrés en el onboarding.
Puede incluir: backend, frontend, infra, BD, scripts de deploy.

## Kata de trabajo de Andrés

Por descubrir. Es parte del objetivo del primer onboarding.

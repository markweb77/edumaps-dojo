# Gestión proactiva de contexto

**Fecha:** 2026-04-27
**Dojo origen:** [privado]

## Patrón

El contexto de una sesión es un recurso finito. Si se agota sin aviso, se pierden los aprendizajes del final de sesión — los más valiosos, porque emergen después de la ejecución. La gestión proactiva invierte el orden: en lugar de esperar a que el contexto se agote, el samurai inicia el cierre cuando todavía hay margen para hacerlo bien.

## Contexto

En sesiones largas con múltiples skills, análisis de archivos y ejecuciones de código, el contexto se consume más rápido de lo esperado. La primera vez que esto pasó en el dojo, la sesión terminó abruptamente: Claude no pudo completar el `/session-end`, la memoria quedó sin actualizar y el seed fue incompleto.

El modelo de "trabajar hasta el límite" funciona para tareas cortas. Para sesiones de Kata, donde el cierre es parte del valor, es contraproducente.

## El protocolo

Dos umbrales, dos respuestas distintas:

**Al 70% de contexto consumido:**
- Evaluar si las tareas críticas de la sesión están completas
- Si hay tareas importantes pendientes: terminarlas antes de continuar con tareas secundarias
- Preparar mentalmente el cierre — qué hay que documentar, qué quedó abierto

**Al 85% de contexto consumido:**
- Iniciar `/session-end` inmediatamente, sin excepción
- Si hay tareas sin completar: registrarlas en backlog como pendientes antes de cerrar
- No iniciar tareas nuevas aunque parezcan pequeñas

La lógica: el `/session-end` consume contexto significativo (actualiza memoria, escribe seed, hace graphify-update). Si se inicia al 95%, no termina bien. Si se inicia al 85%, hay margen.

## Lo que se pierde en un cierre abrupto

- Memoria sin actualizar → la próxima sesión arranca sin los aprendizajes de esta
- Seed incompleto → no hay hilo conductor entre sesiones
- graphify-update no ejecutado → el grafo queda desactualizado
- Tareas críticas sin registrar → se pierden hasta que alguien las recuerda

Los primeros 15 minutos de la siguiente sesión se gastan reconstruyendo lo que se perdió. El cierre proactivo elimina ese costo.

## El cambio de perspectiva

La gestión reactiva trata el contexto como una barra de vida — se trabaja hasta que se acaba. La gestión proactiva lo trata como tiempo en un quirófano: hay que cerrar con margen, no porque falte trabajo, sino porque el cierre es parte de la operación.

Un session-end completo es más valioso que 20 minutos extra de ejecución con un cierre abrupto.

## Regla canonizada

> Al 70% de contexto: evaluar y priorizar. Al 85%: iniciar `/session-end` sin excepción. El cierre es parte de la kata, no el final de ella. Los aprendizajes documentados al cerrar valen más que las tareas extra ejecutadas al límite.

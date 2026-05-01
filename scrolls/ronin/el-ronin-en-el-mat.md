# El ronin en el mat: cómo sacarle provecho a las sesiones desde el primer día

**Fecha:** 2026-04-27
**Dojo origen:** [privado]

## Patrón

La Kata Samurai no es un conjunto de herramientas — es un ritual de trabajo con estructura fija: abrir, ejecutar, cerrar. El ronin que llega al mat sin entender esa estructura puede ejecutar muchas tareas sin completar ninguna kata. La diferencia entre "trabajé mucho" y "avancé" está en el loop.

## El error más común del primer mat

El ronin llega con energía, abre Claude Code y empieza a ejecutar. Resuelve bugs, agrega features, modifica archivos. Al final de la sesión, está cansado y cierra la terminal.

No actualizó la memoria. No escribió el seed. No cerró el loop.

La próxima sesión arranca sin contexto. El ronin gasta 20 minutos reconstruyendo lo que ya sabía. Avanzó el código pero no avanzó el conocimiento.

Este scroll existe para que eso no ocurra.

## Los tres momentos que importan

**Abrir bien:** `/session-start` no es un trámite — es el momento en que el sistema lee el contexto acumulado de todas las sesiones anteriores y propone el foco. Sin ese momento, se trabaja con información de la sesión anterior que el ronin intenta recordar de memoria. Con él, se trabaja con el estado real del proyecto.

**Ejecutar con captura:** Durante la sesión, van a aparecer ideas, bugs secundarios, mejoras que no son urgentes. El impulso natural es anotarlas en algún lado o ignorarlas. Hay una tercera opción: `/btw-add-feature` o `/btw-add-chore`. Un segundo de ejecución, sin perder el hilo, sin acumular deuda cognitiva.

**Cerrar con intención:** `/session-end` es la parte más importante de la sesión. Actualiza la memoria, escribe el seed de la próxima sesión, actualiza el grafo de conocimiento. Si el ronin solo tiene tiempo para hacer una cosa bien, que sea el cierre. Una sesión bien cerrada vale más que dos sesiones sin cerrar.

## El seed es el contrato con tu próximo yo

El seed que se escribe al cerrar es lo que aparece al abrir la próxima sesión. Es la diferencia entre arrancar con "¿dónde estaba yo?" y arrancar con "esto es lo que queda, esto es lo próximo".

Un buen seed tiene tres elementos:
- **Estado:** qué está en pie ahora mismo (qué se completó, qué cambió)
- **Próximo paso:** la tarea más accionable para la próxima sesión
- **Contexto:** lo no obvio que el próximo yo necesita saber

Un seed pobre dice "continuar con el proyecto". Un buen seed dice "el script X quedó a mitad porque la API Y devolvió un error que aún no investigamos — el próximo paso es leer el log en Z".

## El SENSEI no es documentación — es el árbitro

El SENSEI.md rige la sesión. No es un archivo de referencia para leer cuando surja una duda — es el marco que define cómo se trabaja. Cuando el ronin quiere cambiar la metodología, modificar el loop o canonizar un nuevo patrón, el camino es actualizar el SENSEI, no saltárselo.

Leer el SENSEI al inicio del dojo nuevo es el equivalente a leer las reglas del mat antes de la primera práctica. No es opcional.

## La memoria es el activo que se acumula

Cada sesión construye sobre las anteriores porque la memoria persiste. El sistema recuerda decisiones de arquitectura, restricciones del entorno, feedbacks sobre cómo trabajar, punteros a recursos externos. No hay que reexplicar el contexto en cada sesión.

Pero solo persiste lo que se escribe. Si una sesión termina sin actualizar la memoria, ese contexto se pierde. La próxima sesión arranca sin esa capa.

La memoria tiene tipos. Saber cuál usar evita que el índice se llene de ruido:

- **user** — quién es el samurai, su rol, su nivel
- **feedback** — cómo trabajar en este proyecto (qué evitar, qué repetir)
- **project** — estado actual, decisiones en curso, fechas
- **reference** — dónde encontrar información externa (dashboards, repos, APIs)

## El grafo es el mapa

El knowledge graph muestra el proyecto como una red de nodos y relaciones. Para el ronin, tiene un uso práctico concreto: antes de tocar una parte del sistema que no se conoce bien, leer el grafo revela qué está conectado a qué.

El punto de entrada correcto no es el archivo `graph.json` crudo — es el `GRAPH_REPORT.md`. Ahí están los god nodes (los nodos más conectados, los que más impacto tienen si cambian) y las comunidades (los clusters de componentes relacionados).

El grafo no reemplaza leer el código — lo complementa. Muestra la estructura que no es visible desde ningún archivo individual.

## Lo que el loop hace que el ronin no nota

El valor de la Kata Samurai no está en ningún momento individual — está en la acumulación. Cada sesión bien cerrada deja el sistema en mejor estado que lo encontró: más contexto documentado, más patrones identificados, más decisiones registradas.

Al tercer mes de sesiones bien estructuradas, el ronin arranca cada sesión con un grafo actualizado, una memoria que cubre el 90% del contexto relevante y un seed que apunta directamente al siguiente paso. La sesión de dos horas produce más que una sesión de cuatro horas sin estructura porque no se gasta tiempo reconstruyendo lo que ya se sabía.

El loop es la inversión. La kata es el retorno.

## Regla canonizada

> La Kata Samurai tiene tres momentos: abrir (leer el contexto), ejecutar (con captura activa de lo que emerge) y cerrar (actualizar memoria, escribir seed). El ronin que domina los tres momentos avanza en cada sesión. El que solo ejecuta trabaja mucho y avanza poco. El cierre no es el final de la sesión — es la sesión dentro de la sesión.

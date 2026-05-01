# graphify-update: del subprocess roto al SDK directo

**Fecha:** 2026-04-27
**Dojo origen:** [privado]

## Patrón

Cuando un proceso externo captura stdout para parsear JSON estructurado, las respuestas grandes se truncan en silencio. La solución no es ajustar el modelo ni el chunk size — es eliminar el proceso externo y llamar la función directamente.

## Contexto

El dojo tenía `/graphify-update` funcionando con Gemini free tier después de los fixes del scroll anterior (chunks ≤ 5, retry en 429). En una sesión con muchos archivos de documentación, el update empezó a fallar con `Unterminated string` — JSON truncado en el medio de la respuesta.

Primera hipótesis: el modelo devuelve demasiado texto. Fix: reducir chunk size a 2 archivos.

Funcionó parcialmente. Pero el problema real era otro.

## El bug real: subprocess pierde stdout

El script original llamaba `gemini_extract.py` via `subprocess.run(capture_output=True)`. En respuestas grandes (>187k caracteres), `capture_output=True` trunca el stdout antes de que el proceso termine. El JSON quedaba cortado, el parse fallaba, el chunk se perdía.

```python
# Así estaba — captura stdout, trunca en respuestas grandes
r = subprocess.run(
    ['python', 'scripts/gemini_extract.py', ...],
    capture_output=True, text=True
)
data = json.loads(r.stdout)  # falla con Unterminated string
```

## El fix: importar y llamar directo

```python
# Así quedó — sin proceso intermedio, sin truncamiento
import sys
sys.path.insert(0, 'scripts')
from gemini_extract import extract

result = extract(chunk, model_name=model)
```

Eliminar el subprocess elimina el problema de raíz. La función devuelve el dict directamente — no hay serialización, no hay stdout, no hay truncamiento.

## Lección de debugging

El síntoma (JSON truncado) apuntaba al modelo o al tamaño del chunk. La causa real era la capa de transporte entre procesos. Reducir el chunk size mitigaba el problema porque respuestas más chicas no llegaban al límite de truncamiento — pero no lo resolvía.

La lección: cuando un fix de síntoma funciona "casi siempre", buscá la causa un nivel más abajo.

## También: 503 → fallback automático

En la misma sesión se agregó fallback automático cuando el modelo principal devuelve 503 UNAVAILABLE (alta demanda):

```python
MODEL = 'gemini-2.5-flash'
MODEL_FALLBACK = 'gemini-2.5-flash-lite'

# En el retry loop:
if '503' in err or 'UNAVAILABLE' in err:
    if model == MODEL and attempt == 0:
        model = MODEL_FALLBACK  # silencioso, continúa
        continue
```

No interrumpe el run. El usuario ve el switch en el log pero el proceso sigue.

## Regla canonizada

> Al integrar un extractor semántico externo: llamar la función directamente (import), nunca via subprocess con capture_output. Los procesos con stdout grande truncan en silencio — el error aparece como JSON malformado, no como error de proceso.

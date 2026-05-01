# Gemini Free Tier — Bugs de producción en /graphify-update

**Fecha:** 2026-04-26
**Dojo origen:** [privado]

## Patrón

Al correr `/graphify-update` con Gemini free tier en producción, aparecen cinco errores que no son obvios desde el código. Todos tienen fix directo.

## Contexto

Primera ejecución real de `/graphify-update` después de una sesión con 22 archivos cambiados. El skill estaba escrito con `gemini-2.0-flash` y chunks de 15 archivos. Falló en múltiples puntos.

## Bugs encontrados y fixes

### 1. Chunks de 15 archivos → 429 RESOURCE_EXHAUSTED

**Qué pasó:** El free tier de gemini-2.5-flash tiene un límite de 250k tokens de input por minuto. Un chunk de 15 archivos markdown lo supera.

**Fix:** Chunks de **5 archivos** máximo. Agregar `time.sleep(3)` entre chunks.

```python
chunks = [files[i:i+5] for i in range(0, len(files), 5)]
if i < len(chunks) - 1:
    time.sleep(3)
```

### 2. gemini-2.0-flash con daily quota 0

**Qué pasó:** `gemini-2.0-flash` devuelve `limit: 0` en el free tier — quota diaria efectivamente cero.

**Fix:** Usar **gemini-2.5-flash** como modelo por defecto.

### 3. String literal con `\"` corrompe JSON en PowerShell

**Qué pasó:** Escribir JSON como string literal en `python -c "..."` dentro de PowerShell corrompe las backslash-quotes. Resultado: JSON inválido con `\:` en lugar de `:`.

**Fix:** Usar `json.dumps()` siempre:

```python
Path('out.json').write_text(json.dumps({'nodes': [], 'edges': []}), encoding='utf-8')
```

### 4. Sin retry en 429

**Qué pasó:** `subprocess.run` silencia el error y el chunk se pierde sin avisar.

**Fix:** Retry con backoff:

```python
for attempt in range(3):
    r = subprocess.run(
        ['python', 'scripts/gemini_extract.py', '--model', 'gemini-2.5-flash'] + chunk,
        capture_output=True, text=True, env={**os.environ}
    )
    if r.returncode == 0:
        break
    if '429' in r.stderr or 'RESOURCE_EXHAUSTED' in r.stderr:
        time.sleep(60 * (attempt + 1))
    else:
        break
```

### 5. Sin `env={**os.environ}` en subprocess

**Qué pasó:** `GEMINI_API_KEY` seteado en PowerShell no llega al subprocess en todos los contextos.

**Fix:** Pasar `env={**os.environ}` explícitamente siempre.

## Regla canonizada

> Al usar Gemini free tier: chunks ≤ 5 archivos, `gemini-2.5-flash`, retry en 429 con backoff, `json.dumps()` para JSON, `env={**os.environ}` en subprocess.

Aplica a cualquier dojo que use `gemini_extract.py` o script similar para extracción semántica incremental.

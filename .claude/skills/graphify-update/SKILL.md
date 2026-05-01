# /graphify-update

Incremental graphify update using **Gemini** for semantic extraction instead of Claude subagents.
Trigger: `/graphify-update`

Token cost: near-zero for Claude. Heavy extraction runs on Gemini API (gemini-2.5-flash).
Extraction script: `scripts/gemini_extract.py`

**Free tier limits (gemini-2.5-flash):** 250k input tokens/min. Chunks of 5 files + sleep between chunks keeps it safe.
**gemini-2.0-flash:** daily quota is 0 on free tier — do not use as default.

## Steps

### Step 1 — Load GEMINI_API_KEY from secrets/.env

```powershell
$env_content = Get-Content secrets/.env -ErrorAction SilentlyContinue
$env_content | Where-Object { $_ -match "^GEMINI_API_KEY=" } | ForEach-Object {
    $env:GEMINI_API_KEY = $_.Split("=", 2)[1]
}
if (-not $env:GEMINI_API_KEY) { Write-Error "GEMINI_API_KEY not found in secrets/.env"; exit 1 }
Write-Host "API key loaded"
```

### Step 2 — Detect changed files

```powershell
python -c "
import json
from graphify.detect import detect_incremental
from pathlib import Path
result = detect_incremental(Path('.'))
Path('.graphify_incremental.json').write_text(json.dumps(result), encoding='utf-8')
new_total = result.get('new_total', 0)
if new_total == 0:
    print('Nothing changed. Graph is up to date.')
else:
    for ftype, files in result.get('new_files', {}).items():
        if files: print('  ' + ftype + ': ' + str(len(files)) + ' file(s)')
    print('Total: ' + str(new_total) + ' file(s)')
"
```

If output says "Nothing changed" — stop here.

### Step 3 — AST extraction (code files, free)

```powershell
python -c "
import json
from graphify.extract import extract
from pathlib import Path
detect = json.loads(Path('.graphify_incremental.json').read_text(encoding='utf-8'))
code_files = [Path(f) for f in detect.get('new_files', {}).get('code', []) if not f.endswith('.sql')]
if code_files:
    result = extract(code_files)
    Path('.graphify_ast.json').write_text(json.dumps(result), encoding='utf-8')
    print('AST: ' + str(len(result['nodes'])) + ' nodes, ' + str(len(result['edges'])) + ' edges')
else:
    empty = {'nodes': [], 'edges': [], 'hyperedges': [], 'input_tokens': 0, 'output_tokens': 0}
    Path('.graphify_ast.json').write_text(json.dumps(empty), encoding='utf-8')
    print('No code files')
"
```

### Step 4 — Semantic extraction via Gemini

Gather docs + SQL files and run Gemini in chunks of **5 files** with retry on rate limit and server errors:

```powershell
# Load API key in this same PowerShell session (env vars don't persist between tool calls)
$env_content = Get-Content secrets/.env -ErrorAction SilentlyContinue
$env_content | Where-Object { $_ -match "^GEMINI_API_KEY=" } | ForEach-Object {
    $env:GEMINI_API_KEY = $_.Split("=", 2)[1]
}

python -c "
import json, subprocess, sys, os, time
from pathlib import Path

detect = json.loads(Path('.graphify_incremental.json').read_text(encoding='utf-8'))
doc_files = detect.get('new_files', {}).get('document', []) + detect.get('new_files', {}).get('paper', [])
sql_files = [f for f in detect.get('new_files', {}).get('code', []) if f.endswith('.sql')]
files = doc_files + sql_files

if not files:
    empty = {'nodes': [], 'edges': [], 'hyperedges': [], 'input_tokens': 0, 'output_tokens': 0}
    Path('.graphify_semantic.json').write_text(json.dumps(empty), encoding='utf-8')
    print('No semantic files')
    sys.exit(0)

print('Semantic files: ' + str(len(files)))
chunks = [files[i:i+5] for i in range(0, len(files), 5)]
nodes, edges, hyperedges, tin, tout = [], [], [], 0, 0
seen = set()

for i, chunk in enumerate(chunks):
    print('Chunk ' + str(i+1) + '/' + str(len(chunks)) + ': ' + str(chunk))
    for attempt in range(5):
        r = subprocess.run(
            ['python', 'scripts/gemini_extract.py', '--model', 'gemini-2.5-flash'] + chunk,
            capture_output=True, text=True, env={**os.environ}
        )
        if r.returncode == 0:
            break
        if '429' in r.stderr or 'RESOURCE_EXHAUSTED' in r.stderr:
            wait = 60 * (attempt + 1)
            print('Rate limit (attempt ' + str(attempt+1) + '), waiting ' + str(wait) + 's...')
            time.sleep(wait)
        elif '503' in r.stderr or 'UNAVAILABLE' in r.stderr:
            wait = 30 * (attempt + 1)
            print('API unavailable (attempt ' + str(attempt+1) + '), waiting ' + str(wait) + 's...')
            time.sleep(wait)
        else:
            print('Fatal error in chunk ' + str(i+1) + ': ' + r.stderr[-300:])
            break
    else:
        print('Chunk ' + str(i+1) + ' failed after 5 attempts, skipping')
        continue

    try:
        d = json.loads(r.stdout)
    except Exception as e:
        print('JSON parse error in chunk ' + str(i+1) + ': ' + str(e))
        continue

    for n in d.get('nodes', []):
        if n['id'] not in seen:
            nodes.append(n)
            seen.add(n['id'])
    edges.extend(d.get('edges', []))
    hyperedges.extend(d.get('hyperedges', []))
    tin += d.get('input_tokens', 0)
    tout += d.get('output_tokens', 0)

    if i < len(chunks) - 1:
        time.sleep(3)

merged = {'nodes': nodes, 'edges': edges, 'hyperedges': hyperedges, 'input_tokens': tin, 'output_tokens': tout}
Path('.graphify_semantic.json').write_text(json.dumps(merged), encoding='utf-8')
print('Gemini done: ' + str(len(nodes)) + ' nodes, ' + str(len(edges)) + ' edges (' + str(tin) + ' in / ' + str(tout) + ' out tokens)')
"
```

### Step 5 — Merge new extraction + existing graph

```powershell
python -c "
import json
from graphify.build import build_from_json
from networkx.readwrite import json_graph
from pathlib import Path

ast = json.loads(Path('.graphify_ast.json').read_text(encoding='utf-8'))
sem = json.loads(Path('.graphify_semantic.json').read_text(encoding='utf-8'))
seen = {n['id'] for n in ast['nodes']}
merged_nodes = list(ast['nodes'])
for n in sem.get('nodes', []):
    if n['id'] not in seen:
        merged_nodes.append(n)
        seen.add(n['id'])
new_ext = {'nodes': merged_nodes, 'edges': ast['edges'] + sem.get('edges', []),
           'hyperedges': sem.get('hyperedges', []),
           'input_tokens': sem.get('input_tokens', 0), 'output_tokens': sem.get('output_tokens', 0)}
existing = json.loads(Path('graphify-out/graph.json').read_text(encoding='utf-8'))
G = json_graph.node_link_graph(existing, edges='links')
G.update(build_from_json(new_ext))
full = {'nodes': [{'id': n, **d} for n, d in G.nodes(data=True)],
        'edges': [{'source': u, 'target': v, **d} for u, v, d in G.edges(data=True)],
        'hyperedges': new_ext.get('hyperedges', []),
        'input_tokens': new_ext.get('input_tokens', 0), 'output_tokens': new_ext.get('output_tokens', 0)}
Path('.graphify_extract_full.json').write_text(json.dumps(full, ensure_ascii=False), encoding='utf-8')
print('Merged: ' + str(G.number_of_nodes()) + ' nodes, ' + str(G.number_of_edges()) + ' edges')
"
```

### Step 6 — Cluster + build analysis

```powershell
python -c "
import json
from graphify.build import build_from_json
from graphify.cluster import cluster, score_all
from graphify.analyze import god_nodes, surprising_connections, suggest_questions
from pathlib import Path
full = json.loads(Path('.graphify_extract_full.json').read_text(encoding='utf-8'))
G = build_from_json(full)
communities = cluster(G)
cohesion = score_all(G, communities)
gods = god_nodes(G)
surprises = surprising_connections(G, communities)
labels = {cid: 'Community ' + str(cid) for cid in communities}
analysis = {'communities': {str(k): v for k, v in communities.items()},
            'cohesion': {str(k): v for k, v in cohesion.items()},
            'gods': gods, 'surprises': surprises}
Path('.graphify_analysis.json').write_text(json.dumps(analysis, ensure_ascii=False), encoding='utf-8')
print(str(len(communities)) + ' communities, ' + str(G.number_of_nodes()) + ' nodes')
for cid, nodes in {int(k): v for k, v in analysis['communities'].items()}.items():
    sample = [G.nodes[n].get('label', n) for n in nodes[:3] if n in G.nodes]
    print('  C' + str(cid) + ': ' + str(sample))
"
```

Read the community preview above and assign plain-language labels (2-5 words each). Then run:

```powershell
python -c "
import json
from graphify.build import build_from_json
from graphify.cluster import score_all
from graphify.analyze import suggest_questions
from graphify.report import generate
from graphify.export import to_json, to_html
from pathlib import Path
full = json.loads(Path('.graphify_extract_full.json').read_text(encoding='utf-8'))
analysis = json.loads(Path('.graphify_analysis.json').read_text(encoding='utf-8'))
G = build_from_json(full)
communities = {int(k): v for k, v in analysis['communities'].items()}
cohesion = {int(k): v for k, v in analysis['cohesion'].items()}
detection = {'total_files': G.number_of_nodes(), 'total_words': 5000, 'needs_graph': True,
             'warning': None, 'files': {'code': [], 'document': [], 'paper': []}}
tokens = {'input': full.get('input_tokens', 0), 'output': full.get('output_tokens', 0)}
labels = LABELS_DICT
questions = suggest_questions(G, communities, labels)
report = generate(G, communities, cohesion, labels, analysis['gods'], analysis['surprises'],
                  detection, tokens, '.', suggested_questions=questions)
Path('graphify-out/GRAPH_REPORT.md').write_text(report, encoding='utf-8')
to_json(G, communities, 'graphify-out/graph.json')
to_html(G, communities, 'graphify-out/graph.html', community_labels=labels)
print('Done')
"
```

Replace `LABELS_DICT` with the labels dict you assigned above.

### Step 7 — Save manifest + cleanup

```powershell
python -c "
import json
from graphify.detect import save_manifest
from pathlib import Path
detect = json.loads(Path('.graphify_incremental.json').read_text(encoding='utf-8'))
save_manifest(detect['files'])
print('Manifest saved')
"
Remove-Item -ErrorAction SilentlyContinue .graphify_incremental.json, .graphify_ast.json, .graphify_semantic.json, .graphify_semantic_files.txt, .graphify_extract_full.json, .graphify_analysis.json
Write-Host "graphify-update complete"
```

### Step 8 — Report to user

Tell the user:
- Total nodes / edges in updated graph
- Top 3 god nodes
- Gemini token cost from Step 4
- Most interesting suggested question, offer to trace it

**Si Gemini falló después de todos los reintentos** (chunks con 0 nodos por error, no por vacío):
- No silenciar el fallo — reportarlo explícitamente
- Agregar entrada en `memory/project_backlog.md` bajo **Tareas críticas pendientes**:
  ```
  - **[CRÍTICO] graphify-update incompleto** — Gemini no disponible al cierre de sesión YYYY-MM-DD. Reejecutar `/graphify-update` al inicio de la próxima sesión antes de cualquier otro trabajo.
  ```
- Mencionar en el seed de próxima sesión que el grafo está desactualizado

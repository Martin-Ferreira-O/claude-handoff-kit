# Orquestación de slugs en paralelo (Claude-only)

> **El kit funciona sin esto.** El core maneja **un slug a la vez** con
> `/plan → /resume → /implement`. `/dispatch` es una capa **opt-in y Claude-only**
> para lanzar varios slugs a la vez — usa primitivos de Claude Code (`Agent` con
> `isolation: "worktree"`, `TaskCreate`) que no son parte del contrato portable.
> Un usuario de Codex lo ignora por completo.

## Dónde encaja `/dispatch`: tres modos de ejecución

Un slug se puede ejecutar de tres formas — `/dispatch` es la de mayor escala:

| Modo | Comando | Aislamiento | Modelo | Cuándo |
|---|---|---|---|---|
| In-session (default, portable) | `/implement <slug>` | sesión actual | el de la sesión | 1 slug acoplado; Codex |
| Delegate (opt-in, Claude-only) | `/implement --delegate <slug>` | 1 subagente fresco, rama actual | ruteado por card | 1 slug, sin abrir otra terminal |
| Dispatch (opt-in, Claude-only) | `/dispatch` | N subagentes, worktrees aislados | ruteado por card | varios slugs disjuntos en paralelo |

Los dos modos Claude-only **rutean el modelo por el Task card** del slug
(`docs/routing.md`): 1-3 Sonnet · 4-7 Opus medium · 8-10 Opus max; el `effort` va como
guía en el prompt. El resto de este documento describe `/dispatch`.

## El modelo

El kit ya promete "parallel slugs": partir un plan grande en varios slugs con
**conjuntos de archivos disjuntos** en vez de un slug gigante que pudre el
contexto del implementador. `/dispatch` ejecuta esa promesa:

1. **Manifiesto = INDEX estructurado.** `docs/handoff/INDEX.md` es una tabla
   `| slug | status | depends-on | updated | note |`, machine-parseable con
   `awk -F'|'`. `status ∈ {todo, in-progress, blocked, done}`; `depends-on` lista
   los slugs que deben estar `done` primero.
2. **DAG + orden topológico.** Cada `depends-on` es una arista. `/dispatch`
   ordena topológicamente, detecta ciclos y dependencias colgantes, y calcula la
   **oleada lista**: slugs `todo` con todas sus deps en `done`.
3. **Fan-out aislado + routing de modelo.** Cada slug listo se lanza como subagente
   background en su **propio git worktree** (`isolation: "worktree"`). El worktree es
   el habilitador: cada agente commitea en su rama sin pisar el working tree de los
   demás. El `model` del `Agent` se **rutea por el Task card** del slug
   (`Modelo recomendado` → `opus`/`sonnet`, default Sonnet si no hay card; ver
   `docs/routing.md`) en vez de un modelo fijo. El subagente corre `/implement <slug>`
   — sigue siendo un implementador del kit, con PLAN como spec y el gate de
   verificación adentro.
4. **Cierre de oleada → merge revisado.** Cuando la oleada termina, `/dispatch`
   **propone** el merge de las ramas (nunca auto-merge a `main`), reporta
   conflictos, y avanza a la siguiente oleada hasta vaciar el DAG.

```
INDEX (status + depends-on)
        │  awk -F'|'
        ▼
   DAG topológico ──► oleada lista (todo + deps done)
        │
        ▼  Agent run_in_background + isolation:"worktree"  (cap --max N)
   ┌────────────┬────────────┐
   │ worktree A │ worktree C │   cada uno: /implement <slug>, commit por paso
   └─────┬──────┴─────┬──────┘
         ▼            ▼
   status: done   status: done   ──► merge revisado por el usuario
         │
         ▼  recalcular oleada
      worktree B (depende de A)  ──►  …
```

## Por qué cada pieza

| Pre-requisito | Quién lo provee | Por qué es necesario |
|---|---|---|
| INDEX parseable (`status`/`depends-on`) | esquema de `AGENTS.md` (Plan 05) | sin él no hay orden topológico — la prosa libre no se ordena |
| Stop-hook slug-aware por rama | `hooks/verify-gate.sh` (Plan 04) | cada worktree valida **solo su** slug; un `.verify` roto en `slug-a` no bloquea el turno del worktree `slug-b` |
| Worktrees aislados | `Agent` `isolation: "worktree"` | N ramas en paralelo sin pisarse el working tree |
| Tracking | `TaskCreate`/`TaskList` | saber qué se lanzó y cómo terminó cada oleada |

## Caveats

- **Costo / rate-limits.** N agentes en paralelo es caro. El default es **cap 2** y
  el **modelo se rutea por el Task card** de cada slug (default Sonnet si no hay card;
  ver `docs/routing.md`) — un slug mecánico corre barato en Sonnet, uno crítico en
  Opus. Subí `--max` solo si lo necesitás.
- **Archivos disjuntos es obligatorio, no opcional.** `/dispatch` **no puede
  garantizar** ausencia de conflictos: si dos slugs de la misma oleada tocan el
  mismo archivo, el merge los va a exponer. La disciplina de slug-sizing con
  conjuntos de archivos disjuntos pasa de recomendación a requisito. Acotalo al
  diseñar el plan (en `/plan`, partí en slugs disjuntos).
- **Merge siempre revisado.** Nunca hay auto-merge a `main`. El paso de
  integración propone el merge y pide confirmación; los conflictos se reportan con
  los archivos en cuestión, no se resuelven adivinando.
- **Back-channel respetado.** Si un subagente para en una *Open question for the
  spec author*, su slug queda `blocked` — resolverla es trabajo de **Opus**
  (`/resume` la surfacea), no del orquestador ni del implementador.

## Uso

```sh
/dispatch            # cap por defecto (2)
/dispatch --max 3    # subir concurrencia (más costo)
```

Requiere el INDEX estructurado y, para que el gate funcione en cada worktree, el
Stop-hook slug-aware habilitado (ver `docs/hooks.md`). Sin INDEX parseable,
`/dispatch` para y lo reporta.

## Ejemplo end-to-end: Task Map → slugs paralelos

Una tarea multi-unidad — *"agregá export CSV, export PDF y un rate-limit al API"* —
que `/plan` descompone. El **Task Map** (resumido a las columnas de routing):

| TASK | Slug | Archivos | Depende de | Dificultad | Modelo recomendado |
|---|---|---|---|---|---|
| TASK-01 | `api-rate-limit` | `api/middleware.py` | — | 6/10 | Opus 4.8 |
| TASK-02 | `export-csv` | `exports/csv.py` | — | 3/10 | Sonnet 4.6 |
| TASK-03 | `export-pdf` | `exports/pdf.py` | — | 4/10 | Opus 4.8 |
| TASK-04 | `export-docs` | `README.md` | TASK-02, TASK-03 | 2/10 | Sonnet 4.6 |

Las TASK 01/02/03 tocan **archivos disjuntos** → `/plan` **propone 4 slugs** y, con
`AskUserQuestion`, **confirma** la partición (si el usuario declina, cae a 1 slug con
los 4 TASK cards como pasos). Confirmada, siembra **4 filas** en `INDEX.md` con el DAG:

```
| api-rate-limit | todo | —                     | 2026-06-14 | rate-limit middleware |
| export-csv     | todo | —                     | 2026-06-14 | CSV export |
| export-pdf     | todo | —                     | 2026-06-14 | PDF export |
| export-docs    | todo | export-csv,export-pdf | 2026-06-14 | document both exports |
```

`/dispatch` calcula la **oleada lista** = {`api-rate-limit`, `export-csv`, `export-pdf`}
(deps vacías) y lanza cada una en su worktree con el **modelo de su card**:
`api-rate-limit` y `export-pdf` → `model: "opus"`, `export-csv` → `model: "sonnet"`.
Tras el merge revisado de la oleada, recalcula: `export-docs` (sus dos deps ya `done`)
queda lista y corre en `sonnet`. Lo mismo, sin worktrees, lo haría
`/implement --delegate api-rate-limit` para un solo slug.

Una variante de **una sola frase** — *"arreglá el typo del footer"* — no dispara la
pregunta de partición: es **1 slug**, idéntico al flujo de siempre.

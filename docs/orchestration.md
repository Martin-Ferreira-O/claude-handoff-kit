# Orquestación de slugs en paralelo (Claude-only)

> **El kit funciona sin esto.** El core maneja **un slug a la vez** con
> `/handoff → /resume → /implement`. `/dispatch` es una capa **opt-in y Claude-only**
> para lanzar varios slugs a la vez — usa primitivos de Claude Code (`Agent` con
> `isolation: "worktree"`, `TaskCreate`) que no son parte del contrato portable.
> Un usuario de Codex lo ignora por completo.

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
3. **Fan-out aislado.** Cada slug listo se lanza como subagente background en su
   **propio git worktree** (`isolation: "worktree"`). El worktree es el
   habilitador: cada agente commitea en su rama sin pisar el working tree de los
   demás. El subagente corre `/implement <slug>` — sigue siendo un implementador
   del kit, con PLAN como spec y el gate de verificación adentro.
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

- **Costo / rate-limits.** N agentes en paralelo es caro. El default es **cap 2**
  e **implementadores en Sonnet** (el planning Opus ya quedó en el PLAN). Subí
  `--max` solo si lo necesitás.
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

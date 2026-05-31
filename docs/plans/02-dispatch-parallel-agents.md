# Plan 02 — `/dispatch`: orquestación de agentes en paralelo

**Prioridad:** P2 · **Depende de:** [05-structured-index.md](05-structured-index.md), [04-slug-aware-stop-hook.md](04-slug-aware-stop-hook.md) · **Pregunta del usuario:** Q2

## Context

El kit promete "parallel slugs" (README: "you want to parallelize several slugs")
pero **no implementa el cómo**. El usuario quiere que, cuando haya N tareas, se
lancen N agentes en paralelo (o los que se pueda, respetando dependencias).

## Primitivos disponibles en Claude Code

- `Agent` con `run_in_background: true` → fan-out asíncrono; notifica al terminar.
- `isolation: "worktree"` → **el habilitador**: cada agente trabaja en su propio
  git worktree aislado y commitea en su rama sin pisar el working tree de otros.
- `TaskCreate`/`TaskList`/`TaskUpdate` → tracking de las tareas lanzadas.

## Problema / pre-requisitos

1. INDEX es prosa libre → no se puede ordenar topológicamente. **→ requiere Plan 05.**
2. El Stop-hook actual valida solo "el PROGRESS más reciente" → se rompe con
   slugs paralelos. **→ requiere Plan 04.**
3. Slugs que tocan los mismos archivos → conflictos de merge. Disciplina de
   slug-sizing con **conjuntos de archivos disjuntos** se vuelve obligatoria.
4. Hace falta un **paso de integración/merge** de las N ramas.
5. Costo/rate-limits: N agentes Opus en paralelo es caro.

## Approach

Crear `.claude/commands/dispatch.md` (Claude-only; documentarlo como tal, igual
que los hooks — no es parte del core portable).

Pasos del comando:
1. **Leer el manifiesto** (INDEX estructurado del Plan 05): slugs con `status` y
   `depends-on`.
2. **Construir el DAG** y hacer orden topológico. Detectar ciclos → parar y
   reportar.
3. **Calcular la oleada lista:** slugs con `status: todo` cuyas dependencias
   están todas en `status: done`.
4. **Fan-out con cap de concurrencia** (`--max N`, default conservador 2–3):
   lanzar cada slug listo como subagente background con `isolation: "worktree"`,
   prompt = `/implement <slug>`. Registrar cada uno con `TaskCreate`.
5. **Esperar la oleada** (las notificaciones de completion re-invocan al
   orquestador). Marcar `status: done`/`blocked` en INDEX según resultado.
6. **Integración por oleada:** proponer el merge de las ramas terminadas (no
   automerge a `main` sin confirmación). Reportar conflictos.
7. **Avanzar a la siguiente oleada** hasta vaciar el DAG.

Política de concurrencia/merge: **decidir al diseñar** (preferencia del usuario).
Recomendación inicial: cap 2–3, Sonnet para implementadores, merge revisado por
el usuario.

## Files

- **Nuevo:** `.claude/commands/dispatch.md`
- **Nuevo/editar:** `docs/orchestration.md` — documentar el modelo, caveats de
  costo, y la regla de "slugs con archivos disjuntos".
- **Depende de** el esquema de INDEX del Plan 05 y el hook arreglado del Plan 04.

## Verification

1. Sembrar 3 slugs en INDEX: A (todo), B (todo, depends-on A), C (todo, sin deps).
2. Correr `/dispatch --max 2` → confirmar que lanza A y C en paralelo (worktrees
   distintos), **no** B.
3. Al terminar A, confirmar que la siguiente oleada lanza B.
4. Confirmar que cada slug commiteó en su propia rama y que el merge se propone
   (no se auto-aplica) con detección de conflictos.

## Guardrails

- Claude-only y opt-in: el core sigue manejando un slug a la vez sin `/dispatch`.
- Cap de concurrencia por defecto conservador (costo).
- Nunca auto-merge a `main` sin confirmación del usuario.
- Cada subagente sigue siendo un implementador del kit: respeta PLAN, PROGRESS,
  DECISIONS y el gate de verificación dentro de su worktree.

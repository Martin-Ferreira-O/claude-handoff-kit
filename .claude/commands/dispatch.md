---
description: Orquestá varios slugs en paralelo — orden topológico del INDEX, fan-out en worktrees aislados, merge revisado por oleada
argument-hint: [--max N]
allowed-tools: Read, Edit, Agent, TaskCreate, TaskList, TaskGet, TaskUpdate, AskUserQuestion, Bash(awk:*), Bash(grep:*), Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git worktree:*), Bash(git merge:*), Bash(git diff:*)
---

# /dispatch — orquestador de slugs en paralelo

Sos **el orquestador**. El kit promete "parallel slugs"; `/dispatch` es el cómo.
Leés el INDEX estructurado, construís el DAG de dependencias, y lanzás cada slug
**listo** como un subagente implementador en su **propio git worktree aislado**.
No implementás vos: cada subagente corre `/implement <slug>` y respeta PLAN,
PROGRESS, DECISIONS y el gate de verificación dentro de su worktree.

> **Claude-only y opt-in.** `/dispatch` usa primitivos de Claude Code (`Agent`
> con `isolation: "worktree"`, `TaskCreate`) que no son parte del core portable
> — igual que los hooks. El core sigue manejando **un slug a la vez** sin
> `/dispatch`; un usuario de Codex lo ignora por completo.

Concurrencia (opcional): `$ARGUMENTS` (ej. `--max 2`). Default conservador: **2**.

## Pre-requisitos

- **INDEX estructurado** (`docs/handoff/INDEX.md`, tabla con `status`/`depends-on`)
  — sin esto no hay orden topológico. Si el INDEX no parsea, parar y reportar.
- **Stop-hook slug-aware** — el gate de verificación resuelve el slug por rama, así
  que cada worktree valida solo lo suyo. Sin esto, slugs paralelos se pisan.
- **Slugs con conjuntos de archivos disjuntos.** Dos slugs que tocan el mismo
  archivo van a chocar en el merge. Es disciplina del autor del spec, no algo que
  `/dispatch` pueda forzar — ver `docs/orchestration.md`.

## Pasos

1. **Leer el manifiesto.** Parseá la tabla `## Handoffs` de `docs/handoff/INDEX.md`
   con `awk -F'|'`: para cada fila, `slug`, `status` (`todo`/`in-progress`/
   `blocked`/`done`) y `depends-on` (lista separada por comas, o `—`). Si la tabla
   no existe o no parsea, decilo y parar — `/dispatch` **requiere** el INDEX
   estructurado del esquema de `AGENTS.md`.

2. **Construir el DAG y ordenar topológicamente.** Cada `depends-on` es una arista
   `dep → slug`. Detectá **ciclos**: si hay, parar y reportar las aristas del ciclo
   — no lances nada con un DAG inválido. Verificá también que cada `depends-on`
   referencie un slug que existe en el INDEX; una dependencia colgante es un error
   de spec, reportala y parar.

3. **Calcular la oleada lista.** Slugs con `status: todo` cuyas dependencias están
   **todas** en `status: done`. Si la oleada lista está vacía pero quedan slugs
   `todo`, es porque sus deps están `blocked`/`in-progress` — reportá el estado y
   parar (no hay nada que lanzar todavía).

4. **Fan-out con cap de concurrencia + routing de modelo.** Lanzá hasta `--max N`
   (default 2) slugs de la oleada lista, cada uno como subagente **background** y
   **aislado**. Antes de lanzar cada uno, **ruteá el modelo por su Task card**:
   - **Leé el `Modelo recomendado` del Task card** del slug (vive en su `PLAN.md` —
     ver el schema en `AGENTS.md` y la tabla en `docs/routing.md`):
     `grep -A2 -e 'Modelo recomendado' -e 'Dificultad' docs/handoff/<slug>/PLAN.md`.
     Traducí al parámetro `model` del `Agent`: **"Opus 4.8" → `model: "opus"`**,
     **"Sonnet" → `model: "sonnet"`**. **Default `sonnet`** si el slug no tiene card
     legible (retrocompat con slugs viejos; tolerá tanto `Modelo recomendado:` como un
     `Modelo:` pelado).
   - `Agent` con `run_in_background: true`, `isolation: "worktree"` (cada slug en su
     propio worktree → commitea en su rama sin pisar el working tree de otro),
     `subagent_type: "general-purpose"` y el **`model` ruteado arriba** — ya **no** un
     `model: "sonnet"` fijo: el planning Opus quedó en el PLAN, pero un slug 8-10 se
     **implementa** con Opus según su card (ver `docs/routing.md`).
   - `prompt`: que ejecute `/implement <slug>` siguiendo el contrato del kit
     (PLAN como spec, PROGRESS/DECISIONS al día, gate de verificación, un commit
     por paso verificado, **no pushear**). Incluí el **`Effort recomendado`** del card
     como **guía en el prompt** ("razonamiento máximo / exhaustivo" para `max`;
     "directo, sin sobre-análisis" para `low`) — el effort no es un dial del harness,
     se transmite por prompt.
   - Registrá cada lanzamiento con `TaskCreate` para trackearlo.
   - Antes de lanzar, marcá la fila del slug en INDEX como `in-progress` (`Edit`,
     actualizá `updated`). Si hay más slugs listos que `N`, los sobrantes esperan a
     la próxima oleada.

5. **Esperar la oleada.** Las notificaciones de completion de los subagentes
   re-invocan al orquestador. A medida que terminan, leé su resultado (`TaskGet`/
   `TaskList`) y actualizá la fila del slug en INDEX: `done` si implementó y
   verificó todo, `blocked` si paró en una *Open question for the spec author* o
   falló el gate. Refrescá `updated` y `note`.

6. **Integración por oleada (merge revisado, nunca automático).** Cuando la oleada
   cierra, **proponé** el merge de las ramas terminadas a la rama de integración —
   no lo apliques solo. Por cada rama `done`:
   - Mostrá `git diff --stat` y detectá conflictos potenciales (`git merge
     --no-commit --no-ff` en seco, o revisando solapamiento de archivos entre las
     ramas de la oleada).
   - Pedí confirmación al usuario con `AskUserQuestion` antes de cualquier merge.
   - **Nunca auto-merge a `main`** sin confirmación explícita. Reportá conflictos
     con los archivos en cuestión; no los resuelvas adivinando.
   - Limpiá los worktrees terminados (`git worktree remove`) una vez integrados.

7. **Avanzar a la siguiente oleada.** Recalculá la oleada lista (paso 3) con el
   INDEX actualizado y repetí desde el paso 4 hasta vaciar el DAG (todos `done` o
   `blocked`). Reportá el estado final: qué slugs quedaron `done`, cuáles
   `blocked` y por qué, y qué merges quedan pendientes de confirmación.

## Guardrails

- **Claude-only y opt-in.** El core maneja un slug a la vez sin `/dispatch`. No
  metas dependencia de orquestación en los comandos portables.
- **Cap conservador por costo.** N agentes en paralelo es caro; default 2, con el
  **modelo ruteado por el Task card** de cada slug (default Sonnet si no hay card —
  ver `docs/routing.md`). Subí `--max` solo si el usuario lo pide.
- **Nunca auto-merge a `main`.** El merge entre oleadas siempre pasa por
  confirmación del usuario.
- **Cada subagente es un implementador del kit.** Respeta PLAN/PROGRESS/DECISIONS
  y el gate de verificación dentro de su worktree; no rediseña el spec. Ante un
  paso ambiguo/imposible, para y lo registra en su DECISIONS — `/dispatch` no
  improvisa por él.
- **Archivos disjuntos es disciplina del spec.** `/dispatch` no puede garantizar
  ausencia de conflictos; si dos slugs comparten archivos, el merge los va a
  exponer. Acotá los slugs al diseñar (ver `docs/orchestration.md`).

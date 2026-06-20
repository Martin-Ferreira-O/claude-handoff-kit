> Handoff doc for task `atomic-tasks-and-routing`. Author: Claude Opus 4.8. Updated: 2026-06-14 16:35.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `1ec8eb7` on branch `atomic-tasks-and-routing`; source plan: `~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# PLAN — atomic-tasks-and-routing

## Goal
Agregar al kit: (1) **tareas atómicas con metadata** (Task card: dificultad/modelo/effort)
y decomposición en **slugs paralelos** desde `/plan`; (2) **routing dinámico de modelo** por
slug en `/dispatch`; (3) modo opt-in **`/implement --delegate`** que corre un subagente fresco
desde la sesión actual. Todo incremental y retrocompatible: una tarea chica sigue produciendo
**un** slug idéntico al flujo de hoy.

## Non-goals / scope
- **No** subagente-por-paso dentro de un slug (fragmenta una unidad ya dimensionada a una
  ventana → gasta más tokens; ver Source plan §2).
- **No** cambiar el esquema de la tabla de `INDEX.md` (retrocompat; el modelo/effort vive en el Task card).
- **No** cambiar el **flujo** por defecto de `/implement` (in-session, secuencial, commit por paso); `--delegate` es opt-in. (El gate de review **sí** mejora: el modelo del reviewer pasa a rutearse por dificultad — ver Clarifications.)
- **No** tocar `/resume`, `/clarify`, `/archive`, `/handoff-init` salvo referencias.
- **No** convertir `effort` en un dial del harness (no existe); se transmite por prompt.

## Source plan
`~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md` — diseño completo (diagnóstico,
comparación de flujos, rúbrica, routing, riesgos). Este PLAN es su proyección ejecutable. La
**rúbrica de dificultad** (§7) y la **tabla de routing** (§8) del source plan son normativas.

## Clarifications (resolved)
*(De `/clarify`, 2026-06-14 16:35 — foldeadas al spec.)*
- **Decomposición → proponer y confirmar.** Cuando `/plan` detecta partición en slugs
  paralelos, arma el Task Map, **propone** la partición (N slugs + DAG) y **confirma con
  `AskUserQuestion`** antes de materializar N paquetes. Si el usuario declina, cae a **1 slug**.
  (Afecta TASK-02.)
- **Reviewer del gate → ruteado por dificultad.** El revisor adversarial del gate de
  `/implement` usa la **misma tabla de routing** que el implementador: un slug 8-10 lo revisa
  Opus 4.8 max; uno 1-3, Sonnet. Lee la dificultad del Task card del slug. (Afecta TASK-04;
  reemplaza la recomendación previa de "reviewer Sonnet fijo".)
- **Ubicación de la rúbrica → `docs/routing.md` + resumen.** La rúbrica completa (5 ejes) y la
  tabla viven en `docs/routing.md` (nuevo); `AGENTS.md` lleva el schema del Task card + un
  resumen corto con link. (Confirma TASK-01.)

## Ordered steps
Cada paso es un slug atómico (Task card) **committeable por sí solo**. Se materializan como
**pasos de este único slug** porque están acoplados por el contrato compartido y entran en una
ventana (regla de partición del propio diseño). El formato del card dogfoodea la feature.

### TASK-01 — Contrato de tarea atómica + rúbrica de routing
- **Objetivo:** Documentar en `AGENTS.md` el formato Task card, y en `docs/routing.md` (nuevo) la rúbrica de dificultad 1-10 (5 ejes) y la tabla de routing, como contrato compartido que `/plan` y `/dispatch` citan.
- **Archivos:** `AGENTS.md`, `docs/routing.md` (nuevo)
- **Depende de:** —
- **Dificultad:** 4/10 · **Modelo:** Opus 4.8 · **Effort:** medium
- **Motivo:** Es el contrato del que cuelga todo; bajo blast radius pero requiere precisión.
- **Criterios de éxito:**
  - [ ] `AGENTS.md` describe el Task card (campos del §6 del source plan) sin tocar el esquema del INDEX.
  - [ ] `docs/routing.md` contiene la rúbrica de 5 ejes y la tabla (1-3 Sonnet / 4-7 Opus medium / 8-10 Opus max).
  - [ ] Ambos referenciables desde `/plan` y `/dispatch`.

### TASK-02 — `/plan` emite tareas atómicas + decompone en slugs
- **Objetivo:** Agregar a `plan.md` el sub-paso de **Task Map**, la **regla de partición** (multi-unidad disjunta → N slugs + N filas INDEX con DAG; acoplado/una ventana → 1 slug), el **checklist de atomicidad** en la auto-crítica, y el scoring/routing por TASK. Cuando la partición da varios slugs, **proponerla y confirmarla con `AskUserQuestion`** antes de materializar (declinar → 1 slug).
- **Archivos:** `.claude/commands/plan.md`
- **Depende de:** TASK-01
- **Dificultad:** 7/10 · **Modelo:** Opus 4.8 · **Effort:** medium
- **Motivo:** Flujo central; la retrocompat (tarea chica = 1 slug) exige cuidado.
- **Criterios de éxito:**
  - [ ] `/plan` de tarea multi-unidad **propone la partición y la confirma** (`AskUserQuestion`) antes de escribir N paquetes; declinar produce 1 slug.
  - [ ] `/plan` de tarea multi-unidad (confirmada) crea N slugs + N filas INDEX con `depends-on`.
  - [ ] `/plan` de tarea chica crea **1** slug (comportamiento actual).
  - [ ] Cada `PLAN.md` materializado lleva su Task card con dificultad/modelo/effort.
  - [ ] La auto-crítica corre el checklist de atomicidad.

### TASK-03 — Routing dinámico en `/dispatch`
- **Objetivo:** Que `/dispatch` lea el "Modelo recomendado" del Task card de cada slug listo y rutee el parámetro `model` del `Agent` (`sonnet`/`opus`); effort como guía en el prompt. Reemplazar `model: "sonnet"` hardcodeado por el routing, con **default Sonnet** si no hay card.
- **Archivos:** `.claude/commands/dispatch.md`
- **Depende de:** TASK-01
- **Dificultad:** 5/10 · **Modelo:** Opus 4.8 · **Effort:** medium
- **Motivo:** Cambio acotado a un comando, pero toca la mecánica de fan-out.
- **Criterios de éxito:**
  - [ ] Un slug con "Opus 4.8" se lanza con `model: opus`; uno con "Sonnet" con `model: sonnet`.
  - [ ] Sin Task card legible, default `sonnet` (retrocompat con slugs viejos).
  - [ ] El effort recomendado se transmite en el prompt del subagente.

### TASK-04 — `/implement --delegate` (1 subagente fresco, opt-in)
- **Objetivo:** Modo opt-in que lanza **un** subagente fresco para un slug desde la sesión actual (sesión principal = orquestador/reviewer). Sumar `Agent` a `allowed-tools` (gated, Claude-only). El flujo por defecto **no** cambia. **Además**, rutear el modelo del **reviewer del gate** por la dificultad del slug (misma tabla de routing), reemplazando el reviewer genérico.
- **Archivos:** `.claude/commands/implement.md`
- **Depende de:** TASK-01
- **Dificultad:** 6/10 · **Modelo:** Opus 4.8 · **Effort:** medium
- **Motivo:** Amplía superficie (`Agent`) y toca el comando más sensible; el opt-in lo contiene.
- **Criterios de éxito:**
  - [ ] Modo default de `/implement` intacto (in-session, secuencial).
  - [ ] `/implement --delegate <slug>` lanza 1 subagente con el modelo ruteado por su card.
  - [ ] Post-delegación, la sesión principal corre el gate de review y lo registra como `review (fresh)`.
  - [ ] El **reviewer del gate** se rutea por la dificultad del slug (misma tabla): dif 8-10 → Opus max, dif 1-3 → Sonnet.
  - [ ] `allowed-tools` incluye `Agent`; documentado como opt-in/Claude-only.

### TASK-05 — Documentación y ejemplos
- **Objetivo:** Actualizar `CLAUDE.md` (ciclo), `docs/orchestration.md` (routing + delegate), `README.md`, y un ejemplo de Task Map de punta a punta.
- **Archivos:** `CLAUDE.md`, `docs/orchestration.md`, `README.md`
- **Depende de:** TASK-02, TASK-03, TASK-04
- **Dificultad:** 3/10 · **Modelo:** Sonnet 4.6 · **Effort:** medium
- **Motivo:** Mecánico; documenta comportamiento ya implementado; bajo riesgo.
- **Criterios de éxito:**
  - [ ] Las docs reflejan los 3 modos de ejecución (manual / `--delegate` / `/dispatch`) y el routing.
  - [ ] Ejemplo reproducible de un Task Map con decomposición en slugs.

## Verification
Repo de markdown sin tests — verificación estructural. Tras implementar cada paso, corré los
comandos del paso; al cierre, todo el bloque:

```sh
# 1. /plan describe Task Map + decomposición.
grep -n -e 'Task Map' -e 'Task card' .claude/commands/plan.md            # → ≥1 match

# 2. /dispatch rutea por card; ya no asigna sonnet fijo.
grep -n -e 'Modelo recomendado' -e 'rute' .claude/commands/dispatch.md   # → ≥1 match

# 3. /implement tiene --delegate y Agent en allowed-tools.
grep -n -- '--delegate' .claude/commands/implement.md                    # → ≥1 match
grep -n 'allowed-tools:.*Agent' .claude/commands/implement.md            # → 1 match

# 4. Contrato del card + rúbrica + routing en docs.
grep -n -e 'Dificultad' -e 'Modelo recomendado' AGENTS.md docs/routing.md  # → matches en ambos

# 5. Esquema del INDEX intacto.
grep -n '| slug | status | depends-on | updated | note |' docs/handoff/INDEX.md  # → 1 match
```
**Pass signal:** los 5 greps devuelven lo esperado (matches donde se indica, 1 sola línea de schema en INDEX).

**End-to-end (manual):** en un repo de prueba, `/plan <tarea multi-unidad>` crea **N** carpetas
`docs/handoff/<slug>/` + N filas INDEX con `depends-on`, cada `PLAN.md` con su Task card.
`/dispatch` lanza cada slug con el **modelo de su card** (verificable en el log del `Agent`).
`/implement --delegate <slug>` corre **un** subagente fresco desde la misma sesión y vuelve con
review `(fresh)`. Una tarea chica de una frase sigue produciendo **un** slug idéntico al flujo
actual — esa no-regresión es parte del pass.

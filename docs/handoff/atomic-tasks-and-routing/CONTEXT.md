> Handoff doc for task `atomic-tasks-and-routing`. Author: Claude Opus 4.8. Updated: 2026-06-14 16:02.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `1ec8eb7` on branch `atomic-tasks-and-routing`; source plan: `~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# CONTEXT — atomic-tasks-and-routing

## Task
Sube un escalón el kit de handoffs: que las fases sean **tareas atómicas** con
dificultad/modelo/effort, y que cada slug pueda ejecutarse en un **subagente fresco**
orquestado desde la misma sesión. Concretamente: (1) `/plan` emite un **Task Map** con
metadata de routing y decompone tareas multi-unidad en **slugs paralelos**; (2) `/dispatch`
**rutea el modelo** del implementador por slug en vez de hardcodear Sonnet; (3) nuevo modo
opt-in `/implement --delegate` que lanza **un** subagente fresco desde la sesión actual
(mata la fricción de "abrir otra terminal"). Objetivo: ahorrar contexto/tokens y reducir
fricción manual **sin romper** el flujo single-slug actual.

## Project area
Este repo **es** el kit. No hay código de aplicación. Se tocan:
- `.claude/commands/` — definiciones de los comandos (`plan.md`, `dispatch.md`, `implement.md`).
- `AGENTS.md` — el contrato portable (donde vive el schema del Task card + rúbrica + routing).
- `docs/` y `README.md` — documentación del ciclo y la orquestación.

## Read first
Abrí estos archivos y **confirmá que todavía coinciden con este spec antes de confiar en
cualquier resumen** — re-derivar del código gana a recordar de un handoff:
- `.claude/commands/plan.md` — los 8 pasos actuales; acá se inserta el Task Map + decomposición.
- `.claude/commands/dispatch.md:53-56` — el `model: "sonnet"` hardcodeado a reemplazar por routing.
- `.claude/commands/implement.md:1-5` — `allowed-tools` (sumar `Agent`, gated) y `:106-145` — el gate de review fresco donde engancha `--delegate`.
- `AGENTS.md` — el contrato portable; recibe el schema del Task card y la convención de routing.
- `docs/orchestration.md` — el modelo de `/dispatch` a actualizar con routing + delegate.
- `docs/handoff/INDEX.md:9` — el esquema de 5 columnas que **no** se debe cambiar (retrocompat).

## Setup / run / test
Repo de markdown, **sin test suite**. Verificación estructural por comando (ver PLAN §Verification):
```sh
grep -n -e 'Task Map' -e 'Task card' .claude/commands/plan.md
grep -n -e 'Modelo recomendado' -e 'rute' .claude/commands/dispatch.md
grep -n -- '--delegate' .claude/commands/implement.md
grep -n 'allowed-tools:.*Agent' .claude/commands/implement.md
grep -n '| slug | status | depends-on | updated | note |' docs/handoff/INDEX.md
```

## Conventions that matter here
- Cada comando lleva frontmatter: `description`, `argument-hint`, `allowed-tools`. `allowed-tools` mínimo necesario.
- **`Agent` es Claude-only y opt-in** (como `/dispatch` y los hooks). El core portable maneja un slug a la vez sin él; un usuario de Codex lo ignora.
- Slugs en kebab-case; **un handoff por slug** — se actualiza, no se duplica.
- Los 4 archivos del handoff abren con el banner de cabecera.
- **Esquema del INDEX intacto** (tabla de 5 columnas) — el modelo/effort vive en el Task card del PLAN, no en columnas nuevas.
- Prosa de los comandos en **español** (seguí el estilo existente).
- **Solo Opus reescribe `PLAN.md`.** El implementador propone cambios vía `DECISIONS.md` (*Open questions for the spec author*), nunca edita el plan en silencio.

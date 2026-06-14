> Handoff doc for task `atomic-tasks-and-routing`. Author: Claude Opus 4.8. Updated: 2026-06-14 16:35.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `1ec8eb7` on branch `atomic-tasks-and-routing`; source plan: `~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# PROGRESS — atomic-tasks-and-routing

## Checklist
- [x] TASK-01. Contrato de tarea atómica + rúbrica de routing (`AGENTS.md`, `docs/routing.md`)
- [ ] TASK-02. `/plan` emite tareas atómicas + decompone en slugs (`plan.md`)
- [ ] TASK-03. Routing dinámico en `/dispatch` (`dispatch.md`)
- [ ] TASK-04. `/implement --delegate` opt-in + `Agent` en allowed-tools (`implement.md`)
- [ ] TASK-05. Documentación y ejemplos (`CLAUDE.md`, `docs/orchestration.md`, `README.md`)

## Work log
- 2026-06-14 16:39 — Claude Opus 4.8 (implementer) — TASK-01: creado `docs/routing.md`
  (rúbrica de 5 ejes + tabla de routing 1-3/4-7/8-10) y agregada la sección **Atomic tasks
  & model routing (Task card)** a `AGENTS.md` (schema del card + resumen de routing con link).
  Esquema del INDEX intacto. Verify: `grep -e Dificultad -e 'Modelo recomendado' AGENTS.md
  docs/routing.md` → matches en ambos. ✔
- 2026-06-14 16:35 — Claude Opus 4.8 — `/clarify`: resueltas 3 preguntas (decomposición =
  proponer+confirmar con `AskUserQuestion`; reviewer del gate = ruteado por dificultad; rúbrica en
  `docs/routing.md` + resumen). Foldeadas a PLAN §Clarifications y a los criterios de TASK-02/04;
  cerradas las open questions de DECISIONS. Sin código.
- 2026-06-14 16:02 — Claude Opus 4.8 — Paquete materializado por `/plan` desde el source plan
  aprobado en plan mode. Rama `atomic-tasks-and-routing` creada desde `1ec8eb7` (sobre
  `plan-absorbs-handoff`, aún no mergeado a `main`, para construir sobre los archivos de
  comando actuales). 5 pasos sembrados en `todo`. **Sin código aún** — listo para `/implement`
  o `/implement --delegate` (una vez que TASK-04 exista) o ejecución manual.

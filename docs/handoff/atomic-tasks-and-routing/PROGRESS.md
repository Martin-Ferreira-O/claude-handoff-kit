> Handoff doc for task `atomic-tasks-and-routing`. Author: Claude Opus 4.8. Updated: 2026-06-14 16:35.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by Claude Opus 4.8 against commit `1ec8eb7` on branch `atomic-tasks-and-routing`; source plan: `~/.claude/plans/act-a-como-arquitecto-senior-harmonic-wall.md`. If HEAD has moved far past this, reconcile before trusting the spec.

# PROGRESS — atomic-tasks-and-routing

## Checklist
- [x] TASK-01. Contrato de tarea atómica + rúbrica de routing (`AGENTS.md`, `docs/routing.md`)
- [x] TASK-02. `/plan` emite tareas atómicas + decompone en slugs (`plan.md`)
- [x] TASK-03. Routing dinámico en `/dispatch` (`dispatch.md`)
- [x] TASK-04. `/implement --delegate` opt-in + `Agent` en allowed-tools (`implement.md`)
- [ ] TASK-05. Documentación y ejemplos (`CLAUDE.md`, `docs/orchestration.md`, `README.md`)

## Work log
- 2026-06-14 16:46 — Claude Opus 4.8 (implementer) — TASK-04: `implement.md` — `Agent`
  sumado a `allowed-tools` (gated, Claude-only); `argument-hint` → `[--delegate] [task-slug]`.
  Nueva sección **Execution mode** documentando `--delegate` (1 subagente fresco con modelo
  ruteado por card, sin worktree, sesión principal = orquestador/reviewer → `review (fresh)`).
  Gate de review (paso 9): el **reviewer se rutea por dificultad** (8-10 Opus max / 4-7 Opus
  medium / 1-3 Sonnet), ortogonal a los reviewers Django por tipo de archivo. Modo default
  intacto. Verify: `grep -- '--delegate'` y `grep 'allowed-tools:.*Agent'` → matches. ✔
- 2026-06-14 16:44 — Claude Opus 4.8 (implementer) — TASK-03: `dispatch.md` paso 4 ahora
  **rutea el modelo por Task card** (lee `Modelo recomendado` → `model: opus`/`sonnet`,
  default `sonnet` sin card, tolera `Modelo:` pelado), en vez del `model: "sonnet"` fijo;
  `Effort recomendado` se transmite como guía en el prompt. Guardrail "implementadores en
  Sonnet" corregido a "modelo ruteado (default Sonnet)". Verify: `grep -e 'Modelo
  recomendado' -e 'rute' dispatch.md` → matches; `model: "opus"` presente. ✔
- 2026-06-14 16:42 — Claude Opus 4.8 (implementer) — TASK-02: reestructurado `plan.md` de
  8 a 10 pasos. Nuevos pasos 2 (**Emitir el Task Map** con scoring 1-10 + routing) y 3
  (**Decidir la partición**: regla disjunta→N slugs / acoplado→1 slug, **proponer+confirmar
  con `AskUserQuestion`**, declinar→1 slug). Checklist de atomicidad agregado a la
  auto-crítica (paso 7). Task card sumado a la plantilla de `PLAN.md`. Verify: greps de
  `Task Map`/`Task card`/`AskUserQuestion`/`checklist de atomicidad`/`docs/routing.md` → matches. ✔
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

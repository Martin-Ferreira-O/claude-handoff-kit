# Plan 11 — Crear la rama de tarea al arranque, no en `/implement`

**Prioridad:** P2 · **Depende de:** [01-plan-command.md](01-plan-command.md) (parcial) · **Hallazgo:** #11

## Context

Hoy la rama de tarea se crea recién en `/implement` (paso 6: "branch si estás en
`main`/`master`"). El planning y `/clarify` ocurren en la rama actual — que
normalmente es `main`.

## Problema

- Planning/clarify modifican el draft mientras estás en `main` (no toca código,
  pero la disciplina de "no trabajar en `main`" arranca tarde).
- Para **slugs paralelos** (Plan 02), querés una rama por slug **desde el
  arranque**: el Stop-hook slug-aware (Plan 04) resuelve el slug por la rama, y
  los worktrees de `/dispatch` necesitan ramas distintas por slug. Si la rama
  recién nace en `/implement`, la orquestación no tiene de dónde agarrarse.

## Approach

Mover la creación de la rama al **inicio** del ciclo:

1. Si se adopta el Plan 01, `/plan` crea la rama (`<slug>` en kebab-case) desde
   `main`/`master`. Esa es la opción preferida.
2. Si no, agregar la creación de rama a `/handoff` (primer comando que ya escribe
   en disco), o mantenerla en `/implement` pero documentar la convención
   "una rama por slug, creada lo antes posible".
3. Dejar el branch-step de `/implement` como **red de seguridad idempotente**: si
   ya estás en la rama del slug, no hace nada; si estás en `main`, la crea.
4. Documentar la convención "una rama por slug" en `CLAUDE.md`/`AGENTS.md` —
   es pre-requisito de los Planes 02 y 04.

## Files

- **Editar:** `.claude/commands/plan.md` (si existe, Plan 01) o `handoff.md`.
- **Editar:** `.claude/commands/implement.md` (volver el branch-step idempotente).
- **Editar:** `CLAUDE.md`, `AGENTS.md` (convención "una rama por slug").

## Verification

1. Tras `/plan <slug>` (o `/handoff <slug>`), confirmar que la rama actual es
   `<slug>`, no `main`.
2. Correr `/implement <slug>` ya estando en la rama → confirmar que **no** crea
   otra rama ni falla (idempotente).
3. Confirmar que el Stop-hook (Plan 04) resuelve el slug desde esta rama.

## Guardrails

- No forzar un nombre de rama que choque con convenciones del proyecto host;
  permitir prefijos (p.ej. `feat/<slug>`) y que el slug se derive del sufijo.
- Mantener idempotencia para no romper sesiones que ya crearon la rama.

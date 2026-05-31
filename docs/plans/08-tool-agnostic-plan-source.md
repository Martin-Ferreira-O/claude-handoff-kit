# Plan 08 — Desacoplar el source-plan de `~/.claude/plans/`

**Prioridad:** P3 · **Depende de:** — · **Hallazgo:** #8

## Context

El kit se anuncia tool-agnostic ("driven by Codex *and* Claude *and* any future
agent"), y el **core** lo es. Pero la **entrada** no: `/clarify` y `/handoff`
leen el draft desde `~/.claude/plans/<...>.md`, que es un artefacto de Claude Code
(lo escribe el plan mode nativo). Codex no tiene esa carpeta.

## Problema

La promesa de portabilidad se cumple en el core pero se rompe en el arranque: un
implementador/planificador no-Claude no puede producir el "source plan" en la ruta
que `/clarify` y `/handoff` esperan.

## Approach

Tratar `~/.claude/plans/` como **una** fuente posible, no la única:

1. En `/clarify` y `/handoff`, generalizar el paso "leer el plan activo": aceptar
   (a) `~/.claude/plans/<...>.md` (Claude), (b) un path pasado como argumento, o
   (c) un draft dentro del repo (p.ej. `docs/plans/<slug>.md` — que ya existe como
   carpeta tras este backlog). El comando usa el primero que encuentre y lo
   reporta.
2. Documentar en `AGENTS.md` que el "source plan" es **cualquier draft de plan
   acordado**, y que su path se registra en el banner de provenance (ya lo hace).
3. No romper el caso Claude actual (que siga funcionando sin argumento).

## Files

- **Editar:** `.claude/commands/clarify.md`, `.claude/commands/handoff.md`
  (paso de localización del source plan).
- **Editar:** `AGENTS.md` (definición de "source plan").

## Verification

1. Con un plan en `~/.claude/plans/` → `/handoff` lo encuentra (comportamiento actual).
2. Con `/handoff <slug> docs/plans/<slug>.md` → usa ese path.
3. Confirmar que el banner de provenance registra el path real usado en ambos casos.

## Guardrails

- No degradar la experiencia Claude actual.
- Mantener el banner de provenance como fuente de verdad del origen del spec.

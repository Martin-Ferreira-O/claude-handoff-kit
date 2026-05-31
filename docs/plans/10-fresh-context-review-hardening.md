# Plan 10 — Endurecer la garantía de "fresh context" del review gate

**Prioridad:** P3 · **Depende de:** — · **Hallazgo:** #10

## Context

El paso 9 de `/implement` corre un "fresh-context review against PLAN.md" antes de
reportar done. El texto dice "en contexto fresco que ve solo el diff y PLAN.md",
y ofrece "el skill `/code-review` o un subagente".

## Problema

`/code-review` puede correr **en la misma sesión**, que ya tiene todo el contexto
de la implementación cargado. Eso no es "fresh context" de verdad: el revisor
hereda los sesgos y supuestos del implementador, debilitando el valor adversarial
del gate. La garantía es más blanda que lo que sugiere la redacción.

## Approach

Hacer explícito que **el gate debe correr en contexto realmente fresco**:

1. En `/implement` paso 9, preferir un **subagente dedicado** (contexto limpio)
   al que se le pasa **solo el diff + PLAN.md**, no la sesión completa. En Claude:
   un subagente de review; en Codex/otros: una sesión limpia con solo esos inputs.
2. Aclarar que correr `/code-review` dentro de la misma sesión es el **fallback
   de menor garantía**, aceptable solo si no hay subagente disponible — y marcarlo
   como tal en la línea de PROGRESS (`review (in-session)` vs `review (fresh)`).
3. Mantener el prompt shape actual ("report gaps, not style preferences") que ya
   evita el over-engineering.

## Files

- **Editar:** `.claude/commands/implement.md` (paso 9, preferencia de mecanismo).
- **Editar:** `CLAUDE.md` (descripción del gate de review en el ciclo).

## Verification

1. Correr `/implement` hasta el gate → confirmar que se invoca un subagente con
   contexto limpio (no la sesión actual) cuando está disponible.
2. Confirmar que la línea de PROGRESS distingue `fresh` vs `in-session`.
3. Confirmar que el prompt sigue pidiendo "gaps vs PLAN, no estilo".

## Guardrails

- No volver el gate Claude-specific en el core: la regla es "contexto fresco",
  el mecanismo es por-herramienta (subagente Claude, sesión limpia Codex, etc.).
- Mantener el framing anti-over-engineering del prompt.

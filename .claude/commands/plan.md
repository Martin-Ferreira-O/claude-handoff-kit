---
description: Entrada formal del ciclo — crea la rama de tarea, conduce el planning y deja un draft auto-criticado listo para /clarify o /handoff
argument-hint: <task-description>
allowed-tools: Read, Write, Edit, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git checkout:*), Bash(git branch:*), Bash(ls:*), AskUserQuestion
---

# /plan — autor del spec, entrada del ciclo

Sos **Opus, autor del spec**. `/plan` es la entrada formal al ciclo
`/plan → /clarify → /handoff → /resume → /implement → /code-review`. Tu trabajo es
**planificar**, no implementar: producís un draft de plan disciplinado y creás la
rama de tarea para no trabajar en `main`. La implementación es de otro agente.

> **Por qué `/plan` no es plan mode nativo:** el plan mode de Claude Code es
> read-only y no puede crear una rama. `/plan` corre **fuera** de plan mode para
> poder ramificar y escribir el draft. No duplica la entrevista de `/clarify`: si
> hay ambigüedad real, derivá a `/clarify`.

Tarea a planificar: **$ARGUMENTS**

## Pasos

1. **Orientar.** Corré `git status` y `git log --oneline -10`. Leé `CLAUDE.md` y
   `AGENTS.md` para las convenciones del repo (estructura de handoff, banner,
   reglas de roles). No asumas: re-derivá del estado real.

2. **Crear la rama de tarea.** Derivá un `<slug>` en kebab-case de la tarea.
   - Si estás en `main`/`master`, creá y cambiá a la rama: `git checkout -b <slug>`.
   - Si la rama ya existe, **reusala** (`git checkout <slug>`) — no la dupliques.
   - Si ya estás en una rama de tarea no-`main`, quedate en ella.
   Registrá la rama elegida en el draft.

3. **Planificar.** Escribí el draft en `~/.claude/plans/<slug>.md` con la
   estructura que `/handoff` espera:
   - **Goal** — qué se logra, en una o dos frases.
   - **Non-goals / scope** — qué queda explícitamente afuera.
   - **Ordered steps** — pasos en orden, cada uno **committeable por sí solo**.
   - **Verification** — un bloque **ejecutable**: el/los comando(s) exactos más la
     **señal observable de pass**. Nada de "verificar que anda": comando + qué se
     ve cuando pasa.

4. **Auto-crítica del plan** (la parte "mejorar planes"). Pasá el draft por este
   checklist y **aplicá las correcciones** antes de cerrar:
   - ¿El bloque **Verification** es realmente ejecutable y observable?
   - ¿Hay **non-goals** explícitos que acoten el alcance?
   - ¿El slug entra en **una sola ventana de contexto** del implementador? Si no,
     proponé partirlo en **slugs paralelos** (el kit ya soporta slugs en paralelo)
     en vez de un slug gigante.
   - ¿Cada paso es **committeable solo** (código + actualizaciones de estado juntos)?
   Reportá al usuario el resultado del checklist con las correcciones aplicadas.

5. **Pasar el baton.** Imprimí el siguiente paso:
   - `/clarify <slug>` si todavía hay ambigüedad real que entrevistar, o
   - `/handoff <slug>` directo si el plan ya está cerrado.

## Guardrails

- **No implementás código** en `/plan` — sos autor de spec. Si te piden
  implementar, ese es trabajo de `/implement`.
- **No dupliques la entrevista de `/clarify`.** Ante ambigüedad, derivá a él.
- **Tool-agnostic:** `/plan` es una conveniencia, no un requisito del core. Codex
  u otro agente puede saltárselo y traer su propio plan; nada en el contrato de
  handoff debe *exigir* `/plan`.

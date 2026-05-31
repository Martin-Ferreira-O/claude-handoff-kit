# Plan 01 — Comando `/plan` (entrada formal del ciclo)

**Prioridad:** P1 · **Depende de:** — · **Pregunta del usuario:** Q1

## Context

El ciclo documentado arranca con "plan (Opus)" pero **no existe un comando
`/plan`**. Todo aguas abajo (`/clarify`, `/handoff`) depende de que exista un
draft de plan en `~/.claude/plans/<...>.md`, pero nada lo crea con disciplina, y
nada crea la rama de tarea hasta `/implement` (que recién ahí saca de `main`).
El usuario quiere un `/plan` que: planifique, cree una rama para no trabajar en
`main`, y mejore (auto-critique) los planes.

## Problema

- Entrada al ciclo informal → planes inconsistentes en calidad.
- La rama se crea tarde (en `/implement`); planning/clarify ocurren en `main`.
- No hay una pasada de calidad sobre el plan antes del handoff.

## Sutileza técnica (no ignorar)

El **plan mode nativo de Claude Code es read-only**: no se puede crear una rama
mientras está activo. Por eso `/plan` **no puede ser literalmente plan mode si
también crea la rama**. Dos diseños válidos:

- **(A) recomendado:** `/plan` corre fuera de plan mode → crea la rama, conduce
  el planning y escribe el draft. No re-implementa la entrevista de `/clarify`;
  delega la entrevista profunda a `/clarify`.
- **(B):** el planning queda en plan mode read-only y la rama se mueve al primer
  comando mutante (ver [11-early-branch-creation.md](11-early-branch-creation.md)).

Diseñar para **complementar** el plan mode nativo y `/clarify`, no duplicarlos.

## Approach (diseño A)

Crear `.claude/commands/plan.md` con frontmatter
(`description`, `argument-hint: <task-description>`,
`allowed-tools: Read, Write, Edit, Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git checkout:*), Bash(git branch:*), Bash(ls:*), AskUserQuestion`).

Pasos del comando:
1. **Orientar:** `git status` / `git log --oneline -10`; leer CLAUDE.md/AGENTS.md
   para convenciones.
2. **Crear rama de tarea** desde `main`/`master` si estás ahí:
   `<slug>` en kebab-case derivado de la tarea (no crear si ya existe; reusar).
   Registrar la rama elegida en el draft.
3. **Planificar:** producir el draft en `~/.claude/plans/<slug>.md` con la
   estructura que `/handoff` espera: Goal, Non-goals/scope, Ordered steps,
   y un **bloque Verification ejecutable** (comando + señal de pass).
4. **Auto-crítica del plan** (la parte "mejorar planes"): correr un checklist —
   ¿el bloque Verification es realmente ejecutable y observable?, ¿hay non-goals
   explícitos?, ¿el slug entra en una sola ventana de contexto del implementador
   (si no, sugerir partirlo en slugs paralelos)?, ¿cada paso es committeable solo?
   Aplicar las correcciones al draft.
5. **Handoff del baton:** imprimir el siguiente paso (`/clarify <slug>` si hay
   ambigüedad real, o `/handoff <slug>` directo).

## Files

- **Nuevo:** `.claude/commands/plan.md`
- **Editar:** `CLAUDE.md` y `README.md` — agregar `/plan` al frente del ciclo:
  `/plan → /clarify → /handoff → /resume → /implement → /code-review`.
- **Coordinar con:** `.claude/commands/implement.md` (si se adopta el diseño A,
  el branch-step de `/implement` puede quedar como red de seguridad idempotente).

## Verification

1. Correr `/plan agregar-X` en una sesión sobre `main` → confirmar que (a) crea y
   cambia a una rama de tarea, (b) escribe `~/.claude/plans/<slug>.md` con bloque
   Verification, (c) reporta la auto-crítica con al menos el checklist aplicado.
2. Confirmar que `git branch --show-current` ya no es `main`.
3. Confirmar que `/handoff <slug>` consume ese draft sin fricción.

## Guardrails

- No implementar código en `/plan` (es autor de spec).
- No duplicar la entrevista de `/clarify`; si hay ambigüedad, derivar a él.
- Mantener tool-agnostic: documentar que Codex puede saltarse `/plan` y traer su
  propio plan; nada en el core debe *exigir* `/plan`.

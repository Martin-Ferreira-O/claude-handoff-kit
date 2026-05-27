# Repository Guidelines

## Handoff & Shared State
Active task handoffs live in `docs/handoff/<slug>/`, each containing `CONTEXT.md`, `PLAN.md`, `PROGRESS.md`, and `DECISIONS.md`. `docs/handoff/INDEX.md` registers them.

- **Before starting work on a task, read its handoff folder** (CONTEXT → PLAN → PROGRESS → DECISIONS). `PLAN.md` is the spec authored by the planning agent — implement against it and do not silently diverge.
- **Update `PROGRESS.md` after every meaningful change**: check off the steps you completed (`- [x]` / `🚧` / `⛔`) and append a work-log line `YYYY-MM-DD HH:MM — <your agent name> — what changed`.
- **Record any deviation from `PLAN.md`, decision, or blocker in `DECISIONS.md`** before continuing, so the spec author can review it. Put questions that need the author's input under "Open questions for the spec author".

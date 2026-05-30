# Repository Guidelines

## Handoff & Shared State
Active task handoffs live in `docs/handoff/<slug>/`, each containing `CONTEXT.md`, `PLAN.md`, `PROGRESS.md`, and `DECISIONS.md`. `docs/handoff/INDEX.md` registers them.

- **Before starting work on a task, read its handoff folder** (CONTEXT → PLAN → PROGRESS → DECISIONS). `PLAN.md` is the spec authored by the planning agent — implement against it and do not silently diverge.
- **Re-derive, don't just recall.** Open the files listed under CONTEXT's *Read first* and confirm they still match the spec before trusting its summary; the banner's provenance line (planner model + commit SHA the spec was written against) tells you how stale the map may be.
- **`PLAN.md` ends with a runnable `Verification` block** — the exact command(s) plus the observable pass signal. A step is "done" only when its verification command actually passes; report the real output, never assume.
- **Update `PROGRESS.md` after every meaningful change**: check off the steps you completed (`- [x]` / `🚧` / `⛔`) and append a work-log line `YYYY-MM-DD HH:MM — <your agent name> — what changed`.
- **Record any deviation from `PLAN.md`, decision, or blocker in `DECISIONS.md`** before continuing, so the spec author can review it. Put questions that need the author's input under "Open questions for the spec author".

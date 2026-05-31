# Repository Guidelines

## Handoff & Shared State
Active task handoffs live in `docs/handoff/<slug>/`, each containing `CONTEXT.md`, `PLAN.md`, `PROGRESS.md`, and `DECISIONS.md`. `docs/handoff/INDEX.md` registers them.

`INDEX.md` is a markdown table, **one row per slug**, both human-readable and machine-parseable (`awk -F'|'` / `grep`): `| slug | status | depends-on | updated | note |`. `status` ∈ {`todo`, `in-progress`, `blocked`, `done`}; `depends-on` is a comma-separated list of slugs that must be `done` first (or `—`). `/handoff` seeds the row, `/implement` advances its `status`, `/resume` reads it. Update the existing row — never append a duplicate.

**One branch per slug, created as early as possible.** Each slug gets its own task branch, created at the *start* of the cycle (`/plan` branches from `main`/`master`) rather than at `/implement` time. This is a pre-requisite for parallel slugs: the optional Stop hook resolves the slug from the current branch, and `/dispatch` worktrees need a distinct branch per slug. Host-project prefixes are allowed (e.g. `feat/<slug>`) as long as the slug is derivable from the suffix. `/implement`'s branch step is an **idempotent safety net** — it creates the branch only if you're still on the default branch, and is a no-op once you're on the slug's branch.

- **Before starting work on a task, read its handoff folder** (CONTEXT → PLAN → PROGRESS → DECISIONS). `PLAN.md` is the spec authored by the planning agent — implement against it and do not silently diverge.
- **Re-derive, don't just recall.** Open the files listed under CONTEXT's *Read first* and confirm they still match the spec before trusting its summary; the banner's provenance line (planner model + commit SHA the spec was written against) tells you how stale the map may be.
- **`PLAN.md` ends with a runnable `Verification` block** — the exact command(s) plus the observable pass signal. A step is "done" only when its verification command actually passes; report the real output, never assume.
- **Update `PROGRESS.md` after every meaningful change**: check off the steps you completed (`- [x]` / `🚧` / `⛔`) and append a work-log line `YYYY-MM-DD HH:MM — <your agent name> — what changed`.
- **Record any deviation from `PLAN.md`, decision, or blocker in `DECISIONS.md`** before continuing, so the spec author can review it. Put questions that need the author's input under "Open questions for the spec author".
- **The back-channel is a loop, not a dead letter.** Open *Open questions for the spec author* are resolved by **Opus only** — the implementer must not guess past them or edit `PLAN.md`. `/resume` surfaces them as a decision queue for the planner to answer and fold back into the plan.
- **Keep the four files consistent with each other.** When reconciling, also check the package against itself: PROGRESS checkboxes must match PLAN steps, DECISIONS must not contradict PLAN, and the banner's provenance SHA flags how far the spec lags `HEAD`. Surface internal drift before resuming work on it.

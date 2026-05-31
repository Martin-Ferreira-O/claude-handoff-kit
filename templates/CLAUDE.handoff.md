<!-- handoff-kit:start -->
## Working with agents (Harness Engineering)

This project can coordinate a **planning agent** and an **implementing agent**
through file-based handoffs under `docs/handoff/<slug>/`. The shared contract
lives in `AGENTS.md`; this block is the agent-workflow layer on top of your own
project rules — keep your domain, architecture, and testing rules first.

### General working rules
- Read the relevant local docs before changing code: `README.md`, `AGENTS.md`,
  architecture docs, testing guides, and any files named by the task.
- Re-derive current state from the code and tests; don't trust stale summaries,
  prior-session memory, or comments that may be out of date.
- Keep changes scoped to the request. No drive-by refactors, style churn,
  dependency bumps, or reorganizations that the task doesn't require.
- Before editing, understand the existing pattern and follow it unless there is a
  concrete reason to diverge.

### Verification
- Don't mark a task done without running the relevant check: tests, typecheck,
  lint, build, or the project-specific command.
- Report the real command you ran and its observable result. If you couldn't run
  it, say why and what risk remains. Never claim something "passes" unverified.

### Roles (only if you use a separate planner)
- **Planner**: decides architecture, defines scope, writes `PLAN.md`.
- **Implementer**: executes `PLAN.md` without redesigning. On an ambiguous, wrong,
  or impossible step, it **stops** and records it in `DECISIONS.md`.
- **Only the planner rewrites `PLAN.md`.** The implementer proposes spec changes
  via `DECISIONS.md` (*Open questions for the spec author*) — never edits the plan
  silently.

For one-sentence changes, skip the handoff and implement directly, then verify.
Run `/handoff-init` to (re)seed the handoff contract and registry.
<!-- handoff-kit:end -->

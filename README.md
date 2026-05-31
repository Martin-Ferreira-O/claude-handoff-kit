# claude-handoff-kit

> A small **Harness Engineering** kit: a set of slash commands that coordinate a
> **planning agent** (Opus) and an **implementing agent** (Codex, or a fresh
> Claude session) through **file-based handoffs** under `docs/handoff/<slug>/`.

The hard part of long-running agentic work isn't writing code — it's **context
that rots**. A plan made at token 5k is a blurry memory by token 150k, and
handing work to another agent means re-deriving everything from scratch. This
kit makes the handoff an explicit, on-disk contract so any agent can pick up
where the last one left off, without trusting a stale summary.

---

## The cycle

```
/plan → /clarify → /handoff → /resume → /implement → /code-review
```

| Command | Who runs it | What it does |
|---|---|---|
| **`/plan`** | Opus | The formal entry point: creates the task branch (so you avoid working on `main`), drives the planning, writes a draft to `~/.claude/plans/<slug>.md` with a runnable **Verification** block, and runs a self-critique pass over it. Optional, and tool-agnostic — Codex can skip it and bring its own plan. |
| **`/clarify`** | Opus | Interviews the user (`AskUserQuestion`) on the hard parts — edges, scope boundaries, tradeoffs — and folds the answers into the plan **before** the handoff. Optional: skip it for one-sentence changes. |
| **`/handoff`** | Opus | Dumps context + spec into `docs/handoff/<slug>/` (`CONTEXT`, `PLAN`, `PROGRESS`, `DECISIONS`) and registers the slug in `INDEX.md`. |
| **`/resume`** | any agent | Rebuilds working context and briefs the user. **Does not implement.** |
| **`/implement`** | implementer | Executes `PLAN.md` step by step — one atomic commit per verified step — then runs a fresh-context review gate against the plan. |
| **`/code-review`** | any agent | The adversarial gate: does the diff satisfy every requirement in `PLAN.md`? |

Two more commands sit **outside** the linear cycle — one for scale, one for
lifecycle:

| Command | Who runs it | What it does |
|---|---|---|
| **`/dispatch`** | Opus (Claude-only) | Runs several slugs **in parallel**: topologically orders the `INDEX.md` DAG, fans the ready wave out into isolated git worktrees, and proposes a reviewed merge per wave. Opt-in, never auto-merges. See [`docs/orchestration.md`](docs/orchestration.md). |
| **`/archive`** | any agent | Retires a `done` slug by `git mv`-ing its package into `docs/handoff/_archive/` and marking its `INDEX.md` row archived. **Manual and explicit — never a delete:** the record is the point. |

The whole point is that the **spec lives on disk**, not in one session's memory.
The planner writes it once; any implementer — even one that has never seen the
conversation — reads the same four files and re-derives the truth from the code.

---

## The handoff package

Each task gets a folder `docs/handoff/<slug>/` with four files:

| File | Role | Owner |
|---|---|---|
| `CONTEXT.md` | Orientation: what + why, files to read first, setup/run/test commands, conventions that matter. | planner |
| `PLAN.md` | **The spec.** Goal, non-goals, ordered steps, and a runnable **Verification** block. Read-mostly. | planner |
| `PROGRESS.md` | Live status: a checklist mirroring PLAN steps (`- [ ]` / `- [x]` / `🚧` / `⛔`) + a reverse-chronological work log. | implementer |
| `DECISIONS.md` | Decisions taken, deviations, and *Open questions for the spec author*. | implementer → planner |

`docs/handoff/INDEX.md` is the registry — a **structured, machine-parseable
table** (`| slug | status | depends-on | updated | note |`), one row per slug.
Because `status` and `depends-on` are parseable (`awk -F'|'` / `grep`),
orchestration can compute the ready wave — which is exactly what `/dispatch`
runs on. A finished slug is retired with `/archive` into `docs/handoff/_archive/`
(history kept, never deleted); it drops out of the "most recently touched"
heuristic automatically so it stops competing with live work.

Every file opens with a **provenance banner**: the planner model, the commit SHA
the spec was written against, and the source-plan path. That line is how an
implementer detects *"this spec was written 40 commits ago — reconcile before
trusting it"* instead of building on a stale map.

---

## Roles — don't cross the lines

The kit's core discipline is keeping the planner and the implementer separate:

- **Opus = spec author.** Plans, decides architecture, writes `PLAN.md`. Doesn't
  implement unless explicitly asked.
- **Implementer = executor.** Follows `PLAN.md` without redesigning. Hits an
  ambiguous, wrong, or impossible step → **stops** and records it in
  `DECISIONS.md` instead of improvising a different design.
- **Only Opus rewrites `PLAN.md`.** The implementer proposes spec changes through
  `DECISIONS.md` (*Open questions for the spec author*) — never edits the plan
  silently. This is the rule that stops the harness from drifting.

The back-channel is a **loop, not a dead letter**: open questions are surfaced by
`/resume` as a decision queue and resolved by Opus, who folds the answer back
into the plan.

---

## The verification gate

No step is marked `- [x]` or committed without running the **Setup / run / test**
commands from `CONTEXT.md` and seeing them pass.

- Report failures with the **real output** — never claim a step passed unverified.
- Never commit a `🚧` (in progress) or `⛔` (blocked) step.
- `/implement` does **one commit per verified step** and **does not push**.
- Before reporting done, `/implement` runs a **fresh-context review against
  `PLAN.md`**: *"is every requirement implemented and does the Verification
  command pass? Report gaps, not style preferences."* The outcome lands in a
  `PROGRESS.md` work-log line.

---

## Optional enforcement layer (Claude-only)

**The kit works fully without it.** The Markdown commands drive Codex, Claude,
and any future agent with zero hooks. For Claude Code sessions, two hooks in
`hooks/` turn advisory rules into deterministic guarantees:

| Hook | Event | Guarantee |
|---|---|---|
| `hooks/progress-sync.sh` | `PreToolUse` (Bash) | A `git commit` that stages code but no `PROGRESS.md` is **blocked**. |
| `hooks/verify-gate.sh` | `Stop` | Turn-end is **blocked** until the slug's PLAN Verification command passes. |

To enable, make the scripts executable and merge `.claude/settings.json.example`
into your `.claude/settings.json`. Full details in [`docs/hooks.md`](docs/hooks.md).
Both are inactive until you opt in — Codex users ignore this entirely.

---

## When to hand off

- You're running low on context/tokens on a long task.
- You're delegating execution to Codex or another agent.
- You want to parallelize several slugs at once.

**Size each slug** to fit in a single implementer context window. If a plan is
big, split it into parallel slugs (the kit supports them) rather than one giant
slug that rots the implementer's context halfway through. To actually *run* those
slugs concurrently, `/dispatch` fans the ready wave out into isolated worktrees
with capped concurrency and a reviewed merge per wave — see
[`docs/orchestration.md`](docs/orchestration.md).

---

## Repository layout

```
.claude/commands/      plan · clarify · handoff · resume · implement · dispatch · archive
.claude/settings.json.example   optional hook wiring
hooks/                 progress-sync.sh · verify-gate.sh        (Claude-only enforcement)
docs/handoff/<slug>/   CONTEXT · PLAN · PROGRESS · DECISIONS    (per-task handoffs)
docs/handoff/INDEX.md  the structured handoff registry (status + depends-on)
docs/handoff/_archive/ retired done slugs (history, kept out of the live glob)
docs/orchestration.md  /dispatch: parallel slugs in isolated worktrees (Claude-only)
docs/hooks.md          how the optional enforcement layer works
docs/plans/            the kit's own improvement backlog (dogfooded)
AGENTS.md              the shared handoff contract (read by any tool)
CLAUDE.md              Claude/Opus-specific guidance as spec author
CLAUDE.copy.md         merge guide for dropping the kit into an existing project
```

This repo **dogfoods itself**: its own changes are planned and implemented
through the kit, with live handoffs under `docs/handoff/`.

---

## Getting started

1. Drop the `.claude/commands/` files into a project (or use this repo as a
   template).
2. Run **`/plan <task>`** with Opus to branch and draft the spec, then
   **`/clarify`** to pin down the edges.
3. **`/handoff <slug>`** to write the package.
4. Hand the slug to your implementer — a fresh Claude or Codex — and run
   **`/resume <slug>`** to rebuild context, then **`/implement <slug>`** to do
   the work.
5. (Optional) Wire the hooks from `docs/hooks.md` for deterministic enforcement.

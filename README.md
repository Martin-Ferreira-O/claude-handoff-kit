# claude-handoff-kit

> A small **Harness Engineering** kit: a set of slash commands that coordinate a
> **planning agent** (Opus) and an **implementing agent** (Codex, or a fresh
> Claude session) through **file-based handoffs** under `docs/handoff/<slug>/`.

The hard part of long-running agentic work isn't writing code — it's **context
that rots**. A plan made at token 5k is a blurry memory by token 150k, and handing
work to another agent means re-deriving everything from scratch. This kit turns the
handoff into an explicit, on-disk contract: the planner writes the spec once, and
any implementer — even one that has never seen the conversation — reads the same
files and re-derives the truth from the code.

This README is **usage-first**: install it, then learn the cycle by running it.

---

## Install

Pick one path — both end the same way (a `/handoff-init` to seed the contract).

### Claude Code (plugin — zero files copied)

The repo is **its own marketplace** and **its own plugin**. From inside a session:

```
/plugin marketplace add Martin-Ferreira-O/claude-handoff-kit
/plugin install handoff-kit@claude-handoff-kit
/handoff-init
```

Or from the terminal (for scripting/CI):

```sh
claude plugin marketplace add Martin-Ferreira-O/claude-handoff-kit
claude plugin install handoff-kit@claude-handoff-kit
```

`handoff-kit@claude-handoff-kit` reads as `<plugin>@<marketplace>`. After installing,
the `/plan · /clarify · /resume · /implement · /dispatch · /archive · /handoff-init`
commands are available with **no files copied** into your project.

### Codex / any agent (script — tool-agnostic)

```sh
curl -fsSL https://raw.githubusercontent.com/Martin-Ferreira-O/claude-handoff-kit/main/install.sh | sh
# or, from a clone:
./install.sh --target /path/to/project --with-hooks
```

The script copies `.claude/commands/` (and, with `--with-hooks`, the enforcement
hooks) into the target, then seeds the contract. Flags: `--target <dir>`,
`--with-hooks`, `--with-django`, `--force`. It never clobbers files without
`--force`.

### Then: `/handoff-init` (once per project)

```
/handoff-init
```

Seeds the **shared contract** into the repo as real files: `AGENTS.md` (the contract
Codex reads too), `docs/handoff/INDEX.md` (the registry), and optionally a `CLAUDE.md`
workflow block. It's **idempotent** — re-run it any time to refresh an updated
contract.

> **Why `/handoff-init` and not the plugin alone?** Claude Code does not load a
> plugin's `AGENTS.md`/`CLAUDE.md` as project context — plugins contribute commands,
> hooks, and skills. The contract has to land as a real file so Codex and the planner
> can read it; that's what the init step (and the script) do.

---

## How to use it

### The cycle

```
/plan → /clarify → (/resume) → /implement → /code-review
```

The arrows are a **recommended flow, not technical dependencies** — every command
re-derives its own context from the on-disk package, so you can enter at any point
and skip the steps you don't need. (`/code-review` is Claude Code's built-in review
skill; the kit's `/implement` invokes a review gate for you, so it's listed here only
to show where review sits.)

### A typical run

```sh
# 1. Plan — Opus creates the task branch, drafts the spec, self-critiques,
#    scores each task, and writes the whole handoff package to disk.
/plan add CSV export to the reports API

# 2. (optional) Clarify the hard edges — answers fold straight into PLAN.md.
/clarify add-csv-export

# 3. (optional) Read-only briefing before executing — rebuilds context and stops.
/resume add-csv-export

# 4. Implement — executes PLAN.md step by step, one atomic commit per verified
#    step, then runs a fresh-context review gate against the plan.
/implement add-csv-export
```

What each step actually does:

- **`/plan <task>`** — runs **outside** native plan mode (which is read-only and
  can't branch or write files). It creates the task branch (so you never work on
  `main`), drives the planning, runs a **self-critique** pass, scores each task, and
  **writes the four-file package** into `docs/handoff/<slug>/` with a runnable
  **Verification** block — then seeds the `INDEX.md` row. It **absorbed the old
  `/handoff`** step, so there's no second context-rederiving command. Bring your own
  draft with `/plan <slug> <path>` to have it package an existing plan instead.
- **`/clarify <slug>`** — interviews you (`AskUserQuestion`) on edges, scope
  boundaries, and tradeoffs, and folds the answers **into the package `PLAN.md`**.
  Skip it for one-sentence changes.
- **`/resume <slug>`** — rebuilds context from the package and **reports where the
  task stands, then stops**. Optional: `/implement` re-derives context itself, so
  `/resume` is only for a read-only checkpoint first.
- **`/implement <slug>`** — the executor. Loads all four files, reconciles against
  the repo, then implements `PLAN.md` in order with **one commit per verified step**
  (code + PROGRESS/DECISIONS updates together). Before reporting done it runs a
  **fresh-context review gate** (below). It does **not** push.

### Three ways to execute a slug

Once the package exists, you choose how to run it — all three coexist:

| Mode | Command | Isolation | Model | Best for |
|---|---|---|---|---|
| **In-session** (default, portable) | `/implement <slug>` | current session | session's own | one coupled slug; Codex |
| **Delegate** (opt-in, Claude-only) | `/implement --delegate <slug>` | one fresh subagent, current branch | routed by Task card | one slug, without opening another terminal |
| **Dispatch** (opt-in, Claude-only) | `/dispatch` | N subagents, isolated git worktrees | routed by Task card | several disjoint slugs in parallel |

- **`--delegate`** hands the slug to **one** fresh subagent while your session becomes
  the orchestrator/reviewer — it kills the "open another terminal" friction without
  losing the clean context a separate implementer gives you.
- **`/dispatch`** topologically orders the `INDEX.md` DAG, fans the ready wave out into
  isolated worktrees, and **proposes a reviewed merge per wave** (never auto-merges to
  `main`). See [`docs/orchestration.md`](docs/orchestration.md).

### Model routing (Task cards)

`PLAN.md` carries a **Task card** per atomic task — difficulty (1-10), a routed model,
and effort. The two Claude-only modes read it to pick the right model per slug:

| Difficulty | Model | Effort |
|---|---|---|
| 1-3 (mechanical) | Sonnet 4.6 | low / medium |
| 4-7 (reasoning / refactor) | Opus 4.8 | medium |
| 8-10 (critical / architectural) | Opus 4.8 | max |

Difficulty is scored on a **5-axis rubric** (blast radius, coupling, novelty,
verifiability, reversibility). The rubric and table live in
[`docs/routing.md`](docs/routing.md), shared by `/plan` and `/dispatch`; the card
schema lives in `AGENTS.md`. The **review gate's** reviewer is routed by the same
table, and the model/effort live in the card — **not** in new `INDEX.md` columns, so
the registry stays parseable. Effort is passed as prompt guidance, not a harness dial.

### Splitting a big task into parallel slugs

**Size each slug to fit one implementer context window.** If a plan is big, `/plan`
detects multi-unit work with **disjoint files**, **proposes** a decomposition into N
parallel slugs (with a `depends-on` DAG), and **confirms it with you** before writing
N packages — decline and it falls back to a single slug. Then `/dispatch` runs the
ready wave concurrently. A one-sentence task always stays a single slug, identical to
the simple flow.

### The verification gate

No step is marked `- [x]` or committed without running the **Setup / run / test**
commands from `CONTEXT.md` and seeing them pass.

- Report failures with the **real output** — never claim a step passed unverified.
- Never commit a `🚧` (in progress) or `⛔` (blocked) step.
- Before reporting done, `/implement` runs a **fresh-context review against
  `PLAN.md`**: a reviewer that sees **only the diff + `PLAN.md`** (a clean subagent or
  session — not the implementer's context) checks *"is every requirement implemented
  and does the Verification command pass? Report gaps, not style preferences."* The
  outcome lands in a `PROGRESS.md` line tagged `review (fresh)` or `review
  (in-session)` so the guarantee is auditable.

---

## The handoff package

Each task gets a folder `docs/handoff/<slug>/` with four files:

| File | Role | Owner |
|---|---|---|
| `CONTEXT.md` | Orientation: what + why, files to read first, setup/run/test commands, conventions that matter. | planner |
| `PLAN.md` | **The spec.** Goal, non-goals, Task card(s), ordered steps, and a runnable **Verification** block. Read-mostly. | planner |
| `PROGRESS.md` | Live status: a checklist mirroring PLAN steps (`- [ ]` / `- [x]` / `🚧` / `⛔`) + a reverse-chronological work log. | implementer |
| `DECISIONS.md` | Decisions taken, deviations, and *Open questions for the spec author*. | implementer → planner |

`docs/handoff/INDEX.md` is the registry — a **structured, machine-parseable table**
(`| slug | status | depends-on | updated | note |`), one row per slug. Because
`status` and `depends-on` are parseable (`awk -F'|'` / `grep`), `/dispatch` can compute
the ready wave from it. Every file opens with a **provenance banner** (planner model,
the commit SHA the spec was written against, source-plan path) so an implementer
detects *"this spec was written 40 commits ago — reconcile first"* instead of trusting
a stale map. A finished slug is retired with **`/archive <slug>`** into
`docs/handoff/_archive/` (history kept, never deleted) so it stops competing with live
work.

---

## Command reference

| Command | Who runs it | What it does |
|---|---|---|
| `/handoff-init` | any agent | Seeds the contract (`AGENTS.md`, `INDEX.md`, optional `CLAUDE.md` block) into the repo. Idempotent. |
| `/plan <task> [path]` | Opus | The single entry point: branches, plans, self-critiques, scores tasks, and writes the whole package. Can ingest an existing draft. |
| `/clarify <slug>` | Opus | Interviews you on the hard parts and folds answers into `PLAN.md`. Optional. |
| `/resume <slug>` | any agent | Read-only briefing: rebuilds context, reports status, then stops. Optional. |
| `/implement [--delegate] <slug>` | implementer | Executes `PLAN.md` step by step, one verified commit per step, then a fresh-context review gate. `--delegate` runs it in one fresh subagent. |
| `/dispatch [--max N]` | Opus (Claude-only) | Runs several slugs in parallel across isolated worktrees with per-card model routing; proposes a reviewed merge per wave. |
| `/archive <slug>` | any agent | Retires a `done` slug into `docs/handoff/_archive/`. Manual and explicit — never a delete. |

---

## Roles — don't cross the lines

The kit's core discipline is keeping the planner and the implementer separate:

- **Opus = spec author.** Plans, decides architecture, writes `PLAN.md`. Doesn't
  implement unless explicitly asked.
- **Implementer = executor.** Follows `PLAN.md` without redesigning. Hits an
  ambiguous, wrong, or impossible step → **stops** and records it in `DECISIONS.md`
  instead of improvising a different design.
- **Only Opus rewrites `PLAN.md`.** The implementer proposes spec changes through
  `DECISIONS.md` (*Open questions for the spec author*) — never edits the plan
  silently. This is the rule that stops the harness from drifting; the back-channel is
  a **loop, not a dead letter** (`/resume` surfaces open questions for Opus to resolve).

---

## Optional: enforcement hooks (Claude-only)

**The kit works fully without them.** The Markdown commands drive Codex, Claude, and
any future agent with zero hooks. For Claude Code sessions, two hooks in `hooks/` turn
advisory rules into deterministic guarantees:

| Hook | Event | Guarantee |
|---|---|---|
| `hooks/progress-sync.sh` | `PreToolUse` (Bash) | A `git commit` that stages code but no `PROGRESS.md` is **blocked**. |
| `hooks/verify-gate.sh` | `Stop` | Turn-end is **blocked** until the slug's PLAN Verification command passes. |

Enable by making the scripts executable and merging `.claude/settings.json.example`
into your `.claude/settings.json`. Both stay inert until you opt in — Codex users
ignore this entirely. Details in [`docs/hooks.md`](docs/hooks.md).

## Optional: Django layer

For **Django** repos there's an opt-in layer —
[`plugins/handoff-kit-django/`](plugins/handoff-kit-django/) — that adds domain skills
(`django-patterns`, `django-security`, `django-tdd`, `django-verification`) and reviewer
subagents (`python-reviewer`, `security-reviewer`, `database-reviewer`), plus a
`/django-review` command that routes a diff to the right reviewer. Install it **in
addition to** the core plugin, only in a Django project:

```
/plugin install handoff-kit-django@claude-handoff-kit
# or: ./install.sh --target /path/to/project --with-django
```

The reviewers run in their own context window pinned to `model: sonnet`, so the review
gate stays cheap. Skills and reviewers are imported verbatim from
[Everything Claude Code](https://github.com/affaan-m/ECC) (MIT; see the layer's
`ATTRIBUTION.md`).

---

## Repository layout

```
.claude-plugin/plugin.json      plugin manifest (commands + hooks)
.claude-plugin/marketplace.json self-marketplace, so `/plugin marketplace add` works
.claude/commands/      handoff-init · plan · clarify · resume · implement · dispatch · archive
.claude/settings.json.example   optional hook wiring (non-plugin / script path)
plugins/handoff-kit-django/     optional Django layer: skills + reviewer subagents + /django-review (imported from ECC, MIT)
hooks/                 progress-sync.sh · verify-gate.sh · hooks.json  (Claude-only enforcement)
templates/             contract snippets seeded by /handoff-init & install.sh (single source)
install.sh             tool-agnostic installer (curl-able), for Codex / any agent
docs/handoff/<slug>/   CONTEXT · PLAN · PROGRESS · DECISIONS    (per-task handoffs)
docs/handoff/INDEX.md  the structured handoff registry (status + depends-on)
docs/handoff/_archive/ retired done slugs (history, kept out of the live glob)
docs/orchestration.md  /dispatch: parallel slugs in isolated worktrees (Claude-only)
docs/routing.md        difficulty rubric (1-10) + model/effort routing table (shared by /plan & /dispatch)
docs/hooks.md          how the optional enforcement layer works
AGENTS.md              the shared handoff contract (read by any tool)
CLAUDE.md              Claude/Opus-specific guidance as spec author
CLAUDE.copy.md         merge guide for dropping the kit into an existing project
```

This repo **dogfoods itself**: its own changes are planned and implemented through the
kit, with live handoffs under `docs/handoff/`.

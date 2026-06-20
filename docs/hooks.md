# Optional enforcement layer (Claude-only)

> **The kit works fully without anything in this file.** The portable Markdown
> commands (`/plan`, `/clarify`, `/resume`, `/implement`) drive Codex *and*
> Claude *and* any future agent with no hooks at all. This layer is a
> **belt-and-suspenders** add-on for Claude Code sessions only: it turns two of
> the kit's advisory rules into deterministic, enforced ones — the kind of
> guarantee prompt text alone can't make once context rot sets in. Codex users
> ignore this entirely.

## What it enforces

| Hook | Event | Turns this advisory rule… | …into this guarantee |
|---|---|---|---|
| `hooks/progress-sync.sh` | `PreToolUse` (Bash) | "commit code + PROGRESS together" | a `git commit` staging code but no `docs/handoff/<slug>/PROGRESS.md` is **blocked** |
| `hooks/verify-gate.sh` | `Stop` | "verify before you check a step off" | turn-end is **blocked** until the slug's PLAN Verification command passes |

Both are deterministic: they run every time the event fires, regardless of how
full the session's context window is.

## Enabling it

1. The hook scripts live in `hooks/`. Make them executable:
   ```sh
   chmod +x hooks/progress-sync.sh hooks/verify-gate.sh
   ```
2. Merge the blocks from `.claude/settings.json.example` into your real
   `.claude/settings.json` (create it if absent). The example uses
   `$CLAUDE_PROJECT_DIR` so the paths resolve from the repo root.
3. Restart / re-open the session so Claude Code picks up the hook config.

Enable only the hook(s) you want — the pre-commit guard and the Stop gate are
independent.

## `progress-sync.sh` — PROGRESS-sync commit guard

Intercepts `git commit` Bash calls. If the staged set contains any **code** path
but **no** `docs/handoff/<slug>/PROGRESS.md`, it exits 2 to block the commit and
tells Claude to update + stage PROGRESS first. A docs-only or PROGRESS-included
commit passes. Requires `python3` (used only to parse the hook's stdin JSON
robustly).

**What counts as "code".** Anything that is *not* pure documentation. Pure docs —
which never trigger the guard — are anything under `docs/` (plans, `hooks.md`, the
handoff folder itself) plus root-level `*.md` (`README.md`, `CLAUDE.md`,
`AGENTS.md`). This excludes the kit's own bookkeeping commits, which the older
"anything outside `docs/handoff/` is code" rule flagged as false positives. The
classification is the `grep` patterns near the top of the script — tune them if
your repo keeps code under `docs/` or docs outside it.

**Branch-aware slug matching.** When a PROGRESS *is* staged, the guard also checks
it is the **right** slug's. If the current branch names a slug (`<slug>` or
`*/<slug>`, same resolution as `verify-gate.sh`), the staged PROGRESS must be
`docs/handoff/<slug>/PROGRESS.md` — committing slug-a's code while updating
slug-b's PROGRESS is the same gap the guard exists to catch, and aligns with the
kit's one-branch-per-slug model. If the branch matches no handoff folder, any
staged PROGRESS is accepted, so the stricter check adds no friction outside the
normal flow.

## `verify-gate.sh` — Stop verification gate (off by default)

On turn-end it locates the active slug, reads a **single shell command** from
`docs/handoff/<slug>/.verify`, runs it, and blocks turn-end (exit 2) if it fails.
**The gate is inactive whenever no `.verify` file exists** — so this repo, which
has no test suite, is unaffected until someone opts in.

**Slug resolution is branch-aware.** The active slug is the one named by the
current branch — `<slug>` or any `*/<slug>` (e.g. `feature/<slug>`). This aligns
with the kit's "one branch per slug" model and makes **parallel worktrees** safe:
each worktree sits on its own branch and validates only its own slug, so a broken
`.verify` in `slug-a` never blocks a turn in the `slug-b` worktree. If the branch
matches no handoff folder, it falls back to the old heuristic (most recently
touched `PROGRESS.md`).

**Scoped to work in progress.** The gate only fires when the current worktree has
uncommitted or staged changes. A clean tree means the turn didn't touch any work
(a read-only or question turn), so there is nothing new to verify and the gate
exits 0 — it won't trap you in a verification loop over a turn that changed
nothing. Since `/implement` commits one verified step at a time, a clean tree also
means the last commit already cleared this gate.

**`.verify` is generated, not hand-rolled.** `/plan` derives it from the PLAN
**Verification** block: when that block is one runnable command, `/plan` writes
that command to `docs/handoff/<slug>/.verify`; `/implement` keeps it in sync (it
regenerates a stale `.verify` during its consistency check). The PLAN stays the
single source of truth — `.verify` is just a projection of it, so **edit the PLAN
Verification, not `.verify`**; the next `/plan` or `/implement` reprojects it.
If you ever need to set it by hand, it is a single line — the command only:
```sh
echo '.venv/bin/python manage.py test billing' > docs/handoff/<slug>/.verify
```

**Single-command assumption.** The gate runs one command. If your PLAN
Verification block needs several, `/plan` deliberately leaves `.verify`
uncreated (it won't invent a multi-command format) and the gate stays inactive.
Wrap the commands in a script and point `.verify` at it — or, per the kit's own
guidance, **pause and ask the spec author** how to express the pass signal.

## Why this is opt-in and separate

Keeping the core tool-agnostic is a deliberate design choice (see `DECISIONS.md`
in any handoff and the source review): the file-based kit's portability across
Codex/Claude/future agents is worth more than baking Claude-only machinery into
the required path. Hooks are the right tool *only* when you want a deterministic
guarantee on a Claude session — so they ship here, clearly fenced off, never as a
step any core command depends on.

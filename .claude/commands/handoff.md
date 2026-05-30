---
description: Dump current context + plan into docs/handoff/<slug>/ for another agent to continue
argument-hint: <task-slug-or-description>
allowed-tools: Read, Write, Edit, Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(date:*)
---

# Handoff

Package the current working context into a shared, file-based handoff under
`docs/handoff/<slug>/` so another agent — a fresh Claude session (when this one
runs out of tokens) or an implementing agent like Codex — can continue without
re-deriving everything. **You (Opus) are the spec author**; the package you
write is what the implementer reads.

Argument (task slug or short description): `$ARGUMENTS`

## Steps

1. **Resolve the slug.** Turn `$ARGUMENTS` into a kebab-case slug. First
   `ls docs/handoff/` — if an existing folder clearly matches this task, reuse
   it and **update** rather than create a duplicate. If `$ARGUMENTS` is empty,
   derive the slug from the current task and confirm it in your summary.

2. **Gather real state** (do not invent it):
   - The current conversation: what we're doing, why, and what's left.
   - The active plan in `~/.claude/plans/` driving this work — reference its
     full path and copy/summarize it into `PLAN.md`.
   - `git status` and `git diff --stat` for in-flight, uncommitted changes.
   - `git log --oneline -10` for recent landed work.
   - The auto-memory index for project constraints worth carrying over.
   - Run `date "+%Y-%m-%d %H:%M"` for accurate timestamps.

3. **Write the four files** into `docs/handoff/<slug>/` (templates below). Each
   starts with the header banner. Fill them with real content — never leave a
   section as an empty placeholder. If something is unknown, say so explicitly.

4. **Update the registry** `docs/handoff/INDEX.md` — one line per handoff:
   `` - `<slug>` — <one-line status> — updated <date> ``. Create the file if
   missing. Update the existing line instead of appending a duplicate.

5. **Report**: print the folder path and the resume hint `/resume <slug>`.

## File templates

Header banner at the top of all four files (substitute real values):

```
> Handoff doc for task `<slug>`. Author: <your model, e.g. Claude Opus 4.7>. Updated: <YYYY-MM-DD HH:MM>.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by <planner model> against commit `<sha>` on branch `<branch>`; source plan: `~/.claude/plans/<...>.md`. If HEAD has moved far past this, reconcile before trusting the spec.
```

The 4th line is **provenance/freshness**: it pins the planner model, the exact
commit the spec was written against, and the source-plan path. A recalled summary
reflects one moment in time — making that moment explicit lets the implementer (and
`/resume`) detect "spec written N commits ago" drift instead of trusting a stale map.

### CONTEXT.md — orientation
- **Task**: one-paragraph what + why.
- **Project area**: which apps/modules/dirs this touches.
- **Read first**: the handful of files (`path:line`) the implementer should open before coding. Add the standing instruction: *open these files and confirm they still match this spec before trusting any summary below* — re-derivation from the code beats recall from a (possibly stale) handoff.
- **Setup / run / test**: the exact commands, using `.venv/bin/python ...` per repo rule (e.g. `.venv/bin/python manage.py test <app>`).
- **Conventions that matter here**: relevant rules from CLAUDE.md/AGENTS.md (service layer, UUID PKs, Spanish user-facing text, CLP integers, etc.).

### PLAN.md — the spec (author → implementer)
- **Goal** and **non-goals / scope**.
- **Source plan**: link the `~/.claude/plans/<...>.md` path.
- **Ordered steps**, each concrete enough to execute.
- **Verification** (mandatory, not prose): the exact copy-pasteable command(s)
  the implementer runs to prove the work is done, plus the **observable pass
  signal** for each (e.g. `` `.venv/bin/python manage.py test billing` → `OK`, 0
  failures ``). End with one end-to-end check that proves the feature works, not
  just that units pass. This block is load-bearing — `/implement` verifies against
  it and the optional Stop hook (see `docs/hooks.md`) keys off it. If a step
  genuinely cannot be verified by command, say so explicitly and give the manual
  check instead.
- Treat this as read-mostly; the implementer should not silently diverge.

### PROGRESS.md — live status (implementer updates this)
- **Checklist** mirroring PLAN steps: `- [ ]` todo, `- [x]` done, `🚧` in progress, `⛔` blocked.
- **Work log** (reverse-chronological): `YYYY-MM-DD HH:MM — <agent> — what changed`.
- Seed it with the current state (what's already done vs. pending right now).

### DECISIONS.md — decisions + open questions
- **Decisions taken** with brief rationale.
- **Open questions for the spec author** — blockers or ambiguities the
  implementer should surface back to Opus before proceeding.

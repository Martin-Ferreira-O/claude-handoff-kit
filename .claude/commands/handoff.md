---
description: Dump current context + plan into docs/handoff/<slug>/ for another agent to continue
argument-hint: <task-slug-or-description> [plan-path]
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
   - The active **source plan** driving this work — *any agreed plan draft*,
     not only Claude's. Resolve it in order: (a) a path passed as argument,
     (b) `~/.claude/plans/<...>.md`, (c) a repo draft like `docs/plans/<slug>.md`;
     use the first that exists. Reference its **real full path** (it goes in
     the banner) and copy/summarize it into `PLAN.md`.
   - `git status` and `git diff --stat` for in-flight, uncommitted changes.
   - `git log --oneline -10` for recent landed work.
   - The auto-memory index for project constraints worth carrying over.
   - Run `date "+%Y-%m-%d %H:%M"` for accurate timestamps.

3. **Write the four files** into `docs/handoff/<slug>/` (templates below). Each
   starts with the header banner. Fill them with real content — never leave a
   section as an empty placeholder. If something is unknown, say so explicitly.

   Then **derive `.verify` from the PLAN Verification block** (it feeds the
   optional Stop hook — see `docs/hooks.md`). `.verify` is a *projection* of the
   PLAN; PLAN stays the single source of truth.
   - If the Verification block is **one runnable command**, write exactly that
     command to `docs/handoff/<slug>/.verify` (one line, the command only — no
     prose, no pass-signal annotation).
   - If it is **several commands** (or not expressible as one), **do not invent a
     multi-command format**: leave `.verify` uncreated and note in the report that
     the Stop gate stays inactive until the author wraps the commands in a script
     and points `.verify` at it (consistent with `docs/hooks.md`).
   - `.verify` is versioned (auditable) — stage it alongside the four files.

4. **Update the registry** `docs/handoff/INDEX.md` — one **table row per slug**
   under the `## Handoffs` table: `| <slug> | <status> | <depends-on> | <date> | <note> |`.
   - `status` ∈ {`todo`, `in-progress`, `blocked`, `done`} — a fresh handoff is
     normally `todo` (or `in-progress` if you're seeding partial work).
   - `depends-on` = comma-separated slugs that must be `done` first, or `—`.
   - `date` = today (`%Y-%m-%d`); `note` = short human-readable status.
   Create the file with the schema header if missing (see the existing INDEX for
   the format). **Update the existing row** for this slug instead of appending a
   duplicate.

5. **Report**: print the folder path and the resume hint `/resume <slug>`.

## File templates

Header banner at the top of all four files (substitute real values):

```
> Handoff doc for task `<slug>`. Author: <your model, e.g. Claude Opus 4.7>. Updated: <YYYY-MM-DD HH:MM>.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written by <planner model> against commit `<sha>` on branch `<branch>`; source plan: `<resolved-plan-path>`. If HEAD has moved far past this, reconcile before trusting the spec.
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
- **Source plan**: link the resolved source-plan path (see step 2 — may be
  `~/.claude/plans/`, a repo draft, or a path you were given).
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

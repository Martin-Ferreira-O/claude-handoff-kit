> Handoff doc for task `harden-handoff-kit`. Author: Claude Opus 4.8. Updated: 2026-05-29 21:58.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written against commit `857801a` on branch `harden-handoff-kit`. If HEAD has moved far past this, reconcile before trusting the spec.

# CONTEXT — harden-handoff-kit

## Task
Harden this handoff kit's own commands based on a research-backed review (see
`~/.claude/plans/ultrathink-please-review-this-playful-clover.md`). The kit is a
cross-tool spec-driven-development harness; the review found it sound but leaky
at the *seams* where handoffs occur. We are improving the command prompts and
adding an optional Claude-side enforcement layer — **not rebuilding** the kit and
**not switching** to Spec Kit/Kiro. The kit dogfoods itself, so the "code" here
is mostly Markdown command files.

## Project area
- `.claude/commands/handoff.md`, `resume.md`, `implement.md` — the three commands.
- `AGENTS.md`, `CLAUDE.md` — shared contract + Opus-specific guidance.
- New (to be created): `.claude/commands/clarify.md`, `docs/hooks.md`, a
  `hooks/` dir + `.claude/settings.json` example (optional layer).
- This very folder `docs/handoff/harden-handoff-kit/` is the live example.

## Read first
- `~/.claude/plans/ultrathink-please-review-this-playful-clover.md` — the approved
  source plan; the full rationale and source links live here.
- `.claude/commands/handoff.md:43-75` — the four file templates this task edits.
- `.claude/commands/implement.md:39-71` — implement loop + where the review gate goes.
- `.claude/commands/resume.md:15-37` — reconcile step + where loop-closure goes.
- `AGENTS.md` (whole file, ~12 lines) — the shared handoff contract.
- `CLAUDE.md` — the cycle diagram and role rules to keep in sync.

## Setup / run / test
There is no build/test suite — this repo is Markdown commands. "Verification" is
**dogfooding**: run the kit on a real task and observe behavior.
- Inspect a command: `cat .claude/commands/<name>.md`
- Lint frontmatter by eye: each command needs `description`, `argument-hint`,
  `allowed-tools`.
- End-to-end check: in a fresh session run `/clarify` → `/handoff` → `/resume` →
  `/implement` on a throwaway slug and confirm each new behavior fires (see
  PLAN Acceptance criteria / the plan's Verification section).
- `date "+%Y-%m-%d %H:%M"` for accurate work-log timestamps.

## Conventions that matter here
- Slugs in kebab-case; **one handoff per slug — update, never duplicate**.
- Every command file carries frontmatter; `allowed-tools` = minimum necessary
  (read-mostly for handoff/resume; Write/Edit/Bash for implement).
- All four handoff files open with the header banner.
- Roles do not cross: **only Opus rewrites `PLAN.md`**; the implementer proposes
  changes via `DECISIONS.md`, never edits the plan silently.
- `/implement` = one atomic commit per *verified* step (code + PROGRESS/DECISIONS
  together); never commit a `🚧`/`⛔` step; do not push unless asked.
- Keep the portable Markdown core tool-agnostic (must drive Codex too). Anything
  Claude-specific (hooks) ships as a clearly separated **optional** layer.
- User-facing prose in this repo is bilingual (CLAUDE.md is Spanish, AGENTS.md
  English); match the file you are editing.

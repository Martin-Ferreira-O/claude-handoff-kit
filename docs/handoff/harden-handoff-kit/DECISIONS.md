> Handoff doc for task `harden-handoff-kit`. Author: Claude Opus 4.8. Updated: 2026-05-29 21:58.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.

# DECISIONS — harden-handoff-kit

## Decisions taken
- **(implementer, 2026-05-29) Step 4 also edited `implement.md`, not just the
  files in its header.** PLAN step 4's header lists "resume.md + AGENTS.md", but
  its body explicitly says to add the cross-artifact consistency check to "the
  reconcile step of `/resume` *and* `/implement`". I followed the body and added
  the check to implement.md's step 3 too. Not a design change — the spec called
  for it; flagging only because the header undercounts the touched files.
- **(implementer, 2026-05-29) Committed the handoff package into git with step 1.**
  The planner created `docs/handoff/harden-handoff-kit/` but left it untracked.
  Since the package *is* the live spec being implemented (and CONTEXT calls this
  folder "the live example"), I added CONTEXT/PLAN/PROGRESS/DECISIONS/INDEX to the
  repo as the baseline in the step-1 commit so the work is resumable from git.
  PROGRESS/DECISIONS/INDEX continue to evolve in later step commits. Not a PLAN
  deviation — just bookkeeping the planner left open.
- **Deliverable was assessment + plan only** for the prior session; no command
  files were edited. This handoff is the bridge from plan to implementation.
- **Keep the portable Markdown core tool-agnostic.** Enforcement hooks ship as a
  clearly separated optional layer (user choice), never as a required core step,
  so the kit keeps driving Codex.
- **Don't switch toolkits.** Borrow concepts (clarify, consistency check) from
  Spec Kit/Kiro; do not adopt them. Rationale in the source plan.
- **Slug = `harden-handoff-kit`** (not the literal arg "change"): it matches the
  current branch and the task; "change" was too vague to be a durable slug.

## Open questions for the spec author
*(none blocking — the plan is approved and self-contained)*
- Minor: §5's Stop-hook verification gate assumes the PLAN Verification block is a
  single shell command. For multi-command verification, the implementer should
  pause and ask the author how to express the pass signal rather than inventing a
  format. Surface here if hit.

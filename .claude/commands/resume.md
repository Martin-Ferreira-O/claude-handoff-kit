---
description: Rebuild working context from a docs/handoff/<slug>/ package
argument-hint: [task-slug]
allowed-tools: Read, Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*)
---

# Resume

Reconstruct the working context for a handoff so this session can continue the
task. Use this when picking up after a token-exhausted session, or when
checking on work an implementing agent (e.g. Codex) has been doing.

Target handoff (optional slug): `$ARGUMENTS`

## Steps

1. **Locate the handoff.**
   - If `$ARGUMENTS` names a slug, use `docs/handoff/<slug>/`.
   - If empty, `ls -t docs/handoff/*/PROGRESS.md` and pick the folder whose
     `PROGRESS.md` was modified most recently. State which one you chose and why.
     (Archived slugs under `docs/handoff/_archive/<slug>/` fall outside this glob,
     so they won't be picked up here — see `/archive`.)
   - If `docs/handoff/` is empty or missing, say so and stop.

2. **Read all four files in order**: CONTEXT.md → PLAN.md → PROGRESS.md →
   DECISIONS.md. Also read the slug's **row** in `docs/handoff/INDEX.md` for its
   registry `status` (`todo`/`in-progress`/`blocked`/`done`) and `depends-on`;
   if the row's status contradicts what PROGRESS shows, flag it as drift.

3. **Reconcile with the repo, and check the package against itself.** Run
   `git status`, `git log --oneline -10`, and `git diff --stat` to detect work
   done since PROGRESS.md was last updated, or **spec-vs-tree** drift. Then run a
   tiny **cross-artifact consistency check** (internal drift, no repo needed):
   - PROGRESS checkboxes that don't line up with PLAN steps (a step checked off
     with no matching PLAN item, or a PLAN step missing from the checklist).
   - DECISIONS that contradict PLAN (a decision the plan never absorbed).
   - The banner's provenance SHA vs. current `HEAD` — if the spec was written many
     commits ago, say so; the map may be stale.
   Flag every mismatch; a stale package is a bad map to resume on.

4. **Surface the decision queue (loop back to Opus).** If `DECISIONS.md` has open
   *Open questions for the spec author*, list them as a **decision queue** and
   state plainly that **resolving them is Opus's job, not the implementer's** —
   the implementer must not guess past them or silently edit PLAN. If you are
   running this *as Opus*, this is your queue to answer and fold back into PLAN;
   if not, it's the back-channel that needs the planner's input before work
   continues.

5. **Brief the user — then stop.** Output a concise summary:
   - **Where we are**: done vs. pending, from PROGRESS.md (and the INDEX row's
     `status`/`depends-on`).
   - **Next step**: the first unchecked item in PLAN.md.
   - **Decision queue**: the open questions from step 4 (and who owns them).
   - **Drift**: spec-vs-tree and internal-consistency mismatches found in step 3.

   Do **not** start editing or implementing. Wait for the user to confirm the
   next move.

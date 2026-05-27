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
   - If `docs/handoff/` is empty or missing, say so and stop.

2. **Read all four files in order**: CONTEXT.md → PLAN.md → PROGRESS.md →
   DECISIONS.md.

3. **Reconcile with the repo.** Run `git status`, `git log --oneline -10`, and
   `git diff --stat` to detect work done since PROGRESS.md was last updated, or
   drift between the plan and the actual tree. Flag any mismatch.

4. **Brief the user — then stop.** Output a concise summary:
   - **Where we are**: done vs. pending, from PROGRESS.md.
   - **Next step**: the first unchecked item in PLAN.md.
   - **Blockers / open questions**: anything from DECISIONS.md needing a decision.
   - **Drift**: any mismatch found in step 3.

   Do **not** start editing or implementing. Wait for the user to confirm the
   next move.

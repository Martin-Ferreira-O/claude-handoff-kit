---
description: Interview the user on the hard parts of a task and fold the answers into the plan before /handoff
argument-hint: <task-slug-or-description>
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*)
---

# Clarify

Kill ambiguity **before** it gets baked into a handoff. Every unclear scope
boundary or unstated tradeoff that survives into `PLAN.md` is amplified by the
lossy handoff step — so the cheapest place to resolve it is here, with the user
in the loop, while you (Opus) are still the spec author. This runs **before**
`/handoff`; it interviews, then folds the answers into the plan. It does **not**
implement and does **not** touch code.

Argument (task slug or short description): `$ARGUMENTS`

## Escape hatch — skip this for trivial work

If you could describe the whole diff in **one sentence**, skip both `/clarify`
and `/handoff` and just make the change. This gate is for tasks with real
ambiguity — edge cases, scope boundaries, competing approaches. Don't over-apply
it to one-line fixes. Say so and stop if the task is that small.

## Steps

1. **Orient.** Read the active source plan in `~/.claude/plans/` (and any existing
   `docs/handoff/<slug>/PLAN.md` if this task is already drafted). `git status` /
   `git log --oneline -10` for current state. Identify what is genuinely
   under-specified versus already decided — only ask about the former.

2. **Interview with `AskUserQuestion`.** Ask only about the hard parts that change
   what gets built:
   - **Scope boundaries** — what's explicitly in vs. out of this task.
   - **Edge cases** — the inputs/states the happy path ignores.
   - **Tradeoffs** — competing approaches where the user's preference decides.
   Batch related questions; don't interrogate. Stop once the remaining unknowns
   are small enough for the implementer to resolve without guessing at design.

3. **Fold the answers into the plan.** Write the resolved decisions back into the
   source plan draft in `~/.claude/plans/<...>.md` — sharpen **Goal** and
   **Non-goals / scope**, and add a short **Clarifications (resolved)** section
   capturing each Q→A so the rationale survives into `PLAN.md` when `/handoff`
   copies the plan. You may write/append to the plan draft **only** — never edit
   code, and don't create the handoff package here (that's `/handoff`'s job).

4. **Hand off the baton.** Report the sharpened Goal/Non-goals and print the next
   step: `/handoff <slug>`. If a question surfaced something that makes the task
   bigger than one implementer context window, say so and suggest splitting it
   into parallel slugs.

## Guardrails

- **Interview, don't design in secret.** The user's answers drive the plan; you
  fold them in, you don't invent scope they didn't agree to.
- **No code, no package.** `/clarify` only enriches the plan draft. Implementation
  is `/implement`; the handoff files are `/handoff`.
- **Tool-agnostic.** This is an optional planning aid; the kit still works if you
  go straight to `/handoff`. Nothing downstream depends on `/clarify` having run.

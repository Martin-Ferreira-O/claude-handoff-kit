---
description: Interview the user on the hard parts of a task and fold the answers into the handoff PLAN.md (optional, runs after /plan)
argument-hint: <task-slug-or-description>
allowed-tools: AskUserQuestion, Read, Write, Edit, Bash(ls:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*)
---

# Clarify

Kill ambiguity before it gets baked into the spec the implementer reads. Every
unclear scope boundary or unstated tradeoff that survives into `PLAN.md` gets
amplified once an implementing agent runs with it — so the cheapest place to
resolve it is here, with the user in the loop, while you (Opus) are still the spec
author. `/clarify` runs **after `/plan`** (which already created the handoff
package): it interviews the user and **folds the answers directly into
`docs/handoff/<slug>/PLAN.md`**. It does **not** implement and does **not** touch
code — only the spec. Since Opus owns `PLAN.md`, editing it here is in-bounds.

Argument (task slug or short description): `$ARGUMENTS`

## Escape hatch — skip this for trivial work

If you could describe the whole diff in **one sentence**, skip `/clarify` (and the
whole handoff package) and just make the change. This gate is for tasks with real
ambiguity — edge cases, scope boundaries, competing approaches. Don't over-apply it
to one-line fixes. Say so and stop if the task is that small.

## Steps

1. **Orient.** Read the handoff package `/plan` produced — primarily
   `docs/handoff/<slug>/PLAN.md` (the spec) and `CONTEXT.md`. If the package doesn't
   exist yet, fall back to any agreed **source plan** draft (`~/.claude/plans/<slug>.md`,
   a repo draft like `docs/plans/<slug>.md`, or a path you were given) and note
   which — but the normal flow is that `/plan` ran first. `git status` /
   `git log --oneline -10` for current state. Identify what is genuinely
   under-specified versus already decided — only ask about the former.

2. **Interview with `AskUserQuestion`.** Ask only about the hard parts that change
   what gets built:
   - **Scope boundaries** — what's explicitly in vs. out of this task.
   - **Edge cases** — the inputs/states the happy path ignores.
   - **Tradeoffs** — competing approaches where the user's preference decides.
   Batch related questions; don't interrogate. Stop once the remaining unknowns are
   small enough for the implementer to resolve without guessing at design.

3. **Fold the answers into the spec.** Write the resolved decisions back into
   `docs/handoff/<slug>/PLAN.md` directly: sharpen **Goal** and **Non-goals /
   scope**, and add a short **Clarifications (resolved)** section capturing each Q→A
   so the rationale survives. Update `CONTEXT.md` too if an answer changes the
   orientation. You may edit the package spec **only** — never edit code. (If you
   fell back to a source-plan draft because no package exists yet, append there and
   tell the user to run `/plan` to materialize it.)

4. **Hand off the baton.** Report the sharpened Goal/Non-goals and print the next
   step: `/implement <slug>` (or `/resume <slug>` for a fresh session to rebuild
   context first). If a question surfaced something that makes the task bigger than
   one implementer context window, say so and suggest splitting it into parallel
   slugs.

## Guardrails

- **Interview, don't design in secret.** The user's answers drive the spec; you fold
  them in, you don't invent scope they didn't agree to.
- **No code.** `/clarify` only enriches the spec (`PLAN.md`/`CONTEXT.md`).
  Implementation is `/implement`.
- **Tool-agnostic.** This is an optional planning aid; the kit still works if you go
  straight from `/plan` to `/implement`. Nothing downstream depends on `/clarify`
  having run.

---
description: Route the current Django/Python diff to the right specialized reviewer (python / security / database) in a fresh context window
argument-hint: [--staged | <ref>]
allowed-tools: Read, Agent, Bash(git diff:*), Bash(git status:*), Bash(git log:*)
---

# Django review

Thin **wiring** between this kit's review gate and the specialized reviewer
subagents imported from ECC (`python-reviewer`, `security-reviewer`,
`database-reviewer`). It does **not** re-implement orchestration — `/dispatch`
already owns parallel fan-out. This command does one job: look at the current
diff, pick the reviewer that fits, and hand it **only the diff** in a clean
context window so the heavy review rules never pollute the caller's context.

Scope (optional): `$ARGUMENTS`
- empty → review the unstaged working tree (`git diff`)
- `--staged` → review staged changes (`git diff --cached`)
- `<ref>` → review against a ref (`git diff <ref>`)

## Why this saves tokens

- The reviewer runs as a **subagent** — its own context window. The diff plus
  the reviewer's rubric stay out of this session's context.
- The reviewers declare **`model: sonnet`**: mechanical review (PEP 8, type
  hints, injection scan) does not need Opus. Keep them on Sonnet.
- Domain skills load via **progressive disclosure** — `django-patterns` etc.
  only enter context if the reviewer actually activates them.

## Steps

1. **Collect the diff.** Run the `git diff` form selected by `$ARGUMENTS`. If the
   diff is empty, say so and stop.

2. **Route by file signal.** Inspect the changed paths/hunks and pick the
   reviewer (a diff can warrant more than one — run them in order, stop early if
   one blocks):
   - **`database-reviewer`** — migrations (`*/migrations/*.py`), `models.py`,
     raw SQL, schema/index changes, `QuerySet`/manager changes with query-shape
     impact.
   - **`security-reviewer`** — auth/permissions, `settings.py`, CSRF/CORS,
     anything touching user input, serializers/forms, `raw()`/`extra()`,
     secrets, file upload, API endpoints.
   - **`python-reviewer`** — everything else in `*.py` (style, typing, Pythonic
     idioms, complexity, error handling).

3. **Delegate in clean context.** Spawn the chosen reviewer **subagent** with
   **only the diff** (and the file list) — never this session's history. Use the
   same gap-focused framing the `/implement` gate uses:

   > Review this diff. Report correctness/security/quality issues at your
   > severity tiers. Report concrete gaps, not style preferences the project
   > didn't ask for. Pass only if no CRITICAL/HIGH issues remain.

4. **Report.** Summarize per reviewer: the severity findings and the pass/block
   decision. Do not apply fixes here — surface them so the implementer (or the
   `/implement` gate) decides.

## Relationship to the rest of the kit

- This is the **Django-aware reviewer** referenced by `/implement` step 9
  (fresh-context gate). When this layer is installed in a Django repo, the gate
  prefers these reviewers over a generic review subagent.
- For **parallel** work across slugs, `/dispatch` is still the orchestrator;
  this command is what each implementer runs before reporting a slug done.

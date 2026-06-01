---
description: Execute a docs/handoff/<slug>/ plan, updating PROGRESS.md and DECISIONS.md as you go
argument-hint: [task-slug]
allowed-tools: Read, Write, Edit, Bash
---

# Implement

Pick up a handoff package and **do the work**. Where `/resume` rebuilds context
and stops, `/implement` continues past the briefing: it executes `PLAN.md` step
by step, keeps `PROGRESS.md` honest, and surfaces anything that diverges from
the spec in `DECISIONS.md`. **You are the implementing agent**; `PLAN.md` is the
spec authored by Opus — implement against it and do not silently diverge.

Target handoff (optional slug): `$ARGUMENTS`

## Steps

1. **Locate the handoff.**
   - If `$ARGUMENTS` names a slug, use `docs/handoff/<slug>/`.
   - If empty, `ls -t docs/handoff/*/PROGRESS.md` and pick the folder whose
     `PROGRESS.md` was modified most recently. State which one you chose and why.
     (Archived slugs under `docs/handoff/_archive/<slug>/` are one level deeper
     than this glob, so they're excluded automatically — see `/archive`.)
   - If `docs/handoff/` is empty or missing, say so and stop.

2. **Load the spec.** Read all four files in order: CONTEXT.md → PLAN.md →
   PROGRESS.md → DECISIONS.md. Open the **Read first** files from CONTEXT.md
   before touching anything.

3. **Reconcile with the repo, and check the package against itself.** Run
   `git status`, `git log --oneline -10`, and `git diff --stat` to find work done
   since PROGRESS.md was last updated and any **spec-vs-tree** drift. Then run the
   tiny **cross-artifact consistency check**: flag PROGRESS checkboxes that don't
   match PLAN steps, DECISIONS that contradict PLAN, and a provenance SHA far
   behind `HEAD`. Also check the derived **`.verify`** artifact: it is a single-line
   projection of the PLAN **Verification** block (see `docs/hooks.md`). If the
   PLAN's Verification is one runnable command and `.verify` is missing or no longer
   matches it, regenerate `.verify` from the PLAN (PLAN is the source of truth; never
   edit PLAN to match `.verify`). If Verification is multi-command, `.verify` should
   stay absent — don't invent a format. If the spec is already fully done, say so and
   stop; if the package is internally inconsistent, surface it before implementing on
   a bad map.

4. **Check for blockers first.** If `DECISIONS.md` has unresolved *Open questions
   for the spec author* that block the next step, surface them and stop — do not
   guess past a blocker the author flagged. Run `date "+%Y-%m-%d %H:%M"` once for
   accurate timestamps.

5. **Implement the next unchecked PLAN step.** Work in PLAN order, one step at a
   time:
   - Make the change following the **Conventions that matter here** in CONTEXT.md
     (service layer, UUID PKs, Spanish user-facing text, CLP integers, `.venv/bin/python`, etc.).
   - Run the **Setup / run / test** commands from CONTEXT.md to verify the step.
     Report failures with the real output — never claim a step passed unverified.
   - **After every meaningful change, update `PROGRESS.md`**: flip the checkbox
     (`- [x]` done, `🚧` in progress, `⛔` blocked) and prepend a work-log line
     `YYYY-MM-DD HH:MM — <your agent name> — what changed`.

6. **Commit each completed step.** Once a PLAN step (or subtask) is verified and
   its PROGRESS/DECISIONS updates are written, commit the code **and** the doc
   updates together as one atomic commit. Only commit a step that passed its
   checks — never commit a `🚧`/`⛔` step.
   - **Branch safety net (idempotent).** The task branch is normally created at
     the *start* of the cycle by `/plan` (one branch per slug). This step only
     catches the case where it wasn't: if you're already on the slug's branch
     (or a prefixed variant like `feat/<slug>`), do **nothing**; if you're on the
     default branch (`main`/`master`), create it now (`git checkout -b <slug>`).
     Never create a second branch when one for this slug already exists.
   - Stage just what this step touched, then commit with a message tied to the
     step:

     ```
     <slug>: <plan step summary>

     PLAN step <n>. <one line on what changed / how verified>

     Co-Authored-By: <your implementer identity>
     ```
   - **Sign the commit with your own implementer identity** — do not copy a fixed
     `Co-Authored-By`. The author of the spec (Opus) is not who implements it.
     - On Claude, use the model running this session (e.g. the current Sonnet/Opus
       model, not a hardcoded "Opus 4.8"): `Co-Authored-By: Claude <model> <noreply@anthropic.com>`.
     - On Codex or another agent, use its own attribution — or omit the
       `Co-Authored-By` line entirely if no co-author applies.
   - Keep the rest of the template (`<slug>: <summary>` subject and `PLAN step <n>. …`
     body) intact — that format keeps the history legible.
   - Do **not** push — pushing stays manual unless the user asks.

7. **Record deviations as they happen.** Before continuing past any deviation
   from `PLAN.md`, decision, or blocker, append it to `DECISIONS.md` so the spec
   author can review. Put anything that needs Opus's input under *Open questions
   for the spec author*. Do not rewrite `PLAN.md` — it is read-mostly.

8. **Update the registry.** Edit the handoff's **row** in `docs/handoff/INDEX.md`
   (the `## Handoffs` table) to reflect the new `status` and `updated` date —
   flip `status` to `in-progress` while steps remain, or `done` once the plan is
   fully implemented and verified; refresh the `note`. Update the existing row,
   don't append a duplicate. This update rides along with the next step's commit
   (or a final bookkeeping commit if there are no more steps). Once the slug is
   `done`, retiring it from the active area is an **optional, explicit**
   follow-up: `/archive <slug>` moves the package into `docs/handoff/_archive/`
   so it stops competing in the "most recently touched" heuristic. Don't archive
   automatically here — leave it to the user.

9. **Review against the spec (fresh-context gate).** Before reporting done — once
   the PLAN steps you set out to finish are committed — run an adversarial review.
   The guarantee that matters is **truly fresh context**: the reviewer must see
   **only the diff and `PLAN.md`**, not your implementation session, so it can't
   inherit the assumptions you made while writing the code. The gate is mandatory;
   the mechanism is per-tool:
   - **Preferred — a dedicated reviewer in clean context.** Hand a fresh agent
     **only the diff + `PLAN.md`** and nothing else. On Claude, spawn a review
     **subagent** (clean context window); on Codex or another agent, start a clean
     session seeded with just those two inputs. This is the real fresh-context
     gate — use it whenever a subagent/clean session is available.
     - **Django repos with the optional Django layer installed** (the
       `handoff-kit-django` plugin / `--with-django` install — its
       `python-reviewer`, `security-reviewer`, `database-reviewer` subagents are
       available): prefer the **specialized reviewer** that fits the diff over a
       generic one — migrations/`models.py`/schema → `database-reviewer`;
       auth/`settings.py`/user input/serializers → `security-reviewer`; other
       `*.py` → `python-reviewer` (or run `/django-review`, which does this
       routing). These run on `model: sonnet`, so the gate stays cheap.
   - **Fallback — `/code-review` in the same session.** Running the bundled
     `/code-review` skill inline is the **lower-guarantee** path: it reuses the
     current session, which already carries the implementer's context, so it's
     only acceptable when no subagent/clean session is available.

   Prompt shape (identical either way):

   > Review this diff **against `PLAN.md`**. Verify every requirement is
   > implemented and the **Verification** command(s) in PLAN actually pass.
   > **Report gaps against the spec, not style preferences** — do not suggest
   > scope the plan didn't ask for.

   The "report gaps, not style" framing is deliberate: a gap-hungry reviewer
   otherwise drives over-engineering past the spec. Record the outcome as a
   PROGRESS work-log line, **tagging which mechanism ran** so the guarantee is
   auditable: `… — review (fresh) against PLAN: <pass / N gaps>` for a clean
   subagent/session, or `… — review (in-session) against PLAN: <pass / N gaps>`
   for the `/code-review` fallback. If the review finds a real gap in committed
   work, fix it as its own verified+committed step; if it surfaces something the
   spec itself got wrong, log it under *Open questions for the spec author* in
   DECISIONS.md rather than redesigning.

10. **Report.** Summarize:
   - **Done this session**: steps completed, with verification result and the
     commit hash for each.
   - **Review**: the spec-review outcome from step 9 (pass, or the gaps found).
   - **Still pending**: the next unchecked PLAN step.
   - **Decisions / open questions**: anything added to DECISIONS.md the author
     should review.
   - **Drift**: any mismatch found in step 3.

   Pushing stays manual — only push if the user asks.

## Guardrails

- The plan is the contract. If a step is wrong, ambiguous, or impossible, stop
  and record it in `DECISIONS.md` rather than improvising a different design.
- Keep `PROGRESS.md` and the repo in sync — an implementer that finishes code
  but leaves PROGRESS stale breaks the next handoff.
- Match the surrounding code's conventions; don't introduce new patterns the
  spec didn't ask for.
- One commit per verified step keeps history bisectable and makes a partial
  handoff resumable. Don't batch several steps into one commit, and don't commit
  a step whose checks didn't pass.

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
   - If `docs/handoff/` is empty or missing, say so and stop.

2. **Load the spec.** Read all four files in order: CONTEXT.md → PLAN.md →
   PROGRESS.md → DECISIONS.md. Open the **Read first** files from CONTEXT.md
   before touching anything.

3. **Reconcile with the repo, and check the package against itself.** Run
   `git status`, `git log --oneline -10`, and `git diff --stat` to find work done
   since PROGRESS.md was last updated and any **spec-vs-tree** drift. Then run the
   tiny **cross-artifact consistency check**: flag PROGRESS checkboxes that don't
   match PLAN steps, DECISIONS that contradict PLAN, and a provenance SHA far
   behind `HEAD`. If the spec is already fully done, say so and stop; if the
   package is internally inconsistent, surface it before implementing on a bad map.

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
   - First branch if you're on the default branch (`main`/`master`); otherwise
     stay on the current task branch.
   - Stage just what this step touched, then commit with a message tied to the
     step:

     ```
     <slug>: <plan step summary>

     PLAN step <n>. <one line on what changed / how verified>

     Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
     ```
   - Do **not** push — pushing stays manual unless the user asks.

7. **Record deviations as they happen.** Before continuing past any deviation
   from `PLAN.md`, decision, or blocker, append it to `DECISIONS.md` so the spec
   author can review. Put anything that needs Opus's input under *Open questions
   for the spec author*. Do not rewrite `PLAN.md` — it is read-mostly.

8. **Update the registry.** Edit the handoff's line in `docs/handoff/INDEX.md`
   to reflect the new status and date — update the existing line, don't append a
   duplicate. This update rides along with the next step's commit (or a final
   bookkeeping commit if there are no more steps).

9. **Review against the spec (fresh-context gate).** Before reporting done — once
   the PLAN steps you set out to finish are committed — run an adversarial review
   in a fresh context that sees only the diff and `PLAN.md`. Use the bundled
   `/code-review` skill or spawn a subagent with this prompt shape:

   > Review this diff **against `PLAN.md`**. Verify every requirement is
   > implemented and the **Verification** command(s) in PLAN actually pass.
   > **Report gaps against the spec, not style preferences** — do not suggest
   > scope the plan didn't ask for.

   The "report gaps, not style" framing is deliberate: a gap-hungry reviewer
   otherwise drives over-engineering past the spec. Record the outcome as a
   PROGRESS work-log line (`… — review against PLAN: <pass / N gaps>`). If the
   review finds a real gap in committed work, fix it as its own verified+committed
   step; if it surfaces something the spec itself got wrong, log it under
   *Open questions for the spec author* in DECISIONS.md rather than redesigning.

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

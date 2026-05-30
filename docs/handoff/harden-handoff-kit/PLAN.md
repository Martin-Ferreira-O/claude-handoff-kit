> Handoff doc for task `harden-handoff-kit`. Author: Claude Opus 4.8. Updated: 2026-05-29 21:58.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.
> Spec written against commit `857801a`.

# PLAN — harden-handoff-kit

## Goal
Harden the kit's commands so handoffs leak less: make specs source-anchored and
verifiable, add a clarify gate, wire a fresh-context review into `/implement`,
close the planner↔implementer loop, and add an optional Claude-side enforcement
layer. The kit stays lean and cross-tool.

## Non-goals / scope
- **No rebuild.** Do not replace the four-file model or adopt Spec Kit/Kiro/BMAD.
- **No mandatory Claude-only machinery in the core.** Hooks are opt-in and
  separate; Codex must still drive the kit with the Markdown alone.
- Do not over-apply: trivial one-sentence diffs should skip the whole flow.
- No changes to unrelated repo conventions.

## Source plan
`~/.claude/plans/ultrathink-please-review-this-playful-clover.md` (approved).
That file holds the full verdict, the "better alternatives" comparison, and all
research source links. This PLAN is the executable subset.

## Ordered steps
Each step is independently committable. Steps 1–4 are the portable core; step 5
is the optional layer; step 6 is bookkeeping.

1. **Source-anchored, self-contained specs** — edit `.claude/commands/handoff.md`
   and `AGENTS.md`:
   - Replace PLAN template's prose *Acceptance criteria* with a mandatory
     **Verification** section: exact copy-pasteable command(s) + the observable
     pass signal.
   - Add a 4th banner line carrying **provenance**: planner model, source-plan
     path, and the commit SHA the spec was written against. (See the banner in
     this very handoff for the target shape.)
   - In the CONTEXT template, instruct the implementer to **open the Read-first
     files and confirm they still match** before trusting any summary.

2. **Clarify gate** — create `.claude/commands/clarify.md`:
   - Frontmatter: `description`, `argument-hint: <task-slug-or-description>`,
     `allowed-tools` (read-mostly + AskUserQuestion-style interview; no Write to
     code, may write/append to the PLAN draft only).
   - Opus interviews the user on hard parts (edge cases, scope boundaries,
     tradeoffs) and folds answers into the PLAN's Goal/Non-goals **before**
     `/handoff` runs.
   - Document the escape hatch: if the change fits one sentence, skip clarify and
     handoff entirely.
   - Add `/clarify` to the cycle in `CLAUDE.md` (before `/handoff`).

3. **Fresh-context review gate** — edit `.claude/commands/implement.md` and
   `CLAUDE.md`:
   - Add a completion step before the final "Report": run a reviewer (the bundled
     `/code-review` skill or a subagent) **against PLAN.md**, prompt shape
     "verify every requirement is implemented and the Verification command
     passes; **report gaps, not style preferences**."
   - Record the review outcome as a PROGRESS work-log line.

4. **Close the planner↔implementer loop** — edit `.claude/commands/resume.md` and
   `AGENTS.md`:
   - Add a `/resume` step: when open *DECISIONS questions for the spec author*
     exist, surface them as a **decision queue** and note resolving them is an
     Opus job (implementer must not).
   - Add a tiny **cross-artifact consistency check** to the reconcile step of
     `/resume` and `/implement`: flag PROGRESS checkboxes that don't match PLAN
     steps, or DECISIONS that contradict PLAN.

5. **Optional enforcement layer** — create `docs/hooks.md` + a `hooks/` dir and a
   `.claude/settings.json` example, flagged "Claude-only, optional":
   - **PROGRESS-sync pre-commit hook**: block a commit touching the slug's code
     without touching that slug's `PROGRESS.md` in the same commit.
   - **Stop-hook verification gate** (optional): run the PLAN Verification command
     and block turn-end until it passes.
   - Document clearly that the kit works fully without this layer.

6. **Bookkeeping** — minor docs: slug-sizing rule in `CLAUDE.md` (scope a slug to
   one implementer context window; split big plans into parallel slugs), and a
   one-line note that `implement.md`'s broad `allowed-tools: Bash` is the one
   intentional broad grant. Update `docs/handoff/INDEX.md`.

## Acceptance criteria
- [ ] handoff.md PLAN template ends with a runnable **Verification** block; banner
      has a provenance/SHA line.
- [ ] `/clarify` exists with valid frontmatter and appears in the CLAUDE.md cycle.
- [ ] `/implement` runs a review-against-PLAN gate before reporting done.
- [ ] `/resume` surfaces open DECISIONS questions as an Opus decision queue and
      flags PLAN↔PROGRESS internal drift.
- [ ] `docs/hooks.md` + example settings exist, clearly marked optional/Claude-only.
- [ ] Core commands still contain no mandatory Claude-only step (Codex-drivable).

## Verification (end-to-end, dogfood)
Run on a throwaway slug in a fresh session:
1. `/clarify test-slug` → confirm it interviews and writes answers into a PLAN draft.
2. `/handoff test-slug` → open the generated PLAN.md; confirm a runnable
   **Verification** block and a provenance/SHA banner line are present.
3. `/resume test-slug` after seeding a fake DECISIONS open question and an
   intentionally mismatched PROGRESS checkbox → confirm both the decision queue
   and the internal-drift flag fire.
4. `/implement test-slug` → confirm the review-against-PLAN gate runs before the
   final report and writes a PROGRESS line.
5. If the hook layer is enabled per `docs/hooks.md`: a code-only commit with
   stale PROGRESS is blocked; a failing Verification command blocks turn-end.
Pass signal: every box above is observed; no core command required Claude-only
machinery to function.

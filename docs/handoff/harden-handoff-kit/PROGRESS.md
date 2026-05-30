> Handoff doc for task `harden-handoff-kit`. Author: Claude Opus 4.8. Updated: 2026-05-29 21:58.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.

# PROGRESS — harden-handoff-kit

## Checklist (mirrors PLAN steps)
- [x] 1. Source-anchored, self-contained specs (handoff.md + AGENTS.md)
- [x] 2. Clarify gate (new clarify.md + CLAUDE.md cycle)
- [x] 3. Fresh-context review gate (implement.md + CLAUDE.md)
- [x] 4. Close planner↔implementer loop (resume.md + AGENTS.md; implement.md reconcile per step body)
- [x] 5. Optional enforcement layer (docs/hooks.md + hooks/ + settings example)
- [ ] 6. Bookkeeping (slug-sizing note, allowed-tools note, INDEX.md)

## Work log (reverse-chronological)
- 2026-05-29 22:08 — Claude Opus 4.8 (implementer) — Step 5 done. Created `hooks/progress-sync.sh` (PreToolUse/Bash: blocks a git commit staging code but no docs/handoff/<slug>/PROGRESS.md, exit 2), `hooks/verify-gate.sh` (Stop: runs the slug's single-command `.verify` and blocks turn-end on failure; inactive when no .verify exists), `.claude/settings.json.example` (opt-in wiring, not the live file), and `docs/hooks.md` (clearly marks the whole layer Claude-only/optional; documents the single-command assumption + ask-the-author escape). Verified: bash -n clean on both, JSON valid, chmod +x; functional test in a throwaway repo — code-only commit → exit 2 (blocked), code+PROGRESS → exit 0, non-commit → exit 0.
- 2026-05-29 22:05 — Claude Opus 4.8 (implementer) — Step 4 done. resume.md: reconcile step now also runs a cross-artifact consistency check (PROGRESS↔PLAN checkboxes, DECISIONS↔PLAN contradictions, provenance SHA vs HEAD), new step 4 surfaces open DECISIONS questions as a decision queue owned by Opus (implementer must not resolve), renumbered to 1–5. implement.md: same consistency check folded into reconcile step 3 (per the PLAN step *body*, which names /resume and /implement, though the header listed only resume.md+AGENTS.md — logged in DECISIONS). AGENTS.md: added "back-channel is a loop" + "keep the four files consistent" to the contract. Verified by inspection: markers present in all three files, resume.md numbered 1–5.
- 2026-05-29 22:04 — Claude Opus 4.8 (implementer) — Step 3 done. implement.md: inserted step 9 "Review against the spec (fresh-context gate)" before Report — runs /code-review or a subagent against PLAN.md ("every requirement implemented + Verification passes; report gaps, not style"), records outcome as a PROGRESS line, routes real gaps to a fix-commit and spec gaps to DECISIONS; renumbered Report to step 10 with a Review summary bullet. CLAUDE.md: added the gate to the /implement cycle bullet. Verified by inspection: steps numbered 1–10 cleanly, markers present in both files.
- 2026-05-29 22:03 — Claude Opus 4.8 (implementer) — Step 2 done. Created `.claude/commands/clarify.md`: AskUserQuestion interview on scope/edge-cases/tradeoffs, folds answers into the source plan's Goal/Non-goals + a "Clarifications (resolved)" section before /handoff; documents the one-sentence escape hatch; no code/package writes. Added `/clarify` to the cycle in CLAUDE.md (before /handoff) marked optional. Verified by inspection: 3 frontmatter keys present, cycle line updated.
- 2026-05-29 22:01 — Claude Opus 4.8 (implementer) — Step 1 done. handoff.md: added 4th provenance banner line (planner model + SHA + source plan), CONTEXT template "open Read-first files & confirm they match" instruction, and replaced PLAN's prose *Acceptance criteria* with a mandatory copy-pasteable **Verification** block. AGENTS.md: added "Re-derive, don't just recall" + "PLAN ends with a runnable Verification block" to the contract. Verified by inspection (grep markers + frontmatter intact); Markdown-only repo, no test suite.
- 2026-05-29 21:58 — Claude Opus 4.8 (planner) — Created handoff package from approved plan `ultrathink-please-review-this-playful-clover.md`. Nothing implemented yet; all six steps pending. Spec written against `857801a`, branch `harden-handoff-kit`, clean tree.

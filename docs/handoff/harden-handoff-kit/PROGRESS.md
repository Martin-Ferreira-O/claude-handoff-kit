> Handoff doc for task `harden-handoff-kit`. Author: Claude Opus 4.8. Updated: 2026-05-29 21:58.
> IMPLEMENTING AGENT: read CONTEXT.md → PLAN.md → PROGRESS.md → DECISIONS.md before starting.
> Update PROGRESS.md after every meaningful change, and record any deviation from PLAN.md in DECISIONS.md.

# PROGRESS — harden-handoff-kit

## Checklist (mirrors PLAN steps)
- [x] 1. Source-anchored, self-contained specs (handoff.md + AGENTS.md)
- [ ] 2. Clarify gate (new clarify.md + CLAUDE.md cycle)
- [ ] 3. Fresh-context review gate (implement.md + CLAUDE.md)
- [ ] 4. Close planner↔implementer loop (resume.md + AGENTS.md)
- [ ] 5. Optional enforcement layer (docs/hooks.md + hooks/ + settings example)
- [ ] 6. Bookkeeping (slug-sizing note, allowed-tools note, INDEX.md)

## Work log (reverse-chronological)
- 2026-05-29 22:01 — Claude Opus 4.8 (implementer) — Step 1 done. handoff.md: added 4th provenance banner line (planner model + SHA + source plan), CONTEXT template "open Read-first files & confirm they match" instruction, and replaced PLAN's prose *Acceptance criteria* with a mandatory copy-pasteable **Verification** block. AGENTS.md: added "Re-derive, don't just recall" + "PLAN ends with a runnable Verification block" to the contract. Verified by inspection (grep markers + frontmatter intact); Markdown-only repo, no test suite.
- 2026-05-29 21:58 — Claude Opus 4.8 (planner) — Created handoff package from approved plan `ultrathink-please-review-this-playful-clover.md`. Nothing implemented yet; all six steps pending. Spec written against `857801a`, branch `harden-handoff-kit`, clean tree.

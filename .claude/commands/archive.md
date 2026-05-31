---
description: Move a done slug's handoff package into docs/handoff/_archive/ and mark its INDEX row archived
argument-hint: <task-slug>
allowed-tools: Read, Edit, Bash(ls:*), Bash(mkdir:*), Bash(git mv:*), Bash(git status:*), Bash(date:*)
---

# Archive

Retire a **finished** slug from the active handoff area. A `done` slug left in
`docs/handoff/<slug>/` keeps competing with live work in the "most recently
touched" heuristic (`ls -t docs/handoff/*/PROGRESS.md`, used by `/resume`,
`/implement`, and the Stop hook) and bloats `INDEX.md`. Archiving moves its
package one level deeper, into `docs/handoff/_archive/<slug>/`, where that glob
no longer reaches it — **without deleting anything**: the history stays.

Archival is **manual and explicit** by design — never automatic — so a closed
slug is only retired when you say so.

Target slug: `$ARGUMENTS`

## Steps

1. **Resolve the slug.** `$ARGUMENTS` must name an existing
   `docs/handoff/<slug>/` folder. If it's empty, or the folder doesn't exist, or
   it's already under `docs/handoff/_archive/`, say so and stop.

2. **Require it to be `done`.** Read the slug's **row** in
   `docs/handoff/INDEX.md`. Archive only a slug whose `status` is `done` — a
   `todo`/`in-progress`/`blocked` slug is still live work. If it isn't `done`,
   refuse and stop (the user can finish it via `/implement` first). Cross-check
   `PROGRESS.md`: if the registry says `done` but PROGRESS still shows unchecked
   steps, surface the drift and stop rather than archiving an inconsistent slug.

3. **Move the package, preserving history.** Create the archive dir if needed and
   `git mv` the folder so the move is tracked (not a delete + re-add):
   ```sh
   mkdir -p docs/handoff/_archive
   git mv docs/handoff/<slug> docs/handoff/_archive/<slug>
   ```
   The four files (and `.verify`, if present) ride along untouched.

4. **Mark the INDEX row archived.** Run `date "+%Y-%m-%d"`, then update the
   slug's existing row in the `## Handoffs` table: keep `status` as `done` (so
   `awk`/`grep` parsers and `/dispatch`'s dependency check still read it as a
   satisfied dependency), refresh `updated`, and prefix the `note` with
   `archived` so it reads as **done (archived)** to a human — e.g.
   `archived — 6/6 steps implemented & committed`. Update the existing row; never
   append a duplicate, and never drop the row (the record is the point).

5. **Report.** Print the new path (`docs/handoff/_archive/<slug>/`), confirm the
   INDEX row now reads archived, and note that `ls -t docs/handoff/*/PROGRESS.md`
   no longer lists this slug — so it stops competing with active slugs in
   `/resume`, `/implement`, and the Stop hook.

## Guardrails

- **Never delete.** Archiving moves; it does not remove. The handoff history is
  valuable — keep it under `docs/handoff/_archive/`.
- **`done` only.** Don't archive live work; finish or block it first.
- **Don't break the heuristic glob.** `_archive/` is deliberately one level
  deeper than the `docs/handoff/*/PROGRESS.md` glob reaches, so archived slugs
  fall out of it automatically. Don't flatten archived packages back up into
  `docs/handoff/`.

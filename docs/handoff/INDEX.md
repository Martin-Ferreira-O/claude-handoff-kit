# Handoff Index

Registry of all handoffs, one **row per slug**. Update the existing row; never
append a duplicate. The table is both human-readable and machine-parseable
(`awk -F'|'` / `grep`) so orchestration can decide which slug is ready to run.

## Schema

`| slug | status | depends-on | updated | note |`

- **slug** — the handoff folder name under `docs/handoff/`, kebab-case.
- **status** — one of `todo`, `in-progress`, `blocked`, `done`.
- **depends-on** — comma-separated slugs that must be `done` first, or `—`.
- **updated** — `YYYY-MM-DD` of the last change to the row.
- **note** — short free-text status for humans (step count, blocker, etc.).

## Handoffs

| slug | status | depends-on | updated | note |
|---|---|---|---|---|
| harden-handoff-kit | done | — | 2026-05-29 | 6/6 steps implemented & committed |

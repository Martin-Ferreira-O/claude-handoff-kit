---
description: Seed the handoff contract (AGENTS.md), the registry (docs/handoff/INDEX.md), and the optional hooks into the current project — idempotent
argument-hint: "(no args)"
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash(ls:*), Bash(test:*), Bash(cat:*), Bash(grep:*), Bash(mkdir:*), Bash(git status:*)
---

# Handoff init

Bootstrap the **current project** so the handoff cycle works here: drop the shared
contract into `AGENTS.md`, create the `docs/handoff/INDEX.md` registry, optionally
fold the agent-workflow block into `CLAUDE.md`, and surface how to enable the
optional hooks. **Everything here is idempotent** — re-running never duplicates a
block. Run this once after installing the kit (plugin or `install.sh`), and again
any time you want to re-seed an updated contract.

You are operating on the project rooted at the current working directory. Do **not**
write outside it.

## Steps

1. **Locate the kit's templates.** Find the directory that holds
   `templates/AGENTS.handoff.md`, in this order:
   - `"$CLAUDE_PLUGIN_ROOT"/templates/` — set when the kit runs as a plugin.
   - a `templates/` dir alongside this command's kit (e.g. the cloned repo root).

   Resolve it with:
   ```sh
   for d in "$CLAUDE_PLUGIN_ROOT" "$CLAUDE_PLUGIN_ROOT/.." .; do
     test -f "$d/templates/AGENTS.handoff.md" && echo "KIT=$d" && break
   done
   ```
   If none is found, tell the user the templates can't be located (they may have
   copied the commands without the `templates/` dir) and stop — do not invent the
   contract text.

2. **Seed/refresh `AGENTS.md`.** The canonical block is delimited by
   `<!-- handoff-kit:start -->` … `<!-- handoff-kit:end -->` markers in
   `$KIT/templates/AGENTS.handoff.md`.
   - If `AGENTS.md` is **absent**: create it with a `# Repository Guidelines`
     heading followed by the template block.
   - If `AGENTS.md` exists but contains **no** `handoff-kit:start` marker: append
     the template block (separated by a blank line). Leave the user's existing
     content untouched and first.
   - If `AGENTS.md` already has the marked block: replace **only** the text
     between the markers with the current template (so an updated contract lands),
     and report it as "refreshed". If it's byte-identical, report "unchanged".

3. **Create the registry.** If `docs/handoff/INDEX.md` is missing, `mkdir -p
   docs/handoff` and copy `$KIT/templates/INDEX.md` into it. If it already exists,
   leave it alone.

4. **Offer the `CLAUDE.md` workflow block (ask first).** Use `AskUserQuestion` to
   ask whether to fold the agent-workflow block from `$KIT/templates/CLAUDE.handoff.md`
   into the project's `CLAUDE.md`. Only proceed if the user says yes. Merge it with
   the **same marker logic** as step 2 (create / append / refresh between markers),
   always keeping the project's own domain rules first. Skipping is fine — the
   commands work without it.

5. **Hooks (report, don't force).** The hooks are **opt-in** and inert until you
   wire them.
   - If `$CLAUDE_PLUGIN_ROOT` is set, the plugin already wires
     `hooks/hooks.json`; tell the user they're active-but-inert (progress-sync only
     fires on commits that stage code; verify-gate only when a
     `docs/handoff/<slug>/.verify` exists) and how to disable via `/plugin`.
   - Otherwise (copied via `install.sh`), point them at
     `.claude/settings.json.example` + `docs/hooks.md` and remind them to
     `chmod +x hooks/*.sh`.

6. **Report.** Summarize what was created / appended / refreshed / skipped (one
   line each), then the next step: `/plan <task>` to start the cycle, or for a
   one-sentence change, implement directly. Mention that the registry is empty and
   the first `/handoff` will seed a row.

## Notes

- Never clobber a user's existing `AGENTS.md` / `CLAUDE.md` content — only the text
  between the `handoff-kit` markers is owned by this command.
- The markers are how re-runs stay idempotent. If a user hand-edits inside them,
  a re-run overwrites those edits — edit the kit's `templates/` instead.
- This command does not commit. Review with `git status` / `git diff` and commit
  the seeded files yourself.

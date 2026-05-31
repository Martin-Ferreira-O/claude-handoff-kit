#!/usr/bin/env bash
# PROGRESS-sync commit guard — Claude-only, OPTIONAL. See docs/hooks.md.
#
# Wired as a PreToolUse hook on Bash, this blocks a `git commit` that stages code
# changes without also staging a docs/handoff/<slug>/PROGRESS.md in the same
# commit — deterministically enforcing the kit's "code + PROGRESS in one atomic
# commit" rule, which advisory prompt text alone lets context rot erode. Codex
# users (or anyone who doesn't install the hook) are completely unaffected; the
# Markdown rule still governs them.
set -euo pipefail

# PreToolUse feeds the tool call as JSON on stdin; pull out the Bash command.
input=$(cat)
cmd=$(printf '%s' "$input" | python3 -c \
  'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' \
  2>/dev/null || true)

# Only police git commits — everything else passes straight through.
case "$cmd" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

staged=$(git diff --cached --name-only 2>/dev/null || true)
[ -z "$staged" ] && exit 0   # nothing staged; let git itself handle the no-op

# "code" = any staged path that is neither a handoff doc nor pure documentation.
# Pure docs = anything under docs/ (plans, hooks.md, the handoff folder itself, …)
# or a root-level *.md (README.md, CLAUDE.md, AGENTS.md). Editing only those is
# bookkeeping, not implementation, so it must not demand a PROGRESS update — the
# old "anything outside docs/handoff/ is code" rule flagged this repo's own
# doc-only commits as false positives.
code_changed=$(printf '%s\n' "$staged" | grep -v -E '^docs/|^[^/]+\.md$' || true)
progress_changed=$(printf '%s\n' "$staged" | grep -E '^docs/handoff/[^/]+/PROGRESS\.md$' || true)

# Docs-only commit — never gated.
[ -z "$code_changed" ] && exit 0

# Code staged but no PROGRESS at all — block (preserves original behavior).
if [ -z "$progress_changed" ]; then
  {
    echo "PROGRESS-sync hook: this commit stages code but no docs/handoff/<slug>/PROGRESS.md."
    echo "Update the slug's PROGRESS.md (flip the checkbox + add a work-log line) and"
    echo "stage it in the same commit, then retry."
  } >&2
  exit 2   # exit 2 on PreToolUse blocks the call; stderr is shown to Claude
fi

# Stricter, branch-aware check: if the current branch names a slug (`<slug>` or
# `*/<slug>`, same resolution as verify-gate.sh), the staged PROGRESS must be
# *that* slug's. Staging slug-b's PROGRESS while committing slug-a's code is the
# same bookkeeping gap this guard exists to catch. If the branch matches no slug,
# accept any staged PROGRESS — no extra friction outside the one-branch-per-slug
# flow.
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
slug=${branch##*/}
if [ -n "$slug" ] && [ -d "docs/handoff/$slug" ]; then
  if ! printf '%s\n' "$progress_changed" | grep -qx "docs/handoff/$slug/PROGRESS.md"; then
    {
      echo "PROGRESS-sync hook: on branch '$branch' (slug '$slug') but the staged"
      echo "PROGRESS.md belongs to a different slug. Stage docs/handoff/$slug/PROGRESS.md"
      echo "(the slug of the branch you're on) in this commit, then retry."
    } >&2
    exit 2
  fi
fi
exit 0

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

# "code" = any staged path that is not itself a handoff doc.
code_changed=$(printf '%s\n' "$staged" | grep -v '^docs/handoff/' || true)
progress_changed=$(printf '%s\n' "$staged" | grep -E '^docs/handoff/[^/]+/PROGRESS\.md$' || true)

if [ -n "$code_changed" ] && [ -z "$progress_changed" ]; then
  {
    echo "PROGRESS-sync hook: this commit stages code but no docs/handoff/<slug>/PROGRESS.md."
    echo "Update the slug's PROGRESS.md (flip the checkbox + add a work-log line) and"
    echo "stage it in the same commit, then retry."
  } >&2
  exit 2   # exit 2 on PreToolUse blocks the call; stderr is shown to Claude
fi
exit 0

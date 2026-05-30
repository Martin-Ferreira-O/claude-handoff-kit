#!/usr/bin/env bash
# Stop-hook verification gate — Claude-only, OPTIONAL and OFF unless you wire it.
# See docs/hooks.md.
#
# Runs the active slug's PLAN Verification command and blocks turn-end until it
# passes — turning "verify before you check a step off" from an advisory rule
# into an enforced one for Claude sessions. Codex is governed by the Markdown
# rule as before.
#
# ASSUMES A SINGLE SHELL COMMAND. Put it on the first line of
# docs/handoff/<slug>/.verify (this is the exact command from the PLAN
# **Verification** block). If your Verification needs several commands, wrap them
# in a script and point .verify at it — or, per DECISIONS guidance, pause and ask
# the spec author how to express the pass signal rather than inventing a format.
# The gate is inactive (exit 0) whenever no .verify file exists, so this repo —
# which has no test suite — is unaffected until someone opts in.
set -euo pipefail

# Active slug = most recently touched PROGRESS.md (same heuristic /implement and
# /resume use to locate the current handoff).
latest=$(ls -t docs/handoff/*/PROGRESS.md 2>/dev/null | head -1 || true)
[ -z "$latest" ] && exit 0                 # no handoff in play — gate inactive
slug_dir=$(dirname "$latest")
verify_file="$slug_dir/.verify"
[ -f "$verify_file" ] || exit 0            # no command configured — gate inactive

verify_cmd=$(head -1 "$verify_file")
[ -z "$verify_cmd" ] && exit 0

log=$(mktemp)
if ! eval "$verify_cmd" >"$log" 2>&1; then
  {
    echo "Stop-gate: PLAN Verification failed for $slug_dir — not done yet."
    echo "  \$ $verify_cmd"
    echo "--- last 20 lines ---"
    tail -20 "$log"
  } >&2
  rm -f "$log"
  exit 2   # exit 2 on a Stop hook blocks turn-end and feeds stderr back to Claude
fi
rm -f "$log"
exit 0

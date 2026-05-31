#!/usr/bin/env bash
# Stop-hook verification gate — Claude-only, OPTIONAL and OFF unless you wire it.
# See docs/hooks.md.
#
# Runs the active slug's PLAN Verification command and blocks turn-end until it
# passes — turning "verify before you check a step off" from an advisory rule
# into an enforced one for Claude sessions. Codex is governed by the Markdown
# rule as before.
#
# SLUG RESOLUTION IS BRANCH-AWARE. The active slug is the one named by the
# current branch (`<slug>` or any `*/<slug>`), which aligns with the kit's
# "one branch per slug" model and makes parallel worktrees safe: each worktree
# sits on its own branch and validates only its own slug. If the branch matches
# no handoff, it falls back to the old heuristic (most recently touched
# PROGRESS.md).
#
# SCOPED TO WORK IN PROGRESS. The gate only fires when this worktree has
# uncommitted or staged changes — read-only / question turns leave a clean tree,
# so they are never blocked. (/implement commits one verified step at a time, so
# a clean tree means the last commit already passed this gate.)
#
# ASSUMES A SINGLE SHELL COMMAND. Put it on the first line of
# docs/handoff/<slug>/.verify (this is the exact command from the PLAN
# **Verification** block). If your Verification needs several commands, wrap them
# in a script and point .verify at it — or, per DECISIONS guidance, pause and ask
# the spec author how to express the pass signal rather than inventing a format.
# The gate is inactive (exit 0) whenever no .verify file exists, so this repo —
# which has no test suite — is unaffected until someone opts in.
set -euo pipefail

# Active slug = the one named by the current branch. Strip any prefix so both
# `<slug>` and `feature/<slug>` resolve to `<slug>`.
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
candidate=${branch##*/}
slug_dir=""
if [ -n "$candidate" ] && [ -d "docs/handoff/$candidate" ]; then
  slug_dir="docs/handoff/$candidate"
else
  # Fallback: branch matches no slug — most recently touched PROGRESS.md.
  # `_archive/<slug>/PROGRESS.md` sits one level deeper than this glob, so
  # archived (done) slugs are excluded automatically and never win the race.
  latest=$(ls -t docs/handoff/*/PROGRESS.md 2>/dev/null | head -1 || true)
  [ -n "$latest" ] && slug_dir=$(dirname "$latest")
fi
[ -z "$slug_dir" ] && exit 0               # no handoff in play — gate inactive

verify_file="$slug_dir/.verify"
[ -f "$verify_file" ] || exit 0            # no command configured — gate inactive

# Only gate turns that actually touched work. A clean worktree means nothing
# changed this turn (read-only / question turn), so there is nothing new to
# verify — don't trap the user in a verification loop over an unrelated turn.
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

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

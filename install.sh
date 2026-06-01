#!/usr/bin/env sh
# claude-handoff-kit installer — tool-agnostic (Codex, Claude, any agent).
#
# Drops the handoff commands + optional hooks into a target project and seeds the
# shared contract (AGENTS.md) and registry (docs/handoff/INDEX.md). Idempotent:
# re-running never duplicates the contract block and never clobbers your files
# without --force.
#
# Usage:
#   ./install.sh [--target <dir>] [--with-hooks] [--with-django] [--force]
#   curl -fsSL https://raw.githubusercontent.com/Martin-Ferreira-O/claude-handoff-kit/main/install.sh | sh
#
# Flags:
#   --target <dir>   project to install into (default: current directory)
#   --with-hooks     also copy hooks/ and print how to wire them
#   --with-django    also copy the optional Django layer (skills + reviewer
#                    subagents) into .claude/ — use only in Django repos
#   --force          overwrite existing command/hook files instead of skipping
set -eu

REPO_URL="https://github.com/Martin-Ferreira-O/claude-handoff-kit.git"
MARKER_START="<!-- handoff-kit:start -->"

TARGET="."
WITH_HOOKS=0
WITH_DJANGO=0
FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="${2:?--target needs a dir}"; shift 2 ;;
    --target=*) TARGET="${1#--target=}"; shift ;;
    --with-hooks) WITH_HOOKS=1; shift ;;
    --with-django) WITH_DJANGO=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,21p' "$0" 2>/dev/null || true; exit 0 ;;
    *) echo "install.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
done

info() { printf '  %s\n' "$1"; }

# --- Resolve the kit source: a local clone, or fetch one ---------------------
KIT=""
SELF="$0"
if [ -f "$SELF" ]; then
  SELF_DIR=$(CDPATH= cd -- "$(dirname -- "$SELF")" && pwd)
  if [ -f "$SELF_DIR/templates/AGENTS.handoff.md" ]; then
    KIT="$SELF_DIR"
  fi
fi
CLONED=""
if [ -z "$KIT" ]; then
  command -v git >/dev/null 2>&1 || { echo "install.sh: need git to fetch the kit" >&2; exit 1; }
  CLONED=$(mktemp -d 2>/dev/null || mktemp -d -t handoff-kit)
  echo "Fetching claude-handoff-kit…"
  git clone --depth 1 "$REPO_URL" "$CLONED" >/dev/null 2>&1 \
    || { echo "install.sh: git clone failed ($REPO_URL)" >&2; exit 1; }
  KIT="$CLONED"
fi
cleanup() { [ -n "$CLONED" ] && rm -rf "$CLONED"; return 0; }
trap cleanup EXIT INT TERM

mkdir -p "$TARGET"
TARGET=$(CDPATH= cd -- "$TARGET" && pwd)
echo "Installing claude-handoff-kit into: $TARGET"

# --- Commands ----------------------------------------------------------------
echo "Commands → .claude/commands/"
mkdir -p "$TARGET/.claude/commands"
for src in "$KIT"/.claude/commands/*.md; do
  [ -e "$src" ] || continue
  base=$(basename "$src")
  dst="$TARGET/.claude/commands/$base"
  if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
    info "skip $base (exists; --force to overwrite)"
  else
    cp "$src" "$dst"; info "copy $base"
  fi
done

# --- Hooks (opt-in) ----------------------------------------------------------
if [ "$WITH_HOOKS" -eq 1 ]; then
  echo "Hooks → hooks/"
  mkdir -p "$TARGET/hooks"
  for src in "$KIT"/hooks/*.sh; do
    [ -e "$src" ] || continue
    base=$(basename "$src")
    dst="$TARGET/hooks/$base"
    if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
      info "skip $base (exists; --force to overwrite)"
    else
      cp "$src" "$dst"; chmod +x "$dst"; info "copy $base (+x)"
    fi
  done
  cp "$KIT/.claude/settings.json.example" "$TARGET/.claude/settings.json.example"
  info "copy .claude/settings.json.example"
fi

# --- Django layer (opt-in) ---------------------------------------------------
if [ "$WITH_DJANGO" -eq 1 ]; then
  DJANGO_SRC="$KIT/plugins/handoff-kit-django"
  if [ ! -d "$DJANGO_SRC" ]; then
    echo "install.sh: --with-django requested but $DJANGO_SRC is missing" >&2
    exit 1
  fi
  echo "Django layer → .claude/{skills,agents}/"
  # Skills are folders (SKILL.md + optional assets); agents are flat .md files.
  find "$DJANGO_SRC/skills" "$DJANGO_SRC/agents" -type f | while IFS= read -r src; do
    rel="${src#"$DJANGO_SRC"/}"            # e.g. skills/django-patterns/SKILL.md
    dst="$TARGET/.claude/$rel"
    if [ -e "$dst" ] && [ "$FORCE" -eq 0 ]; then
      info "skip $rel (exists; --force to overwrite)"
    else
      mkdir -p "$(dirname "$dst")"
      cp "$src" "$dst"; info "copy $rel"
    fi
  done
  # Carry the attribution next to what it covers (MIT requires the notice).
  cp "$DJANGO_SRC/ATTRIBUTION.md" "$TARGET/.claude/DJANGO_LAYER_ATTRIBUTION.md"
  info "copy .claude/DJANGO_LAYER_ATTRIBUTION.md"
fi

# --- Contract: AGENTS.md (idempotent via markers) ----------------------------
echo "Contract → AGENTS.md"
AGENTS="$TARGET/AGENTS.md"
if [ ! -f "$AGENTS" ]; then
  { printf '# Repository Guidelines\n\n'; cat "$KIT/templates/AGENTS.handoff.md"; } > "$AGENTS"
  info "create AGENTS.md with handoff contract"
elif grep -qF "$MARKER_START" "$AGENTS"; then
  info "AGENTS.md already has the handoff block (use /handoff-init to refresh)"
else
  { printf '\n'; cat "$KIT/templates/AGENTS.handoff.md"; } >> "$AGENTS"
  info "append handoff contract to existing AGENTS.md"
fi

# --- Registry: docs/handoff/INDEX.md -----------------------------------------
echo "Registry → docs/handoff/INDEX.md"
if [ ! -f "$TARGET/docs/handoff/INDEX.md" ]; then
  mkdir -p "$TARGET/docs/handoff"
  cp "$KIT/templates/INDEX.md" "$TARGET/docs/handoff/INDEX.md"
  info "create docs/handoff/INDEX.md"
else
  info "docs/handoff/INDEX.md already exists"
fi

# --- Next steps --------------------------------------------------------------
cat <<'EOF'

Done. Next:
  • Start the cycle with /plan <task> (Claude), or read AGENTS.md and follow the
    cycle manually (Codex / any agent): plan → clarify → handoff → resume →
    implement → code-review.
EOF
if [ "$WITH_HOOKS" -eq 1 ]; then
  cat <<'EOF'
  • Hooks are OPT-IN. To enable the Claude-only enforcement layer, merge
    .claude/settings.json.example into .claude/settings.json — see docs/hooks.md.
EOF
fi
if [ "$WITH_DJANGO" -eq 1 ]; then
  cat <<'EOF'
  • Django layer installed under .claude/{skills,agents}/. The /implement review
    gate now prefers python/security/database-reviewer for matching diffs; run
    /django-review to route a diff to the right reviewer on demand. Imported from
    ECC (MIT) — see .claude/DJANGO_LAYER_ATTRIBUTION.md.
EOF
fi
echo "  • Review with 'git status' / 'git diff' and commit the seeded files."

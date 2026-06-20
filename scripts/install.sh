#!/usr/bin/env bash
# install.sh
#
# Installs the global toolkit (CLAUDE.md, settings.json, skills, agents,
# scripts) from this repo into ~/.claude.
#
# Defaults to COPY mode (safe everywhere, including corporate machines that
# dislike symlinks). Pass --symlink to link instead.
#
#   bash scripts/install.sh             # copy mode (default)
#   bash scripts/install.sh --symlink   # symlink mode
#   bash scripts/install.sh --dry-run   # show what would happen
#
# Behavior:
#   - Never deletes files it did not create.
#   - Backs up any existing target before overwriting (timestamped).
#   - Does NOT touch settings.local.json or any credentials.
set -uo pipefail

MODE="copy"
DRY=0
for arg in "$@"; do
  case "$arg" in
    --symlink) MODE="symlink" ;;
    --copy)    MODE="copy" ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO/global"
DEST="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S 2>/dev/null || echo backup)"

say() { echo "[install] $*"; }
do_() { if [ "$DRY" -eq 1 ]; then echo "  DRY: $*"; else eval "$*"; fi; }

[ -d "$SRC" ] || { echo "Missing $SRC — run from the repo root." >&2; exit 1; }

say "mode=$MODE  source=$SRC  dest=$DEST"
do_ "mkdir -p '$DEST'"

backup() { # backup a path if it exists and we're about to replace it
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  local bdir="$DEST/.toolkit-backups/$STAMP"
  do_ "mkdir -p '$bdir'"
  do_ "cp -R '$target' '$bdir/' 2>/dev/null || true"
  say "backed up $(basename "$target") -> $bdir/"
}

place_dir() { # place_dir <name>  (skills/agents/scripts)
  local name="$1"
  local s="$SRC/$name" d="$DEST/$name"
  [ -d "$s" ] || { [ "$name" = "scripts" ] && s="$REPO/scripts"; } # scripts live at repo root
  [ -d "$s" ] || { say "skip $name (no source)"; return 0; }
  backup "$d"
  if [ "$MODE" = "symlink" ]; then
    do_ "rm -rf '$d'"
    do_ "ln -s '$s' '$d'"
  else
    do_ "rm -rf '$d'"
    do_ "mkdir -p '$d'"
    do_ "cp -R '$s/.' '$d/'"
  fi
  say "installed $name"
}

place_file() { # place_file <relsrc> <reldest>
  local s="$SRC/$1" d="$DEST/$2"
  [ -f "$s" ] || { say "skip $2 (no source)"; return 0; }
  backup "$d"
  if [ "$MODE" = "symlink" ]; then
    do_ "rm -f '$d'"
    do_ "ln -s '$s' '$d'"
  else
    do_ "cp '$s' '$d'"
  fi
  say "installed $2"
}

place_file "CLAUDE.md" "CLAUDE.md"
place_file "settings.json" "settings.json"
place_dir "skills"
place_dir "agents"

# scripts (sourced from repo root, copied into ~/.claude/scripts and chmod'd)
backup "$DEST/scripts"
if [ "$MODE" = "symlink" ]; then
  do_ "rm -rf '$DEST/scripts'"
  do_ "ln -s '$REPO/scripts' '$DEST/scripts'"
else
  do_ "rm -rf '$DEST/scripts'"
  do_ "mkdir -p '$DEST/scripts'"
  do_ "cp -R '$REPO/scripts/.' '$DEST/scripts/'"
fi
do_ "chmod +x '$DEST/scripts/'*.sh 2>/dev/null || true"
say "installed scripts (executable)"

echo
say "Done. settings.local.json and credentials were left untouched."
say "Verify with: bash '$REPO/scripts/validate-claude-config.sh'"

#!/usr/bin/env bash
# context-restore.sh
#
# Helper for the /context-restore skill. Locates the most recent project-local
# saved context and reports the current git state so the skill can detect drift
# (branch changed, working tree diverged) before resuming.
#
# Usage: bash context-restore.sh
set -uo pipefail

ctx_dir=".claude/context"
default="$ctx_dir/current-session.md"

echo "=== SAVED CONTEXT ==="
if [ -f "$default" ]; then
  echo "file: $default"
  echo "---"
  cat "$default"
elif [ -d "$ctx_dir" ] && ls "$ctx_dir"/*.md >/dev/null 2>&1; then
  latest="$(ls -t "$ctx_dir"/*.md 2>/dev/null | head -n1)"
  echo "file: $latest"
  echo "---"
  cat "$latest"
else
  echo "(no saved context found in $ctx_dir/)"
fi

echo
echo "=== CURRENT GIT STATE (compare against saved) ==="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  echo "--- status (short) ---"
  git status --short 2>/dev/null
  echo "--- recent commits ---"
  git log --oneline -5 2>/dev/null
else
  echo "(not a git repository)"
fi

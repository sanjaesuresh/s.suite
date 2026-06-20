#!/usr/bin/env bash
# unfreeze-edits.sh
#
# Removes the edit boundary set by /freeze (or /guard) for the current project.
# Safe to run anytime; no-op if nothing is frozen.
#
# Usage: bash unfreeze-edits.sh [project-dir]
set -uo pipefail

dir="${1:-$(pwd)}"
boundary_file="$dir/.claude/session-state/freeze-boundary"

if [ -f "$boundary_file" ]; then
  prev="$(head -n1 "$boundary_file" 2>/dev/null)"
  rm -f "$boundary_file"
  echo "Unfrozen. Edit boundary removed (was: ${prev:-unknown})."
else
  echo "Nothing to unfreeze (no boundary file at $boundary_file)."
fi

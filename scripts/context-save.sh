#!/usr/bin/env bash
# context-save.sh
#
# Helper for the /context-save skill. Gathers raw git state for the current
# repo and runs a lightweight secret/PII scan over the working tree changes.
# It does NOT write the context file itself — the skill composes the narrative
# (task, decisions, remaining work) and writes the final document after
# reviewing this output. This keeps a human/Claude review step in the loop.
#
# Usage: bash context-save.sh
# Prints: a git-state block, then a SECRET-SCAN block with any warnings.
set -uo pipefail

echo "=== GIT STATE ==="
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "(not a git repository)"
  exit 0
fi

echo "branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
echo
echo "--- status (short) ---"
git status --short 2>/dev/null
echo
echo "--- recent commits ---"
git log --oneline -8 2>/dev/null
echo
echo "--- diff stat ---"
git diff --stat 2>/dev/null
git diff --cached --stat 2>/dev/null

echo
echo "=== SECRET-SCAN (review before saving) ==="
# Scan staged+unstaged diffs for things that should never be persisted.
scan="$( { git diff 2>/dev/null; git diff --cached 2>/dev/null; } )"
patterns='(AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|xox[baprs]-[0-9A-Za-z-]+|ghp_[0-9A-Za-z]{36}|api[_-]?key["'"'"']?\s*[:=]|secret["'"'"']?\s*[:=]|password["'"'"']?\s*[:=]|bearer\s+[A-Za-z0-9._-]{20,}|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,})'
hits="$(printf '%s' "$scan" | grep -nEi "$patterns" 2>/dev/null | head -n 20 || true)"
if [ -n "$hits" ]; then
  echo "WARNING: potential secrets/PII/internal identifiers in your changes."
  echo "Do NOT paste these into the saved context. Review:"
  echo "$hits"
else
  echo "No obvious secret/PII patterns found in the diff. Still review manually."
fi

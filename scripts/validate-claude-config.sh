#!/usr/bin/env bash
# validate-claude-config.sh
#
# Sanity-checks an installed toolkit: required files exist, JSON parses,
# every SKILL.md / agent has valid frontmatter, and scripts are executable.
# Read-only. Exits non-zero if any hard check fails.
#
#   bash scripts/validate-claude-config.sh           # validate ~/.claude
#   bash scripts/validate-claude-config.sh --repo     # validate this repo's global/
set -uo pipefail

TARGET="$HOME/.claude"
SKILLS_ROOT="$TARGET/skills"
AGENTS_ROOT="$TARGET/agents"
if [ "${1:-}" = "--repo" ]; then
  TARGET="$(cd "$(dirname "$0")/.." && pwd)/global"
  SKILLS_ROOT="$TARGET/skills"
  AGENTS_ROOT="$TARGET/agents"
fi

errors=0; warns=0
err()  { echo "FAIL  $*"; errors=$((errors+1)); }
warn() { echo "WARN  $*"; warns=$((warns+1)); }
ok()   { echo "OK    $*"; }

echo "=== validating: $TARGET ==="

# Required top-level files.
for f in CLAUDE.md settings.json; do
  if [ -f "$TARGET/$f" ]; then ok "$f present"; else err "$f missing"; fi
done

# settings.json must be valid JSON.
if [ -f "$TARGET/settings.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    jq empty "$TARGET/settings.json" >/dev/null 2>&1 && ok "settings.json parses" || err "settings.json invalid JSON"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import json,sys;json.load(open('$TARGET/settings.json'))" 2>/dev/null && ok "settings.json parses" || err "settings.json invalid JSON"
  else
    warn "no jq/python3 to validate JSON"
  fi
fi

# Each skill needs SKILL.md with name + description frontmatter.
if [ -d "$SKILLS_ROOT" ]; then
  count=0
  for d in "$SKILLS_ROOT"/*/; do
    [ -d "$d" ] || continue
    count=$((count+1))
    sm="$d/SKILL.md"
    if [ ! -f "$sm" ]; then err "skill $(basename "$d"): no SKILL.md"; continue; fi
    head -n1 "$sm" | grep -q '^---' || err "skill $(basename "$d"): missing frontmatter"
    grep -q '^name:' "$sm"        || err "skill $(basename "$d"): missing name:"
    grep -q '^description:' "$sm" || err "skill $(basename "$d"): missing description:"
  done
  ok "$count skills checked"
else
  warn "no skills/ dir at $SKILLS_ROOT"
fi

# Each agent needs name + description frontmatter.
if [ -d "$AGENTS_ROOT" ]; then
  count=0
  for a in "$AGENTS_ROOT"/*.md; do
    [ -f "$a" ] || continue
    count=$((count+1))
    head -n1 "$a" | grep -q '^---' || err "agent $(basename "$a"): missing frontmatter"
    grep -q '^name:' "$a"          || err "agent $(basename "$a"): missing name:"
    grep -q '^description:' "$a"    || err "agent $(basename "$a"): missing description:"
  done
  ok "$count agents checked"
else
  warn "no agents/ dir at $AGENTS_ROOT"
fi

# Scripts executable (only meaningful for installed ~/.claude/scripts).
if [ -d "$TARGET/scripts" ]; then
  for s in "$TARGET/scripts/"*.sh; do
    [ -f "$s" ] || continue
    [ -x "$s" ] || warn "$(basename "$s") not executable (run chmod +x)"
  done
fi

echo
echo "=== result: $errors error(s), $warns warning(s) ==="
[ "$errors" -eq 0 ]

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
SCRIPTS_DIR="$TARGET/scripts"
if [ "${1:-}" = "--repo" ]; then
  TARGET="$(cd "$(dirname "$0")/.." && pwd)/global"
  SKILLS_ROOT="$TARGET/skills"
  AGENTS_ROOT="$TARGET/agents"
  # scripts/ lives at the repo root, not inside global/
  SCRIPTS_DIR="$(cd "$(dirname "$0")/.." && pwd)/scripts"
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
    # model: must be present and be a known alias or a full claude- model ID
    _model_line=$(grep '^model:' "$a" | head -1)
    if [ -z "$_model_line" ]; then
      err "agent $(basename "$a"): missing model: field"
    else
      _model_val=$(printf '%s' "$_model_line" | sed 's/^model:[[:space:]]*//')
      case "$_model_val" in
        opus|sonnet|haiku|claude-*) ;;
        *) err "agent $(basename "$a"): unrecognized model: $_model_val" ;;
      esac
    fi
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

# Cross-check: every script path referenced in settings.json must exist under scripts/.
# Graceful degradation: skip (warn only) if jq is absent.
if [ -f "$TARGET/settings.json" ]; then
  if command -v jq >/dev/null 2>&1; then
    # statusLine command
    _sl_cmd=$(jq -r '.statusLine.command // empty' "$TARGET/settings.json")
    if [ -n "$_sl_cmd" ]; then
      _sh=$(printf '%s' "$_sl_cmd" | grep -oE '[^/]+\.sh' | head -1)
      if [ -n "$_sh" ]; then
        [ -f "$SCRIPTS_DIR/$_sh" ] \
          && ok "statusLine command → $_sh found" \
          || err "statusLine references missing script: $_sh (looked in $SCRIPTS_DIR)"
      fi
    fi
    # all hook commands across every event type
    while IFS= read -r _cmd; do
      [ -z "$_cmd" ] && continue
      _sh=$(printf '%s' "$_cmd" | grep -oE '[^/]+\.sh' | head -1)
      [ -z "$_sh" ] && continue
      [ -f "$SCRIPTS_DIR/$_sh" ] \
        && ok "hook command → $_sh found" \
        || err "hook command references missing script: $_sh (looked in $SCRIPTS_DIR)"
    done < <(jq -r '.hooks // {} | to_entries[] | .value[] | .hooks[] | select(.type == "command") | .command' "$TARGET/settings.json" 2>/dev/null)
  else
    warn "jq not available — skipping settings script cross-check"
  fi
fi

echo
echo "=== result: $errors error(s), $warns warning(s) ==="
[ "$errors" -eq 0 ]

#!/bin/bash
# Claude Code status line: model, git branch, context usage, session cost, session duration.
# Receives session JSON on stdin (see https://code.claude.com/docs/en/statusline).
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | round')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
mins=$(echo "$input" | jq -r '(.cost.total_duration_ms // 0) / 60000 | floor')

# git branch for the current workspace dir; empty when not a repo. a trailing dot
# signals state: green = clean, amber = uncommitted changes.
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    DOT_COLOR=$'\033[38;5;214m'   # amber = dirty
  else
    DOT_COLOR=$'\033[32m'         # green = clean
  fi
fi

# static colors: model and branch each get their own so they read as distinct fields
RESET=$'\033[0m'
MODEL_COLOR=$'\033[32m'   # green
BRANCH_COLOR=$'\033[38;2;217;119;87m'  # Claude orange (#D97757)

# context % is colored by how full the window is, so it warns before auto-compact
if   (( pct >= 85 )); then CTX_COLOR=$'\033[31m'   # red
elif (( pct >= 70 )); then CTX_COLOR=$'\033[33m'   # yellow
else                       CTX_COLOR=''            # default terminal color
fi

if (( mins >= 60 )); then
  dur="$((mins / 60))h $((mins % 60))m"
else
  dur="${mins}m"
fi

# assemble; the branch segment is dropped entirely outside a git repo
line="${MODEL_COLOR}${model}${RESET}"
[ -n "$branch" ] && line="${line} | ${BRANCH_COLOR}⎇ ${branch}${RESET} ${DOT_COLOR}•${RESET}"
line="${line} | ${CTX_COLOR}${pct}%${RESET} context | \$$(printf '%.2f' "$cost") | ${dur}"
printf '%s\n' "$line"

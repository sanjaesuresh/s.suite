#!/usr/bin/env bash
# bootstrap.sh — one-shot setup for macOS / Linux.
#
# Run from a fresh clone of this repo:
#     git clone https://github.com/sanjaesuresh/claude-code-toolkit.git
#     cd claude-code-toolkit
#     bash bootstrap.sh
#
# Or, to clone + install in one go from anywhere:
#     REPO=https://github.com/sanjaesuresh/claude-code-toolkit.git \
#       bash -c 'git clone "$REPO" ~/claude-code-toolkit && bash ~/claude-code-toolkit/bootstrap.sh'
#
# Copy mode by default. Pass --symlink for symlink mode.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "[bootstrap] toolkit at: $REPO_DIR"
echo "[bootstrap] installing global config into ~/.claude ..."
bash "$REPO_DIR/scripts/install.sh" "$@"
echo "[bootstrap] validating ..."
bash "$REPO_DIR/scripts/validate-claude-config.sh" || {
  echo "[bootstrap] validation reported problems — review the output above."
}
echo
echo "[bootstrap] Done. Open Claude Code and try:  /office-hours   or   /careful"

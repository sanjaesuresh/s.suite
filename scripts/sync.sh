#!/usr/bin/env bash
# sync.sh
#
# Pull the latest toolkit from the private repo and re-install into ~/.claude.
# Use this on each machine to stay in sync.
#
#   bash scripts/sync.sh             # git pull + copy-mode install
#   bash scripts/sync.sh --symlink   # git pull + symlink install
#   bash scripts/sync.sh --no-pull   # re-install without pulling
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
PULL=1
PASS=()
for arg in "$@"; do
  case "$arg" in
    --no-pull) PULL=0 ;;
    *) PASS+=("$arg") ;;
  esac
done

cd "$REPO"
if [ "$PULL" -eq 1 ] && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[sync] pulling latest..."
  git pull --ff-only || { echo "[sync] pull failed (resolve manually), continuing with local copy."; }
fi

echo "[sync] installing..."
bash "$REPO/scripts/install.sh" "${PASS[@]:-}"
echo "[sync] done."

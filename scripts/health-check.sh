#!/usr/bin/env bash
# health-check.sh
#
# Best-effort project health probe. Auto-detects the toolchain and runs the
# usual checks (lint / typecheck / test / build) without assuming a specific
# stack. Prints a pass/fail line per check; the /health-check skill turns this
# into a score and prioritized fixes.
#
# It does NOT install anything and does NOT modify files. Unknown stacks simply
# report "no recognized <x> script".
set -uo pipefail

pass=0; fail=0; skip=0
run() { # run "<label>" "<command...>"
  label="$1"; shift
  if "$@" >/tmp/healthcheck.out 2>&1; then
    echo "PASS  $label"; pass=$((pass+1))
  else
    echo "FAIL  $label  (see output below)"; fail=$((fail+1))
    sed 's/^/      /' /tmp/healthcheck.out | tail -n 15
  fi
}
skipmsg() { echo "SKIP  $1"; skip=$((skip+1)); }

echo "=== PROJECT HEALTH CHECK ==="

# --- Node / JS / TS ---
if [ -f package.json ]; then
  has() { grep -q "\"$1\"" package.json 2>/dev/null; }
  pm="npm"; [ -f pnpm-lock.yaml ] && pm="pnpm"; [ -f yarn.lock ] && pm="yarn"
  has lint      && run "lint"      $pm run lint      || skipmsg "lint (no script)"
  has typecheck && run "typecheck" $pm run typecheck || { has tsc && run "typecheck" npx tsc --noEmit || skipmsg "typecheck (no script)"; }
  has test      && run "test"      $pm test          || skipmsg "test (no script)"
  has build     && run "build"     $pm run build     || skipmsg "build (no script)"
fi

# --- Python ---
if [ -f pyproject.toml ] || [ -f setup.py ] || ls ./*.py >/dev/null 2>&1; then
  command -v ruff   >/dev/null 2>&1 && run "ruff"   ruff check .            || skipmsg "ruff (not installed)"
  command -v mypy   >/dev/null 2>&1 && run "mypy"   mypy .                  || skipmsg "mypy (not installed)"
  command -v pytest >/dev/null 2>&1 && run "pytest" pytest -q               || skipmsg "pytest (not installed)"
fi

# --- Go ---
if [ -f go.mod ]; then
  run "go vet"   go vet ./...
  run "go test"  go test ./...
fi

# --- Rust ---
if [ -f Cargo.toml ]; then
  run "cargo check" cargo check
  run "cargo test"  cargo test
fi

echo
echo "=== SUMMARY ==="
echo "pass=$pass fail=$fail skip=$skip"
[ "$fail" -eq 0 ]

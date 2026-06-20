---
name: health-check
description: >
  Run or propose project health checks: lint, typecheck, unit tests, integration
  tests, build, formatting, dead code, dependency risk, flaky tests, and basic
  security checks. Use when you want a quick "is this project in good shape?" answer,
  before a release, or after inheriting a codebase. Runs checks if possible;
  proposes them if the environment doesn't support execution.
---

## Tool contract — READ-ONLY

Investigate and report. Does not modify files. Runs read-only commands (lint,
typecheck, test) only — does not install packages, deploy, or mutate state.

## How to work

1. **Check for a health script**: If `~/.claude/scripts/health-check.sh` exists,
   run it and use its output as the primary input. Parse results into the output
   format below.

2. **Detect the stack**: Read `package.json`, `pyproject.toml`, `Cargo.toml`,
   `go.mod`, `.github/workflows/`, or equivalent CI config. Identify what tools
   are configured.

3. **Run what you can**: Execute available checks in this order:
   - Formatting: `prettier --check`, `black --check`, `gofmt -l`, etc.
   - Lint: `eslint`, `ruff`, `clippy`, etc.
   - Typecheck: `tsc --noEmit`, `mypy`, etc.
   - Unit tests: `jest`, `pytest`, `cargo test`, etc.
   - Build: `tsc`, `cargo build`, `go build`, etc.
   - Dead code: `ts-prune`, `vulture`, `cargo +nightly rustc -- -W dead-code`, etc.
   - Dependency risk: outdated packages, known CVEs if `npm audit` / `pip-audit`
     is available.

4. **If execution is not possible**: Propose the specific commands that should be
   run, based on the detected stack. Do not invent checks that have no basis in
   the project config.

5. **Score 0–10**: 10 = all checks pass with no warnings, CI covers everything,
   no dependency risk. Deduct for each failing category proportionally.

6. **Flag flaky tests**: Look for tests marked `.skip`, `xfail`, `TODO`, or known
   to be commented out.

7. **Flag CI gaps**: Compare what runs locally to what runs in CI. Note anything
   that is checked locally but not in CI, or vice versa.

## Output format

```markdown
# Project Health Check

## Score
X/10 — <one sentence explaining the score>

## Passing checks
- Lint: clean (`eslint src/` — 0 errors)
- ...

## Failing checks
- Typecheck: 3 errors (`tsc --noEmit` — see `src/api/handler.ts:42`)
- ...

## Missing checks
- No dead-code detection configured
- No dependency vulnerability scan in CI
- ...

## Top fixes
1. Fix typecheck errors in `src/api/handler.ts:42` — blocking
2. Add `npm audit` to CI pipeline
3. ...

## Recommended CI additions
- [ ] `npm audit --audit-level=high` on every PR
- [ ] Typecheck as a required status check
- [ ] ...
```

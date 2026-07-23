---
name: test-gap-analysis
description: >
  Find missing, weak, or misleading tests in a codebase or diff. Use when you want
  to know what tests are missing before a PR merges, after writing new code, or when
  a test suite is green but you still don't trust it. Examines changed code, existing
  tests, test patterns, and CI config to surface real gaps.
argument-hint: "[path | 'current diff' | module-name]"
---

## Tool contract — READ-ONLY

Investigate and report. Do not write or modify test files unless the user explicitly asks.

## How to work

1. **Read the scope**: If an argument is given, read that path or diff. Otherwise
   run `git diff HEAD` to find changed files.

2. **Map existing tests**: Find test files corresponding to changed modules. Note
   the test framework, runner, and any coverage config (e.g. `jest.config`, `pytest.ini`,
   `.nycrc`, `coverage.py`). Check CI config for how tests are run.

3. **Identify gaps**:
   - Behaviors that exist in code with no corresponding test
   - Edge cases and error paths that are not exercised
   - Tests that only test the happy path
   - Assertions so weak that they pass even if the implementation is wrong
   - Over-mocked tests that don't prove real behavior (mock returns mock, test passes)
   - Tests that test implementation details instead of observable behavior
   - Regression tests missing for bugs mentioned in commit messages or comments

4. **Check test quality**:
   - Are assertions specific enough to fail on regression?
   - Are there `expect(true).toBe(true)` or equivalent no-op assertions?
   - Are there tests that would still pass if the function returned `undefined`?
   - Are integration or e2e tests absent where unit tests alone are insufficient?

5. **Cross-reference [[deep-codebase-audit]]** if a full audit is also needed.

## Output format

```markdown
# Test Gap Analysis

## Current test coverage
(Describe what is actually tested today. Be specific — which files, which behaviors.
 Do not claim "coverage is X%" unless a coverage report exists.)

## Missing tests
| Behavior | Test type | Where to add | Why |
|---|---|---|---|
| e.g. rejects null userId | unit | `auth.test.ts` | No null guard tested |

## Weak tests to improve
- [test-file:line] — why it's weak — what to assert instead

## Suggested test names
(Concrete `it('...')` / `def test_...` names that would close the gaps.)

## Minimal test plan before PR
(Ordered list: the smallest set of tests that would make this safe to merge.)
```

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

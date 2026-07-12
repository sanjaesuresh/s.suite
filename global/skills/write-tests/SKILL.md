---
name: write-tests
description: >
  Add or fill in test coverage for changed or new code, end to end — full-scope,
  edge-case-first, regression-aware. Use when the user says "write tests", "add
  tests", "cover this", "test this", or when a fix changes untested behavior.
  Reads the diff first and skips changes that don't need tests, enumerates edge
  and failure cases, checks existing tests the change may break, writes tests via
  software-engineer (Sonnet), then loops run (added tests first, then the scoped
  domain suite — not the whole repo) → score until every behavior is pinned, the
  regression set stays green, and test quality clears the bar.
argument-hint: "<file, function, or change to cover — optional>"
---

# write-tests

The front door for **adding real tests to real code**. It owns the loop nothing
else does — **decide what needs a test, enumerate the edge cases, find the
regression blast radius, write full-scope tests, then run and score them until
they hold up** — and delegates the two halves it should not do inline: gap and
quality analysis to `test-strategist` (read-only) and the writing to
[[software-engineer]] (Sonnet). It does not re-review the product diff
([[pre-pr-review]]) or design a manual QA pass (`qa-reviewer`).

Flow: **read the changes → decide if tests are even warranted → scope the target
→ map coverage + regression blast radius + edge cases → plan if non-trivial
(gated) → write full-scope tests (software-engineer, Sonnet) → loop run (added
tests first, then the scoped domain suite) → score until behaviors are pinned,
regressions stay green, and quality clears the bar.**

## When to use

- The user says "write/add tests", "cover this", "test this function/change".
- A build or fix landed behavior with no test that would fail if it broke.
- Coverage feels thin around a specific file, module, or diff.

## When NOT to use

- **Reviewing** a product diff for correctness bugs → [[pre-pr-review]] or
  `/code-review`. This skill reviews *test quality*, not product code.
- A **manual / exploratory** QA test plan with no automated tests to write →
  `qa-reviewer`.
- Only wanting the **gap list**, not the tests written → dispatch
  `test-strategist` directly.
- Debugging *why* a test fails → [[systematic-debugging]] first, then return here.

## Model tiering

Scoping, edge-case enumeration, gap analysis, planning, and scoring run in
**this** session (assumed Opus). Writing the tests is **delegated** to
`software-engineer`, pinned to **Sonnet**, so the Opus-decide / Sonnet-write
split happens automatically — no `/model` switching. Return here (Opus) for the
score and summary.

## Phase 1 — Read the changes and decide whether tests are warranted

**Read the actual changes before deciding to write anything.** Not every change
needs a test, and this skill's whole point is tests that pin real behavior —
manufacturing no-op tests for a change that doesn't need them is worse than
writing none.

1. **Read the diff.** `git diff`, `git diff --cached`, `git status --short`, and
   the changed files in context. If the user named a target, use it; otherwise
   **state what you concluded** the change is.
2. **Decide.** Write tests when the change **adds or alters behavior**, fixes a
   bug (add the regression test that would have caught it), or touches logic,
   branching, error handling, data transforms, or a public contract. **Skip —
   say so plainly and stop** — when the change is docs / comments / formatting
   only, a config or dependency bump with no logic, a pure mechanical rename or
   move, or already fully covered by an existing test that would fail if it
   broke. When it's borderline, lean toward one focused test and say why.
   - Even when the user invoked this skill explicitly, if the change genuinely
     gains nothing from a test, report that instead of writing filler — confirm
     before forcing coverage.
3. **Identify the test stack** — runner, framework, file naming (`*.test.*`,
   `*.spec.*`, `__tests__`, `tests/`), fixtures/factories, and how tests are
   invoked (package script, Makefile, CI). Note how to run a **scoped** subset —
   a single file, a package/workspace, a directory, or a tag/marker — because
   Phase 5 runs scoped, not the whole repo. New tests must match the existing
   convention, not introduce a second one.

## Phase 2 — Map coverage, regression blast radius, and edge cases

Three things return here as summaries; dispatch read-only subagents so the reads
stay out of this thread.

1. **Coverage gaps for the target.** Dispatch `test-strategist` — current
   coverage, missing tests (behavior / type / where), and weak tests that would
   pass even if the code were broken.
2. **Regression blast radius.** Find the **existing** tests elsewhere that the
   change may affect — not just the target's own tests. Grep for the changed
   symbols, their call sites, and the module the target lives in; collect every
   test that exercises that code path into a **regression set**. These must stay
   green. If the change *intentionally* alters a behavior an existing test pins,
   that test is updated deliberately in Phase 4 and called out — never left to
   break silently or mutated only to make it pass.
3. **Edge-case enumeration — first-class, not an afterthought.** For the target,
   list the cases explicitly, walking these categories:
   - boundaries: empty, null/undefined, zero, one, max, min, off-by-one, overflow;
   - invalid / malformed input, wrong type, out-of-range;
   - error and exception paths: thrown errors, rejected promises, non-zero exits;
   - external-dependency failure: network error, DB empty/unavailable, timeout,
     partial/duplicate response;
   - permission / auth denied, unauthenticated, expired;
   - concurrency and ordering: races, retries, idempotency, out-of-order events;
   - encoding and size: unicode, whitespace, very large input, truncation.

   Not every category applies — keep the ones the target can actually hit and say
   which you ruled out and why. This list is the coverage contract for Phase 4.

## Phase 3 — Plan — gate on size

Follow the planning gate. Writing a handful of tests that match an existing
pattern is a small, contained change — proceed without a written plan. Plan first
(prose, no code, get approval) when any of these is true:

- a new test harness, fixture layer, or dependency is needed;
- the target has no tests at all and the framework/wiring must be chosen;
- more than a handful of files or ~100+ lines of test code are in play;
- test infrastructure (CI wiring, coverage gates, mocks/factories) changes.

When unsure whether it's small, treat it as not small and plan.

## Phase 4 — Write full-scope tests (Sonnet, delegated)

Delegate to `software-engineer` (Sonnet). Hand it the target, the
test-strategist gap list, the **edge-case list from Phase 2**, the regression set,
and the repo's test convention. Require:

- **Full behavioral scope**, not the smallest change — cover the happy path plus
  every applicable edge, boundary, and failure case enumerated in Phase 2. Breadth
  of real coverage is the goal; volume of no-op tests is not.
- each test names the **specific behavior** it pins and **fails if that behavior
  breaks** — no tests that pass even when the code does nothing (asserting a mock
  was called, snapshotting whatever the code happens to emit);
- reuse existing fixtures/helpers and match local style; don't restructure the
  suite to fit new tests;
- for any regression-set test the change intentionally invalidates, update it in
  the same pass and flag the behavior change.

## Phase 5 — Run and score — loop until it holds up

Drive a self-paced loop (via `/loop` with no interval, or an internal iteration
loop) over **run → score → fix**. Two **hard gates** decide done; the quality
score is a **soft target**, not the referee — the score is a noisy LLM judgment,
so don't let the loop chase ±3 of it.

**Hard gate A — every behavior is pinned.** Each target/changed behavior has a
test that **fails if that behavior breaks**. Not "there's a test nearby" — a test
that actually catches the break. This is non-negotiable; a missing one keeps the
loop going regardless of the score.

**Hard gate B — the added tests and the scoped suite are green.** Run in this
order, **reading the output** each time and quoting the real pass/fail — never
claim green without it:

1. **The specific tests you just added, first** — the fastest signal that the new
   cases pass and actually exercise the target.
2. **Then the scoped suite for the change's domain** — the package / workspace /
   module / directory the change lives in, plus the Phase-2 regression set. **Not
   the whole repo.** A work repo's full suite can take an hour+, and CI runs it on
   the PR anyway; locally you want fast, relevant signal, so filter to the domain
   (runner path filter, workspace/package selector, or test tag/marker).

Run the **entire** repo suite only when it's genuinely small — the full run
finishes in a couple of minutes, or there's no meaningful domain to scope to.
Otherwise leave the full sweep to CI and note that you ran scoped.

**Soft target — normalized quality ≥ 85.** Dispatch `test-strategist` on the
written tests to score them against this rubric and return the score plus what's
missing. **Score only the applicable categories** — drop any that the target
can't reach (no failure paths, no concurrency) from the denominator instead of
counting them as 0, so an inapplicable category never makes the bar unreachable:

- 30 — every target/changed behavior is pinned by a test that fails if it breaks;
- 20 — edge and boundary cases from Phase 2 are covered;
- 20 — failure / error paths are covered;
- 15 — regression set is green and intended behavior changes are reflected;
- 10 — no tautological, no-op, over-mocked, or brittle-snapshot tests;
- 5  — matches repo conventions (naming, fixtures, structure).

Each iteration, feed the gate failures and the score's gap list back into another
`software-engineer` pass, then re-run and re-score. Exit when **both hard gates
pass and the normalized score is ≥85**. Stop early — reporting the best result
and the remaining gap rather than spinning — when:

- the **iteration cap (default 5)** is hit, or
- the score **plateaus** (no improvement across two consecutive iterations) while
  the hard gates are already met — the last few points are usually convention
  nits, not missing coverage.

If a test fails for an **unclear** reason → hand to [[systematic-debugging]]
instead of mutating the test until it passes.

Never lower a test's assertions or delete cases just to clear a gate — that games
the score and defeats hard gate A. If a real behavior genuinely can't be tested,
say so and count it as a gap.

## Phase 6 — Summarize

Short prose in chat:

- **Covered** — the behaviors now under test, including which edge and failure
  cases from Phase 2, and why they mattered.
- **Tests added** — files and the named cases, one line each.
- **Regression** — which existing tests were in the blast radius, that they still
  pass, and any deliberately updated for an intended behavior change.
- **Score** — that both hard gates passed, the final normalized quality score,
  how many loop iterations it took, and (if it stopped below the target) why.
- **Results** — the commands run (added tests first, then the scoped domain
  suite) and their real pass/fail evidence; note the full suite is left to CI.
- **Gaps left** — anything deliberately not written, and why (out of scope, needs
  infra, untestable).

**Do not auto-commit.** Ask before any `git commit` or `push`; name what would go
out.

## Related

- `test-strategist` — the read-only agent that finds the gaps and scores the tests.
- [[software-engineer]] — the Sonnet implementer that writes the tests.
- [[pre-pr-review]] — reports test gaps as review findings; this skill closes them.
- `qa-reviewer` — manual / exploratory test plans, not automated tests.
- [[systematic-debugging]] — when a written test fails for an unclear reason.
- [[jira-ticket]] — calls this skill to add coverage when a fix changes untested behavior.

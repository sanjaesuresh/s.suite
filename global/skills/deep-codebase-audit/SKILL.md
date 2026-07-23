---
name: deep-codebase-audit
description: >
  Multi-agent deep audit of a repo, feature, folder, or diff. Use when you want a
  thorough pre-merge review, a second opinion on a branch, or a full repo health
  sweep — any time you'd ask "is this actually safe to ship?" Accepts an optional
  argument like "current diff", a file path, or a feature name to scope the audit.
argument-hint: "[path | 'current diff' | feature-name]"
---

## Tool contract — READ-ONLY

Investigate and report. Do not modify files unless the user explicitly asks.

## How to work

1. **Scope**: Read the argument (or default to the current diff via `git diff HEAD`).
   Determine what changed: files, domains, migration files, tests, config.

2. **Select subagents**: Dispatch the relevant subset in parallel using the Agent tool.
   Skip agents that have nothing to examine (e.g. skip `migration-risk-reviewer` if
   no DB migrations changed). Available agents:
   - `pre-pr-reviewer` — logic correctness, edge cases, contract violations
   - `security-reviewer` — injection, auth, secrets exposure, data leakage
   - `architecture-reviewer` — coupling, layering, violation of local patterns
   - `test-strategist` — test coverage gaps, brittle tests, missing regressions
   - `ai-slop-detector` — unnecessary abstraction, generic naming, fake error handling
   - `scope-guardian` — scope creep, unrelated changes bundled in the diff
   - `migration-risk-reviewer` — destructive migrations, missing rollbacks, data loss
   - `qa-reviewer` — user-facing behavior regressions, acceptance criteria
   - `health-checker` — build, lint, typecheck, dependency risk

3. **Ground each agent**: Pass the relevant files/diff content. Require each agent
   to cite file:line evidence. Reject vague findings.

4. **Synthesize**: Merge findings, deduplicate, rank by severity (blocker → high →
   medium → suggestion). Separate blockers from suggestions.

5. **Gate by confidence**: Label speculative findings as "low confidence." Only
   escalate to critical if there is direct evidence.

## Output format

```markdown
# Deep Audit Report

## Executive summary
(2–4 sentences. What changed, what risk level, ship/don't-ship verdict.)

## Verdict
SHIP / SHIP WITH FIXES / DO NOT SHIP — reason in one sentence.

## Top 5 issues to fix first
1. [file:line] — description
...

## Critical / high risk
- [file:line] — finding — severity — confidence

## Medium risk
- [file:line] — finding

## AI slop and maintainability
- [file:line] — finding

## Test gaps
- Missing: <behavior> — suggested test type — where to add

## Security / privacy
- [file:line] — finding

## Scope issues
- Unrelated changes bundled: <description>

## Suggested fix plan
(Ordered steps to address blockers before merging.)

## What not to change
(Things that look fine; do not churn these.)
```

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

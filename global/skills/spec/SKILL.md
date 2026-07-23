---
name: spec
description: Turn vague intent into a precise, executable spec before any implementation begins. Use when the user says "write a spec", "spec this out", "I want to build X", or when an idea has survived idea-validation but lacks a clear definition of done.
---

## Tool contract
Read-only investigation only. The spec is the only artifact. Do not edit code unless explicitly asked.

## Purpose
A spec is a forcing function. It makes ambiguity visible before it becomes a bug. Good specs eliminate "I thought you meant..." conversations after code is written.

## How to work

1. **Read the repo first.** Check existing models, routes, types, and related features. The spec must fit the real system, not a hypothetical one.
2. **Identify the goal in one sentence.** If you cannot, the idea is not ready — redirect to [[office-hours]].
3. **Write non-goals explicitly.** Every non-goal is a future argument you are winning now.
4. **Write user stories in "when / I want / so that" form** — not "the system shall".
5. **Surface edge cases aggressively.** Empty state, error state, concurrent writes, permission boundaries, large data sets.
6. **Call out data and state changes.** What gets created, updated, or deleted? What are the before/after states?
7. **Flag API and interface changes.** New endpoints, changed contracts, schema migrations.
8. **Write the test plan before implementation.** If you cannot describe how to test it, the requirement is underspecified.
9. **End with open questions.** Anything unresolved should be listed, not assumed away.
10. **Implementation-ready checklist** — a final gate: only proceed when every box is checkable.

## When to hand off
- Idea not yet formed → [[office-hours]] first
- Spec done → [[implementation-plan]] to scope the work
- Plan done → [[product-plan-review]] or [[engineering-plan-review]] before coding
- Matching subagent: **engineering-manager**, **founder-reviewer**

## Output format

```markdown
# Spec
## Goal
## Non-goals
## User stories / use cases
## Requirements
## Edge cases
## Data / state changes
## API / interface changes
## UX behavior, if relevant
## Security/privacy considerations
## Test plan
## Open questions
## Implementation-ready checklist
```

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

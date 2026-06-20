---
name: implementation-plan
description: Research the relevant codebase area and produce a scoped implementation plan before any coding begins. Use when the user says "make a plan", "plan this out", "implementation plan", or wants to know what changes a feature will require before touching code.
---

## Tool contract
Read-only investigation only. The plan is the only artifact. Do not edit code unless explicitly asked.

## Purpose
Prevent wasted implementation effort by front-loading research. A good implementation plan names the exact files that change, the patterns to follow, the risks to watch, and the questions to resolve — before a single line is written.

## How to work

1. **Understand the task precisely.** Restate it in your own words. If it is ambiguous, list the interpretations and pick the most likely one — note it as an assumption.
2. **Read the repo.** Explore entry points, existing patterns, related features, types, tests, and config. Do not guess at the structure.
3. **Map files likely to change.** Be specific: file path, what changes, and why. Flag files that look stable but might have unexpected coupling.
4. **Extract existing patterns to follow.** Naming conventions, error handling patterns, test structure, state management, API shape. The plan should fit the codebase, not import new idioms.
5. **Name the risks.** Breaking changes, shared state, missing abstractions, performance cliffs, migration needs, things that only work in dev.
6. **Write the test plan.** Unit, integration, edge case. If a requirement cannot be tested, flag it as underspecified.
7. **List out-of-scope items.** Things you considered and decided not to include. Prevents scope creep during implementation.
8. **List open questions and assumptions.** Anything unresolved must be named. Assumptions must be marked so the implementer can verify them.
9. **Write suggested implementation steps** in order. Steps should be atomic enough to verify individually.
10. **End with a review recommendation.** State which review skill(s) should run before coding starts, and why.

## When to add a review before implementing
- Feature touches user-facing flows → [[product-plan-review]]
- Feature touches architecture, APIs, or data models → [[engineering-plan-review]]
- Feature touches UI or UX → [[design-plan-review]]
- Idea not yet validated → [[spec]] or [[office-hours]] first

## Output format

```markdown
# Implementation Plan
## Task understanding
## Files likely to change
| File | What changes | Why |
|---|---|---|
## Existing patterns to follow
## Risks
## Test plan
## Out of scope
## Open questions / assumptions
## Suggested implementation steps
1.
2.
...
## Recommended review before coding
```

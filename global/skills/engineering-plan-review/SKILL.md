---
name: engineering-plan-review
description: Review an implementation plan like an engineering manager or tech lead before any code is written. Use when the user says "engineering review", "tech review", "review this implementation plan", or shares a plan and wants a hard look at architecture, failure modes, and edge cases.
---

## Tool contract
Read-only investigation only. The review is the only artifact. Do not edit code unless explicitly asked.

## Purpose
Catch architectural mistakes, missing failure modes, and untested edge cases before they are locked in by code. An engineering review is not about style — it is about whether the plan will actually work under real conditions.

## How to work

1. **Read the plan and the repo.** Check existing patterns: how is state managed, how are errors handled, how are tests structured. The review must be grounded in the actual codebase.
2. **Assess architecture.** Does the structure match the problem? Are there unnecessary layers or missing ones?
3. **Map system boundaries.** What calls what? Where are the trust boundaries? What is owned vs. external?
4. **Trace data flow.** Where does data enter, transform, and persist? Are there race conditions or ordering assumptions?
5. **List state transitions.** What are the valid states? What are the invalid ones? What happens if you arrive in an unexpected state?
6. **Force failure modes.** For each external call, network boundary, and write operation: what happens when it fails? Is it retried? Is it idempotent?
7. **Check edge cases.** Empty input, max-size input, concurrent writes, clock skew, missing permissions, partial success.
8. **Review trust boundaries.** Is user input validated? Are there privilege escalation paths? Is anything over-permissioned?
9. **Assess test plan.** Are unit, integration, and edge-case tests specified? Can the plan be tested without shipping?
10. **Evaluate rollout and rollback.** Can this be deployed incrementally? Is there a kill switch? What breaks if you revert?
11. **Suggest diagrams** where a picture is worth 500 words of review comments.

## Related skills
- [[product-plan-review]] — pair with a product review; different questions, same plan
- [[design-plan-review]] — if the plan touches UI, add a design review pass
- Matching subagent: **engineering-manager**

## Output format

```markdown
# Engineering Plan Review
## Verdict
## Architecture
## System boundaries
## Data flow
## State transitions
## Failure modes
## Edge cases
## Trust boundaries
## Test plan
## Rollout / rollback
## Diagrams to create
## Required changes before implementation
```

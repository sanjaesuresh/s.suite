---
name: ai-slop-cleanup
description: >
  Review code or a diff for AI-generated slop: unnecessary abstractions, generic
  naming, over-commenting, duplication, unused helpers, fake error handling, silent
  fallbacks, catch-all exceptions, premature extensibility, style inconsistency, and
  tests that don't prove behavior. Use when something smells over-engineered, when a
  PR looks like it was generated wholesale, or before a code review to pre-clean.
  MAY apply fixes only when explicitly asked.
argument-hint: "[path | 'current diff']"
---

## Tool contract

This skill MAY edit files, but only when the user explicitly says "apply fixes" or
"clean it up." When editing, prefer minimal, behavior-preserving changes. Do not
refactor logic, rename symbols project-wide, or change public APIs without explicit
instruction. When in doubt, report only.

## What counts as AI slop

- **Unnecessary abstraction**: interfaces or wrapper classes that wrap a single
  concrete type with no polymorphism planned or present
- **Generic naming**: `handleData`, `processItem`, `doThing`, `Manager`, `Helper`,
  `Util` — names that say nothing about what the code actually does
- **Over-commenting**: comments that restate the code (`// increment i by 1`)
  rather than explain intent
- **Duplication**: nearly identical blocks copy-pasted instead of extracted
- **Unused helpers**: functions or variables defined but never called
- **Fake error handling**: `catch (e) { console.log(e) }` or swallowed errors
  that leave the system in an undefined state
- **Silent fallbacks**: returning `null`, `[]`, or `{}` on error without logging
  or surfacing the failure
- **Catch-all exceptions**: `except Exception` / `catch (e: any)` hiding real failures
- **Premature extensibility**: plugin systems, strategy patterns, or factory
  hierarchies for code that has exactly one use case
- **Style inconsistency**: naming or formatting conventions that differ from the
  rest of the file or module
- **Tests that don't prove behavior**: tests that would pass if the function returned
  a hardcoded stub

## How to work

1. Read the argument (or `git diff HEAD` if none). Read the surrounding file context
   for any suspicious block — do not flag things without understanding intent.

2. For each finding, confirm it is actually slop and not intentional design. Check
   if there's a comment or test explaining why the pattern exists.

3. Rate overall slop level: Clean / Minor / Significant / Generated-looking.

4. If asked to apply fixes: make the minimal change, preserve behavior exactly,
   and list every file touched.

## Output format

```markdown
# AI Slop Cleanup

## Overall assessment
Clean / Minor slop / Significant cleanup needed / Generated-looking
(One sentence explaining the rating.)

## Findings
### 1. [file:line] — <slop type>
**Why it looks like slop:** ...
**Why it matters:** ...
**Simpler alternative:** ...

### 2. ...

## Suggested cleanup order
(Prioritized list: tackle in this order to get the most improvement with least risk.)
```

(If the user asked to apply fixes: list each changed file and what changed, keeping
descriptions brief and behavior-focused.)

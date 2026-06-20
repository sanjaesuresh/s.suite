---
name: debugging-incident-review
description: >
  Investigate a bug or production incident methodically. Use when something is broken
  and you want to find the root cause before touching code — not just guess and patch.
  Works for runtime errors, wrong output, flaky tests, performance regressions, and
  anything where the symptom is known but the cause is not.
argument-hint: "[symptom description | error message | incident ID]"
---

## Hard rule

**No fixes without investigation.** Do not propose a fix until the root cause is
confirmed or explicitly stated as the most likely hypothesis after elimination.
Random changes that "might help" make the problem harder to diagnose.

Consider activating [[freeze]] to lock the scope of edits during diagnosis.

## Tool contract — READ-ONLY

Investigate and report. Do not modify files during the investigation phase.
Only propose a fix after a root cause is identified, and only implement if asked.

## How to work

1. **Capture the symptom exactly**: What fails, when, with what error or wrong output?
   Get the full stack trace or log output if available. Do not paraphrase.

2. **Reproduce**: Identify the minimal condition that triggers the failure. If it
   cannot be reproduced, say so explicitly — do not guess at cause.

3. **Trace data flow**: Follow the data from input to failure point. Read the code
   path, not just the error location. Check callers, not just the failing function.

4. **Build a hypothesis tree**: List every plausible cause. Rank by likelihood.
   For each: what evidence supports it, what evidence contradicts it, how to test it.

5. **Test hypotheses**: Check logs, read code, look at recent commits (`git log -p`),
   check config and env differences. Do not modify code to test a hypothesis unless
   it is clearly reversible and the user agrees.

6. **Reassess after failed attempts**: If the first hypothesis is wrong, stop and
   rebuild the tree. Do not keep probing randomly.

7. **Confirm root cause**: State it with evidence before proposing any fix.

## Output format

```markdown
# Debugging / Incident Review

## Symptom
(Exact error, stack trace, or wrong behavior. File:line if known.)

## What I verified
- Checked `file:line` — finding
- Ran `command` — output
- ...

## Hypotheses (ranked)
| # | Hypothesis | Evidence for | Evidence against | How to test |
|---|---|---|---|---|
| 1 | ... | ... | ... | ... |

## Most likely root cause
(State with evidence. If unconfirmed, say so.)

## Suggested validation
(How to confirm the root cause before fixing.)

## Recommended fix
(Only after root cause is confirmed. Be specific — file, line, change.)

## If still unconfirmed
(What to instrument or log next to narrow it down.)
```

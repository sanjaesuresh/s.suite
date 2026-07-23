---
name: context-save
description: Save the current working context (task, decisions, git state, remaining work, risks) to a project-local file so a future session can resume. Use when the user says "context save", "save context", "checkpoint this", "I'm stopping for now", or before a long break / handoff.
---

# context-save

Capture enough state that a future Claude Code session resumes without backfill.

## Tool contract

Read-only except for writing the single context file (and creating its
directory). Do not modify project code.

## Where it saves (default: project-local, gitignored)

Default target: `.claude/context/current-session.md` in the current repo.

- This is **project-local** so work context stays with the work, not in any
  global or synced location.
- Ensure it is gitignored. If `.claude/context/` is not already ignored, add it
  to the repo's `.gitignore` (or `.git/info/exclude`) and tell the user.
- Only save elsewhere (e.g. a global path) if the user **explicitly** asks. Never
  save work context into `~/.claude` or the toolkit repo.

## Steps

1. Run the helper to gather git state and run a secret/PII pre-scan:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/context-save.sh"
   ```

2. **Review the SECRET-SCAN output.** If it flags anything (keys, tokens,
   private email/PII, internal identifiers), STOP and warn the user. Do not copy
   flagged content into the saved file. Redact or omit.

3. Compose the context file using the format below. Keep it tight — summaries,
   not code dumps. Do **not** paste large code excerpts unless the user asks.

4. Write to `.claude/context/current-session.md`. Confirm the path and that it's
   gitignored.

## Work-safety rules (IMPORTANT)

- This file may capture in-flight work. In a work/employer repo, keep it
  **local and ignored** — never sync it into the private toolkit repo or global
  memory.
- Do not persist secrets, tokens, internal URLs, service/repo names you
  shouldn't externalize, logs, or stack traces. Summarize behavior instead.
- If unsure whether something is sensitive, leave it out and note "omitted —
  sensitive".

## Format

```markdown
# Saved context — <branch> — <date>

## Current task
What I'm actually working on, in one or two sentences.

## Status
On track / blocked / mid-refactor / debugging — plus a one-line why.

## Decisions made (don't re-litigate)
- <decision> — <short rationale>

## Files touched
- path — what changed / why

## Remaining work
- [ ] next concrete step
- [ ] ...

## Validation status
What's been run (tests/lint/build) and the result. What still needs verifying.

## Open risks / questions
- <risk or open question>

## Git state
branch, last commit, uncommitted summary (from the helper).
```

## Related

- `/context-restore` to resume. See [[context-restore]].

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

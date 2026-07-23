---
name: pr-description
description: >
  Generate a pull request description grounded in the actual diff and validation
  performed. Use when you're about to open a PR and want a description that tells
  reviewers what actually changed and why, not a vague summary. Runs git diff and
  git log to avoid fabricating details.
---

## Tool contract — READ-ONLY

Investigate and report. Does not open or push a PR unless the user explicitly asks.
For opening PRs, the user should invoke the PR creation flow separately.

## How to work

1. **Ground the diff**: Run `git diff main...HEAD` (or `git diff HEAD~1` if on main).
   Also run `git log main...HEAD --oneline` to get the commit history.

2. **Read changed files**: For non-trivial changes, open the key files to understand
   intent — especially if the diff alone is ambiguous.

3. **Identify**: What behavior changed? What stayed the same? What is the scope?
   What tests were added or modified?

4. **Validation**: Check if tests pass, lint is clean, or any CI results are visible.
   Report what was actually verified, not what should theoretically be verified.

5. **Risks**: Flag anything that might break consumers, require a deploy step, touch
   data migrations, change a public API, or require reviewer attention.

6. **Reviewer notes**: Call out lines that are subtle, unintuitive, or where a design
   decision was made — anything a reviewer might ask about.

7. Do not pad the description. Omit sections that have nothing to say.

## Output format

```markdown
# PR Description

## Summary
(1–3 sentences. What this PR does and why. Do not restate the title.)

## Changes
- `path/to/file.ts` — what changed and why
- ...

## Validation performed
- [ ] Tests: <what ran, result>
- [ ] Lint/typecheck: <result>
- [ ] Manual: <what was checked, if anything>

## Risks / rollout notes
(Migrations, feature flags, env vars, deploy order dependencies. Omit if none.)

## Reviewer notes
(Lines or decisions that deserve extra scrutiny. Quote file:line if specific.)
```

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

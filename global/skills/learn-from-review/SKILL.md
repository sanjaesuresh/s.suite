---
name: learn-from-review
description: Turn a PR review comment into a durable toolkit rule so the same mistake isn't repeated. Generalizes the comment to its class, finds the right home (CLAUDE.md, a skill, or an agent), and records it. Use after PR feedback, or say "learn from this review", "capture this lesson", "/learn-from-review".
---

# learn-from-review

Convert PR review feedback into a **durable, generalized** improvement to this
toolkit, so the same **class** of mistake is prevented next time — not just
fixed once. A reviewer caught something; this skill makes sure the toolkit
learns it.

This is for **continuous toolkit improvement**. It edits the toolkit's own
files (`~/.claude/CLAUDE.md`, `~/.claude/skills/*`, `~/.claude/agents/*`) — which load in
every future session — and logs each lesson to `~/.claude/LESSONS.md`.

## Trigger

Manual. You invoke it after receiving review feedback. Accept any of:
- pasted comment text,
- a PR number (pull the comments via the `github-pat` MCP),
- a pointer to the commit/diff/branch the comment was about.

## HARD GATE — never leak work-specific information

Before writing to ANY `~/.claude/` file, strip every work-specific identifier:
repo/service names, internal URLs, real pasted code, secrets, tokens, stack
traces. Generalize the lesson so it would make sense in any project. **If the
lesson cannot be generalized without leaking, do NOT write to a global file** —
say so and recommend a project-local note instead. This overrides the desire to
record something.

## The loop

Do these in order. Create a todo per step.

### 1. Gather

Collect the comment(s) and the code they refer to. If given a PR number, fetch
the review comments via `github-pat`. If the MCP is unavailable, ask the user to
paste the comment. Read the offending diff so the lesson is grounded in what
actually happened — not a paraphrase.

### 2. Diagnose root cause

Separate the **surface fix** ("add a null check here") from the **class** of
mistake ("validate external inputs at trust boundaries"). The class is what gets
recorded. State it in one sentence. If the comment is a one-off with no
generalizable lesson (a typo, a pure matter of taste), stop here and say so —
not every comment yields a toolkit edit.

### 3. Gap-scan the toolkit

Search the toolkit for whether this class is already covered:

```bash
ls ~/.claude/skills ~/.claude/agents
grep -ri "<keyword from the class>" ~/.claude/CLAUDE.md ~/.claude/skills ~/.claude/agents
```

Pick the single best home:
- a general behavior rule → `~/.claude/CLAUDE.md` or a build skill (e.g. `software-engineer`);
- a review blind spot → the matching reviewer agent (e.g. `security-reviewer`, `ai-slop-detector`);
- a workflow gap → the relevant skill.

If the class is **already well covered**, stop and say so. Do not add a
redundant rule. If two files could host it, carry both into the step-4 brief and
let the user choose.

### 4. Sanitize + generalize

Apply the HARD GATE above. Rewrite the lesson as a project-agnostic rule. Draft
the exact edit: which file, the precise before/after text, in the voice and
format of that file.

### 5. Propose the edit (decision brief)

Show the user, and get explicit confirmation before writing — this edits durable
global files:
- **Target file:** `<path>`
- **Class of mistake:** one sentence
- **Edit:** the exact before → after
- **Rationale:** one line on why this is the right home

### 6. Apply + record

After approval:
1. Make the edit to the target file.
2. Gather metadata: `git rev-parse --abbrev-ref HEAD` (branch),
   `date '+%Y-%m-%d %H:%M %Z'` (timestamp), PR number if known.
3. Dedup: scan existing **Root cause / class** lines in `~/.claude/LESSONS.md`. If
   this class is already logged, update that entry instead of adding a duplicate.
4. Prepend a new entry to `~/.claude/LESSONS.md`, directly below the
   `<!-- New entries... -->` marker:

```
### YYYY-MM-DD HH:MM TZ — <one-line class of mistake>

- **Branch:** <branch the review was on>
- **PR:** #N (or "n/a")
- **Comment:** <the review comment, sanitized — verbatim quote, trimmed>
- **Root cause / class:** <the generalized mistake, one sentence>
- **Fix applied to toolkit:** <file changed> — <one-line what changed>
```

## Edge cases

- **No clear class** → record nothing; say why.
- **Already covered** → stop at step 3; no edit, no ledger entry.
- **Cannot sanitize** → stop at step 4; recommend a project-local note.
- **MCP unavailable** → fall back to pasted comment text.
- **Ambiguous home** → present the choice in the step-5 brief; don't guess.

## What not to do

- Don't write the surface fix as the lesson — record the class.
- Don't pile a redundant rule onto something already covered.
- Don't let any work-specific identifier reach a `~/.claude/` file.
- Don't edit a global file without explicit confirmation in step 5.

## Keeping the toolkit repo in sync

If you maintain the toolkit as a git repo (e.g. `s-suite`), mirror any edits made to `~/.claude/CLAUDE.md`, `~/.claude/skills/*`, or `~/.claude/LESSONS.md` back into the repo's `global/` copy and commit — otherwise the installed changes will be overwritten the next time `install.sh` runs.

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

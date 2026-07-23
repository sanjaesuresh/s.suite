# Prompt: Scaffold a New Claude Code Skill

Paste this into Claude Code to create a new skill. Claude will ask for missing details before generating files.

---

## Instructions for Claude

If the user has not described what this skill should do, ask:

1. What is the skill's purpose in one sentence?
2. What exact phrases or situations should trigger it? (Give 2–4 examples of user messages that should invoke it.)
3. Will this skill be used across all projects (global) or only in this repo (project-specific)?
4. Does it need to write/modify files, or is it read-only by nature?

Once you have answers, produce the following. Be concrete and direct — no filler.

---

## Deliverables

### 1. Recommended Skill Folder Name

Kebab-case. Match what the skill does, not what it sounds like. Examples: `security-review`, `db-migration-check`, `api-doc-audit`. One word if the scope is narrow enough.

### 2. Full SKILL.md

Use this skeleton and fill every field:

```markdown
---
name: <skill-name>
description: >
  <One to three sentences. Front-load the trigger phrases so auto-dispatch
  matches early. Example: "Use when the user asks to review, audit, or check
  security in any code. Covers auth, input validation, secrets, dependency
  risk, and OWASP top-10 patterns.">
argument-hint: "<optional: what to pass as args, e.g. 'a PR number or branch name'>"
---

# <Skill Display Name>

## When to use

- <Concrete trigger 1>
- <Concrete trigger 2>
- <Concrete trigger 3>

## When NOT to use

- <Anti-trigger 1: be specific about what this skill does not cover>
- <Anti-trigger 2>

## What this skill does

<Step-by-step description of the skill's behavior. Number the steps.>

1. ...
2. ...
3. ...

## Output format

<Describe the exact output structure. If it produces sections, name them here.
If it separates blockers from suggestions, say so explicitly.>

**Blockers** — must be fixed before merge/deploy. Each item: finding + file:line + why it matters + fix.
**Suggestions** — worth doing but not blocking. Same format.
**Observations** — neutral notes, no action required.

## House style rules

- Instructions are numbered steps — one action per step, the exact command/file/check in the step itself. NEVER write a procedure as a paragraph.
- Hard gate words for hard rules: DO NOT / NEVER / SKIP / ABORT / STOP. No hedging ("consider", "you may want to").
- Spec the output order explicitly (see Output format) and keep answers answer-first: outcome on line one, context after.
- Skeptical, concrete voice. Never say "it appears", "it seems", "I noticed", "I found", "great", "excellent".
- Every finding must cite evidence (file path + line or specific code).
- Gate confidence: if uncertain, say "unverified — check X manually" rather than asserting.
- Separate blockers from suggestions. Never bundle them.
- No AI-tell vocabulary: avoid "certainly", "absolutely", "of course", "happy to", "as an AI".
- Read-only by default for review/audit skills. Do not modify files unless the skill is explicitly a fix/apply skill.

## Example invocations

- `/<skill-name>`
- `/<skill-name> PR #42`
- `/<skill-name> src/auth/`
```

### 3. Supporting Files / Scripts

List any helper scripts the skill needs (e.g., a bash script it calls, a config file it reads). If none are needed, say so explicitly. For each file, provide full content.

### 4. Example Invocation Prompts

Give 3–5 user messages that should trigger this skill, ranging from exact to natural-language variants.

### 5. Eval Checklist

How to verify the skill is working correctly:

- [ ] Trigger test: does pasting `/<skill-name>` invoke it without extra prompting?
- [ ] Argument test: does passing a file path or PR number constrain scope correctly?
- [ ] Blocker vs. suggestion: are these two categories kept separate in output?
- [ ] Evidence test: does every finding include a file path and/or line number?
- [ ] No false read-only violation: if the skill is read-only, does it refrain from writing files?
- [ ] Voice test: re-read output — remove any filler, hedging, or AI-tell phrases.
- [ ] Scope creep test: does the skill stay within its declared purpose?

### 6. Global vs. Project-Specific

Decide and justify:

- **GLOBAL** (`~/.claude/skills/`): only if the skill contains zero proprietary context and is useful across all repos. Examples: generic security review, code style audit, commit message linter.
- **PROJECT-SPECIFIC** (`.claude/skills/`): if the skill references project conventions, domain terms, internal APIs, or anything an employer/client owns. When in doubt, keep it project-specific.

State which and why.

### 7. Work-Safety Assessment

Answer: is this skill safe to store in a shared or public toolkit repo?

- **SAFE**: skill contains no employer names, internal system names, proprietary logic, or confidential domain knowledge. Generic patterns only.
- **NOT SAFE**: skill encodes project-specific details. Keep it in the project repo only; do not copy it to any synced or public toolkit.

State which and why.

---

## Minimal SKILL.md Skeleton

If you want to start from scratch without running this full prompt:

```markdown
---
name: my-skill
description: >
  Use when the user asks to ... Covers ...
---

# My Skill

## When to use
-

## When NOT to use
-

## What this skill does
1.

## Output format
**Blockers** —
**Suggestions** —

## Example invocations
- `/my-skill`
```

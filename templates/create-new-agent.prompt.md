# Prompt: Scaffold a New Claude Code Subagent

Paste this into Claude Code to create a new subagent definition. Claude will ask for missing details before generating files.

---

## Instructions for Claude

If the user has not described what this agent should do, ask:

1. What is the agent's purpose in one sentence?
2. What tasks will it be delegated? Give 2–4 concrete examples.
3. Does it need to write or modify files, or is it read-only?
4. Is there a specific codebase or domain context it needs to know?
5. Global (reusable across projects) or project-specific?

Once you have answers, produce the following. Be concrete — no filler.

---

## Deliverables

### 1. Recommended Agent Name

Kebab-case. Name it after what it does, not what it is. Examples: `security-auditor`, `migration-planner`, `test-gap-finder`, `api-contract-checker`. Prefer nouns that imply a role.

### 2. Full Agent Markdown File

Place at `.claude/agents/<agent-name>.md` (project) or `~/.claude/agents/<agent-name>.md` (global).

Use this skeleton and fill every field:

```markdown
---
name: <agent-name>
description: >
  <One to three sentences. Front-load delegation triggers. Example: "Use this
  agent for security audits, vulnerability review, and dependency risk
  assessment. Specializes in auth, input validation, secrets exposure, and
  OWASP top-10 patterns. Delegate when the user asks to review security
  in any file, PR, or module.">
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
---

# <Agent Display Name>

## Role

<One paragraph. What does this agent do? What lens does it apply?>

## When to delegate to this agent

- <Concrete case 1>
- <Concrete case 2>
- <Concrete case 3>

## When NOT to delegate to this agent

- <Anti-case 1: be specific>
- <Anti-case 2>

## Behavior

<Numbered steps describing how the agent approaches a task.>

1. ...
2. ...
3. ...

## Output format

<Exact structure the agent must produce. Name every section.>

**Blockers** — must be fixed before merge/deploy. Format: finding + file:line + why + recommended fix.
**Suggestions** — worth doing, not blocking. Same format.
**Observations** — neutral notes, no action required.

## House style rules

- Instructions and procedures are numbered steps — one action per step. NEVER describe a procedure in a paragraph.
- Hard gate words for hard rules: DO NOT / NEVER / SKIP / ABORT / STOP. No hedging.
- Answer-first output: verdict or key finding on line one, evidence after.
- Skeptical, evidence-grounded voice. Every claim must cite a file path, line number, or specific code.
- Confidence-gated: if a finding is unverified, say "unverified — check X manually" rather than asserting it as fact.
- Separate blockers from suggestions. Never bundle them under a generic "issues" heading.
- No AI-tell vocabulary: avoid "certainly", "absolutely", "of course", "happy to", "great", "excellent", "I found", "it appears", "as an AI".
- Read-only by default: do not write or modify files unless the agent is explicitly a fix/apply agent.
- Do not encode proprietary context. Keep all employer/project-specific knowledge in the project's CLAUDE.md, not in this agent file.
```

### 3. Recommended Tools

Default to the minimum set. Expand only with explicit justification.

| Tool | Include? | When to add |
|---|---|---|
| Read | Always | Core — file reading |
| Grep | Always | Pattern search |
| Glob | Always | File discovery |
| Bash | Default yes | Shell commands, test runners, linters |
| Edit / Write | Only for fix agents | Explicitly applying changes |
| WebFetch / WebSearch | Only if agent needs external docs | API specs, CVE lookups |
| mcp__* tools | Only for specific integrations | GitHub, Supabase, etc. |

State which tools this agent uses and why each is included.

### 4. Recommended Model

- **sonnet** (default): fast iteration, code generation, most review tasks, summarization, search-heavy work.
- **opus** (upgrade for): deep-reasoning tasks — security architecture review, complex debugging, migration planning, multi-file refactor analysis, tasks where a missed edge case has high cost.

> Aliases resolve to current models: `sonnet` → Sonnet 5, `opus` → Opus 4.8. `haiku` is also available.

State which model and why.

### 5. When to Use This Agent

List 3–6 concrete delegation scenarios. Be specific enough that an orchestrator can match them.

### 6. When NOT to Use This Agent

List 2–4 explicit anti-cases. This prevents misrouting.

### 7. Example Prompts

Give 4–6 user messages that should cause the orchestrator to delegate to this agent.

### 8. Safety Considerations

Answer all three:

- **Read-only?** Will this agent ever write or modify files? If yes, document which tools enable that and why it is necessary.
- **Proprietary info risk?** Could this agent, if made global, expose internal system names, domain knowledge, or confidential patterns? If yes, keep it project-specific only.
- **Data leakage risk?** Does this agent receive secrets, credentials, or PII as part of its input? If yes, note that and ensure it does not log or repeat them.

### 9. Global vs. Project-Specific

- **GLOBAL** (`~/.claude/agents/`): only if the agent contains zero proprietary context and is generically useful. All project-specific knowledge must stay in CLAUDE.md, not in the agent file itself.
- **PROJECT-SPECIFIC** (`.claude/agents/`): if the agent references internal APIs, domain terms, project conventions, or employer-owned context.

State which and justify.

---

## Minimal Agent Skeleton

To start from scratch without running this full prompt:

```markdown
---
name: my-agent
description: >
  Use this agent for ... Delegate when the user asks to ...
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: sonnet
---

# My Agent

## Role


## When to delegate

-

## When NOT to delegate

-

## Output format

**Blockers** —
**Suggestions** —
```

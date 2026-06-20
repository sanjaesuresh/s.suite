---
name: product-plan-review
description: Review a feature plan through a product and founder lens before any code is written. Use when the user says "review this plan", "does this make sense to build", "product review", or shares a feature spec or PRD and wants a second opinion on scope, value, and framing.
---

## Tool contract
Read-only investigation only. The review is the only artifact. Do not edit code unless explicitly asked.

## Purpose
Catch product mistakes before they become sunk engineering costs. This review asks whether the right thing is being built, not just whether it will be built correctly.

## Modes
Ask the user which mode to use before starting. Default: **Hold scope**.

| Mode | What it does |
|---|---|
| **Expansion** | Dream bigger — what should this become? Explore adjacent value and longer-term positioning. |
| **Selective expansion** | Optional upgrades only — suggest additions that are clearly worth their cost; skip the rest. |
| **Hold scope** | Rigorously improve the current scope without adding features. Sharpen, not grow. |
| **Reduction** | Cut to the smallest version that still delivers real user value. |

If the user does not specify, say: "I'll default to **Hold scope** — reply with a mode name to switch."

## How to work

1. **Read the plan and the repo.** Check existing features, data models, and patterns. Review against what is actually built, not a blank slate.
2. **State the current framing** in one sentence. Is it a solution or a problem statement?
3. **Propose a better framing** if the current one is off. A bad frame produces a correct answer to the wrong question.
4. **Apply the chosen mode** strictly. In Reduction mode, every item must justify its existence. In Expansion, every suggestion must tie to real user value.
5. **Separate "what should change" from "what should stay out of scope"** — both matter.
6. **Assess user value.** Is this solving a real, recurring pain? For whom? How often?
7. **Name risks.** Scope creep, wrong user segment, shipping the 10% that drives 0% of the value.
8. **Give a single recommended product decision** at the end.

## Related skills
- [[office-hours]] — if the idea has not been challenged yet, do that first
- [[engineering-plan-review]] — pair this with a technical review once product shape is settled
- Matching subagents: **product-strategist**, **founder-reviewer**

## Output format

```markdown
# Product Plan Review
## Verdict
## Current framing
## Better framing
## What should change
## What should stay out of scope
## User value
## Risks
## Recommended product decision
```

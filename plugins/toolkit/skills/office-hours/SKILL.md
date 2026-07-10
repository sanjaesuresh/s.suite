---
name: office-hours
description: Challenge a product idea like a YC founder-mentor before any planning or coding begins. Use when the user says "office hours", describes a product idea, asks "what should I build", "is this the right approach", or wants a gut-check before committing to a direction.
---

## Tool contract
Read-only investigation only. The plan is the only artifact. Do not edit code unless explicitly asked.

## Purpose
Force the user to think before they build. Most ideas arrive half-formed; office hours surfaces the real problem, the riskiest assumption, and the smallest thing worth shipping. It does not validate — it interrogates.

## How to work

1. **Read first.** If there is a repo open, scan `README`, key entry points, and any existing feature code before forming opinions. Ground everything in the actual project, not a generic version of it.
2. **Reframe the problem.** Ask: what is the user actually trying to fix? Does the stated idea address that, or is it one layer removed?
3. **Apply the forcing questions below** — answer each one honestly, even if the answer is uncomfortable.
4. **State the 10-star version.** What would this look like if there were no constraints? (Useful for finding the direction, not the literal roadmap.)
5. **State the smallest useful version.** What is the minimum that would confirm or deny the core assumption?
6. **Name the riskiest assumption.** The one thing that, if wrong, invalidates the whole plan.
7. **Decide what NOT to build.** Scope-creep starts here; kill it early.
8. **Give a concrete recommended next step.** One action, not a list.

## Forcing questions
- Who specifically is in pain, and what are they doing today instead?
- Is the framing too narrow (solving a symptom) or too broad (solving everything)?
- What makes this meaningfully better than the obvious alternative?
- What makes users come back on day 7, not just day 1?
- What is the wedge — the single use case that earns the right to expand?
- What is the obvious-but-wrong solution to this problem?
- If you shipped nothing and the user had to wait 3 months, what would they do?

## Related skills
- [[brainstorming]] — once the idea survives office hours, turn it into a design before implementation
- Matching subagent: **founder-reviewer** — if a plan already exists, review it through a product/founder lens

## Output format

```markdown
# Office Hours
## Reframed problem
## User pain
## Strongest version of the idea
## Smallest useful version
## Hidden assumptions
## Risks
## What not to build
## Recommended next step
```

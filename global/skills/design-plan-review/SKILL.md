---
name: design-plan-review
description: Review a frontend or product UX plan like a designer who codes, before implementation. Use when the user says "design review", "UX review", "does this UI make sense", or shares wireframes, mockups, or a frontend plan and wants a structured critique.
---

## Tool contract
Read-only investigation only. The review is the only artifact. Do not edit code unless explicitly asked.

## Purpose
Catch UX mistakes before they are pixel-perfect and hard to change. This review evaluates clarity, hierarchy, interaction, accessibility, edge states, and whether the plan is over-engineered for what users actually need.

## How to work

1. **Read the plan and the existing UI code.** Check component patterns, design tokens, existing screens. Review against what is actually built.
2. **Rate each dimension** on the scorecard (0–10). Be specific about what earns or loses points.
3. **State the biggest UX risks** — the things most likely to confuse, block, or lose users.
4. **Give concrete recommended changes.** Not "improve hierarchy" — "move the CTA above the fold and reduce the label from 14 words to 3."
5. **Name what not to overbuild.** Most UX mistakes are additions, not omissions. Flag animations, modals, and multi-step flows that are not yet earned.
6. **Check every state.** Loading, empty, error, partial success, zero-data, max-data, mobile viewport.
7. **Check copy.** Labels, button text, error messages, empty-state messages. Copy is UX.

## Dimensions to rate
- Visual clarity and hierarchy
- Spacing and density
- Interaction model (clicks, taps, flows)
- Accessibility (contrast, focus order, ARIA, keyboard)
- Empty states
- Error states
- Mobile responsiveness
- Visual consistency with existing UI
- Copy quality

## Related skills
- [[engineering-plan-review]] — pair when the plan has both UX and backend components
- [[product-plan-review]] — if the feature scope itself is in question, review product first
- Matching subagent: **design-reviewer**

## Output format

```markdown
# Design Plan Review
## Verdict
## Scorecard
| Dimension | Score / 10 | Why | What a 10 looks like |
|---|---:|---|---|
## Biggest UX risks
## Recommended changes
## Do not overbuild
```

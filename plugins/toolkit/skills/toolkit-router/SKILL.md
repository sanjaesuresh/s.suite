---
name: toolkit-router
description: "Orchestration layer for non-trivial coding work. Enforces the planning gate (a written plan plus explicit approval before medium-or-larger changes) and routes between overlapping toolkit skills. Consult at the start of any build, fix, plan, or review task, before acting."
---

# toolkit-router

The orchestration layer for this toolkit. When a coding task starts, this skill
decides two things: whether a plan is required before any code, and which of the
overlapping skills to reach for. It replaces the routing and planning discipline
that otherwise lives only in a hand-written global `CLAUDE.md`.

## Planning gate (non-negotiable)

For any full project or medium-sized-or-larger feature, produce a **written plan
file** and get the user's **explicit approval** BEFORE writing or editing any
non-trivial code. During planning, the plan is the only artifact — no code.

- A detailed spec from the user is **not** approval to start coding. A spec says
  WHAT; you still owe a plan for HOW — scope boundaries, out-of-scope, risks,
  assumptions, and a test plan — then you wait for the go-ahead.
- Write the plan to a file — default `docs/<feature>-plan.md`, or the path the
  spec designates — and keep it updated if scope changes. Chat gets a short prose
  summary, not the whole plan. A chat-only plan does not satisfy this gate.
- Plans and approval requests are **prose only**: plain English, no code blocks
  or diffs. Literal code appears only during implementation, after approval.

**Plan-first is REQUIRED when any of these is true:**

- more than ~100 lines meaningfully changed;
- new modules, new dependencies, or schema / migration / API-contract changes;
- anything touching architecture, data flow, money/trading logic, auth,
  security, or persistence;
- a multi-step build (scaffold + wire-up + tests);
- the user asked to "build / implement / create" a feature or project.

**Only exceptions** (may implement without an approved plan): a genuinely small
change (a typo, a one-liner, an obvious localized fix), or a change that needs
little thinking and has a small, contained blast radius. If unsure whether
something qualifies as small, treat it as NOT small and plan first.

## Routing between overlapping skills

Each skill's own description says what it does; this is the tie-break when more
than one could fire. Invoke **process skills first** (brainstorming, planning,
kickoff), then implementation skills.

- **Build / fix (default):** `software-engineer` — it already bakes in
  test-first and verify-before-done, so don't run a separate verification pass
  alongside it. "Build X" → brainstorm/plan first; "Fix bug Y" →
  `systematic-debugging` first.
- **Web UI:** `frontend-engineer`, not `software-engineer` — it adds
  accessibility, Core Web Vitals, and every-state gates. Use
  `frontend-design` for open-ended creative direction only, then build with
  `frontend-engineer`.
- **Execute a plan:** `subagent-driven-development` (default, when the Agent tool
  is available); `dispatching-parallel-agents` for ad-hoc fan-out with no written
  plan.
- **Plan artifact:** `writing-plans`.
- **New work:** `jira-ticket` when there's a Jira key + MCP access; else
  `kickoff` (the paste / no-API front door) → then `writing-plans`.
- **Debug a root cause:** `systematic-debugging`.
- **CI red:** `ci-watch`. **Ship:** `pre-pr-review` → `ci-watch` →
  `finishing-a-development-branch` → `pr-description`. **Release:** `release`.
- **Review a plan:** `engineering-plan-review` (engineering), `design-plan-review`
  (UX), or `plan-pipeline` to run all angles at once.
- **Analyze:** `health-check`, `safe-refactor-plan`, `researcher` (external
  research), `learn-codebase` (how THIS repo works).

Treat rigid skills (`systematic-debugging`, `safe-refactor-plan`) as discipline
to follow exactly, not adapt away. An explicit user request or a project
`CLAUDE.md` overrides any routing here.

## What this plugin does NOT set

This skill carries the planning gate and routing only. Model tiering (plan on the
stronger model, build on the cheaper one), the voice rules, the decision-brief
format for presenting options, and the deny-list permissions for secret files are
**not** enforced by the plugin — they live in the optional `CLAUDE.md` template
and `settings.json` snippet in `docs/plugin-adoption.md`. Paste those into your
own `~/.claude/` setup if you want the full toolkit posture.

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

---
name: jira-ticket
description: >
  Work a Jira ticket end to end. Use when the user pastes a Jira key (e.g.
  MX125662) or says "work this ticket". Fetches it via the Atlassian MCP (or asks
  to connect/paste), searches the repo, proposes options, always plans (Opus),
  then implements via software-engineer (Sonnet) and runs tests.
argument-hint: "<jira ticket key, e.g. MX125662>"
---

# jira-ticket

The front door for Jira work. It owns only what nothing else does — **fetch the
ticket, keep the per-ticket doc, force a plan** — then hands the plan → implement
→ test loop to [[software-engineer]]. It does **not** re-implement that loop.

Flow: **resolve doc home → intake ticket → investigate repo → propose options →
plan (Opus, gated) → implement (Sonnet, delegated) → verify → summarize.**

## When to use

- The user pastes a Jira key (`MX125662`, `PROJ-1234`) or says "work this ticket".
- Starting work that originates from a Jira issue and should end in a tested fix
  with a written trail.

## When NOT to use

- New work with **no ticket** / paste-only, no MCP → [[kickoff]] (it stays on
  `main` for personal work and never touches ticket systems).
- Executing an **already-approved** written plan with several tasks →
  [[subagent-driven-development]].
- Reviewing an existing diff → [[pre-pr-review]]. Just understanding code →
  [[learn-codebase]].

## Model tiering

Planning and proposing run in **this** session (assumed Opus). Implementation is
**delegated** to the `software-engineer` subagent, which is pinned to **Sonnet**,
so the Opus-plan / Sonnet-build split happens automatically — no `/model`
switching. Return here (Opus) for the summary.

## Phase 0 — Resolve the doc home and filename

The per-ticket doc holds work-ticket content, so it must live in a folder git
**already ignores** — never commit ticket details, never edit `.gitignore`.

1. Find an already-ignored docs folder with `git check-ignore -q <path>`
   (exit 0 = ignored). Preference order: `docs/superpowers/`, then `docs/`,
   then any other docs dir the repo already ignores.
2. If one is ignored, use it. If **none** is ignored, **stop and ask** the user
   where to put the doc. Do not add anything to `.gitignore` to make room.
3. Filename = ticket key + a 3–5 word kebab summary of the fix intent, e.g.
   `MX125662-message-performance-fix.md`. You may not know the fix intent until
   after Phase 3 — start with a placeholder slug and rename once the approach is
   clear.

## Phase 1 — Intake the ticket (Atlassian MCP, with fallback)

1. **Find the MCP tools at runtime.** Do not hardcode tool names — Atlassian MCP
   builds differ. Use `ToolSearch` (e.g. query `atlassian jira issue`) to locate
   the get-issue / JQL-search tools, then fetch the issue by key.
2. **Pull:** summary, description, acceptance criteria, issue type, status,
   priority, comments, and linked issues. Read attachments' text if exposed.
3. **If the Atlassian MCP is not connected or not authorized:** say so plainly
   and give the user two ways forward — **(a) connect the Atlassian MCP now**,
   then re-run, or **(b) paste the ticket body** (title, description, acceptance
   criteria) and continue from the paste. Do not try to reach any internal URL
   yourself.
4. Write the ticket content into the doc's **Problem** section. **Scan for
   secrets/PII** in fetched or pasted text and warn before writing; never echo
   tokens. Never copy ticket content into any global file or this toolkit repo.

## Phase 2 — Investigate the repo

Answer your own questions from the code before asking the user. Dispatch
read-only subagents (`Explore`, `codebase-teacher`) so only summaries return to
this thread — find the relevant files, entry points, existing patterns, and
tests. Record the map in the doc.

## Phase 3 — Propose a solution and options

- If there is **one** sensible approach, state it and move on — don't invent
  forks.
- If there is a **genuine** fork (different libraries/architectures, a hard-to-
  reverse data choice, a scope boundary the ticket leaves open), present options
  in the **Decision-brief format** from the global CLAUDE.md: each option carries
  `Completeness: X/10`, dual effort `(human: ~… / AI: ~…)`, a `[one-way]`/
  `[two-way]` tag, and a one-line recommendation with the pick first. Use
  `AskUserQuestion` when the choice is genuinely the user's; gate `[one-way]`
  choices behind explicit confirmation.
- Write the chosen approach (and the options considered) into the doc.

## Phase 4 — Plan — HARD GATE (always, no bypass)

**Jira tickets always plan** — there is no trivial-change shortcut here.

1. Write the plan into the doc, plain English, **no code/diffs**: files likely to
   change, the approach grounded in real files, scope in/out, risks, assumptions,
   and the test plan. For real blast radius, consider an
   [[engineering-plan-review]] pass first.
2. **Request approval and name the doc path.** You may not start Phase 5 until
   the user approves. A pasted ticket is not approval to code.

## Phase 5 — Implement (Sonnet, delegated)

1. Branch first if not already on a work branch — propose a name
   (`sanjae-<team>-<number>-<short-name>`, matching existing branch style) and
   **wait for OK** before creating it.
2. Delegate the build: `software-engineer` for a single scoped change, or
   [[subagent-driven-development]] when the approved plan has multiple
   independent tasks. Both run on **Sonnet**. Pass them the doc path and the
   locked approach so they implement the smallest correct change.

## Phase 6 — Verify

Detect and run the project's tests / lint / typecheck (package scripts, Makefile,
CI config). Quote the **real** pass/fail output — never claim green without it.
If a PR exists and CI is red, hand to [[ci-watch]]. Record results in the doc.

## Phase 7 — Summarize

Append a **Summary** section to the doc and give a short prose version in chat,
with these headings:

- **Problem** — what the ticket needed, in two or three sentences.
- **Fix** — what changed and why; the files touched and the behavior now
  different (not a diff replay).
- **Risks** — what could still go wrong; edge cases and failure modes.
- **Mitigation** — how those risks are handled or bounded.
- **Test results** — the commands run and their evidence (pass/fail).
- **Next steps** — follow-ups, out-of-scope items, and the ship path
  ([[pre-pr-review]] → [[finishing-a-development-branch]] → [[pr-description]]).

**Do not auto-commit.** Ask before any `git commit` or `push`; name what would
go out.

## Doc skeleton

The living doc (in the gitignored folder) accretes across phases:

```markdown
# <TICKET-KEY> — <short fix title>

## Problem            (Phase 1: ticket content, acceptance criteria)
## Repo context       (Phase 2: relevant files, patterns, tests)
## Options considered  (Phase 3: only if there was a real fork)
## Plan               (Phase 4: approach, files, risks, test plan)
## Summary            (Phase 7: Problem / Fix / Risks / Mitigation / Test results / Next steps)
```

## Work-safety

- The doc lives **only** in an already-gitignored folder; never edit
  `.gitignore`; ask if nothing suitable is ignored.
- Never persist ticket content, keys, internal URLs, logs, or secrets into any
  global file, global memory, or this toolkit repo — project-local only.
- Scan fetched/pasted ticket text for secrets/PII and warn before writing.

## Related

- [[kickoff]] — no-ticket / paste-only front door that never touches ticket systems.
- [[software-engineer]] — the plan→implement→verify loop this skill delegates to.
- [[subagent-driven-development]] — multi-task execution of an approved plan.
- [[ci-watch]] — when a PR exists and CI is red.
- [[pr-description]] — draft the PR once the fix is green.

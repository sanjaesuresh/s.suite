---
name: onboarding-map
description: >
  Generate a codebase onboarding map for a new contributor or for understanding an
  unfamiliar repo. Use when you've just cloned a project, when onboarding a teammate,
  or when picking up code you haven't touched in months. Reads the actual repo
  structure, config, and key modules — no generic advice.
---

## Tool contract — READ-ONLY

Investigate and report. Do not modify files. Does not write files unless the user
explicitly asks to save the map somewhere.

## How to work

1. **Read the repo root**: List top-level directories and files. Read `package.json`,
   `pyproject.toml`, `Cargo.toml`, `go.mod`, or equivalent. Read any existing
   `README` or `CONTRIBUTING` files — but do not trust them blindly; cross-check
   against actual directory structure.

2. **Identify the stack**: Language(s), framework(s), build tool, test runner, linter.
   Note versions where relevant.

3. **Trace data flow**: Pick the most important user-facing entry point (HTTP handler,
   CLI command, main function) and follow it through the layers. Name the layers.

4. **Map run/test/build commands**: Read the actual scripts, not just the README.
   Confirm they exist.

5. **Identify core concepts**: Domain objects, key abstractions, naming conventions
   the codebase uses. If the repo has its own jargon, note it.

6. **Recommend where to start**: Given the structure, which file or module is the
   best entry point for understanding the system? Be specific.

7. Cross-reference [[deep-codebase-audit]] for a full quality review, or
   [[docs-generate]] to turn this map into persisted documentation.

## Output format

```markdown
# Onboarding Map

## Architecture overview
(3–6 sentences. Stack, layers, and what the system does. No filler.)

## Important directories
| Path | What lives here | Why it matters |
|---|---|---|
| `src/api/` | HTTP route handlers | Entry point for all requests |
| ... | ... | ... |

## How data flows
(Trace one representative request or operation end-to-end, naming real files.)

## How to run / test / build
```sh
# Install
<command>

# Run
<command>

# Test
<command>

# Build
<command>
```

## Core concepts
- **<Term>**: what it means in this codebase, where it lives (`file:line`)
- ...

## Where to start learning
(The single best file or module to read first, and why. Then what to read next.)
```

## Output brevity (hard rule)

- Answer first: verdict / outcome / result on line one.
- Procedures, steps, and findings are numbered lists — NEVER paragraphs.
- DO NOT restate the request, add preamble, or end with a recap of what was just said.
- Cut anything that does not change what the user does next. Expand only if asked.

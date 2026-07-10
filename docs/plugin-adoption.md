# Install s-suite as a Claude Code plugin

The toolkit ships as an installable Claude Code plugin. Two slash commands get
you the 32 skills, 19 agents, and 3 safety hooks. A few things a plugin *cannot*
install — the global operating instructions, the statusline, and the deny-list
permissions — are provided below as copy-paste templates.

## Install

Run these inside Claude Code:

```
/plugin marketplace add sanjaesuresh/s-suite
/plugin install toolkit@s-suite
```

If the skills/agents don't show up immediately, run `/reload-plugins`.

## Updating

Updates are **pull-based** — nothing auto-updates. When you want the latest:

```
/plugin marketplace update s-suite
/plugin update toolkit@s-suite
```

## What installs automatically vs. what's manual

| Component | Ships in plugin? | Notes |
|---|---|---|
| 32 skills | ✅ Automatic | Includes `toolkit-router`, which carries the planning gate + routing table. |
| 19 agents | ✅ Automatic | All review/build/research specialists. |
| 3 safety hooks | ✅ Automatic | `block-dangerous-commands` (Bash), `freeze-edits` (Edit/Write/NotebookEdit), `notify` (Notification). |
| Global `CLAUDE.md` operating instructions | ❌ Manual | Plugins can't set global instructions. Paste the template below. |
| Statusline | ❌ Manual | No plugin manifest field exists for statusline. |
| Deny-list permissions (secrets/env) | ❌ Manual | Plugins can't set `permissions`. |
| `skillOverrides` (disable superseded skills) | ❌ Manual | Optional; trims context tokens. |

Why the split: the Claude Code plugin manifest has no fields for global
instructions, statusline, or permissions — those are `settings.json` concerns
that live in your own `~/.claude/`. The `toolkit-router` skill reintroduces the
most important piece (the planning gate and routing) so you get most of the
discipline even if you skip the manual template.

## Manual piece 1 — `CLAUDE.md` operating instructions

The `toolkit-router` skill already carries the planning gate and skill routing.
What it does **not** carry — model tiering, voice, and the decision-brief format
— is below. Paste this into your own `~/.claude/CLAUDE.md` (applies everywhere)
or a project `CLAUDE.md` (applies to one repo). This is generic guidance; adjust
to taste.

```markdown
## Model tiering — plan on the stronger model, build on the cheaper one

- Use the stronger model for thinking-heavy work: product / engineering / design
  planning, architecture decisions, debugging hypotheses, and code review.
- Once a plan is written and agreed, execute it on the cheaper model — delegate
  the build to the `software-engineer` subagent or switch the session. Switch
  back to the stronger model for the review pass.

## Decision-brief format (when presenting options)

When asking the user to choose between approaches, present each option with:

- **Completeness: X/10** — 10 = handles all edge cases; 7 = happy path; 3 = shortcut.
- **Effort, both scales** — (human: ~2 days / AI: ~20 min), so the real cost is visible.
- **[one-way] or [two-way]** — is the decision hard to reverse, or cheap to change later?
- A one-line **Recommendation:** with (recommended) on the option you'd pick, and why.

Keep each option write-up prose only. For [one-way] (irreversible/destructive)
decisions, require an explicit confirmation before proceeding.

## Safety & work-information rules

- Never persist proprietary or work-specific information into global files —
  not into `~/.claude/CLAUDE.md`, global skills/agents, saved contexts, or any
  synced repo.
- In a work repository, rely only on that repo's local `CLAUDE.md` / `.claude/`
  and the current session for project context.
- When saving context or generating docs, default to project-local, gitignored
  files. Scan for secrets/PII/internal identifiers and warn before writing.

## Voice

- Direct. No filler, no flattery.
- Avoid AI-tell vocabulary: delve, crucial, robust, comprehensive, seamless,
  leverage (verb), tapestry, nuanced, multifaceted, furthermore, moreover,
  pivotal, landscape, underscore, foster, showcase, intricate, "it's important
  to note." Prefer plain sentences over em-dash pile-ups.
```

## Manual piece 2 — optional `settings.json` snippet

These are quality-of-life settings, not required for the plugin to work. Merge
into your `~/.claude/settings.json`. The statusline references a `statusline.sh`
you'd need to supply (see the repo's `scripts/statusline.sh`).

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash \"$HOME/.claude/scripts/statusline.sh\""
  },
  "permissions": {
    "ask": [
      "Bash(git commit:*)",
      "Bash(git push:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/.env)",
      "Read(./**/.env.*)",
      "Read(./secrets/**)",
      "Read(./**/credentials*)",
      "Read(./**/*.pem)",
      "Read(./**/id_rsa*)"
    ]
  },
  "skillOverrides": {
    "spec": "off",
    "deep-codebase-audit": "off",
    "implementation-plan": "off",
    "product-plan-review": "off",
    "onboarding-map": "off",
    "test-gap-analysis": "off",
    "ai-slop-cleanup": "off",
    "debugging-incident-review": "off",
    "test-driven-development": "off",
    "verification-before-completion": "off",
    "executing-plans": "off"
  }
}
```

The `skillOverrides` block disables eleven skills the toolkit supersedes (they're
not shipped in the plugin either). Leaving them off keeps context lean; flip any
back on (`"spec": "on"`) if you want it.

## Notes and limitations

- The script-backed skills (`freeze`, `guard`, `careful`, `context-save`,
  `context-restore`, `health-check`) call their scripts via
  `${CLAUDE_PLUGIN_ROOT}`. If that variable isn't available in your Bash tool
  environment, those specific skills degrade to "works only with the manual
  `bootstrap.sh` install" — every other skill and all agents are unaffected.
- The freeze lockfile lives at a project-local path
  (`.claude/session-state/freeze-boundary`), not under the plugin cache, so a
  freeze survives a plugin update and can always be lifted.

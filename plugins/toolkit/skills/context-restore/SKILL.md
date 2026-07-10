---
name: context-restore
description: Restore a previously saved working context and reconcile it with the current git state. Use when the user says "context restore", "resume", "where was I", "pick up where I left off", or at the start of a session continuing earlier work.
---

# context-restore

Resume from a saved context and flag anything that drifted since it was written.

## Tool contract

Read-only. Do not modify code. You may read the saved context and inspect git.

## Steps

1. Load the saved context and current git state:

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/context-restore.sh"
   ```

   This prints the project-local saved context (`.claude/context/current-session.md`
   or the most recent file in `.claude/context/`) and the current branch/status/log.

2. If no saved context exists, say so plainly and offer to start fresh — do not
   invent a prior state.

3. **Reconcile saved vs. current.** Compare and call out drift:
   - Branch changed since save?
   - New commits since the saved "last commit"?
   - Working tree diverged from the saved "files touched"?
   - Any "remaining work" already done?

4. Produce the summary below.

## Output format

```markdown
# Resuming: <task>

## Where you left off
2–3 sentences: the task and its status at save time.

## Decisions still in force
- <decision> — <rationale>  (carry these forward; don't re-litigate)

## Drift since save
- <branch/commits/working-tree differences, or "none detected">

## Likely next steps
1. <the most sensible next action given remaining work + current state>
2. ...

## Risks / things to re-verify
- <open risks from the saved context, plus anything drift introduced>
```

## Notes

- If the working tree changed significantly versus the saved state, warn before
  acting — the saved plan may be stale.
- Treat the saved file as a memory aid, not gospel. Verify against the live repo.

## Related

- `/context-save`. See [[context-save]].

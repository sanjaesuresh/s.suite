# Lessons

This file is the toolkit's continuous-improvement ledger. The
`learn-from-review` skill maintains it: each time a PR review catches a mistake
worth generalizing, the skill applies a fix to the relevant toolkit file
(`global/CLAUDE.md`, a skill, or an agent) and prepends an entry here.

The **Root cause / class** line of each entry is the dedup key — the skill scans
existing entries before adding a new one, so the same lesson is not re-learned.

Entries are newest-first. Format:

```
### YYYY-MM-DD HH:MM TZ — <one-line class of mistake>

- **Branch:** <branch the review was on>
- **PR:** #N (or "n/a")
- **Comment:** <the review comment, sanitized — verbatim quote, trimmed>
- **Root cause / class:** <the generalized mistake, one sentence>
- **Fix applied to toolkit:** <file changed> — <one-line what changed>
```

All fields are sanitized before writing: no repo/service names, internal URLs,
secrets, or pasted proprietary code. Generalize or redact rather than leak.

---

<!-- New entries are prepended directly below this line. -->

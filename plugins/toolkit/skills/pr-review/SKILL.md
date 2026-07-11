---
name: pr-review
description: >
  Review someone else's GitHub PR, or reply to review comments on a PR (yours or
  theirs). Drafts inline comments and thread replies grounded in the real PR diff
  and existing comments, then posts via the github MCP only on your confirmation.
  Use when asked to review a PR, reply to a PR comment, respond to review
  feedback, or comment on a pull request. Not for your own uncommitted diff (that
  is pre-pr-review).
---

# pr-review

Works against **real GitHub PRs**, not your local diff. Two jobs: review a PR and
draft inline feedback, or continue a review conversation by drafting replies. It
**drafts by default and posts only on explicit confirmation**.

This is the remote counterpart to `pre-pr-review` (which reviews your own
uncommitted diff before a PR exists). If the user wants their local diff checked,
use `pre-pr-review` instead.

## Tool contract — draft first, post only when confirmed

- Read PR data through the github MCP (this session: `github-pat`). Never invent
  PR contents — every finding cites something actually fetched.
- **Nothing is posted until the user approves the exact text.** Drafting,
  reviewing, and rewording are free; posting is a gated step.
- If no github MCP is available in the session, degrade gracefully: produce the
  drafts and tell the user to paste them. Do not silently fail.
- Read-only on the local repo. This skill does not edit code or push.

## Determine the mode

- A **PR number or URL** (and no existing thread to answer) → **review mode**.
- A request to **reply to / respond to** comments on a PR (yours or theirs) →
  **respond mode**.
- Ambiguous → ask which, in one line. Don't guess.

Resolve owner/repo/number from the URL or the current repo's remote before
fetching.

## Review mode

1. **Fetch the PR** via the MCP: description, changed files + diff, and existing
   review comments (`pull_request_read` for metadata/diff/comments).
2. **Dispatch the `pr-reviewer` agent** to read the diff and its context in its
   own isolation and return a structured verdict + prioritized, file:line-anchored
   findings. Brief it with owner/repo/PR number, the PR's stated purpose, and the
   diff. The agent reads; it does not post.
3. **Turn its findings into drafts**: a review summary body plus specific inline
   comments (each tied to a file and line). Present these in chat for the user to
   read, cut, or reword.
4. **Post only on approval** using the MCP review flow: `pull_request_review_write`
   with method `create` to open a pending review, `add_comment_to_pending_review`
   for each line comment, then `pull_request_review_write` with `submit_pending`
   to submit. Ask whether to submit as Comment, Approve, or Request changes.

## Respond mode

1. **Read the thread(s)** — the specific review comments to answer, with enough
   surrounding diff/context to respond substantively (`pull_request_read`).
2. **Draft replies that actually continue the conversation**: answer the
   question, concede where the reviewer is right, or push back with reasoning and
   a file:line reference. No filler, no "great point!" padding.
3. **Post only on approval**: `add_reply_to_pull_request_comment` for a reply on a
   review-comment thread, or `add_issue_comment` for a general PR comment.

## Output format

For review mode, present:

```markdown
# PR Review: <owner>/<repo>#<number>

## Verdict
Comment | Approve | Request changes. One line why.

## Draft review body
(What goes in the top-level review comment.)

## Draft inline comments
- `path:line`
  <comment text>
- ...

## Notes for you
(Anything uncertain, or where you should decide before posting.)
```

These headings are for reading in chat only. This skill writes nothing to a file.
The scaffolding (the `#`/`##` headings, "Verdict", "Notes for you") is never
posted. Only the review body prose and each inline comment's text reach GitHub,
via the MCP, after you approve. Never post a section heading as part of a comment.

For respond mode, present each draft reply under the comment it answers (quote the
reviewer's point here for your reference; it does not go in the posted reply).

## Voice: write like a person, not a bot

Every draft (inline comments and thread replies) must read as if a senior engineer
typed it in a hurry. This is a hard requirement, not a preference.

- **No em dashes. Ever.** Use a period, a comma, parentheses, or a short word
  (so, but, and). If a sentence wants an em dash, split it or use a comma.
- **Banned words / phrases** (left is banned, right is what to write): delve →
  look at; crucial → important; robust → solid; comprehensive → complete;
  seamless → smooth; leverage → use; underscore → show; furthermore / moreover /
  additionally → cut it; "it's worth noting" / "it's important to note" → cut it,
  just say the thing; "that said" → but. No flattery openers ("Great question",
  "You're absolutely right", "Nice work overall").
- **Don't restate the comment before answering, and don't add a summary at the
  end.** Answer and stop.
- Keep it short. Sentence fragments and lowercase are fine. A one-word reply
  ("done", "good catch", "fair") is fine when that's all it needs.
- Comment on the code, not the person. Prefer "we" or "this line" over "you".
  Ask a question rather than issue a command when the author might have a reason
  you're missing. Say why, briefly. Avoid "just", "obvious", "simply", "easy".
- Ground every comment in a `file:line`. Vary the phrasing across comments; never
  reuse a template. Don't pad with rule-of-three lists.
- **Labels:** the only prefix to ever use is `nit:`, for a non-blocking cosmetic
  point. Write everything else (issues, suggestions, questions, praise) as plain
  sentences with no prefix. Still make clear in words when something blocks versus
  when it's optional.

## What not to do

- Don't post, submit, approve, or request-changes without explicit confirmation
  of the exact text.
- Don't fabricate diff or comment content — if the MCP fetch is incomplete, say so.
- Don't review the local uncommitted diff here — that's `pre-pr-review`.
- Don't pad feedback. Every inline comment ties to a real line and says something
  actionable.

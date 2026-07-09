# Example Workflow

An illustrative end-to-end run (sequential tasks, then a parallel wave). Not
normative — the rules live in [SKILL.md](SKILL.md); this just shows the shape.

```
You: I'm using Subagent-Driven Development to execute this plan.

[Read plan file once: docs/superpowers/plans/feature-plan.md]
[Create todos for all tasks]

Task 1: Hook installation script

[Run task-brief for Task 1; dispatch implementer with brief + report paths + context]

Implementer: "Before I begin - should the hook be installed at user or system level?"

You: "User level (~/.config/superpowers/hooks/)"

Implementer: "Got it. Implementing now..."
[Later] Implementer:
  - Implemented install-hook command
  - Added tests, 5/5 passing
  - Self-review: Found I missed --force flag, added it
  - Committed

[Run review-package, dispatch task reviewer with the printed path]
Task reviewer: Spec ✅ - all requirements met, nothing extra.
  Strengths: Good test coverage, clean. Issues: None. Task quality: Approved.

[Mark Task 1 complete]

Task 2: Recovery modes

[Run task-brief for Task 2; dispatch implementer with brief + report paths + context]

Implementer: [No questions, proceeds]
Implementer:
  - Added verify/repair modes
  - 8/8 tests passing
  - Self-review: All good
  - Committed

[Run review-package, dispatch task reviewer with the printed path]
Task reviewer: Spec ❌:
  - Missing: Progress reporting (spec says "report every 100 items")
  - Extra: Added --json flag (not requested)
  Issues (Important): Magic number (100)

[Dispatch fix subagent with all findings]
Fixer: Removed --json flag, added progress reporting, extracted PROGRESS_INTERVAL constant

[Task reviewer reviews again]
Task reviewer: Spec ✅. Task quality: Approved.

[Mark Task 2 complete]

Wave 3 — Tasks 3 & 4 (pre-flight proved them disjoint: Task 3 touches
src/api/ only, Task 4 touches src/cli/ only, no dependency between them)

[Record wave base; dispatch both implementers in ONE message, each with its
 File Boundary block]

Task 3 implementer: DONE — 6/6 passing, committed
[Boundary check ✅; review-package WAVE_BASE HEAD -- src/api/; dispatch reviewer]
Task 4 implementer: DONE — 4/4 passing, committed
[Boundary check ✅; review-package WAVE_BASE HEAD -- src/cli/; dispatch reviewer]

Task 3 reviewer: Spec ✅. Approved.   Task 4 reviewer: Spec ✅. Approved.

[Mark Tasks 3 and 4 complete — Wave 3 done, next wave may now start]

...

[After all tasks]
[Dispatch final code-reviewer]
Final reviewer: All requirements met, ready to merge

Done!
```

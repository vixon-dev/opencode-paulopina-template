---
description: Run a long-running agent loop until a completion promise is printed
agent: build
---
You are running in a loop orchestrated by the operator.

Task: $ARGUMENTS

State:
- Read `@.opencode/state/ralph.md` at the start.
- Update `@.opencode/state/ralph.md` at the end of every iteration with:
  - What changed (files, behavior)
  - What you validated (tests/commands)
  - What failed (if any)
  - Next step

Rules:
- Do work in small, verifiable steps.
- Prefer running tests/linters frequently.
- If you hit an error, fix it and continue.
- If you need human input:
  1) Trigger a notification by running: `!curl -fsS "$RALPH_NOTIFY_PAUSED_URL" >/dev/null 2>&1 || true`
  2) Print exactly: `<pause>NEED_INPUT</pause>`
  3) Ask EXACTLY ONE question and then stop.
- When (and only when) fully done, print exactly:
  <promise>DONE</promise>

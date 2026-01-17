#!/usr/bin/env bash
set -euo pipefail

# opencode-paulopina: Ralph-style loop runner
# Usage:
#   ./.opencode/ralph.sh "Build X and run tests" [MAX_ITERS]

PROMPT="${1:-}"
MAX_ITERS="${2:-50}"

if [ -z "$PROMPT" ]; then
  echo "usage: $0 \"<task prompt>\" [max_iters]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load project-scoped env (notify URLs, API keys, etc.)
export OPENCODE_PROJECT_ROOT="$ROOT_DIR"
set -a
. "$ROOT_DIR/.opencode/.env"
set +a

STATE_DIR="$ROOT_DIR/.opencode/state"
SESSION_FILE="$STATE_DIR/ralph.session"
STATUS_FILE="$STATE_DIR/ralph.md"

mkdir -p "$STATE_DIR"

# Initialize (or reuse) session id
if [ ! -f "$SESSION_FILE" ] || [ ! -s "$SESSION_FILE" ]; then
  echo "Creating a new opencode session for Ralph loop..." >&2
  sid="$($ROOT_DIR/.opencode/run.sh run --format json --title "ralph-loop" --command ralph-loop "$PROMPT" \
    | /usr/bin/grep -m1 '"sessionID"' \
    | python3 -c 'import json,sys; print(json.loads(sys.stdin.readline()).get("sessionID",""))')"
  if [ -z "$sid" ]; then
    echo "Failed to create session id" >&2
    exit 1
  fi
  echo "$sid" > "$SESSION_FILE"
  echo "Session: $sid" >&2
fi

SID="$(cat "$SESSION_FILE")"

# Seed status file if missing
if [ ! -f "$STATUS_FILE" ]; then
  cat > "$STATUS_FILE" <<EOF
# Ralph Loop State

Task:
$PROMPT

Progress:
- [ ] Not started

Last iteration:
- none

Next:
- Start
EOF
fi

# Optional verbosity controls
# - Set RALPH_PRINT_LOGS=0 to hide opencode logs (stderr)
# - Set RALPH_LOG_LEVEL=DEBUG|INFO|WARN|ERROR (default: ERROR)
# - Set RALPH_SUPPRESS_MCP_PROMPT_ERRORS=0 to disable filtering
RALPH_PRINT_LOGS="${RALPH_PRINT_LOGS:-1}"
RALPH_LOG_LEVEL="${RALPH_LOG_LEVEL:-ERROR}"
RALPH_SUPPRESS_MCP_PROMPT_ERRORS="${RALPH_SUPPRESS_MCP_PROMPT_ERRORS:-1}"

print_logs_args=()
if [ "$RALPH_PRINT_LOGS" = "1" ]; then
  print_logs_args+=(--print-logs --log-level "$RALPH_LOG_LEVEL")
fi

filter_stderr_cmd=("/bin/cat")
if [ "$RALPH_SUPPRESS_MCP_PROMPT_ERRORS" = "1" ]; then
  filter_stderr_cmd=(/usr/bin/awk '!/service=mcp/ || !/failed to get prompts/ { print }')
fi

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "\n=== ralph loop iteration $i/$MAX_ITERS (session $SID) ===" >&2

  out="$($ROOT_DIR/.opencode/run.sh run --session "$SID" --format default --command ralph-loop "$PROMPT" "${print_logs_args[@]}" 2> >("${filter_stderr_cmd[@]}" >&2) || true)"
  echo "$out"

  # If agent requested human input
  if echo "$out" | /usr/bin/grep -q "<pause>NEED_INPUT</pause>"; then
    if [ -n "${RALPH_NOTIFY_PAUSED_URL:-}" ]; then
      /usr/bin/curl -fsS "$RALPH_NOTIFY_PAUSED_URL" >/dev/null 2>&1 || true
    fi
    echo "\nRalph loop: paused for human input." >&2
    exit 3
  fi

  # If agent completed
  if echo "$out" | /usr/bin/grep -q "<promise>DONE</promise>"; then
    if [ -n "${RALPH_NOTIFY_DONE_URL:-}" ]; then
      /usr/bin/curl -fsS "$RALPH_NOTIFY_DONE_URL" >/dev/null 2>&1 || true
    fi
    echo "\nRalph loop: completion promise detected." >&2
    exit 0
  fi

done

echo "\nRalph loop: max iterations reached without completion." >&2
exit 2

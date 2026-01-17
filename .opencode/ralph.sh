#!/usr/bin/env bash
set -euo pipefail

# Ralph loop runner (Th0rgal's ralph-wiggum CLI) + ntfy.sh notification on completion.
#
# Prereq:
#   npm install -g @th0rgal/ralph-wiggum
#   # or
#   bun add -g @th0rgal/ralph-wiggum
#
# Usage:
#   ./.opencode/ralph.sh "<prompt>" [MAX_ITERS]

PROMPT="${1:-}"
MAX_ITERS="${2:-50}"

if [ -z "$PROMPT" ]; then
  echo "usage: $0 \"<task prompt>\" [max_iters]" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Ensure project-scoped env is available for notify.sh
export OPENCODE_PROJECT_ROOT="$ROOT_DIR"
set -a
. "$ROOT_DIR/.opencode/.env"
set +a

if ! command -v ralph >/dev/null 2>&1; then
  echo "Missing 'ralph' CLI. Install it first:" >&2
  echo "  npm install -g @th0rgal/ralph-wiggum" >&2
  echo "  # or" >&2
  echo "  bun add -g @th0rgal/ralph-wiggum" >&2
  exit 127
fi

# Run ralph in project root so it writes .opencode state files there
(
  cd "$ROOT_DIR"
  ralph "$PROMPT" --max-iterations "$MAX_ITERS"
)
exit_code=$?

# Notify only on success (exit 0)
if [ "$exit_code" = "0" ]; then
  "$ROOT_DIR/.opencode/notify.sh" "OpenCode: done" "Ralph loop finished: ${PROMPT}" || true
fi

exit "$exit_code"

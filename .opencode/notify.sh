#!/usr/bin/env bash
set -euo pipefail

# ntfy.sh notification helper.
#
# Usage:
#   ./.opencode/notify.sh "Title" "Message"
#
# Config:
#   NTFY_TOPIC in .opencode/.env

TITLE="${1:-}"
TEXT="${2:-}"

if [ -z "$TITLE" ] || [ -z "$TEXT" ]; then
  echo "usage: $0 \"<title>\" \"<message>\"" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export OPENCODE_PROJECT_ROOT="$ROOT_DIR"
set -a
. "$ROOT_DIR/.opencode/.env"
set +a

if [ -z "${NTFY_TOPIC:-}" ]; then
  echo "NTFY_TOPIC not set; skipping notification" >&2
  exit 0
fi

# Uses x-www-form-urlencoded fields.
/usr/bin/curl -fsS -X POST "https://ntfy.sh/${NTFY_TOPIC}" \
  -d "title=${TITLE}" \
  -d "message=${TEXT}" \
  >/dev/null 2>&1 || true

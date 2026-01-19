#!/usr/bin/env bash
set -euo pipefail

# ntfy.sh notification helper.
#
# Usage:
#   ./.opencode/notify.sh "<type>" "<message>" [priority] [tags]
#
# Examples:
#   ./.opencode/notify.sh "done" "Deploy finished" high "heavy_check_mark,rocket"
#   ./.opencode/notify.sh "need_input" "Please approve the plan" urgent "warning,robot"
#
# Config:
#   NTFY_TOPIC in .opencode/.env
#
# Notes:
# - ntfy supports Title/Priority/Tags headers.
# - Tags can be emoji shortcodes (e.g. warning, robot, heavy_check_mark).

TYPE="${1:-}"
MESSAGE="${2:-}"
PRIORITY="${3:-default}"
TAGS="${4:-robot}"

if [ -z "$TYPE" ] || [ -z "$MESSAGE" ]; then
  echo "usage: $0 \"<type>\" \"<message>\" [priority] [tags]" >&2
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

# Use Ralphy title if called from ralphy context
if [ -n "${RALPHY_CONTEXT:-}" ]; then
  TITLE="Ralphy"
else
  TITLE="OpenCode"
fi
BODY="[${TYPE}] ${MESSAGE}"

/usr/bin/curl -fsS "https://ntfy.sh/${NTFY_TOPIC}" \
  -H "Title: ${TITLE}" \
  -H "Priority: ${PRIORITY}" \
  -H "Tags: ${TAGS}" \
  -d "${BODY}" \
  >/dev/null 2>&1 || true

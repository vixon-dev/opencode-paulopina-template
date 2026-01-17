#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENCODE_DIR="$ROOT_DIR/.opencode"

# Ensure expected structure exists
mkdir -p "$OPENCODE_DIR/logs" "$OPENCODE_DIR/openapi" "$OPENCODE_DIR/_catalog" "$OPENCODE_DIR/_dereferenced"

# Bootstrap env if missing
if [ ! -f "$OPENCODE_DIR/.env" ]; then
  if [ -f "$OPENCODE_DIR/.env.example" ]; then
    cp "$OPENCODE_DIR/.env.example" "$OPENCODE_DIR/.env"
    chmod 600 "$OPENCODE_DIR/.env" || true
    echo "Created $OPENCODE_DIR/.env from .env.example (fill secrets)." >&2
  else
    echo "Missing $OPENCODE_DIR/.env and .env.example" >&2
    exit 1
  fi
fi

# If this template README was copied to root, move it back
# (keeps project root clean, but still ships a top-level README in this repo)
if [ -f "$ROOT_DIR/README.md" ] && [ ! -f "$OPENCODE_DIR/README.md" ]; then
  mv "$ROOT_DIR/README.md" "$OPENCODE_DIR/README.md"
  echo "Moved $ROOT_DIR/README.md to $OPENCODE_DIR/README.md" >&2
fi

# Bootstrap AGENTS.md in project root
# - If missing: create from template
# - If present: ensure it mentions the template so a new repo doesn't lose conventions
if [ -f "$OPENCODE_DIR/AGENTS.template.md" ]; then
  if [ ! -f "$ROOT_DIR/AGENTS.md" ]; then
    cp "$OPENCODE_DIR/AGENTS.template.md" "$ROOT_DIR/AGENTS.md"
    echo "Created $ROOT_DIR/AGENTS.md from template." >&2
  else
    if ! /usr/bin/grep -q "opencode-paulopina" "$ROOT_DIR/AGENTS.md"; then
      echo "WARN: $ROOT_DIR/AGENTS.md exists but does not mention opencode-paulopina template." >&2
      echo "      Consider merging $OPENCODE_DIR/AGENTS.template.md into it." >&2
    fi
  fi
fi

# Export project root so .env can be portable
export OPENCODE_PROJECT_ROOT="$ROOT_DIR"

# Load project-scoped env
set -a
. "$OPENCODE_DIR/.env"
set +a

cd "$ROOT_DIR"
exec opencode "$@"


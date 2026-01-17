# opencode-paulopina template

This repository includes a reusable **OpenCode (opencode)** project template, designed to be copied into any new project so you can immediately use:

- Project-scoped secrets/config via `.opencode/.env`
- A consistent `AGENTS.md` rules baseline
- Project-local **Skills** (`.opencode/skill/*/SKILL.md`)
- Project-local **Commands** (`.opencode/command/*.md`)
- A Ralph loop runner that uses Th0rgal's `ralph` CLI (`.opencode/ralph.sh`)
- OpenAPI tooling directories and caches

Everything is centralized under `.opencode/` so the project root stays clean.

---

## Layout

- `.opencode/.env` — project secrets (NOT committed)
- `.opencode/.env.example` — safe template to copy
- `.opencode/run.sh` — bootstrap + start opencode in project root
- `.opencode/AGENTS.template.md` — rules template copied to `AGENTS.md`
- `.opencode/skill/` — project-local skills
- `.opencode/command/` — project-local slash commands
- `.opencode/openapi/` — OpenAPI specs for this project
- `.opencode/_catalog/` — OpenAPI MCP cache
- `.opencode/_dereferenced/` — OpenAPI MCP dereferenced cache
- `.opencode/logs/` — MCP logs (ex: Redis MCP)
- `.opencode/ralph.sh` — wrapper around Th0rgal's `ralph` CLI
- `.opencode/notify.sh` — ntfy.sh notification helper (optional)

---

## First-time setup (new project)

1) Copy `.opencode/` and `.gitignore` entry
- Ensure the project `.gitignore` contains:
  - `.opencode/`

2) Create secrets file
- `cp .opencode/.env.example .opencode/.env`
- Fill `.opencode/.env` with your tokens/URLs
- `chmod 600 .opencode/.env`

3) Start OpenCode
- `./.opencode/run.sh`

`run.sh` bootstraps automatically:
- Creates `.opencode/.env` from `.env.example` if missing
- Creates `AGENTS.md` in project root from `.opencode/AGENTS.template.md` if missing
- Creates required directories (`logs/`, `openapi/`, caches)

---

## Running OpenCode

### Open the TUI
- `./.opencode/run.sh`

### Run one-off prompts (non-interactive)
- `./.opencode/run.sh run "Explain the repo"`

### Check MCP connectivity
- `./.opencode/run.sh mcp list`

---

## MCP servers (expected)

These MCPs are configured **globally** in `~/.config/opencode/opencode.json`. This template only provides the **project-local wiring** (env vars + folders under `.opencode/`).

If the MCP servers are not installed/working yet on your machine, do this first:
- Ensure you have a JS runtime available:
  - **Node.js 20+** (recommended) so `npx` works, or
  - **Bun** so `bunx` works: https://bun.sh
- Run `./.opencode/run.sh mcp list` to see what is available.
- Note: most local MCPs here run via `npx -y ...` (or `bunx --yes ...`) so the first run will download the package automatically.

Switching from `npx` to `bunx` (global config):
- Edit `~/.config/opencode/opencode.json` and replace MCP `command` entries like `"npx", "-y", "<pkg>"` with `"bunx", "--yes", "<pkg>"`.
- Some MCP packages may still require Node-specific behavior; if you hit issues, revert to Node for that MCP.

Per-server references (install/docs):
- `playwright` — browser automation
  - MCP package: https://www.npmjs.com/package/@playwright/mcp
  - Playwright install docs: https://playwright.dev/docs/intro
- `n8n` — workflow listing/triggering
  - MCP package: https://www.npmjs.com/package/@pagelines/n8n-mcp
  - n8n API auth docs: https://docs.n8n.io/api/authentication/
- `context7` — up-to-date documentation lookup
  - Docs + API key: https://context7.com/docs
  - Install: https://github.com/upstash/context7#installation
- `openapi` — OpenAPI catalog discovery (reads `.opencode/openapi/`)
  - MCP package: https://www.npmjs.com/package/@reapi/mcp-openapi
- `postgres` — Postgres read-only querying (connection string only)
  - MCP package: https://www.npmjs.com/package/mcp-postgres
- `redis` — Redis inspection (writes disabled by default)
  - MCP package: https://www.npmjs.com/package/@liangshanli/mcp-server-redis

If you copy this template to a new machine, you still need the global `opencode.json` with these MCP definitions (or add them via `opencode mcp add`).

---

## Skills (project-local)

Located in `.opencode/skill/*/SKILL.md`.

- `webhook-verification`
- `sso-auth-flow`
- `message-sync-idempotency`
- `db-migration-review`
- `api-client-wrapper`

OpenCode automatically discovers project skills in `.opencode/skill/`.

---

## Commands (project-local)

Located in `.opencode/command/*.md`.

- `/smoke-helpdesk` — identify core helpdesk endpoints to implement/test first
- `/smoke-webhooks` — webhook validation checklist
(no Ralph-specific slash command; loop runs via the `ralph` CLI)

---

## Ralph loop (long running)

This template delegates Ralph looping to Th0rgal's CLI-only implementation: `@th0rgal/ralph-wiggum`.

### Install (global)

```bash
npm install -g @th0rgal/ralph-wiggum
# or
bun add -g @th0rgal/ralph-wiggum
```

### Run a loop

```bash
./.opencode/ralph.sh "Build feature X with tests" 50
```

This wrapper runs `ralph` in the project root so it can persist its state under `.opencode/`.

### Monitor / add hints

```bash
ralph --status
ralph --add-context "Focus on fixing auth first"
```

### Notifications (ntfy.sh)

Standard pattern: always use `./.opencode/notify.sh` (it reads `NTFY_TOPIC` from `.opencode/.env`).

Manual usage:

```bash
./.opencode/notify.sh "Processo finalizado" "Precisa checar algo!"
```

`./.opencode/ralph.sh` uses this same helper automatically on successful completion.

---

## Notes / best practices

- ntfy.sh notifications use `curl` (available by default on macOS).

- Keep `.opencode/.env` out of git.
- Keep OpenAPI specs in `.opencode/openapi/`.
- Prefer read-only DB tooling in production.
- If `AGENTS.md` already exists in a repo, `run.sh` will not overwrite it (it will warn if it doesn’t mention the template).

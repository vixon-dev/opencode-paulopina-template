# opencode-paulopina template

This repository includes a reusable **OpenCode (opencode)** project template, designed to be copied into any new project so you can immediately use:

- Project-scoped secrets/config via `.opencode/.env`
- A consistent `AGENTS.md` rules baseline
- Project-local **Skills** (`.opencode/skill/*/SKILL.md`)
- Project-local **Commands** (`.opencode/command/*.md`)
- **Ralphy** - autonomous AI loop runner (`.opencode/ralphy.sh`)
- OpenAPI tooling directories and caches

Everything is centralized under `.opencode/` so the project root stays clean.

---

## Layout

- `.opencode/.env` — project secrets (NOT committed)
- `.opencode/.env.example` — safe template to copy
- `.opencode/run.sh` — bootstrap + start opencode in project root
- `.opencode/ralphy.sh` — autonomous AI loop runner (multi-engine)
- `.opencode/notify.sh` — ntfy.sh notification helper
- `.opencode/AGENTS.template.md` — rules template copied to `AGENTS.md`
- `.opencode/skill/` — project-local skills
- `.opencode/command/` — project-local slash commands
- `.opencode/openapi/` — OpenAPI specs for this project
- `.opencode/ralphy-template/` — templates for Ralphy config/PRD
- `.opencode/logs/` — MCP logs (ex: Redis MCP)

---

## First-time setup (new project)

1) Copy `.opencode/` and `.gitignore` entry
- Ensure the project `.gitignore` contains:
  - `.opencode/`
  - `.ralphy/`

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

## Ralphy - Autonomous AI Loop

Ralphy runs AI agents in a loop until tasks are complete. Based on [michaelshimeles/ralphy](https://github.com/michaelshimeles/ralphy).

### Supported Engines

| Engine | Flag | Notes |
|--------|------|-------|
| OpenCode | `--opencode` | **Default** |
| Claude Code | `--claude` | |
| Cursor Agent | `--cursor` | |
| Codex CLI | `--codex` | |
| Qwen-Code | `--qwen` | |
| Factory Droid | `--droid` | |

### Quick Start

```bash
# Single task mode
./.opencode/ralphy.sh "add dark mode toggle"

# PRD mode (task list)
./.opencode/ralphy.sh --prd PRD.md

# Initialize project config
./.opencode/ralphy.sh --init

# See all options
./.opencode/ralphy.sh --help
```

### Two Modes

**Single Task** - run one task:
```bash
./.opencode/ralphy.sh "fix the login bug"
./.opencode/ralphy.sh "add user authentication" --cursor
```

**PRD Mode** - work through a task list:
```bash
./.opencode/ralphy.sh                    # uses PRD.md
./.opencode/ralphy.sh --prd tasks.md     # custom file
./.opencode/ralphy.sh --yaml tasks.yaml  # YAML format
./.opencode/ralphy.sh --github owner/repo # GitHub Issues
```

### Project Configuration

Run `--init` to create `.ralphy/config.yaml`:

```bash
./.opencode/ralphy.sh --init
```

This auto-detects:
- Project name, language, framework
- Test/lint/build commands
- Creates rules and boundaries config

```yaml
# .ralphy/config.yaml
project:
  name: "my-app"
  language: "TypeScript"
  framework: "Next.js"

commands:
  test: "bun test"
  lint: "bun run lint"

rules:
  - "Always use TypeScript strict mode"
  - "Use server actions instead of API routes"

boundaries:
  never_touch:
    - ".opencode/**"
    - "*.lock"
```

Manage rules:
```bash
./.opencode/ralphy.sh --config                    # view config
./.opencode/ralphy.sh --add-rule "use Zod for validation"
```

### PRD Format (Markdown)

```markdown
## Tasks
- [ ] Create auth module
- [ ] Add dashboard page
- [x] Setup database (completed - skipped)
```

### YAML Task Format

```yaml
tasks:
  - title: "Create User model"
    completed: false
    parallel_group: 1
  
  - title: "Create Post model"
    completed: false
    parallel_group: 1  # Same group = runs in parallel
  
  - title: "Add relationships"
    completed: false
    parallel_group: 2  # Runs after group 1
```

### Parallel Execution

```bash
./.opencode/ralphy.sh --parallel                  # 3 agents (default)
./.opencode/ralphy.sh --parallel --max-parallel 5 # 5 agents
```

Each agent gets isolated worktree + branch:
```
Agent 1 → /tmp/xxx/agent-1 → ralphy/agent-1-create-auth
Agent 2 → /tmp/xxx/agent-2 → ralphy/agent-2-add-dashboard
```

### Git Branch Workflow

```bash
./.opencode/ralphy.sh --branch-per-task              # branch per task
./.opencode/ralphy.sh --branch-per-task --create-pr  # + create PRs
./.opencode/ralphy.sh --branch-per-task --draft-pr   # + draft PRs
./.opencode/ralphy.sh --base-branch main             # branch from main
```

### Common Options

| Flag | Description |
|------|-------------|
| `--max-iterations N` | Stop after N tasks (0 = unlimited) |
| `--max-retries N` | Retries per task (default: 3) |
| `--no-tests` | Skip tests |
| `--no-lint` | Skip linting |
| `--fast` | Skip both tests and lint |
| `--no-commit` | Don't auto-commit |
| `--dry-run` | Preview without executing |
| `-v, --verbose` | Debug output |

### Requirements

- `jq` (required)
- `yq` (optional, for YAML tasks)
- `gh` (optional, for GitHub Issues and --create-pr)

### Notifications

Ralphy integrates with `.opencode/notify.sh` for push notifications:
- Configure `NTFY_TOPIC` in `.opencode/.env`
- Sends notifications on completion and errors

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

---

## Notifications (ntfy.sh)

Standard pattern: always use `./.opencode/notify.sh` (it reads `NTFY_TOPIC` from `.opencode/.env`).

Manual usage:

```bash
./.opencode/notify.sh "status" "Precisa checar algo!" default "robot"
./.opencode/notify.sh "done" "Task completed" high "heavy_check_mark"
./.opencode/notify.sh "need_input" "Blocking question" urgent "warning"
```

Ralphy uses this helper automatically for completion and error notifications.

---

## Notes / best practices

- ntfy.sh notifications use `curl` (available by default on macOS).
- Keep `.opencode/.env` out of git.
- Keep `.ralphy/` out of git (created by `--init`).
- Keep OpenAPI specs in `.opencode/openapi/`.
- Prefer read-only DB tooling in production.
- If `AGENTS.md` already exists in a repo, `run.sh` will not overwrite it (it will warn if it doesn't mention the template).

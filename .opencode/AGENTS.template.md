# Project OpenCode Rules (opencode-paulopina template)

## Security and Secrets
- Never commit secrets or paste tokens into repo files.
- Keep all OpenCode runtime secrets in `.opencode/.env` (gitignored).
- Do not read `*.env` files unless explicitly asked.
- Prefer `{env:VAR}` or `{file:...}` in config over hardcoding.

## Webhooks
- Always verify webhook signatures using the raw request body.
- Use constant-time comparison for signatures.
- Fail closed (401) on invalid signature.
- Always write an audit row for webhook receive success/failure.

## Message Sync (Bidirectional)
- Design sync to be idempotent and loop-safe.
- Always record sync attempts in `helpdesk_sync_logs` with direction, latency, and error.
- Never store full message content in mta-core DB when helpdesk is the source of truth.

## SSO
- Always log SSO attempts in `helpdesk_sso_logs`.
- Enforce role mapping strictly (guest has no access).

## DB Access
- Use Postgres via connection string (no Supabase API dependency).
- Production should default to read-only access for DB tools.

---

## Ralphy - Autonomous AI Loop

Ralphy is an autonomous bash script that runs AI agents in a loop until tasks are complete.
Based on [michaelshimeles/ralphy](https://github.com/michaelshimeles/ralphy).

### Supported AI Engines
- **OpenCode** (default) - `--opencode`
- Claude Code - `--claude`
- Cursor Agent - `--cursor`
- Codex CLI - `--codex`
- Qwen-Code - `--qwen`
- Factory Droid - `--droid`

### Quick Start

```bash
# Single task (brownfield mode)
./.opencode/ralphy.sh "add dark mode toggle"

# PRD mode (work through task list)
./.opencode/ralphy.sh --prd PRD.md

# Initialize project config
./.opencode/ralphy.sh --init
```

### Key Features

| Feature | Command |
|---------|---------|
| Single task | `./ralphy.sh "task description"` |
| PRD task list | `./ralphy.sh --prd PRD.md` |
| YAML tasks | `./ralphy.sh --yaml tasks.yaml` |
| GitHub Issues | `./ralphy.sh --github owner/repo` |
| Parallel execution | `./ralphy.sh --parallel --max-parallel 5` |
| Branch per task | `./ralphy.sh --branch-per-task --create-pr` |
| Skip tests | `./ralphy.sh --no-tests` or `--fast` |
| Dry run | `./ralphy.sh --dry-run` |

### Project Configuration (.ralphy/)

Run `./ralphy.sh --init` to create `.ralphy/config.yaml` with:
- Project info (auto-detected: language, framework)
- Commands (test, lint, build)
- Rules (AI must follow these)
- Boundaries (files AI must not touch)

```yaml
# .ralphy/config.yaml example
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

### PRD Format (Markdown)

```markdown
## Tasks
- [ ] Create auth module
- [ ] Add dashboard page
- [x] Setup database (completed)
```

### YAML Task Format

```yaml
tasks:
  - title: "Create User model"
    completed: false
    parallel_group: 1  # Same group = runs in parallel
  
  - title: "Create Post model"
    completed: false
    parallel_group: 1
  
  - title: "Add relationships"
    completed: false
    parallel_group: 2  # Runs after group 1
```

### Common Options

```bash
# Execution control
--max-iterations N    # Stop after N tasks (0 = unlimited)
--max-retries N       # Retries per task (default: 3)
--retry-delay N       # Seconds between retries

# Git workflow
--branch-per-task     # Create branch for each task
--base-branch NAME    # Base branch (default: current)
--create-pr           # Create PR after task
--draft-pr            # Create as draft PR

# Speed
--no-tests            # Skip tests
--no-lint             # Skip linting
--fast                # Skip both

# Debug
-v, --verbose         # Debug output
--dry-run             # Preview without executing
```

### Requirements

- `jq` (required for JSON parsing)
- `yq` (optional, for YAML tasks)
- `gh` (optional, for GitHub Issues and --create-pr)

### Notifications

Ralphy integrates with `.opencode/notify.sh` for ntfy.sh push notifications:
- Sends "done" notification on successful completion
- Sends "error" notification on failures
- Configure `NTFY_TOPIC` in `.opencode/.env`

---

## Tooling (Template)

### MCP Servers (configured globally, enabled per-project by `.opencode/.env`)
- `playwright`: browser automation for E2E checks.
- `n8n`: access workflows via API.
- `context7`: up-to-date docs lookup.
- `openapi`: OpenAPI catalog + schema discovery from `.opencode/openapi/`.
- `postgres`: Postgres access via connection string (prefer read-only in prod).
- `redis`: cache/rate-limit inspection (write ops disabled by default).

### Skills (project-local copy lives in `.opencode/skill/*/SKILL.md`)
- `webhook-verification`: raw-body HMAC + constant-time compare + fail closed + audit.
- `sso-auth-flow`: Supabase JWT -> provisioning -> SSO URL -> audit.
- `message-sync-idempotency`: idempotent + loop-safe bidirectional sync.
- `db-migration-review`: constraints/indices/safe rollout.
- `api-client-wrapper`: consistent HTTP clients (timeouts/retries/logging).

### Commands (project-local copy lives in `.opencode/command/*.md`)
- `/smoke-helpdesk`: identify the core helpdesk endpoints to implement/test.
- `/smoke-webhooks`: checklist for webhook validation (Chatwoot + Evolution).

## Human-in-the-loop notifications (ntfy.sh)
- If you need the user's attention (blocking question, important status, handoff), send a notification via:
  - `!./.opencode/notify.sh "need_input" "<message>" urgent "warning,robot"`
- For non-blocking status updates you want the user to see:
  - `!./.opencode/notify.sh "status" "<message>" default "robot"`
- For completion notifications:
  - `!./.opencode/notify.sh "done" "<message>" high "heavy_check_mark"`
- The notification uses `NTFY_TOPIC` from `.opencode/.env` (do not hardcode topics/URLs in repo files).
- After notifying for a blocking issue:
  - Ask EXACTLY ONE question and then stop.

## Conventions
- Keep all project secrets in `.opencode/.env` (gitignored).
- Keep OpenAPI specs in `.opencode/openapi/`.
- OpenAPI caches live in `.opencode/_catalog/` and `.opencode/_dereferenced/`.
- MCP logs live in `.opencode/logs/`.
- Ralphy config lives in `.ralphy/` (auto-created by `--init`).

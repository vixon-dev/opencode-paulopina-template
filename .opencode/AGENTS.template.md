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
- `sso-auth-flow`: Supabase JWT → provisioning → SSO URL → audit.
- `message-sync-idempotency`: idempotent + loop-safe bidirectional sync.
- `db-migration-review`: constraints/indices/safe rollout.
- `api-client-wrapper`: consistent HTTP clients (timeouts/retries/logging).

### Commands (project-local copy lives in `.opencode/command/*.md`)
- `/smoke-helpdesk`: identify the core helpdesk endpoints to implement/test.
- `/smoke-webhooks`: checklist for webhook validation (Chatwoot + Evolution).

## Conventions
- Keep all project secrets in `.opencode/.env` (gitignored).
- Keep OpenAPI specs in `.opencode/openapi/`.
- OpenAPI caches live in `.opencode/_catalog/` and `.opencode/_dereferenced/`.
- MCP logs live in `.opencode/logs/`.

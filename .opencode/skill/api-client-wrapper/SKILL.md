---
name: api-client-wrapper
description: Build consistent HTTP API clients (Chatwoot/Evolution) with retries, timeouts, and structured logging.
---
## What I do
- Define a standard client shape (baseURL, auth, request/response typing).
- Enforce timeouts, retry policy, and error normalization.
- Require structured logging and correlation ids.

## When to use me
Use this when creating helpdesk-api.client.ts, evolution-api.client.ts, and internal API callers.

## Checklist
- Centralize baseURL/auth.
- Set explicit timeouts.
- Implement retries only for safe cases (idempotent or guarded).
- Normalize errors with stable codes.
- Log request metadata without leaking secrets.

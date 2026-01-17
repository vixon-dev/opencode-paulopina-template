---
name: message-sync-idempotency
description: Design bidirectional message sync to be idempotent and loop-safe.
---
## What I do
- Provide patterns to avoid message loops between systems.
- Define idempotency keys (message_ext_id, helpdesk_message_id) and dedupe logic.
- Recommend safe retry/backoff and conflict handling.

## When to use me
Use this when implementing inbound/outbound sync and webhook handlers.

## Checklist
- Define canonical idempotency keys per channel.
- Store mapping row before/after remote call (transaction strategy).
- Prevent echo loops (direction markers + source checks).
- Handle retries with backoff and cap.
- Record sync attempt in audit table with latency and payload references.

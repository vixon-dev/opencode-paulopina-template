---
name: webhook-verification
description: Validate webhooks (raw body, HMAC, replay safety) and log/audit failures consistently.
---
## What I do
- Enforce raw-body signature verification (HMAC) without breaking the body stream.
- Require constant-time signature comparison.
- Require clear failure logging with request identifiers (but never secrets).
- Recommend replay protection strategy (timestamp + nonce) when available.

## When to use me
Use this whenever implementing or modifying webhook receivers (Chatwoot/Helpdesk, Evolution, etc.).

## Checklist
- Read raw request body bytes before JSON parsing.
- Compute expected signature using the correct secret per tenant/inbox.
- Compare signatures in constant-time.
- Fail closed (401) on mismatch.
- Log audit row for both success and failure.

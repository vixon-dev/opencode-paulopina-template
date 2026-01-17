---
name: sso-auth-flow
description: Implement and review SSO flows (Supabase JWT -> provisioning -> helpdesk login URL) with strict auditing.
---
## What I do
- Provide a canonical SSO flow checklist (auth, role mapping, provisioning, link generation).
- Enforce explicit audit logging for every attempt and provisioning action.
- Require safe error handling (no secret leakage, stable error codes).

## When to use me
Use this when building endpoints like GET /api/v1/helpdesk/sso or provisioning users/accounts.

## Checklist
- Validate Supabase JWT and extract user+company.
- Reject guest/no-access roles early.
- Provision helpdesk account lazily if missing.
- Provision helpdesk user lazily if missing.
- Generate login URL via Platform API.
- Insert audit row with user_agent + ip + success/failure.

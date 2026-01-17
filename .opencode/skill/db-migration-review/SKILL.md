---
name: db-migration-review
description: Review Postgres migrations for correctness, constraints, indexes, and rollback safety.
---
## What I do
- Review schema changes for correctness and performance.
- Check unique constraints and indexes align with access patterns.
- Flag risky operations (DROP COLUMN, long locks) and propose safer rollout.

## When to use me
Use this when writing migrations for helpdesk mapping tables and auditing tables.

## Checklist
- Validate PK/FK/UNIQUE constraints match business invariants.
- Add indexes for lookup-heavy columns.
- Avoid destructive ops without staged rollout.
- Consider migration lock time and production impact.

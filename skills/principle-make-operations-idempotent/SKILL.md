---
name: principle-make-operations-idempotent
description: "Apply when writing anything that changes state: a mutation and the control that triggers it, an effect that writes, a cache update, a form reset, a data migration, a script or codemod. It must converge to the same end state if it runs twice, dies halfway, or races another writer. Money and other irreversible actions first."
disable-model-invocation: true
---

# Make operations idempotent

Every state change converges to the same correct end state, however many times it runs and wherever the last run stopped.

**Why:** Double clicks, retries, refetches, re-renders, reloads, restarts, and a development mode that runs setup twice are all normal. If partial or repeated execution changes the outcome, every one of them becomes a bug report.

**Pattern:**

- **One action, one effect.** A control that triggers a write is disabled while the write is in flight, and the inputs that feed it are locked until it settles. For money or other irreversible actions, confirm the server deduplicates. If it does not, say so in the change.
- **Sync only when needed.** An effect that sets a default writes only when the current value is missing or invalid. It never overwrites a valid user choice on a refetch or re-render.
- **Setup mirrors teardown.** Every subscription, listener, or timer has a cleanup, so running setup twice leaves exactly one of each.
- **Converge on the authoritative value.** After a write, put the server's returned value into every cache that shows it, or invalidate them. Never refetch in a way that can overwrite fresh local state with a stale response.
- **Replace by identity, not by timing.** Reset or rehydrate from an explicit version or id, not because an object's reference changed.
- **Multi-step flows reconcile.** When step two can fail after step one succeeded, decide what a retry does with the half-done state, and make it safe.
- **Persisted state migrates.** When the shape of stored state changes, add the migration. Data written by a previous version is the normal case, not the edge case.
- **Scripts rerun safely.** A generator, codemod, or sync checks what already exists and never replaces good output with a worse result.
- **Separate before serializing.** When two writers target the same key, first ask whether they need the same target at all, and give each its own if not. Serialize structurally only when one shared writer is a real invariant.

**The test:**

1. "What happens if this runs twice in a row?"
2. "What happens if the previous run died at each await or step?"
3. "Can two writers (two requests, two tabs, two features) touch the same key, record, or cache entry?"

If any answer is "it depends on what was left behind", the operation needs a reconciliation step.

Distinct from **principle-never-fake-a-state**, which covers what the user sees while an operation is pending or has failed. This principle covers what the system ends up holding.

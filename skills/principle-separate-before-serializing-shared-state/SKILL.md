---
name: principle-separate-before-serializing-shared-state
description: "Apply when concurrent actors (processes, workers, agents, tabs, requests) might write to the same file, branch, key, or state object. Remove the sharing first by giving each actor its own target, and serialize access structurally only when one shared writer is a real invariant."
disable-model-invocation: true
---

# Separate before serializing shared state

When concurrent actors might share mutable state, first ask whether they need the same object at all. If not, remove the sharing. When the sharing is real, enforce the order in structure. Instructions and conventions are not concurrency control.

**Why:** Concurrent writes to shared state cause race conditions that are intermittent, hard to reproduce, and expensive to debug. A lock fixes the race but keeps the coupling, and every new writer inherits it.

**Pattern:**

- **Find the shared mutable state.** A file two actors read and write, a branch two actors push to, a cache key two requests update, a store two tabs persist.
- **Default to separate targets.** Ask whether the actors need one canonical object or are publishing independent facts. Give each actor its own file, key, branch, or directory, and merge only where the results are read or reported.
- **Separate fields are still shared.** Two workers each writing their own field into one `state.json` still race on the file. `indexer-state.json` and `metrics-state.json` do not.
- **Serialize only a real invariant.** When one shared target must exist, enforce it with a lockfile, sequential phases, a single-writer owner, or an atomic compare-and-swap.
- **Treat "we need a lock" as a smell to check.** It is often the sign that two actors were given one target they did not need to share.

**The test:**

- "Which actors write this, and can two of them run at the same time?"
- "Do they need one canonical object, or could each own its own and a reader merge them?"
- "If they must share, what stops two writes from interleaving, other than a sentence in a doc?"

Distinct from **principle-make-operations-idempotent**, which makes one operation safe to repeat. This principle removes the second writer before any operation runs.

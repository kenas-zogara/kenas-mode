---
name: principle-reconcile-with-live-state
description: "Apply before acting on the state of work: whether a ticket exists, a PR merged, a branch is current, a fix is on dev, or a task is finished. Memory, transcripts, an earlier session, and another agent's pasted output are leads. Check each against its live source before you create, close, report, or build on it."
disable-model-invocation: true
---

# Reconcile with live state

Work state goes stale the moment you stop looking. A note from yesterday, a summary from another agent, or your own earlier reply only tells you where to look.

**Why:** Each source of state ages on its own schedule. Someone else merges a PR, and a teammate closes a ticket. Dev moves on from the commit you tested. Acting on a remembered state leads to a duplicate ticket, a closed item that should be open, a fix for a bug that is already fixed, or a "done" that is not done.

**Before you act:**

- Name the state the action depends on: exists, merged, deployed, assigned, still reproduces.
- Read it from the system that owns it:
  - **PRs and branches:** the forge.
  - **Work items:** the tracker.
  - **Behavior:** the running app on current code. Pull the latest default branch first.
- Search before you create. A ticket, PR, or branch for this may already exist under a different title.
- Act only on what you asked for. Under a broad instruction, list the items you would touch and act on that list, not on everything a query returns.

**After you learn something:**

- Correct the stale source in the same step: the memory file, the work-item state, the tracking note.
- Label every state you report as `live` or `remembered, unconfirmed`, and name the source.

**The test:**

- "When did I last observe this, and from which system?"
- "If this changed since then, does my action break something?"
- "Would a search have found an existing one?"

Distinct from **principle-prove-it-works**, which proves the facts a code change depends on. This one is about the state of the work around the change.

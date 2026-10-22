---
name: principle-migrate-then-delete
description: "Apply when a new pattern, API, library, or page replaces an old one, including ports from one app to another. Prove parity with the old path, migrate every caller, delete the old path in the same wave, then ban it, instead of leaving two paths alive."
disable-model-invocation: true
---

# Migrate then delete

A migration is done when the old path is deleted and banned, not when the new path works. A port is a move, not a copy.

**Why:** Two live paths double the code to read, test, and fix, and they drift apart. Whatever the surrounding code does is what the next person copies, so a surviving legacy path keeps gaining new callers.

**Pattern:**

- **Inventory the callers** of the old path before starting.
- **Prove parity before deleting.** Drive the old and the new side by side with the same data, states, messages, and variants. A difference is either a deliberate change you name, or a bug.
- **Migrate and delete in one wave.** Move every caller, then remove the old path in the same change or the one immediately after. Delete the tests that only protected the old implementation.
- **Ban it.** Once no callers remain, add a lint rule or banned import so the old path cannot come back.
- **Copying is not porting.** A port that duplicates files leaves two sources of truth. Move shared code to one home, then point both consumers at it.
- **Declare temporary coexistence.** When both paths must run during a rollout, name the removal task and link it where the old path lives.

**The test:**

- "After this change, how many callers still use the old path, and what stops that number growing?"
- "Did I compare the old and the new behavior directly before deleting?"
- "Is there now more than one implementation of the same thing?"

Distinct from **principle-minimize-reader-load**, which removes what is unused. This principle retires what is being replaced.

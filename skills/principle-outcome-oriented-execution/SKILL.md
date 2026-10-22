---
name: principle-outcome-oriented-execution
description: "Apply during a planned rewrite or migration that has explicit phase boundaries. Converge on the target design and prove it at the declared checkpoints, instead of writing throwaway compatibility code to keep every intermediate state smooth."
disable-model-invocation: true
---

# Outcome-oriented execution

Optimize for the intended end state, proven at declared checkpoints, rather than for a smooth path between here and there.

**Why:** Keeping every intermediate step fully stable usually means temporary compatibility code: shims, adapters, and dual paths. That code outlives the migration and becomes the debt the migration was meant to remove.

**Pattern:**

- **End-state integrity over transitional stability.** Build toward the target design directly. Do not write code whose only job is to keep a halfway state working.
- **Planned breakage only.** A broken intermediate state is acceptable when it is planned, scoped to a phase, and reversible. An unplanned break is still a bug.
- **Declare it up front.** Before starting, write down which phases may leave what broken, and where the next green checkpoint is.
- **Keep checks on what you touch.** While migrating, keep fast, high-signal checks running on the areas you are actively changing.
- **Verify fully at the end.** At plan completion, the full static and runtime checks pass. No declared breakage survives the last phase.

**The test:**

- "Is this code here for the target design, or only to keep a halfway state alive?"
- "Did I declare this breakage before it happened, and does it end at a named checkpoint?"
- "At the final checkpoint, does everything pass with no shim left behind?"

Use this only for planned work with phase boundaries. Everywhere else, **principle-sequence-verifiable-units** holds: each unit ends green. Here, green is the checkpoint you declared.

Distinct from **principle-migrate-then-delete**, which retires the old path once the new one has parity. This principle decides how much stability the steps in between owe.

---
name: principle-sequence-verifiable-units
description: "Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break the work into small units that each end in a state you can check, check each one before starting the next, and order delivery so a reviewer can replay it."
disable-model-invocation: true
---

# Sequence verifiable units

Order work as a sequence of small units, each ending in a state you can check. Do not start the next unit until the current one passes.

**Why:** A break caught at the unit that caused it is cheap to find. A break caught after a batch is buried, and you have already built on a broken base. Sequencing the same units into a delivery a reviewer can replay replaces "trust me" with "watch it fail, then pass".

**Pattern:**

- **One change per bracket.** Start from a known-good state, make one change, run the check, then continue.
- **Measure against the real baseline.** Rebase onto a clean trunk first, so every check compares against what will actually ship.
- **Check even when it is cheap.** When a script does the edits, the per-unit check costs almost nothing. Run it anyway.
- **Stack commits in the order that proves the work.** The usual shape is the failing test first, then the fix on top. Others are a removal before the reshape, a baseline capture before the change, and the skeleton before the feature.
- **Each commit stands on its own.** Every commit builds and passes, and the sequence reads as an argument.

**The test:**

- "If this unit breaks the build, will I know it was this unit?"
- "Did I start this unit from a state I had checked?"
- "Can a reviewer read my commits in order and watch the claim become true?"

Distinct from **principle-prove-it-works**, which keeps each check real, and **principle-build-the-lever**, which makes the per-unit check cheap. This principle decides the order the checks run in.

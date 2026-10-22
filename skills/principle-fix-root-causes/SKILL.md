---
name: principle-fix-root-causes
description: "Apply when fixing a bug, a failing test, or anything reported broken. Reproduce it, ask why until you reach the cause, fix it once where every caller routes through, check for the same pattern elsewhere, and never silence a symptom with a guard."
disable-model-invocation: true
---

# Fix root causes

A report names a symptom. Find the cause, fix it once where every path passes through, and look for the same pattern elsewhere.

**Why:** Symptom fixes accumulate. Each workaround makes the system harder to reason about, and the real bug stays. The next caller the patch did not cover hits it again.

**Pattern:**

- **Reproduce first.** No fix before you have seen the failure yourself.
- **Instrument, don't guess.** When state is unclear, log it or read the actual error. Rule hypotheses out with evidence, one split at a time.
- **Ask why until you reach a design fact.** "The value was null" is a symptom. "This field is never set for cancelled records" is a cause.
- **Fix where every caller routes through.** Find every caller of the code you are about to change. A fix in the shared function is smaller than a guard in each caller, and it covers the callers the report did not name.
- **No symptom guards.** An optional chain, early return, empty catch, type cast, retry, or delay that makes a violated invariant go quiet is a symptom fix. If a workaround needs a paragraph to justify it, the code is wrong.
- **The pattern, not the instance.** Search for the same mistake elsewhere and fix every occurrence, or name the ones you leave.
- **Attack the premise.** When two fixes that share an assumption have both failed, write the assumption down and test it before writing a third.
- **Suspect stale state first** when something breaks only after a reload or restart: persisted storage, caches, and saved sessions.

**The test:**

- "Can I state the cause in one sentence that is not the symptom restated?"
- "Does the fix sit where every caller routes through, and did I check every caller?"
- "Would this change hide the next occurrence instead of preventing it?"
- "Does a test fail without the fix and pass with it?"

Distinct from **principle-encode-lessons-in-structure**, which stops a fixed mistake from coming back.

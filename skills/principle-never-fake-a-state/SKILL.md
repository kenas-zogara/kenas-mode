---
name: principle-never-fake-a-state
description: "Apply when rendering or acting on asynchronous data, writing a fallback value (?? [], ?? 0, || ''), catching an error, or enabling an action whose inputs come from a request. Loading is not empty, missing is not zero, failed is not success. Represent each state explicitly and render it on purpose."
disable-model-invocation: true
---

# Never fake a state

Loading is not empty. Missing is not zero. Failed is not success. Represent every state a value can be in, and render each one on purpose.

**Why:** A fallback that turns "not known yet" into a real-looking value makes the interface show something false. The user sees "no results" while data is still loading, a zero where the amount is unknown, or a success where the write failed. They act on it, and the logs record no error.

**Pattern:**

- **Four states, four renders.** Asynchronous data is pending, failed, empty, or ready. Each gets its own output. Empty is only for a successful response with no items.
- **No disguising fallbacks.** `?? []`, `?? 0`, `|| ''`, or a default object on data that has not arrived turns "unknown" into "known and blank". Keep the value absent until it is known, and let the type force every consumer to handle that.
- **Errors surface.** Every failure reaches the user in a form they can act on, or it is rethrown to a layer that shows it. A `catch` that logs and continues is a silent failure. So is a retry that hides a broken contract.
- **Actions wait for their inputs.** A control whose correctness depends on fetched data stays disabled until that data has resolved successfully, not merely until it stops loading.
- **Derived requests wait for their sources.** A request keyed on another request's result waits for that result and refreshes when it changes. It never runs on a stale or placeholder key.
- **Keep what already worked.** When replacing an implementation, keep every state the old one showed: its error message, its empty state, its regional and role variants.

**The test:**

- "What does the user see while this is pending, and when it fails? Can either be mistaken for 'no data'?"
- "Does any fallback turn an unknown value into a plausible one?"
- "Is any error caught and dropped, or replaced with a default?"
- "Can this action run on inputs that have not resolved?"

Distinct from **principle-make-operations-idempotent**, which covers what the system ends up holding. This principle covers what the system claims to hold.

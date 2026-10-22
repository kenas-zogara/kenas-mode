---
name: principle-prove-it-works
description: "Apply before building on an assumption and before claiming anything works. Observe the facts the change depends on (the real response, the real units, the current behavior) before implementing, then show evidence from where the user touches it, not a proxy such as a passing type check, a mock that was called, or a summary from another agent. State how far each claim got: pointed at, walked, ran, or reproduced."
disable-model-invocation: true
---

# Prove it works

Nothing is true until observed. Before building, prove the premise. After building, prove the result where the user touches it. Every claim states how far its evidence got.

**Why:** Unverified work has unknown correctness. Indirect evidence (it compiles, the suite is green, a helper was called, a subagent said so) feels cheaper than looking. Acting on a wrong inference costs far more than checking the source.

**Before: prove the premise.**

- List the facts the change depends on: the response shape, units, nullability, and enum values; how a library behaves at the installed version; what the user sees today.
- Observe each one directly. Call the endpoint, read the library source, reproduce the bug, open the page. A schema, a field name, or a comment is a claim, not an observation.
- If a fact cannot be observed, say so, and design so that a wrong guess fails loudly.

**After: prove the result.**

- Build it. A clean build is necessary, not sufficient.
- Run it where the user touches it, and exercise the changed path end to end.
- Read the real value back. After a write, reload and read it from a fresh fetch. An optimistic update that rolls back proves nothing.
- For a bug, show the failing reproduction before the fix and the passing one after.
- For delegated work, inspect the artifact (the diff, the file, the running behavior), not the delegate's summary.

**Script the check when you can.** A rerunnable test or script beats a one-time look. You and the reviewer can run it again instead of taking your word for it.

**How sure are you?** For each claim that matters, state where it stopped:

1. Said so.
2. Pointed at the line.
3. Walked the failure path and showed it cannot be reached.
4. Ran code that fails loudly if the claim is wrong.
5. Reproduced it in the running app.

Rungs 1 and 2 are not evidence. Anything short of rung 4 is labelled "unverified".

**The test:**

- "Which fact would make this change wrong if it were false, and have I observed it?"
- "Is my 'done' a proxy or the real thing?"
- "Could a reviewer rerun my evidence?"

When a verification fails, suspect the observation method before the system. Distinct from **principle-experience-it-first**, which decides whose experience the evidence must show.

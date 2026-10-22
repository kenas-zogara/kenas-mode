---
name: principle-build-the-lever
description: "Apply to any non-trivial work, not only bulk work: edits, migrations, analyses, and checks. Build the tool that does it or proves it (a codemod, script, generator, or a written recipe your subagents follow) instead of working by hand. The tool is what a reviewer reruns."
disable-model-invocation: true
---

# Build the lever

When the work is not trivial, build the tool that does it instead of doing it by hand.

**Why:** A codemod, generator, or script does the work the same way every time and reruns for free. It is also one file a reviewer can read and rerun. Hand-done changes can only be re-verified by redoing them. A deterministic script replaces "trust me" with "run this".

**Pattern:**

- **Default to the lever.** Skip it only when the task is trivial, a couple of obvious edits you can see at a glance. The bar is triviality, not repetition. A one-off still earns a lever when the lever is what makes the work checkable.
- **Learn by hand, then build.** Do the first unit by hand to learn the recipe. Build the tool, rerun it on that unit, and diff the result against your hand-done version. Make it safe to rerun.
- **Pick the tool by the work.** A codemod or script for edits, a generator for repetitive files, a query over the data loaded into SQLite for analysis, a rerunnable check for verification.
- **A script beats fan-out.** If the tool can process every unit in one pass, run it yourself. Do not send subagents to hand-apply what a script can do.
- **Write the recipe once for delegates.** When you do fan out, put the recipe, the verification contract, and the files not to touch in one written instruction every subagent reads. Keep it outside their write scope, so no subagent can quietly edit the contract.
- **It leaves a file.** If you cite this principle and the diff has no codemod, script, generator, or delegate recipe, you did not apply it. Commit the lever when the work outlives the session.
- **Smallest lever that works.** Build the smallest script that does or proves the job, never a framework.

**The test:**

- "Could a reviewer rerun something to check this, or only redo it by hand?"
- "Did I diff the tool's output against one unit I did by hand?"
- "Am I fanning out work a single script could do in one pass?"

Distinct from **principle-encode-lessons-in-structure**, which turns a recurring lesson into a lasting guardrail. This principle is about throughput and reviewability on the work in front of you. **principle-prove-it-works** covers scripting the check itself, and **principle-minimize-reader-load** keeps the lever small.

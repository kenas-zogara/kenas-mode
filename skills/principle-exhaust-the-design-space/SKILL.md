---
name: principle-exhaust-the-design-space
description: "Apply when a UI interaction or architectural decision has no precedent in the codebase and the right answer is not obvious. Build two or three structurally different prototypes, compare them side by side, and only then commit."
disable-model-invocation: true
---

# Exhaust the design space

When a decision has no precedent and the answer is not obvious, build several concrete alternatives and compare them before you implement one.

**Why:** Building the wrong thing costs more than exploring three options. The first idea anchors every later one, and a design nobody compared against anything is a guess that shipped.

**Pattern:**

- **Two or three, structurally different.** Each option takes a different shape: a modal versus inline editing, a push model versus a poll, one table versus two. A second flavor of the first idea does not count.
- **Concrete, not described.** A clickable prototype, a sketch, or a type signature with its call site. Prose comparisons hide the costs a prototype exposes.
- **Side by side.** Judge the options against the same criteria at the same time: what the user feels, what the code has to know, and what the next change costs.
- **Throw the losers away.** A prototype is a question, not a first draft. Keep what you learned, not its code.
- **Design it twice.** When time is short, two options are still better than one.

**When it applies:**

- A UI interaction with no prior art in the codebase.
- An architectural choice with more than one viable approach.
- A product decision where the experience depends on feel, not logic.

**When it doesn't:**

- Mechanical work where the codebase already has a pattern.
- A bug fix or refactor with a clear target state.
- A change where the constraints leave one viable approach.

**The test:**

- "Does the codebase already have a pattern for this?" Then use it.
- "Are my options different shapes, or one shape with different names?"
- "Did I compare working artifacts, or only descriptions of them?"

Distinct from **principle-model-the-domain**, which picks the data shape once the direction is chosen. For judging UI options, see **principle-experience-it-first**.

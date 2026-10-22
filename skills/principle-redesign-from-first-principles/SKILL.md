---
name: principle-redesign-from-first-principles
description: "Apply when a new requirement lands on an existing design. Redesign as if the requirement had been a founding assumption, propagate it through every type, doc, and example it touches, and deliver the result in small steps instead of bolting it on."
disable-model-invocation: true
---

# Redesign from first principles

When a new requirement arrives, don't bolt it onto the current design. Work out what you would build if the requirement had been there from the start, then move the code there.

**Why:** A bolted-on requirement leaves the old design's assumptions in place and adds a special case on top. Each special case makes the next change harder, until the design no longer describes what the code does. Redesigning at the moment the requirement arrives keeps options open. Recovering the design later reads as a rewrite and gets deferred.

**Pattern:**

- **Read the whole design first.** Read every file the requirement touches and the reasons behind the current shape before you change any of it.
- **Ask the from-scratch question.** "If we were writing this today with this requirement, what would we build?" Compare that answer with the current design, and name every place they differ.
- **Propagate everywhere.** Change the types, names, docs, examples, and stated rationale that assumed the old world. A design half-updated is two designs.
- **Plan the whole, ship in steps.** Decide the full target first, then deliver it in increments that each leave the system working.
- **Keep what still fits.** The from-scratch answer often matches most of the current code. Redesign the parts the requirement breaks, not the parts you would merely write differently.

**The test:**

- "Does my change add a flag, branch, or optional field that only exists because the old design didn't expect this?"
- "Would a reader who never saw the old version understand why the code has this shape?"
- "Do the docs, examples, and types still describe the old assumptions anywhere?"
- "Does each step I ship leave the system working?"

Distinct from **principle-fix-root-causes**, which traces a failure back to its cause. This principle reshapes a working design for a requirement it never expected. For moving callers from the old shape to the new one, see **principle-migrate-then-delete**.

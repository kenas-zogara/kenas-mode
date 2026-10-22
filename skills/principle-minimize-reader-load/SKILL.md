---
name: principle-minimize-reader-load
description: "Apply to every diff and every piece of prose, before adding code, a layer, a file, a flag, a comment, or a paragraph. Write less and stop doing more: the smallest change that does what was asked, nothing it was not asked to do, and code a new reader can trace in thirty seconds."
disable-model-invocation: true
---

# Minimize reader load

Every line you add is a line someone must read, review, and maintain. Delete before you add, reuse before you write, do only what was asked, and keep what remains cheap to trace.

**Why:** Code is read far more often than it is written. Reader load is the work a reader does to understand code: the layers between a question and its answer, and the hidden state they must hold in their head. Every future reader pays for every extra line, layer, and unrequested change.

**Pattern:**

- **Write less.** Before writing, look for what already does it, in this order: this codebase, a shared package, the platform or standard library, an installed dependency. Only then write the minimum that works.
- **Subtract first.** When changing a design, remove dead code, redundant checks, and obsolete paths before building on top. The next design is usually obvious once the code is smaller.
- **Stop doing more.** No unrequested refactors, renames, reformatting, extra features, or defensive code for cases that do not exist. A cleanup the task did not ask for is its own change.
- **Collapse layers that do not earn their place.** A wrapper with one caller, an adapter with one implementation, or a layer that forwards the same arguments adds a hop and hides nothing. Inline it.
- **Question the threading.** When a task asks you to pass a new signal through several types, schemas, or pipeline stages, stop and look for a direct path first. Each layer it crosses is one more place a reader must follow it.
- **Delete, don't stub.** A reference, file, or section with nothing new in it gets deleted, not left as a placeholder that points elsewhere.
- **Shrink state.** Prefer return values to mutation, locals to fields, and derivation to synchronized copies.
- **Name so no comment is needed.** A good name, an extracted function, or a precise type replaces the comment that would have explained it.
- **Prose too.** A PR description, commit message, or reply leads with what the reader must know or do, and stops.

**The test:**

- "Does every added line trace to the request?" If not, it is scope creep. Remove it.
- "Can a new reader answer 'where does X come from?' and 'what can change X?' in thirty seconds?"
- "Is there a wrapper with one caller, or a layer that forwards the same arguments?"
- "Did the change push a file past what a reader can hold, around a thousand lines?"
- "Does this reduce reader load somewhere else by at least as much as it adds here?"

Distinct from **principle-eat-useless-comments**, which applies the same test to comments.

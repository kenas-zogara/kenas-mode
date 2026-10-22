---
name: principle-model-the-domain
description: "Apply before writing logic, when adding a variant, flag, or state to an existing flow, and when choosing where state lives. Name the data shape first, encode variants in one structure the compiler checks (discriminated union, lookup table, state machine) instead of scattered conditionals, and reuse an established pattern before inventing one."
disable-model-invocation: true
---

# Model the domain

Name the data shape before writing code. Encode the domain in one structure the compiler can check, so the next feature adds a row, not a branch.

**Why:** Scattered booleans, repeated shape assumptions, and branching spread across files are accidental complexity. A structure that matches the domain makes invalid states unrepresentable and deletes branches. Choosing it at write time is cheap. Recovering it later reads as a refactor and gets deferred.

**Pattern:**

- **Shape first.** Write the types and the caller's usage before the implementation. The right shape makes the downstream code obvious.
- **State lives where its lifetime says.** Server data belongs to the server cache. State a user should be able to link to or restore belongs in the URL. State shared across unrelated parts of the app belongs in one store. State used by one component stays in it. Anything derivable is computed, never stored and synced.
- **Variants as a sum type.** A discriminated union, not a bag of optional fields where contradictory combinations compile. `{ done: boolean; doneAt?: Date }` admits `done: true` with no date. `{ kind: 'open' } | { kind: 'done'; at: Date }` does not.
- **Tables over branches.** A lookup table, registry, or state machine beats an if/else chain that grows one branch per feature. Each entry declares everything the system needs from it, so a new entry cannot forget a case.
- **Exhaustive by construction.** Matching on a variant must fail to compile when a variant is added and not handled. A `default` branch that silently does nothing is a future bug.
- **Named values, not bare literals.** A value that drives logic or appears in two places gets a name and a type.
- **Established pattern first.** When the codebase already has a pattern for this shape, use it. When there is no precedent, sketch two structurally different designs and compare them before committing.

**The test:**

- "Does this change grow an if/else or switch by one branch, or add a second boolean that must stay in sync with the first?"
- "If a variant is added next month, will the compiler point the next person at every place that must handle it?"
- "Can I write a comment explaining which combinations of these fields are valid?" Then the type is too loose.
- "Is this state stored somewhere it could be derived from?"
- "Does a pattern for this already exist here?"

Do not force an abstraction. Boring, local code whose shape is already clear stays as it is. An abstraction earns its place by deleting branches, duplicated rules, or invalid states, not by adding indirection.

Distinct from **principle-separation-of-concerns**, which decides who owns the code. This principle decides the shape of the data and the structure of the decisions.

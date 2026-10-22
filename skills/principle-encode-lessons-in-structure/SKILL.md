---
name: principle-encode-lessons-in-structure
description: "Apply when a correction, review comment, or bug repeats, when a rule exists only as prose, or when a lesson lives only in someone's memory, notes, or chat. Move the lesson into the strongest mechanism available (a type, a lint rule, a CI check, a canonical helper, a runtime check) and delete the prose that only restated it."
disable-model-invocation: true
---

# Encode lessons in structure

A rule someone must remember is a rule someone will forget. Put each recurring lesson where forgetting it fails loudly.

**Why:** Prose asks the reader to notice, remember, and comply. Agents lose context and people skim, so prose-only rules drift. A mechanism enforces the rule without anyone's cooperation, and it keeps working after the person who learned the lesson has moved on.

**Pick the strongest mechanism the situation allows:**

1. A type that makes the wrong state unrepresentable.
2. A lint rule, banned import, or banned API that fails the build.
3. A CI script or drift check.
4. A canonical helper that makes the right way the easy way.
5. A runtime check or tripwire that fails when an assumption stops holding.
6. A rule document, loaded where the work happens.
7. A comment or a personal note. This is the weakest, and never enough on its own.

People and agents copy whatever the surrounding code already does, so a weak guard becomes the next template.

**Pattern:**

- **Capture every correction.** When a reviewer, a test, or a user catches something, decide whether it is a one-off or a pattern.
- **Route it.** A one-off gets fixed. A recurring fix gets a mechanism. A domain fact gets a type or a shared rule document, never only a personal note or a chat message.
- **Act on it now.** Encode it now, or record a tracked task. "I'll keep that in mind" records nothing.
- **Delete the restatement.** Once a mechanism enforces a rule, remove the prose that only repeated it, and point to the mechanism.
- **Stop legacy violations from growing.** When existing code violates the new rule, check only new and changed lines, or fail when the count of violations rises.

**The test:**

- "Is this the second time this correction has been made?"
- "Where would forgetting this rule fail loudly today?" If nowhere, it is not encoded.
- "Does this lesson live only in one person's memory, notes, or chat history?"

Distinct from **principle-fix-root-causes**, which fixes the instance. This principle stops the next one.

---
name: principle-eat-useless-comments
description: "Apply whenever writing a comment, and before every commit and review. A comment is guilty until proven load-bearing: eat narration, restated names and types, change history, and commented-out code, and keep only what the code cannot say. Judged by a fresh reader who did not write the code. Prefer suppressions that expire (@ts-expect-error) to ones that never do (@ts-ignore)."
disable-model-invocation: true
---

# Eat useless comments

A comment is guilty until proven load-bearing. If the code already says it, the comment goes. If the code is surprising, fix the code instead of explaining it.

**Why:** A comment that restates the code adds nothing while it is true, and becomes a lie the moment the code changes. It also buries the rare comment that matters. The author is the worst judge, because authors defend their own comments. A reader who did not write the code does the judging.

**Eat these:**

- Narration that restates the line below it.
- Doc blocks that repeat a function's name, and parameter or return tags that repeat the types.
- The same fact stated on every consumer instead of once where it lives.
- The rationale for this change, changelog notes, and author or date stamps. They belong in the PR and in version control.
- Commented-out code.
- Decorative banners, and section labels that name only language constructs ("imports", "types", "render").
- Workarounds, TODOs, and suppressions with no link and no stated reason.

**Keep only these:**

- **Why, not what.** The non-obvious reason a correct-looking alternative was rejected.
- **What the type cannot say.** A unit, format, or invariant, stated once on the type or value that carries it.
- **An example the signature cannot show,** such as a formatter's output, written as a call with its result.
- **A tracked deferral.** A workaround or TODO that links its issue or work item. The only accepted reason for having no link is that none can exist, and the comment says why.
- **A pointer to the source of truth,** instead of a copy of it.
- **A section scheme that names concerns.** Judge the scheme as a whole. Never delete one label and leave its siblings.
- **Tool directives,** because they are code, not prose. Each carries its reason or link and uses the narrowest form. Prefer the suppression that fails once it is no longer needed (`@ts-expect-error`) to the one that stays silent forever (`@ts-ignore`), and a single-line disable to a file-wide one.

**The test:**

- Strip the comment and read only the name and the signature. If no fact is gone, eat it.
- "Is this comment explaining a surprise in our own code?" Then the code is the defect. Rename, extract, or tighten the type, and delete the comment.
- "Can I name the keep rule that protects this comment, and the fact it carries that the code cannot?" If not, eat it. Doubt is not a reason to keep.

**Scope.** This applies to new and modified code. Remove existing comments only where the change already edits the code around them. A sweep of untouched files is a separate change, never mixed with behavior changes.

Distinct from **principle-minimize-reader-load**, which applies the same economy to code and prose.

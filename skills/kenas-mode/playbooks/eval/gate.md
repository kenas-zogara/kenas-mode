# Principle gate

Fresh read-only agents check a change against the principles it triggers, and the lead judges what they find. Run it from the Principles row of [eval](../eval.md), at `code` (the diff before it ships) or `ship` (the diff plus the PR body).

## 1. Select with this table, not from memory

Keep a principle when the stage is in its row and the change matches its trigger. A principle the table selects is checked, even when it looks irrelevant. Skipping one silently is the failure this gate exists to stop.

| Principle | Stages | Triggers on a change that… |
| --- | --- | --- |
| `system-boundaries` | code | touches an API client, a response transformer or schema, URL or query state, middleware, an embed or `postMessage` channel, or date and time code, or adds `as`, a non-null `!`, `?.`, `JSON.parse`, storage access, or `catch` |
| `separation-of-concerns` | code | adds a file, or touches a shared package, a hook, a route definition, or a component past the repo's extraction thresholds |
| `model-the-domain` | code | adds a type, `switch`, `enum`, boolean prop or field, local state, a store slice, URL state, a query key, or a table |
| `type-system-discipline` | code | adds or changes a type, a signature, or a branch over a union |
| `make-operations-idempotent` | code | adds or changes a mutation, an effect, a cache write or invalidation, a form reset, persisted state, or a script |
| `never-fake-a-state` | code | adds or changes a query, a fallback such as `?? []`, `?? 0` or `\|\| ''`, a `catch`, or an enabled or disabled condition |
| `test-behavior-not-implementation` | code | adds or changes a test |
| `minimize-reader-load` | code, ship | always. At `ship`, it also judges the PR body against the repo's PR-body rules |
| `eat-useless-comments` | code | adds or edits a comment. Run by [comment-eater](comment-eater.md), not the principle checker |
| `prove-it-works` | code, ship | always. At `code` the checker judges the tests in the diff; at `ship`, the evidence in the body |
| `experience-it-first` | ship | touches rendered UI, locale files, or styles |
| `fix-root-causes` | code | the task is a bug fix |
| `encode-lessons-in-structure` | ship | adds or edits a rule doc, or a finding repeats one from an earlier review |
| `migrate-then-delete` | ship | ports, replaces, or duplicates a page, component, or library usage |

## 2. Pick each principle's rule docs

For each kept principle, pick the repo docs that apply it to the area the change touches. Look in the repo's rule index (its `CLAUDE.md` or `AGENTS.md`) and in its full docs listing, not only the docs a path glob loads: a domain rule the globs miss is still a rule. A principle with no matching doc is checked against the principle alone.

## 3. Fan out

Launch every checker in one message, so they run in parallel. Each is a fresh subagent told it is read-only (`subagent_type: "general-purpose"`), and none sees another's output. Give each:

- the path of [principle-checker](principle-checker.md) to read and follow,
- its principle's path, `~/.claude/skills/principle-<name>/SKILL.md`,
- the rule docs from step 2,
- the stage, the intent in one paragraph, and the diff.

At `code`, also launch one [comment-eater](comment-eater.md) with the repo's comment rule, if it has one.

## 4. Judge the findings

You are the lead, not an aggregator. Open the code at HEAD for every finding, then sort it:

- **Act on:** a real defect whose failure scenario holds when you trace it.
- **Consider:** real, but its cost may outweigh fixing it now. The user decides.
- **Dismissed:** unreachable, contradicted by a rule doc, or a preference. Write a one-line reason.

The same line flagged by two checkers is the strongest signal. A finding with no failure scenario is dismissed.

## 5. Act, on your own change only

Apply the comment-eater's eats and rewrites, and fix each act-on finding at its root. Then re-run each affected checker once. When the change is someone else's, or the caller is a review that reports rather than fixes, stop before this step.

## 6. Write the verdict

At most twelve lines, plus the evidence block:

- The stage and the scope checked.
- The principles checked, and for each one that changed a decision, the decision.
- Act-on findings, fixed or still open. Dismissed findings, each with its reason.
- What was not verified, and why.

At `ship`, the PR body carries one line per principle that changed a decision. The full verdict stays in the conversation.

## Guardrails

- The author never judges its own diff alone. Every principle finding comes from a fresh agent that did not write the change.
- Checkers and the comment-eater never edit. Only step 5 changes files.
- No finding without a failure scenario, and no dismissal without a reason.

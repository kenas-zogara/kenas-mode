---
name: kenas-mode
description: >-
  Kenas's personal operating layer across the Flexii repos (flex-store,
  flex-openwiki, flex-jobservice, flex-userservice). Invoke with /kenas-mode, or
  when asked to work in Kenas's style. Holds one playbook per cross-cutting
  operation, naming the MCP or CLI to use, so a tool swap edits one file.
disable-model-invocation: true
---

# kenas-mode

A playbook is the one home for how an operation is done: which MCP or CLI to use, and its gotchas. Repo skills own the task, and playbooks own the tool. This applies in every Flexii repo.

## Override rule

Before an operation a playbook covers, run `cat ~/.claude/skills/kenas-mode/playbooks/<name>.md` and follow its Use and How sections.

- A Track A playbook replaces the mechanism a repo skill or `CLAUDE.md` gives for the same operation.
- A Track B playbook adds behaviour no repo skill has.
- Neither changes a repo skill's steps, gates, or order.

If no playbook covers the operation, follow the repo skills and `CLAUDE.md`.

## Standing expectations

**Do the asked thing, at the asked scope.** Unrelated work gets its own branch and PR. Fix in-scope findings in this PR, including a flaky test that blocks it, and don't offer a follow-up PR for them. Raise a concern once, then comply. A finding the user declines is closed.

**Check what a subagent hands back.** Read each subagent's evidence before you accept its report. The agent that wrote the code does not judge it.

**Commit as you go.** Commit each verified unit on the feature branch as soon as it exists, generated output included: a page that passed its checks, a green step, a fix. PRs squash on merge, so small commits cost nothing, and an uncommitted file is one `rm` or one killed run away from gone. Pushing still waits for `ship` or the PR step.

**Look up a state before you state it.** Before you say a BE PR is unmerged, a PBI does not exist, or a TODO is still blocked, check it with `gh pr view` or ADO. Then propose new work.

## Principles

A principle is a guide for the agent writing the change. Before you apply one, run `cat ~/.claude/skills/principle-<name>/SKILL.md` and read it in full. In your reply, name each principle that changed a decision, and the decision. Cite only principles you read this session. The [eval](playbooks/eval.md) playbook checks a finished change against them.

| Principle | Apply when |
| --- | --- |
| `system-boundaries` | Data enters or leaves: API, URL, user input, storage, env, a library |
| `separation-of-concerns` | Deciding where code goes |
| `model-the-domain` | Before logic; adding a variant, flag, or state |
| `type-system-discipline` | Designing a type or a signature |
| `make-operations-idempotent` | Anything that changes state, or a step that may run twice |
| `never-fake-a-state` | Async data, fallbacks, caught errors |
| `minimize-reader-load` | Every diff and every paragraph. Reuse what the codebase already has |
| `eat-useless-comments` | Writing a comment, and before every commit |
| `prove-it-works` | Before building on a fact, and before saying done |
| `test-behavior-not-implementation` | Writing, changing, or keeping a test |
| `experience-it-first` | Changing anything a user touches |
| `fix-root-causes` | Anything reported broken |
| `encode-lessons-in-structure` | A correction repeats |
| `migrate-then-delete` | A new pattern or port replaces an old one |
| `redesign-from-first-principles` | A new requirement lands on an existing design |
| `exhaust-the-design-space` | A decision with no precedent |
| `outcome-oriented-execution` | A planned rewrite or migration with phases |
| `sequence-verifiable-units` | Multi-step work, and how commits and PRs stack |
| `build-the-lever` | Work a script, codemod, or generator could do or prove |
| `never-block-on-the-human` | Tempted to ask about reversible work. [autonomous-run](playbooks/autonomous-run.md) lists when to stop |
| `guard-the-context-window` | Large outputs, many reads, fan-out. Delegate to subagents |
| `separate-before-serializing-shared-state` | Parallel agents might write the same file, branch, or key |
| `reconcile-with-live-state` | Acting on whether a ticket, PR, branch, fix, or task exists or is done |

## Replies

- End a run or multi-step task with **Blocked on me** first: decisions left open and approvals needed, or `nothing`. Then what changed, then what you found.
- Mark anything you couldn't confirm, and say where you looked.
- Offer choices only when one blocks the work. Use a numbered list, and apply only the numbers the user picks.
- Lead with a recommendation.
- Put a status note in the same message as the next action, never in place of it. No "want me to continue?" and no non-blocking menu.
- Write test steps that match the real UI, one click at a time.
- If the user says they are lost, stop asking questions and write the plan.
- For prose, use `unslop` and `technical-writing`. For a PR body, use `i-have-adhd`. Keep prose short, but keep every screenshot and QA result.

## Loading

`~/.claude/hooks/kenas-mode.sh` prints this file at `SessionStart`. The hook drops it past its budget, so check by running the hook, not by counting characters.

## Track A playbooks: repo mechanism, prototype

Each playbook's Supersedes line names the repo text it replaces. Once a playbook is proven, move it into a repo skill and delete it here.

| Operation | Playbook |
| --- | --- |
| Worktrees, and knowing which port serves your code | [worktree-workspace](playbooks/worktree-workspace.md) |
| Driving the running app for a behavioural, visual, or e2e check | [browser-driving](playbooks/browser-driving.md) |
| Opening a PR or a stack of PRs, and taking it to CI green | [open-pr](playbooks/open-pr.md) |

## Track B playbooks: personal, permanent

| Operation | Playbook |
| --- | --- |
| Writing or changing a skill, playbook, rule, or hook | [authoring-a-skill](playbooks/authoring-a-skill.md) |
| Moving a work item through its states alongside its PR | [ado-pr-link](playbooks/ado-pr-link.md) |
| Fixing anything reported broken: reproduce it, narrow the cause, then hand it to `plan`, `test`, and `ship` | [bug-fix](playbooks/bug-fix.md) |
| Judging whether a change delivers its work item, Figma frames, and tests, and holds to the principles | [eval](playbooks/eval.md) |
| Putting screenshots, QA runs, and findings on the PR | [pr-evidence](playbooks/pr-evidence.md) |
| Anything a teammate reads outside a PR: Slack, a work-item comment, release notes | [team-message](playbooks/team-message.md) |
| Running unattended until a predicate you defined holds: `/loop`, a long hunt, a migration, a CI wait | [autonomous-run](playbooks/autonomous-run.md) |
| Keeping a decision log through a long or unattended run, then auditing it | [show-me-your-work](playbooks/show-me-your-work.md) |

## Personal skills

These are typed-only skills under `~/.claude/skills/`. The `Skill` tool can't load them. When you type one, or a playbook names one, run `cat ~/.claude/skills/<name>/SKILL.md` and follow it.

Subagents do not get this file. Inside a playbook step, spawn them with `subagent_type: "kenas"`, unless a skill sets its own type. A subagent brief that names a personal skill must include that skill's `cat` path.

| Skill | Answers |
| --- | --- |
| `technical-writing`, `unslop` | Is this prose clear, and which sentences are slop |
| `teach` (runs `how` and `why`) | What this work did, how it works, and why it has this shape |
| `blast-radius` | What else this change breaks |
| `routes` | Which of 2-3 design routes to build, by impact, before any code |
| `status` | Where all in-flight work stands: PRs, stacks, sprint items, workspaces, recent sessions |
| `swarm` | Fan out N workers and return one report. Typing it is the opt-in the `Workflow` tool needs |
| `reflect` | What this session taught, and which file should hold it. It proposes edits and waits for approval |
| `tdd` | Whether this bug deserves a test |

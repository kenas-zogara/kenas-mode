# Playbook: bug-fix

**When.** Anything is reported broken, from the report through to the PR. This covers an Azure DevOps Bug, a QA finding, a failing test, and "it doesn't work on staging".

**Track.** B, personal and permanent. It covers an operation no repo skill covers and replaces nothing. `principle-fix-root-causes` says what a correct fix is, and `plan` classifies a bug as failing test first. Nothing covers the diagnosis between the report and the plan: who reproduces it, where, and what counts as evidence. It uses the [browser-driving](browser-driving.md) and [ado-pr-link](ado-pr-link.md) playbooks, and hands off to `plan`, `test`, `commit`, `review`, and `ship`, whose workflows still rule.

**Use.** Runtime evidence, not hypotheses. You own this task, so you plan, review, and verify. Delegate the investigation and the fix to subagents and stay in the lead.

Every line you ship traces to evidence you observed. An extra change that might help is a hypothesis, not a fix, and it does not ship. When evidence refutes a hypothesis, revert what that hypothesis motivated. Ship the smallest change the evidence justifies and nothing more.

`principle-fix-root-causes` is the judgment this playbook executes. `principle-prove-it-works` sets the bar for steps 1 and 6.

Three things that are never the fix. Deleting the failing test is not a fix, so guard at the boundary instead. A guard in each caller is not a fix, so fix where they all pass through. Patching the child PR is not a fix when a stacked parent introduced the defect, so repair it in the PR where it entered.

## Steps

1. Reproduce it yourself, on the screen the report names, using [browser-driving](browser-driving.md). Do not hand the repro back to the user. A protocol that says to ask the user to try it does not override this. Ask only when you can state a specific reason the browser cannot reach the target, and only after driving it as far as it goes. If it will not reproduce directly, force it. Synthesize the trigger, tighten the conditions, use `emulate` to change the network or the viewport, or add instrumentation until it fires.

   An Azure DevOps Bug carries its repro in `Microsoft.VSTS.TCM.ReproSteps`, holding Steps, Expected, and Actual. Bugs have no acceptance criteria field. See [eval](eval.md) for how to read work items.

   In a worktree the repro starts before the browser does, because a fresh worktree has no `.env` and no server on the port you expect. Read [worktree-workspace](worktree-workspace.md) first.

   Verify the premise before you choose a fix. Read the backend service's own code, which is checked out locally for jobservice and userservice, rather than inferring its behaviour from the frontend. Compare against current production behaviour before declaring what the intended behaviour is.

2. Fan out the investigation as two parallel subagents, and read both before you split anything.
   - How. Trace the affected code end to end along the layer chain, from `apps/*` into `packages/ui`, `packages/api`, and `packages/common`. Find where the value comes from and who else calls it.
   - Why. Look at the history. Run `git log -S'<symbol>'`, `git log -L`, and `git bisect` against the repro, and find the PR that introduced the line with `gh`.

3. Narrow the cause by halves. Form the candidate hypotheses, then eliminate them. On each pass, take the split that cuts the most remaining space, and get runtime evidence for it, such as a console log, a network response, or a DOM probe. When the program state is unclear, add instrumentation and read it as the code runs. Do not guess. Drive a long hunt with `/loop`. Confirm the surviving cause with runtime evidence before you plan anything.

4. Plan the fix. If it crosses a function or file boundary, run `.agents/skills/plan` first. Grep every caller of the code you are about to change and fix where they all pass through, because a guard per caller is a symptom fix.

   Grep finds the callers. It does not find what else breaks, so before you commit to a fix that touches a shared package, apply the `blast-radius` skill, which is typed-only and so is read rather than invoked: `cat ~/.claude/skills/blast-radius/SKILL.md`. Fixing where all callers pass through is the correct move and also the one with the widest reach, and that reach is when the impact pass earns its cost.

   Delegate the implementation to a fresh subagent with a scope you wrote, then review the diff yourself.

5. Land the failing repro before the fix in git history. `.agents/skills/test` owns the cadence. Stage the commits so the red test lands first. Whether the bug earns a test at all, and what to run instead when it does not, is the `tdd` skill's call: `cat ~/.claude/skills/tdd/SKILL.md`.

6. Verify in the same place you reproduced it. The original repro now passes. An inconclusive result, or a result from somewhere else, does not pass. Flag it. A green unit test shows branch behaviour, not the absence of the bug. When the change alters a stored or persisted shape, prove at runtime that existing records still work.

7. Ship it with `.agents/skills/ship`, putting the bare `AB#<id>` in the description as [ado-pr-link](ado-pr-link.md) describes, and the before-and-after proof in the body as [pr-evidence](pr-evidence.md) describes. A hotfix PR carries the fix and nothing else, so leave the test file, the refactor, and the drive-by cleanup out of it.

## Reply

Say what was broken, the root cause in one sentence that is not the symptom restated, the fix, and how you verified it. Paste the failing-then-passing repro output verbatim. Name any sibling caller you found with the same pattern and left alone.

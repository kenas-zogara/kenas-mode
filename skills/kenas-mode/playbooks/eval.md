# Playbook: eval

**When.** You are judging whether an implementation (a PR, a branch, or a local change) delivers what its authoritative spec asked for. `pr-review` asks whether the code is bug-free and rule-clean. `eval` asks whether the change matches its source of truth, and its Principles row runs the [principle gate](eval/gate.md) on whether it holds to the principles.

**Trigger.** Eval is the default on any request to review, verify, or judge a PR. The user does not have to name it. Step 4 scales it to the diff, so a small PR costs little.

**Track.** B. It uses the [browser-driving](browser-driving.md), [ado-pr-link](ado-pr-link.md), and [pr-evidence](pr-evidence.md) playbooks.

## What eval produces

A test design, then its verdict. Each source you gather narrows what to check and how, so the rubric is a test plan. Each criterion carries its source, its method, and its evidence.

Gather, design the rubric, judge, and report. Never judge from a rubric you did not derive from sources.

## Context gathering, before you open the diff

Collect every layer that exists. Record a missing layer rather than treating it as fatal.

| Layer | What it gives | How |
| --- | --- | --- |
| Work item, a PBI or a Bug | The requirement itself | `az boards work-item show --id <id>`, or the connector's `wit_work_item` with `action: "get"`, following the "Azure DevOps access order" section in `CLAUDE.md` |
| Parent Feature | The intent the child acceptance criteria point up to | Follow `System.Parent`. Read it when the acceptance criteria are thin or reference it |
| Figma | Visual and interaction requirements | `mcp__claude_ai_Figma__get_design_context`, `get_screenshot`, `get_variable_defs` |
| Existing e2e and regression tests | Established behaviour of the code being changed | `packages/e2e/tests/<feature>/`, `--grep @<feature>` or `@PBI-<n>`, plus the unit tests next to the changed files |
| Repo rules | Conventions the code must keep | The repo's rule index (its `CLAUDE.md` or `AGENTS.md`) and its full docs listing, including docs no path glob loads |
| The running app | What actually happens | [browser-driving](browser-driving.md) |

Find the work item from the `AB#<id>` in the PR body (see [ado-pr-link](ado-pr-link.md)), the work item's Development links, the branch name, or the user. A local branch with a known ticket id is a valid target without a PR.

The spec field differs by type. A PBI carries `Microsoft.VSTS.Common.AcceptanceCriteria`. A Bug carries `Microsoft.VSTS.TCM.ReproSteps` (Steps, Expected, and Actual) and usually has no acceptance criteria field. The Bug's Expected line is its spec, and its Steps to reproduce are a ready-made test case. Read `System.Description` on both types.

Look for a Figma link on both the PR body and the work item. Read only the frames the change touches. If neither has a figma.com URL, say there are no visual criteria and grade the rest.

Existing tests are context, never spec. They show today's behaviour and where the regression risk sits. They do not define correctness.

- A test can encode the bug under eval. `packages/e2e/tests/listing/lifecycle.spec.ts` asserted around a modal that showed "Could not delete listing" even on a successful 204. A rubric seeded from it would have graded the bug as correct.
- Tests written or changed inside the change are part of the implementation. They show that a criterion was checked, never that it was the right criterion. Keep them out of rubric derivation.

## Non-negotiables, which are what keep this unbiased

1. Rubric before code. Derive the criteria from the sources before you read the diff. A rubric reverse-engineered from the implementation rationalizes whatever was built.
2. Judge blind to the author's narrative. The "what I did" in a PR or commit description is a claim, not evidence. Give the judge the spec and the code or behaviour, without that narrative.
3. Fresh judge. If you wrote or reviewed this code, you are not the judge. Dispatch one that starts clean.
4. The spec is ground truth in both directions. Code that does something no source asked for is unspecified scope, so flag it neutrally. A source that asks for something the code lacks is a gap. If a source is silent or ambiguous, say so, and do not fill it with your own taste.
5. The change is unproven until the sources show it is done. Silence does not pass.
6. Degrade rather than refuse. Grade against the layers that exist and name the missing ones. A tooling, skill, or docs PR often has no work item and no Figma, so grade it against the tests, the rules, and the stated intent. Only when every layer is absent (no work item, no Figma, no tests, and no stated expectation) is there nothing to grade. Report the missing anchor and stop. Never invent criteria.
7. Show the judge's reasoning, not only its verdict.

## Steps

1. Identify the target and its sources: the work item ids, the Figma URLs on both the PR and the work item, and the e2e and unit tests covering the changed code.
2. Gather, independently of the diff. Read the acceptance criteria or the repro steps, the parent where relevant, the Figma frames, the existing tests, and the applicable repo rules.
3. Design the rubric, with 3 to 8 concrete criteria. Tag each one with its source, such as `PBI-AC #n`, `Bug: Expected`, `Figma: <frame>`, or the repo rule's path. Step 4 sets the method.
4. Size the check plan. See [Sizing the check plan](#sizing-the-check-plan). A one-line docs PR and a change to `packages/ui` do not earn the same checks.
5. Read the implementation. Run `gh pr diff <n>` or read the local diff, plus the changed files.
6. Judge each criterion against its source, by the method the plan set, using a fresh `kenas` agent that cannot see the author's narrative.
7. Run the checks the plan kept, and only those. Behavioural and visual checks follow [browser-driving](browser-driving.md). Put each screenshot beside its Figma frame at the same viewport.
8. Check the regression edge. For each existing test over the changed code, decide whether it is still valid, now wrong because it asserted the old or buggy behaviour, or missing a case the change introduces. `.agents/skills/e2e-audit` answers this for the Playwright specs.
9. If the plan kept the impact pass, run it. A PR can meet every acceptance criterion and still break a sibling app. Read the typed-only `blast-radius` skill rather than invoking it:

   ```bash
   cat ~/.claude/skills/blast-radius/SKILL.md
   ```

   Its one job here is the fact that makes the change safe. Prove that fact by running code, and report it beside the rubric verdicts.
10. Give a verdict per criterion: pass with evidence, fail because the source asks for X and the code does Y, unspecified scope, ambiguous source, or `unverified` because the plan skipped the only method that could prove it.

## Sizing the check plan

Every check costs minutes or agents. The judge picks the ones this change earns from the area the diff touches, and writes down why it skipped the rest.

**Who sizes it.** A fresh agent, `subagent_type: "kenas"`, `model: "sonnet"`, never the author, who will always find a reason to skip checks. Give it the rubric, the changed-file list (`gh pr diff <n> --name-only`, or `git diff --name-only dev...HEAD`), and `git diff --stat`. Do not give it the diff body or the PR description.

**What it returns.** For each criterion, the cheapest method that can prove it. For each row below, `run` or `skip`, with one line naming the files that decided it.

| Check | Mechanism | Earns a run when the diff touches |
| --- | --- | --- |
| Code read and CI | The judge reads the diff. `gh pr checks <n>` | Always. This is the floor |
| Unit tests | `mise exec -- pnpm --filter <package> test <path relative to the package>`, for the sibling `*.test.ts(x)` of each changed file. No `--`: with it, vitest drops the filter and runs the whole suite | Logic: a hook, a transformer, a Valibot schema, a date or money helper, a reducer, or a file that already has a sibling test |
| Playwright e2e | `.agents/skills/e2e-audit` picks the specs, then `mise exec -- pnpm --filter flex-store-e2e exec playwright test --grep @<tag>` | A user flow: a route, a form submit, a mutation, a `data-testid`, a permission or auth path |
| Behaviour in the browser | `.agents/skills/qa-test`, per [browser-driving](browser-driving.md) | An interaction no e2e spec covers, or a Bug whose repro steps are the spec |
| Visual | `.agents/skills/ui-ux-test`, with screenshots beside the Figma frames | Rendered output: JSX structure, class names, styles, a `packages/ui` component, or a linked Figma frame |
| Principles | [principle gate](eval/gate.md), stage `code`. It also runs the comment-eater when the diff adds or edits a comment | Not sized by the sizer, which never sees the hunks. The lead runs the gate's step 1 table on the diff; any match earns the row, so a one-line `?? 0` does |
| Impact | `blast-radius`, step 9 | `packages/ui`, `packages/api/lib`, `packages/common`, a locale key rename, persisted or URL state, the router, or auth |

Three shapes cover most PRs:

- **Docs, skills, comments, CI config, or a locale value only.** Code read and CI. Nothing else runs.
- **One feature, no shared package.** The rows its files call for, and no impact pass.
- **Anything in the Impact row.** Every row its files call for, plus the impact pass.

Rules:

1. Report a skipped check as skipped, with its reason, never as passed.
2. A criterion whose only method was skipped is `unverified`, not passed. The judge picks a method that can prove it, or accepts that grade on purpose.
3. The plan can grow mid-run but never shrink. If a check turns up a wider impacted area, size the plan again with the new files.
4. The user's words override the plan. "Just read it" drops to the floor. "Full QA" runs every row.

## Reply

- The sources used: work item ids and types, Figma frames read, tests consulted, and the layers that were absent.
- The check plan: each row as run or skip, with its one-line reason.
- The rubric, with each line tagged to its source and its method.
- A verdict per criterion, with its evidence: a source citation plus a code reference or a screenshot.
- Gaps and unspecified scope, listed separately.
- Regression notes: existing tests now invalid, and cases still uncovered.
- The overall verdict on whether the sources justify the implementation, and for each gap, what closes it.
- When the target is a PR, post the findings on it per [pr-evidence](pr-evidence.md). Otherwise report in chat.
- On a PR, also post the overall verdict as one PR comment whose first line is `<!-- factory:eval -->`. The factory ready gate (`~/.claude/hooks/factory-gate.py`) refuses `gh pr ready` until such a comment is newer than the last commit. Inline findings alone don't count.

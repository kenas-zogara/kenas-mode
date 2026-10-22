# Playbook: autonomous-run

**When.** The work is long enough that you will not be watched through it: a `/loop`, a hunt that needs many iterations, a migration across many files, a wait on CI or a merge, a green-the-suite run, or any "keep going until it works" handed over before the user steps away.

**Track.** B, personal and permanent. It covers an operation no repo skill covers and replaces nothing. Every repo skill assumes a human is in the turn, so none says who picks the exit condition, what wakes you, which mid-run discoveries are yours to fix, or where the human-marks-it-ready boundary sits when nobody is watching. It uses [show-me-your-work](show-me-your-work.md), [worktree-workspace](worktree-workspace.md), [browser-driving](browser-driving.md), [bug-fix](bug-fix.md), and [pr-evidence](pr-evidence.md), and hands off to `plan`, `test`, `commit`, `review`, and `ship`, and to [eval](eval.md) for the principle gate, whose workflows still rule.

**Use.** You own the exit condition. Define done, then drive to it without stopping.

## Steps

1. **State the exit condition as a checkable predicate, before the first iteration.** Something a command answers yes or no: `pnpm test --filter flex-admin` green, the repro in [bug-fix](bug-fix.md) step 1 no longer fires, all N PRs merged, pixel-diff zero, `pnpm build` clean across all four apps. Write the command next to it. A predicate you cannot run is a wish.

   Run in a worktree, not the main checkout, so a long run does not sit on the 3000 band or on someone else's `.env`. Read [worktree-workspace](worktree-workspace.md) first, because a fresh worktree has neither.

   Keep the task list in `.audit/<task-slug>-tasks.md`, with the predicate at the top and one checkbox per unit. Tick each item when its unit is verified, and add anything new you find. Read this file, not the scrollback, after context is summarized. `log.sh` already excludes `.audit/` from git. If you create the file before the first log row, append `.audit/` to `$(git rev-parse --git-common-dir)/info/exclude` yourself.

2. **Pick the wake mechanism.**

   | What you are waiting on | Mechanism |
   | --- | --- |
   | Your own long command | Bash with `run_in_background`. The harness re-invokes you when it exits, so do not poll it |
   | A condition in your own workspace | `Monitor` with an until-loop |
   | External state the harness cannot see: a CI run, a merge, a review landing, a ref advancing | `/loop <interval> <prompt>`, the interval sized to how fast that state changes. One 8-minute check on an 8-minute CI run, not eight 1-minute ones |
   | Nothing specific, just keep pushing | `/loop <prompt>` with no interval, and let it self-pace |

   Whatever the primary signal, keep a long heartbeat as the fallback so the run survives a hang. Never schedule a wakeup to keep a cache warm.

3. **Each iteration makes the smallest change the evidence justifies.** Verify it against the predicate. Commit if it advanced. Discard what did not. A change that "might help" but no evidence asked for gets reverted, not kept. That is [bug-fix](bug-fix.md)'s rule, and it holds for every run, not only bugs.

   Verify each unit before starting the next, rather than batching the checks at the end. `test` owns the red-before-green cadence, [eval](eval.md) judges the finished change, and `principle-prove-it-works` sets the bar for both. A batch of ten unverified units is one unit of progress and nine unknowns.

   If `plan` armed `~/.claude/hooks/flex-store-pipeline.sh`, the phase sentinels it waits on still apply inside the loop. The hook, not you, decides when the turn may end.

4. **Mid-run discoveries are yours.** A broken skill, a flaky verifier, a related bug, review noise, a tooling failure, an orphaned follow-up, drift you can fix. Fix it, in kenas-mode, and return to the predicate. Do not park reversible work for the user and do not reach for `AskUserQuestion` to get permission for something you can undo.

   Out-of-band fixes get their own branch and their own draft PR, per the standing expectation on scope. Branch prefix per `docs/file-folder-structure.md`, then `git push` and `gh pr create --draft --base dev`. Do not fold an unrelated fix into the run's PR because it was convenient.

   **Surface, and stop, only for these.** Everything else you handle.

   - Irreversible or outward-facing: marking a PR ready for review, merging, pushing a release tag, posting to a PR or a work item, any Azure DevOps write, deleting a branch or a worktree, anything that touches data on a regional dev host beyond your own test account.
   - A genuine product or preference call no experiment can settle. An aesthetic verdict is the user's, per [browser-driving](browser-driving.md).
   - A real dead end.

   `ship` deliberately does not fire the PR as ready. A human marks it. That boundary does not move because a run is autonomous.

5. **Checkpoint every iteration** via [show-me-your-work](show-me-your-work.md): one row for what changed and whether the predicate moved. On a run nobody watched, the log is the only place the evidence exists.

6. **Stop when the predicate is met.**

   A plateau is not a stop. Keep going and change the approach to get past it. Two iterations that move nothing means the current line is wrong, so pivot rather than repeat it harder.

   Never relax the predicate to declare victory. If the predicate turns out to have been the wrong target, say that in the reply as a finding, leave the original predicate written as it was, and report it unmet.

## Reply

- **Blocked on me.** Every stop from step 4 that the run hit, or `nothing`.
- The exit condition, as the predicate and its command.
- Iterations run.
- What landed: the commits and PRs, with the out-of-band ones named separately.
- What was discarded, and what refuted it.
- Final predicate state, with the run output that shows it.
- The **Attention** section from [show-me-your-work](show-me-your-work.md), including the cross-model review.

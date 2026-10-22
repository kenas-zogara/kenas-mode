# Playbook: show-me-your-work

**When.** A run is long enough, or unattended enough, that the user will read the result without having watched it happen. This covers an [autonomous-run](autonomous-run.md), a multi-phase `plan` to `ship` chain, a `/loop`, a fan-out across parallel subagents, and any session the user steps away from. It also covers a request to "show your work", "keep a decision log", or "what did you decide and why".

**Track.** B, personal and permanent. It covers an operation no repo skill covers and replaces nothing. `pr-evidence` gets a finished result in front of a reviewer. This gets the *path* to that result in front of them, which is a different artifact. Used by [autonomous-run](autonomous-run.md).

**Use.** One canonical log. A single TSV, one row per decision, append-only. Evidence is a pointer, never prose.

Keeping the log is not optional on an unattended run. "Evidence, or it did not happen" is a standing expectation, and on a run nobody watched, the log is the only place the evidence exists.

## The format

Columns, in order:

- **ts.** ISO8601, UTC. Written for you.
- **phase.** The phase or workstream. Use the stage names the skills already use where they fit: `plan`, `test`, `implement`, `review`, `ship`, plus `repro`, `qa`, `e2e`, `harness`.
- **decision.** What was chosen or done, one line.
- **why.** The reason in plain words. If a principle drove it, say it plainly rather than as a jargon tag: "fixed it where every caller passes through", not "applied fix-root-causes".
- **evidence.** One pointer that proves it. See the table below.
- **result.** The outcome, or the predicate state: `tests green`, `reverted`, `pixel-diff 0`, `INCONCLUSIVE`, `open`.

What counts as evidence here:

| Kind | Pointer |
| --- | --- |
| A commit | Short SHA |
| A PR | `#4702` |
| A code claim | `apps/flex-admin/src/features/x/y.ts:41` |
| A test run | The spec path plus `--grep` tag, such as `packages/e2e/tests/listing/lifecycle.spec.ts --grep @PBI-3517` |
| A browser check | The screenshot path, or the Playwright trace, per [browser-driving](browser-driving.md) |
| A work item | `AB#2978`, but see the warning below |
| A discard | `reverted <sha>`, or `worktree reset` |

**Never write a bare `AB#<id>` into a log you might commit.** The Azure Boards bot scans commit messages and PR bodies and links whatever it finds, which silently attaches every ticket the log ever mentioned. Use the inert link form from [ado-pr-link](ado-pr-link.md) in any row that names a ticket the run does not deliver.

A row is written the way you would tell a teammate what you did. Plain words, concrete actions, no AI voice. `/unslop` applies to log text.

## Logging a row

```bash
bash ~/.claude/skills/kenas-mode/scripts/log.sh decisions.tsv \
  implement "hoisted the date format into ~common/lib/date-time" \
  "three apps had their own copy and two disagreed" \
  "9f2a1c4, packages/common/src/lib/date-time/format.ts:22" "tests green"
```

The script stamps `ts`, writes the header on first use, flattens stray tabs and newlines, and quotes any cell a spreadsheet would read as a formula. It also excludes the log locally on creation, which is the point below about where it lives. A bare `printf >>` works too, but then those bytes are yours to mind.

Log decision points and checkpoints, not every action: a fork chosen, a unit completed with its verification result, a pivot or revert with its trigger, a blocker surfaced, a broken gate fixed. One row per iteration on a loop run. Skip the trivial.

## Where it lives

`decisions.tsv` in the worktree root, or `.audit/<task-slug>.tsv` when several efforts run at once. Not committed by default.

flex-store's `.gitignore` covers neither path, so an uncommitted log is a stowaway that `commit` and `ship` will offer you. `log.sh` appends both patterns to `$(git rev-parse --git-common-dir)/info/exclude` the first time it creates a log, which is per-machine, untracked, and shared across every worktree. If you hand-roll the log, do that write yourself.

Commit it only when the run was ambitious enough that a reviewer needs the trail to trust the result. Then it is part of the change and `commit` stages it like anything else.

## Rules

1. One row is one decision or checkpoint.
2. Append-only. A wrong call gets a new row that supersedes it. Never edit or delete history.
3. Prefer evidence produced by a committed script over a hand-made one-off, following `principle-encode-lessons-in-structure`.
4. A row with no evidence pointer is a claim. Either get the pointer or write `INCONCLUSIVE` in `result`.

## Audit the log against the transcript

Before handing back, check the log told the truth. The transcript is a JSONL file named for the session id, under a directory in `~/.claude/projects/` named for the **working directory** with every `/` and `.` replaced by `-`.

That directory is the worktree, not the repo. A run in an Orca workspace writes to `-Users-flexi-orca-workspaces-flex-store-<workspace>`, and one under `.claude/worktrees` gets a doubled dash from the dot. So derive the path, never type it:

```bash
ls ~/.claude/projects/"$(echo "$PWD" | tr '/.' '-')"/<session-id>.jsonl
```

The session id is the last segment of your scratchpad directory path. Do not take the newest file with `ls -t`, because a parallel session in the same worktree may have written last. Do not confirm by reading the first line either, because it is a `mode` or `file-history-snapshot` record, not the opening prompt.

**Read only this session's file, and never `cat` it.** These run to tens of megabytes and will blow the context of whatever reads one. Stream it with `grep -o`, `grep -c`, or a line-by-line `python3`, printing only short matches. The parent directory holds every other repo and worktree you have worked in, so globbing across them reads unrelated private work.

Walk the log against what happened:

- Every row maps to a real action. Cut invented or aspirational entries.
- Each row's evidence resolves and shows what the row claims. Open the file at that line, `gh pr view` that number, `git show` that SHA.
- A fork, pivot, or abandoned approach that shaped the work but is not logged is a gap. Add it.
- Drop padding.

Fix the log, not the story. If the work diverged from what a row claims, the row is wrong.

## Cross-model review of the trail

Self-review is not a substitute, so the trail gets read by something that did not write it. "Fan out, and let a fresh agent judge" is the standing expectation, and this is its cheapest form.

- **Different family, when the run produced a PR.** `/review-pr-agent` runs GLM/ZAI over the PR. That is a different model family and the strongest version of this check.
- **Otherwise, a different model.** Dispatch `Agent` with an explicit `model` override that is not the one that did the work, and give it the log plus the transcript path. A fork inherits your context and your model, so it is the wrong tool here.

The reviewer scans, it does not redo the work. Ask it for:

- Decisions logged with weak or absent evidence.
- Verification claimed without proof in the transcript.
- Choices that look risky in hindsight: premature, scope-creeping, or papering over a symptom.
- Gaps a casual skim would miss.

## Reply

Every reply for a run that produced a trail ends with an **Attention** section. Lead with the reviewer on its own line, `reviewed by <model>`, then one line per flag pointing at a specific row or moment. `No flags` is a valid value. Omitting the section because there were no flags is not.

`column -s$'\t' -t decisions.tsv` renders the log in a terminal. GitHub renders a committed TSV as a table.

## Composing this playbook

Other skills and playbooks route their audit trail here rather than inventing one. Name it and let it own the format. Do not restate the columns.

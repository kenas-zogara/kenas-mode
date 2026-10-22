# Playbook: open-pr

**When.** You are opening a PR or a stack of PRs and taking it to a mergeable state. This covers `ship` step 10 and any PR opened outside `ship`.

**Use.** `gh pr create` for one PR, and `gh stack` (the `github/gh-stack` extension) for stacked PRs. `~/.claude/hooks/gh-pr-guard.sh` refuses any `gh pr create` without `--draft` or `--assignee`.

**How**

- `gh-pr-guard.sh` also refuses `gh pr create` until the `review` skill has run on a tree matching HEAD. `review-marker.py` records the tree whenever `review` runs, and changes to `.md` files afterwards are allowed. If you commit code after the review, run `review` again.
- One PR: `gh pr create --draft --assignee "@me" --base <base> --title "<title>" --body-file <path>`. The base is `dev` unless the PR is stacked.
- Stacked PRs. Build the branches with `gh stack`, not by hand, or GitHub never links them as a Stack.
  - `gh stack init --base dev <first-branch>` starts a stack, and `gh stack add <branch>` adds a branch on top.
  - `gh stack submit --auto` pushes every branch, opens each PR as a draft based on the branch below, and creates the Stack on GitHub.
  - `submit` sets no assignee and writes its own titles. Afterwards, run `gh pr edit <n> --add-assignee "@me" --title "<title>" --body-file <path>` on every PR it created.
  - To stack PRs that are already open, run `gh stack link <bottom-pr> <next-pr>...`, listed from the bottom up.
  - After the base moves, run `gh stack rebase`. Never rebase the branches one by one.
- Add `--label "needs backend deployment"` when the PR relies on backend work that has not reached DEV. Signs of this are a `packages/api/lib/*` diff that adds fields or endpoints missing from `origin/dev`'s spec, or a body that says "depends on", "requires", or "until it deploys" about a `flex-<service>` PR or work item. A resync that only removes things does not need it. For a stack, add it per PR with `gh pr edit <n> --add-label`.
- A draft never runs `ci`. Its `bootstrap` job requires `draft == false`, and the `run-ci` label only matters on `renovate*` branches, so a green `gh pr checks` on a draft is the skip. Until a human marks it ready, the local gate is the CI you report: lint, `turbo format -- --list-different`, `turbo test`, `turbo build`, with `--filter` names taken from each `package.json` (flex-store is `react-flex-store`). Run it on a tree that matches HEAD. Read a job's whole `if:` before you change a PR to trigger it.
- The PR is not done until it can merge. After you push, run `gh pr checks <n> --watch` until every check is green, and fix anything red. If `gh pr view <n> --json mergeable` reports `CONFLICTING`, rebase onto the base, resolve the conflicts, and push again. Only then report the PR as ready.
- Never run `gh pr ready`. A human marks a PR ready for review.
- `added_lines` fails a lift-and-shift port that re-adds the original's TODOs. Add the `skip-added-lines` label to that PR rather than rewriting ported comments.

**Unverified.** Nobody has run `gh stack` against this repo yet. The first stacked PR tests it, so record what broke here.

- 2026-09-23, #4781 → #4783, stack made with `gh stack link` (no local tracking). There are three things to know.
  - `gh stack rebase` then fails with "current branch is not part of a stack". It also can't move a parent branch that is checked out in another worktree, and in Orca the parent always is.
  - When the parent was rebased on `dev`, the child showed `CONFLICTING`. The fix was `git rebase --onto origin/<parent> <old-parent-tip>` in the child's worktree, then `push --force-with-lease`.
  - The `ci` job skips on a stacked child because `ci.yml` only triggers for PRs based on `dev`. Only `Verify required checks passed` and `label` run until GitHub retargets the child. Run the full local gate instead.

**Supersedes.** The literal `gh pr create` command in `ship` step 10, and the "gh has no native stack command" line in the `feedback_git_workflow` memory.

**Graduation.** Once proven, fold the stack steps and the CI-green exit into `ship` under `.agents/skills`, then delete this file.

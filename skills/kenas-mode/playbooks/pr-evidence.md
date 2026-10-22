# Playbook: pr-evidence

**When.** A reviewer needs to see a result: a screenshot of a UI change, a QA run, review findings, or proof that a fix is real. This covers `ship`, `review`, `pr-review`, `qa-test`, `ui-ux-test`, and `eval`.

**Track.** B. `ship` owns creating the PR and `pr-review` owns the review mechanics. Neither owns how evidence gets into them. The Screenshots section below replaces `ui-ux-test` step 7's clipboard-and-Chrome upload: upload with `gh`, never through a browser or `computer-use`.

**Use.** Evidence lands on the PR or the work item, never only in chat.

## Screenshots

`gh` 2.99.0 and later uploads images itself. If `gh pr edit --help | grep -q -- --attach` fails, run `brew upgrade gh`.

1. Attach. Each `--attach` uploads one file and appends `![<alt>](https://github.com/user-attachments/assets/<uuid>)` to the end of the body. `gh pr create` and `gh pr comment` take the same flag.

   ```bash
   gh pr edit <pr> --attach '<png>#<alt text>' --attach '<png>#<alt text>'
   ```

   A non-zero exit means some files failed. The ones that uploaded are already appended, so re-attach only the missing ones.
2. Move each appended line into its section. Pull the body with `gh pr view <pr> --json body -q .body > <scratchpad>/pr-body.md`, cut the trailing image lines into place, and write it back with `gh pr edit <pr> --body-file <scratchpad>/pr-body.md`. To size an image, rewrite it as `<img width="720" alt="…" src="<url>" />`.
3. Run `gh pr view <pr> --json body` and confirm the expected number of images, with nothing left at the end and no local paths.

Never put a local path in the body and expect `--attach` to rewrite it. `--help` says `![alt](./x.png)` gets rewritten in place, but it did not on 2.101.0 or 2.103.0, with `--body` or `--body-file`, relative or absolute (#4972, 2026-10-22). The upload was appended and the broken reference stayed.

If `--attach` itself fails, save the image locally, put its path under Blocked on me, and ask the user to paste it.

- Evidence is per PR and per fix. After every fix, take new screenshots before you report it done. Never copy evidence from another PR or an earlier commit. Delete superseded QA or screenshot comments with `gh api -X DELETE repos/<owner>/<repo>/issues/comments/<id>`. Do not hide them.
- A state you cannot reach, such as a region with no credentials, goes under Blocked on me. Never simulate it by forwarding the region's calls to another one, and never swap in unit tests as its evidence.
- Never commit an image to the repo to embed it in a PR body. It stays in the history forever.
- Delete any local temporary image afterwards and confirm the tree is clean with `git status`.

Capture at the real viewport and high resolution, not a shrunken full page. A blurry screenshot gets sent back.

For a fix, show the before and the after, or the failing and the passing run. One screenshot alone is not proof.

The "before" gets its own checkout, `git worktree add --detach <path> <base>`, on its own port band. Never roll back files in the tree under test, not even to restore them after. A verifier brief says "do not modify the working tree" in those words, and before you run any gate after a delegate returns, confirm `git status --short` is empty and `git diff HEAD` is clean.

## The PR body

Write the body to a file and pass it with `--body-file`:

```bash
gh pr create --draft --base dev --assignee "@me" --title "<title>" --body-file <scratchpad>/pr-body.md
```

`ship` owns those flags and the rest of the PR shape. Check the body before the PR exists and again after any edit:

```bash
.agents/skills/i-have-adhd/check-pr-body.sh --file <path> --touches-source
.agents/skills/i-have-adhd/check-pr-body.sh <pr> --touches-source
```

Pass `--touches-source` when the diff changes anything under `apps/` or `packages/`. It then demands a fenced block holding a command and its output. Decide from the diff: `git diff --name-only dev...HEAD | grep -qE '^(apps|packages)/'`.

The flag arrives with PR #4752. Until that merges, the script rejects it with `unrecognized arguments`, so check first and drop the flag when this prints nothing: `.agents/skills/i-have-adhd/check-pr-body.sh --help | grep -- --touches-source`. Still include the fenced command-and-output block by hand.

The `i-have-adhd` rules cut narration, never the screenshots, the QA results, or the regression proof.

## Findings

- Post review findings on the PR as short inline bullet comments on their lines, without being asked. `pr-review` does the posting. A findings list in chat is a draft, not a review.
- Fix every valid finding. If none needs fixing, submit an LGTM review.
- Put a QA or behavioural result in the PR body, next to its screenshots.
- When every finding is resolved, say so on the PR.
- Reply to every open thread the change answers, and re-read the threads after pushing a fix.
- A finding the user declines is closed, not re-argued.

## Work items

Link the PR to its work item with [ado-pr-link](ado-pr-link.md), then verify that the relation landed. The bot sometimes does not attach it.

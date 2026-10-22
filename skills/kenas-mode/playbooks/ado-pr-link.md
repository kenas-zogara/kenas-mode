# Playbook: ado-pr-link

**When.** You are moving an Azure DevOps work item through its lifecycle alongside a PR: creating it, setting its fields, moving its state, closing it. This covers `ship`, `az-create-ticket`, `fix-pr`, `code-freeze-report`, and any PR that delivers a work item, in every Flexii repo.

**Track.** B, personal and permanent. The linking mechanics graduated into the repo with PR #4752. This playbook keeps only the lifecycle defaults no repo skill states.

**Use.** `az boards` first, the MCP connector as fallback, per the access order in `CLAUDE.md`.

## Linking a PR

The repo owns it. The `AB#<id>` rules live in `.agents/skills/ship/SKILL.md`. The link table, the unlink call, and the connector gaps live in `.agents/skills/az-create-ticket/SKILL.md` under "Work item ↔ PR links". Read the one you need.

Until #4752 merges, `dev` still carries the old `CLAUDE.md` text, whose tool names no longer exist. Unlink with `wit_work_item_link_write`, `action: "unlink"`, `id`, `type` (`artifact` or `hyperlink`), and the `url` of the one relation. Without `url` it strips every link of that type.

## The work item's lifecycle

`.agents/skills/az-create-ticket` owns creating one, including the gotcha that `wit_query`/`wiql` returns bare ids and needs a follow-up `wit_work_item`/`get_batch` read.

- The work item exists before the code. A bug arrives as a bare `dev.azure.com/.../edit/<id>` URL.
- Set the parent, iteration, state, and assignee when you create an item. A Bug with no parent Feature is the most common miss. Unless told otherwise, use these defaults:
  - The assignee is the user.
  - The state is New.
  - The iteration is the current sprint. Look it up with `az boards iteration team list --team "Flexii Team" --timeframe current`. Never guess it.
  - A hotfix also gets the tags `hotfix; adhoc`.
- Move the state as the work moves, for example to pending review when the PR opens.
- When a PR is closed without merging, close its work item too.
- After the bot has run, confirm the relation landed on the item. It sometimes does not.

# Playbook: worktree-workspace

**When.** You are starting, running, or cleaning up work in a git worktree, or you need to know which port serves the code you are looking at. This covers every feature, fix, and review session, because they all run in a worktree rather than the main checkout.

**Track.** A, shared mechanism, prototype. It uses nothing and is used by [browser-driving](browser-driving.md), which owns how to drive a browser once this playbook has said what to point it at.

**Use.** `orca worktree create` to make a feature or fix workspace, so Orca runs the setup hook and shows it in its UI. Plain `git` only for inspection and cleanup.

## Create a workspace through Orca

Load the guide first, as the `orca-cli` stub requires: `orca skills get orca-cli`. Then:

```bash
orca repo list --json                     # take the id whose path is the repo's main checkout
orca worktree create --repo id:<repoId> --name <slug> --no-parent \
  --base-branch origin/dev --setup run --activate --json
```

- `--setup run` runs the project's setup script (`pnpm install && setup-workspace.sh`, below), so `.env` and the port band land without a manual step.
- `--activate` reveals it in Orca. Without it the workspace is created in the background.
- Keep the whole `id` from the JSON (`<repoId>::<path>`). Every later `orca worktree set` or `terminal create --worktree` call addresses it by that id.
- Read the branch with `git branch --show-current` inside it. If it lacks the strict `<app>/` prefix, rename it with `git branch -m`. Unverified: which branch name Orca gives a fresh create.

Never `git worktree add` for branch work, whether under `~/orca/workspaces/` or in the scratchpad. No setup hook runs, it opens no terminal, and `mise` is left untrusted. `-B` also resets a branch that already exists and drops its unpushed commits. `~/.claude/hooks/gh-pr-guard.sh` denies it. Only a read-only checkout passes, with `--detach`.

## Two worktree systems, for two kinds of work

| System | Path | Use it for |
| --- | --- | --- |
| Orca workspace | `~/orca/workspaces/flex-store/<name>/` | Feature and fix work. This is the primary workflow, with about 39 of them in use |
| Claude Code `EnterWorktree` | `<repo>/.claude/worktrees/<slug>-<hash6>`, on branch `claude/<slug>-<hash6>` | Meta work and read-only PR review |

The directory name is not the branch name. The directory is the slugified, flattened form, so `fix-shift-editor-validate-shift-start-in-store-z` is the directory for a branch created inside it as `store/fix-...`. The branch itself keeps the strict `<app>/` prefix that `docs/file-folder-structure.md` requires. Read the branch with `git branch --show-current`, never from the directory name.

## A fresh worktree has no secrets

A git worktree does not carry gitignored files, so `apps/<app>/.env` and `packages/e2e/.env` do not come along. This is the single most frequent source of friction.

`scripts/setup-workspace.sh`, beside this playbook, is the one place that fixes it. It is idempotent and safe to re-run. It copies each `.env` from the main checkout, which it resolves with `git rev-parse --git-common-dir`, and writes a free port band into `apps/<app>/.env.local`. It exits without writing anything when it is not in a git worktree, not in flex-store, or in the main checkout, which keeps the 3000 band.

It runs once, at workspace creation, from Orca's setup script below. Not from a `SessionStart` hook:
the band comes from what is currently listening, so a re-run while your own vite is up sees its port
busy, picks the next band, and rewrites `.env.local` under the running server. Run it by hand only
when a workspace was created without it:

```bash
bash ~/.claude/skills/kenas-mode/scripts/setup-workspace.sh
```

It lives here rather than in the repo because it wires one person's Orca setup to one repo's layout. The shared half is the `VITE_<APP>_PORT` override in each app's `vite.config.ts`, which any developer can use with no Orca involved, and that stays in the repo. Wire this script as the flex-store Orca project's setup script, under Settings, flex-store, Setup script.
There is no `orca` CLI for this field. `repo set-base-ref` and `project setup-update` cannot reach
`hookSettings.scripts.setup`, so it is a one-time UI edit. The old value pointed at
`.agents/orca/setup-workspace.sh`, which no longer exists on `dev`, so it fails after `pnpm install`:

```
pnpm install && bash ~/.claude/skills/kenas-mode/scripts/setup-workspace.sh
```

The e2e credentials that [browser-driving](browser-driving.md) injects live in `packages/e2e/.env`, so a worktree without that file cannot authenticate a browser at all. Copy the env before you try to reproduce anything.

Before you report a credential missing, such as a TW admin login, read the main checkout's copy: `grep -c <KEY> "$(git rev-parse --path-format=absolute --git-common-dir)/../packages/e2e/.env"`. If it is there, re-run `setup-workspace.sh`, or copy that one file. It is missing only when the main checkout lacks it too, and then it goes under Blocked on me.

## Ports: never assume a listening server is yours

The main checkout owns the 3000 band, with flex-store on 3000, flex-pro on 3002, flex-account on 3003, and flex-admin on 3004. Each workspace takes its own 1000-port band, so workspace N serves the default plus N times 1000. A server on 3004 is very likely another worktree's flex-admin.

Before you trust a running server, confirm which working directory owns it:

```bash
lsof -nP -iTCP:3004 -sTCP:LISTEN
```

If it is not yours, start your own on your band rather than reading someone else's code through a browser:

```bash
mise exec -- pnpm --filter flex-admin start --port 3014 --strictPort
```

**Supersedes** the `Dev servers: flex-store :3000, flex-admin :3004` line in the `Standard` block of `qa-test` and of `ui-ux-test`. Those ports are correct for the main checkout only.

## Cleanup

Remove the worktree when its PR is merged or the work is abandoned, not when a test finishes. Close it out in this order:

1. Close the browser pages you opened. The Teardown bullet in [browser-driving](browser-driving.md) covers how.
2. Kill the dev server on this worktree's port, then confirm with `lsof -nP -iTCP:<port> -sTCP:LISTEN` that nothing is still listening.
3. Remove the worktree. `ExitWorktree` with `action: remove` works only in the same session whose `EnterWorktree` created it. For a `.claude/worktrees/*` left by an earlier session, and for any Orca workspace, use git directly:

   ```bash
   git worktree remove <path>
   ```

4. Delete its branch.

## Sessions in Orca workspaces

Creation goes through Orca (above). Inspection and cleanup stay on plain `git`, `lsof`, and `gh`.

**One workspace per task means one session per workspace.** When the user asks for an Orca workspace per task, such as one per PR, run Claude Code inside each workspace. Do not drive the workspaces with subagents from your own session. The user steers each session in Orca.

**Opening a workspace is not a handoff.** When the task is already under way in this session, create the workspace and keep driving it from here. Launch `claude` inside it only for a new task, or when the user asks.

Before you create any workspace, run the owning skill's own triage and create workspaces only for the tasks that still have work. For `fix-pr`, that is its GraphQL thread query with `isResolved`. A REST comment listing has no resolution state, so it over-counts.

```bash
orca terminal create --worktree path:<W> --title "<task>" --command claude --json
orca terminal wait --terminal <handle> --for tui-idle --timeout-ms 90000 --json   # send only on satisfied: true
orca terminal send --terminal <handle> --text "<one-line brief>" --enter --json
```

Keep the brief on one line, because a newline submits the prompt early. To work on an existing PR branch, create with `--base-branch origin/<branch>`, then `git switch <branch>` in the workspace and delete the throwaway branch Orca made.

When a new session takes over from a stopped attempt, first list what the attempt already did: replies posted, commits pushed, threads resolved. Stash its uncommitted edits so the new session starts on a clean tree, `git stash push -m "stopped attempt <date>"`, and name the stash and the prior writes in the brief.

**Graduation.** Only the port facts graduate. Move the port band and the "confirm which worktree owns this server" check into `docs/development.md`, and trim the dev-server lines out of `qa-test` and `ui-ux-test` to point at it. The env copy and `scripts/setup-workspace.sh` stay here, because they are personal Orca tooling and the repo should not carry them.

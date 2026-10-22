# kenas-mode

Kenas's Claude Code operating layer for the Flexii repos, plus the 23 engineering principles it applies.

- `skills/kenas-mode/`: the mode itself. `SKILL.md` holds the standing expectations and the principle table, and `playbooks/` holds one file per cross-cutting operation (bug fix, open PR, eval, browser driving, and so on).
- `skills/principle-*/`: one skill per principle. kenas-mode tells the agent which one to read before which kind of decision.
- `hooks/`: loads kenas-mode into every session and every subagent.
- `agents/kenas.md`: the subagent type the playbooks spawn.

## Install

Symlink, so `git pull` picks up changes:

```bash
git clone git@github.com:kenas-zogara/kenas-mode.git ~/kenas-mode
cd ~/kenas-mode
mkdir -p ~/.claude/skills ~/.claude/hooks ~/.claude/agents
for d in skills/*; do ln -s "$PWD/$d" ~/.claude/skills/; done
ln -s "$PWD"/hooks/*.sh ~/.claude/hooks/
ln -s "$PWD/agents/kenas.md" ~/.claude/agents/
```

Then add the hooks to `~/.claude/settings.json`, merging with any `hooks` you already have:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/kenas-mode.sh\"", "timeout": 10 }]
      }
    ],
    "SubagentStart": [
      {
        "hooks": [{ "type": "command", "command": "bash \"$HOME/.claude/hooks/kenas-mode-subagent.sh\"", "timeout": 10 }]
      }
    ]
  }
}
```

Start a new session. The first reply opens with `kenas-mode: loaded`. To use the principles without the mode, skip the hooks and type `/principle-<name>`.

## Not included

kenas-mode names some files that are not in this repo. When a playbook reaches one, it fails or skips that step:

- Personal skills from its table: `technical-writing`, `unslop`, `teach` (with `how`, `why`), `blast-radius`, `routes`, `status`, `swarm`, `reflect`, `tdd`.
- Hooks: `gh-pr-guard.sh`, `flex-store-pipeline.sh`, and `factory-gate.py`, which belongs to the AI software factory and is out of scope here.
- The repo skills it hands work to (`plan`, `test`, `ship`, `qa-test`, and so on) live in each Flexii repo's `.agents/skills`.

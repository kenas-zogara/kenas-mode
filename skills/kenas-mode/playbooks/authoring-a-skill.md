# Playbook: authoring-a-skill

**When.** You are writing or modifying a skill, a kenas-mode playbook, or a rule. This covers "codify this workflow", "add a playbook", and editing an existing `SKILL.md`.

**Track.** B, personal and permanent. It covers an operation no repo skill covers and replaces nothing. `new-skill` covers repo skills completely and this playbook does not repeat it. This playbook owns the routing decision above `new-skill`, playbook authoring, which happens outside the repo and so `new-skill` cannot cover it, and the voice, which applies to both.

**Use.** You own the voice. Route it first, then write it, then check that the links resolve.

## 1. Route it: five homes, pick one

| The content is | Home | Who owns the mechanics |
| --- | --- | --- |
| A step-by-step recipe for a repo task | `.agents/skills/<name>/SKILL.md` | `.agents/skills/new-skill`. Follow it, including the routing row and the seven sections |
| The mechanism of an operation, meaning which MCP or CLI to use and its gotchas, that several skills each write out separately | A Track A playbook here | This file, section 2 |
| A personal operating style no repo skill covers | A Track B playbook here | This file, section 2 |
| A guardrail on what correct code looks like | `/docs/*.md`, plus `.agents/skills/update-docs`. In flex-store, also give it `paths` frontmatter and one symlink, `ln -s ../../docs/<name>.md .claude/rules/<name>.md`, or Claude Code never loads it | `docs/docs-constitution.md` |
| Something that must happen whether or not an agent chooses to do it | Local harness config | `~/.claude/settings.json` and `~/.claude/hooks/`. A repo's `.claude/settings.local.json` is gitignored, so a fresh worktree does not have it. A new agent file in `~/.claude/agents/` loads only when a session starts, so smoke-test it from a new session |

That last home is the one people forget. A rule an agent can decline is prose. A rule wired into a hook is not. In the worked example, `~/.claude/hooks/flex-store-pipeline.sh` runs as a `Stop` hook, arms itself when `plan` hands off, and refuses to let the turn end until each phase reports its `[[PHASE:<name>]]` sentinel, chaining test, implement, review, and ship. `ship` deliberately does not auto-fire the PR as ready, because a human marks it. Nothing in `.agents/skills` describes this, and nothing should, because the skills it chains must not each carry a copy.

Two checks decide the rest.

Is it a universal repo skill? Never hand-write one into a single repo. Author it in `flexii-agent-skills` and install it. Step 1 of `new-skill` is the authority. Re-read it, because this is the routing mistake that costs the most.

Is it a playbook or a repo skill? A playbook is a mechanism or a personal style. If it is a task workflow every Flexii engineer should follow, it is a repo skill and belongs in the repo, not in `~/.claude`. A playbook that should be a repo skill is a private fork of shared behaviour.

## 2. Writing a playbook here

Write it to `~/.claude/skills/kenas-mode/playbooks/<name>.md`, in the house shape. See `browser-driving.md` for Track A and `eval.md` for Track B.

```md
**When.** The trigger, as concrete task shapes.
**Track.** A or B, and which playbooks it uses.
**Use.** The mechanism, in one line.
**How** or **Steps.** The mechanism, with the gotchas that make it non-obvious.
**Supersedes.** Track A only. The exact repo text it replaces, named by skill and block, or by `CLAUDE.md` section.
**Graduation.** Track A only. The repo skill it moves to, and what gets deleted.
```

Then add one row to the matching table in `SKILL.md`. A row names the operation and links the file. The repo text a Track A playbook replaces goes in its Supersedes line, and the gap a Track B playbook covers goes in its Track line. A playbook with no row is invisible, and a row with no file is a broken link. Do both halves in one edit.

A Track A playbook is temporary. It depends on a soft override that the model must honor each turn, so it is a prototype rather than a home. Once it has proven itself, move it into the repo per its own Graduation line and delete it here, following `principle-migrate-then-delete`.

## 3. The voice

This applies to every home above. `/unslop` holds the full pattern list. The rules that matter most when writing a skill:

- When in doubt, delete. Keep only prose that changes a decision.
- Tell the reader to do the thing and skip the reason. Explain only where the rule is confusing without one, or where a plausible wrong path exists, and then name that path.
- Match the tone to the scope. A two-line mechanism does not get a rationale section.
- Point rather than restate. Link to other skills, playbooks, and `/docs` rules by path. A restated rule is a second copy that will drift.
- Prefer structure to prose, following `principle-encode-lessons-in-structure`. A type, a lint rule, or a preflight check beats a paragraph asking nicely.
- Give every step that writes its exact command. A step that names an outcome with no mechanism does not fail loudly. The agent picks the nearest wrong tool and reports success.
- Number the rules in a skill that accumulates them, so a correction can be made by number and then tested by number.

Two scope rules that decide where a rule may point:

- The repo wins. A skill may ship default patterns, in a `references/` folder when they are long, but a repo's own docs override them wherever the two disagree.
- A principle names no repo. A `principle-*` skill that links a repo's `/docs` file has stopped being portable, which was the whole point of it.

## 4. Verify and land

- The frontmatter has `name` and `description`. This applies to repo skills. Playbooks have no frontmatter by design.
- After editing kenas-mode's `SKILL.md`, run `bash ~/.claude/hooks/kenas-mode.sh | head -1`. It must print the `kenas-mode: loaded` marker, not `OVER BUDGET`. Over budget, trim prose or move it into a playbook. Never raise the budget past the harness's ~10,000-character hook limit.
- Every referenced path exists and every cross-link resolves. Check with `find -L` over the paths you wrote.
- For a new flex-store rule doc, `find .claude/rules -type l ! -exec test -e {} \; -print` prints nothing.
- For a repo skill, run the Output and Verification table in `new-skill`, including the mirror check and the untouched skill-set version line, then run `ship`. A playbook lives in `~/.claude`, outside the repo, so there is nothing to ship and nothing to review.
- Write test cases only if the skill is structural. Skip them when it is judgment.

If you keep re-explaining a workflow you never wrote down, propose it as a skill or a playbook instead of explaining it a fourth time.

## Reply

Say what the skill or playbook does, which home you routed it to and why, and the validation you ran.

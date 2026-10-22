#!/bin/bash
# kenas-mode SessionStart hook: load the mode, nothing else.
# User scope (~/.claude/settings.json) so a fresh Orca worktree, which carries
# no .claude/settings.local.json, still gets it.
#
# Workspace setup is deliberately NOT here. scripts/setup-workspace.sh picks its
# port band from what is currently listening, so a re-run while your own vite is
# up moves the band under it. It belongs to Orca's create-time setup script.
#
# The payload lands as a <system-reminder>, which the terminal never renders, so
# a working hook and a dead one look identical. The marker is the only visible
# difference, so it goes FIRST: anything after it can be cut.
#
# Budget. Claude Code swaps hook output over ~10,000 characters for a file path
# plus a 2KB preview. SKILL.md grew past that on 2026-09-23 and the playbook
# tables fell outside the preview, so a session fixed a bug without them. Over
# budget, print a short loud fallback instead of letting the harness truncate.
D="$HOME/.claude/skills/kenas-mode"
BUDGET=9500
[ -f "$D/SKILL.md" ] || exit 0
MARKER='Open your next reply with the line `kenas-mode: loaded` and nothing else on that line, then answer as normal. Do not repeat it on later replies in this session.'
SIZE=$(( $(wc -m < "$D/SKILL.md") + ${#MARKER} + 2 ))
if [ "$SIZE" -gt "$BUDGET" ]; then
  printf 'kenas-mode is ON but its payload (%s chars) is over the %s-char hook budget, so it was not printed.\n' "$SIZE" "$BUDGET"
  printf 'Before any other tool call, run `cat %s/SKILL.md` and follow it.\n' "$D"
  printf 'Open your next reply with the line `kenas-mode: OVER BUDGET` and nothing else on that line, then tell the user SKILL.md needs trimming.\n'
  exit 0
fi
printf '%s\n\n' "$MARKER"
cat "$D/SKILL.md"
exit 0

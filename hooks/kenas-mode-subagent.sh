#!/bin/bash
# kenas-mode SubagentStart hook. SessionStart context never reaches subagents,
# so without this every subagent runs kenas-mode-unaware. Same budget rule as
# kenas-mode.sh: over budget, point at the file instead of letting it truncate.
D="$HOME/.claude/skills/kenas-mode"
BUDGET=9500
[ -f "$D/SKILL.md" ] || exit 0
cat >/dev/null
if [ "$(wc -m < "$D/SKILL.md")" -gt "$BUDGET" ]; then
  CTX="kenas-mode is ON. Before any other tool call, run \`cat $D/SKILL.md\` and follow it."
else
  CTX="You are a subagent under kenas-mode. Your parent's brief outranks it on scope.

$(cat "$D/SKILL.md")"
fi
python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":sys.argv[1]}}))' "$CTX"

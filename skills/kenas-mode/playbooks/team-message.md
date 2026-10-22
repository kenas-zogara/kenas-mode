# Playbook: team-message

**When.** You are writing something a teammate reads outside a PR: a Slack message or DM, an Azure DevOps work-item comment, release notes, a blocker escalation, a handover. This covers "tell Jaume the BE ticket is blocking us", "ask Richard to merge", "post the release notes", and "reply to that thread".

Not PR bodies and not review comments. `ship` and `i-have-adhd` own the PR body, and [pr-evidence](pr-evidence.md) owns getting findings onto a PR.

**Track.** B, personal and permanent. It covers an operation no repo skill covers and replaces nothing. Nothing covers the message you send a person, which is where the ids go unnamed and the ask goes missing. It uses the `technical-writing` and `unslop` skills, and [ado-pr-link](ado-pr-link.md) for anything naming a work item.

**Use.** Draft it through `technical-writing`, strip it with `unslop`, then send it as a **draft** for review. Never send straight to a channel.

## Running the skills

`technical-writing` and `unslop` are typed-only, so they are not in your skill list and the `Skill` tool will not take them. Read the files and apply them:

```bash
cat ~/.claude/skills/technical-writing/SKILL.md   # the "Messages to people" section first
cat ~/.claude/skills/unslop/SKILL.md
```

Diátaxis does not apply to a message. Every other layer does.

The four rules that decide whether a message lands, and the worked example, live in the "Messages to people" section of `technical-writing`. If you read only one section, read that one. The one most often skipped is naming every id the first time: `3458 (store break-time column)`, not `3458`.

## Sending it

**Draft, don't send.** A Slack message is outward-facing and cannot be unsent cleanly, so it gets a confirmation every time, even when the same recipient was fine with the last one.

**Write it last.** When the message summarises a work item, draft it only after the work item's text is final and every figure in it has been checked. Slack allows one draft per channel, and you cannot edit it once it exists, so a correction afterwards falls to the user.

```
slack_search_users        # resolve the person to an id, don't guess one
slack_send_message_draft  # puts it in their compose box for you to read and send
```

Use `slack_send_message` only when the user has explicitly said to send this specific message without review.

Read the thread before replying to it. `slack_read_thread` costs one call and stops you answering a question that was already answered.

## Naming work items without linking them by accident

The Azure Boards bot scans for `AB#<id>` and attaches whatever it finds. That matters in a **commit message or PR body**, not in Slack, so a Slack message may use `AB#` freely. In anything that reaches git or GitHub, follow [ado-pr-link](ado-pr-link.md) and use the inert form for a ticket the change does not deliver.

For a work-item comment, the reader is already on the item. Name the *other* ids, not the one they are looking at.

## Reply

Show the drafted message in chat before it goes anywhere, and say which recipient and channel it is aimed at. If you rewrote a draft the user wrote, show what changed and why in one line, not a diff.

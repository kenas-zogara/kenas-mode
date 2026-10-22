---
name: principle-guard-the-context-window
description: "Apply when context fills up: large command output, long files, repeated reads, screenshots, or planning a fan-out. Send bulk payloads to a subagent, keep only its summary in the main thread, and size each phase so it fits."
disable-model-invocation: true
---

# Guard the context window

The context window is finite and does not refill within a session. Spend each token on something that changes a decision.

**Why:** When context overflows, reasoning degrades, compaction drops details the work still needed, and progress halts. A raw log that told you one fact costs the same as a thousand facts.

**Pattern:**

- **Isolate large payloads.** Send verbose output, screenshots, and large documents to a subagent. The main thread gets the summary and the evidence it cites, not the raw data.
- **Filter before you read.** Search, grep, or slice to the part you need instead of reading a whole file or log to find one line.
- **Read once.** Keep what you learned from a file instead of reading it again. Reread only when the file has changed.
- **Keep what every run needs inline.** A template or reference used on every invocation belongs in the instructions themselves, not in a separate file that costs a read each time.
- **Size phases and cap scope.** Limit the files each phase touches, set a turn budget, and count what each tool call costs before you plan the fan-out.

**The test:**

- "Will I use more than a few lines of this output?" If not, filter it or delegate it.
- "Have I already read this file in this session?"
- "Does this phase fit in the context left, with room for the fix and its check?"

Distinct from **principle-minimize-reader-load**, which cuts what a human reader must hold. This principle budgets what the agent holds while it works.

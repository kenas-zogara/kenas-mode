---
name: principle-system-boundaries
description: "Apply when data enters or leaves the system (HTTP responses and requests, URL params, user input, persisted storage, env config, messages between frames or processes, third-party libraries), or before adding a null check, try/catch, or type assertion. Parse and validate at the edge, trust typed data inside, and keep each edge's private shapes from leaking inward."
disable-model-invocation: true
---

# System boundaries

Validate, parse, and normalize data where it crosses into the system. Inside, trust the types. Keep each boundary's private representation on the boundary.

**Why:** A check scattered through business logic is noise that hides the one check that matters, and it gives a false sense of safety. A wire type used inside the system couples every consumer to another system's naming, nullability, and units, so a contract change means finding and editing every consumer.

**Pattern:**

- **Know the edges.** Network responses and requests, the URL, user input, persisted storage, environment config, messages from other frames or processes, and every third-party library call. Storage written by an older build is external input too.
- **At the edge.** Parse raw data into a domain shape once. Reject or default invalid input there, and handle the error there, where the context to handle it exists.
- **Inside.** Do not re-validate, add defensive optional chaining to a value the edge already guaranteed, or add a type assertion to data nobody parsed.
- **Across the edge.** Expose domain concepts, not the transport, storage, or library representation. Generated client types stop at the adapter that maps them.
- **Authority stays with its owner.** A client can hide what a user may not do. Only the server can forbid it. Never make a security decision from data the client can edit.
- **Derive, don't hand-roll.** When a schema defines a shape, derive the type from it instead of writing a parallel one. Never hand-edit generated code. Fix the source and regenerate.

**The test:**

- "Is this data crossing a boundary right now?" If not, the guard is redundant. Delete it or move it to the edge.
- "Does a transport or storage field name appear in a view or in domain logic?" The wire shape leaked past its adapter.
- "Is there an `as`, `!`, or `?.` on data nobody parsed?" Parse it at the edge instead.
- "Would this check still protect anything if the client were modified?" If it is a permission check, it belongs on the server.

Distinct from **principle-separation-of-concerns**, which decides which unit owns a behavior. This principle decides where data becomes trusted. For values that must not pass for other values once inside, see **principle-never-fake-a-state**.

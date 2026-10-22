---
name: principle-experience-it-first
description: "Apply before changing anything a user touches (a screen, a flow, copy, or an API a colleague imports) and whenever a product or UX tradeoff comes up. Use it the way its user does before you change it and again after, across the languages, regions, roles, screen sizes, and states they actually hit, and choose their result over implementation convenience."
disable-model-invocation: true
---

# Experience it first

See it before you change it, and see it again after. When implementation convenience conflicts with the user's result, choose the user.

**Why:** A change designed from the code alone is designed against an imagined interface. The details users feel, such as an empty state, a long translated label, a narrow screen, or a role that sees something different, are exactly the ones code reading misses.

**Pattern:**

- **Use it first.** Before designing a change, open the running product and use the feature as its user does. For a bug, reproduce it yourself where the user hit it.
- **The user is whoever consumes the work.** That can be an end user, an operator, the colleague who imports the module, or the next maintainer. Weigh their experience, and explain impact from their side.
- **Walk the real matrix.** Check every language, region, and role the feature serves, at mobile and desktop widths, in the pending, empty, failed, and long-content states.
- **Replacements keep parity.** When a page or flow replaces another, drive the old and the new side by side before calling it done. Compare the same fields, messages, variants, and edge behavior.
- **Justify every control.** Each feature, option, and setting must earn its place. Ship fewer finished things rather than more rough ones.
- **Get the details right.** Users judge the product by its alignment, spacing, feedback after an action, focus, and error copy.
- **Use it again after.** The change is not done until you have used the result the way the user will.

**The test:**

- "Have I seen the current behavior myself before designing the change?"
- "Did I check the states and variants a real user hits, not just the happy path in one language?"
- "What will the user notice? If nothing, why are we changing it?"

Distinct from **principle-prove-it-works**, which sets the standard of evidence. This principle sets whose experience the evidence must show.

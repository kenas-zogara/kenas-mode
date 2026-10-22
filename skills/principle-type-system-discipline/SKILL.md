---
name: principle-type-system-discipline
description: "Apply when designing a type or reviewing a function signature in a statically typed language. Brand primitives that mean different things, build types from the values you want instead of checking a looser one, strengthen a type only where an operation would otherwise be partial, and never assert what the compiler cannot prove."
disable-model-invocation: true
---

# Type system discipline

The type checker is a proof assistant. Use it to rule out mixed-up primitives and impossible values at compile time, and to define special cases out of existence instead of handling them at every call site.

**Why:** A case the types let you ignore becomes a runtime failure the compiler could have stopped. Two strings that mean different things will be swapped one day. A check repeated at every use site will be skipped at one of them.

**Pattern:**

- **Brand semantic primitives.** `UserId` and `OrderId` are both strings, but passing one where the other belongs must not compile. In TypeScript, `type UserId = string & { readonly __brand: 'UserId' }`. Create the value once, through one function that validates it, and trust the type after that.
- **Build types, don't carve them.** Construct the type from the values you want instead of restricting a looser type with checks. A non-empty list is a head plus a rest, `[T, ...T[]]`, not an array with a length check. A valid time range is a start plus a duration, not two timestamps you must keep ordered.
- **Strengthen only where partiality appears.** A runtime assertion, a null check, or a "should never happen" throw marks the place a type is too weak. Move that check into the type, then stop. `sum` of an empty list is 0, so it takes a plain array. `first` of an empty list has no answer, so it takes the non-empty one.
- **Prefer total functions.** A function that returns a value for every input its type admits needs no caller to guard it.
- **Don't lie to the compiler.** A cast, a non-null assertion, or an assertion function that checks nothing is a runtime crash waiting for its input. Prove the fact by narrowing or by changing the model, or treat the cast as a known hazard.

**The test:**

- "Do two arguments share a primitive type but mean different things?" Brand them.
- "Is there a check that enforces a shape the type could have built?"
- "Where did this `as`, `!`, or `assertNotNull` come from, and what would make it unnecessary?"
- "Am I strengthening this type to keep an operation total, or only to be more precise?" If nothing would otherwise throw, keep the plain type.

Distinct from **principle-model-the-domain**, which covers sum types, illegal states, and exhaustive matching, and from **principle-system-boundaries**, which covers parsing external data and deriving types from schemas. This principle covers the types of the values themselves.

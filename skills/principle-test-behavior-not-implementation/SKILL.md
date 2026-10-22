---
name: principle-test-behavior-not-implementation
description: "Apply when you write, change, or keep a test. Call the code the way its users do and assert what they observe against a literal expected value. If the test would still pass with every imported function returning undefined, rewrite the assertion or delete the test."
disable-model-invocation: true
---

# Test behavior, not implementation

A test calls the code the way its users do and asserts the result they observe against a literal expected value. A test that asserts which calls the code made, or restates a constant the code contains, checks neither.

**Why:** A test that cannot fail for a defect costs CI time and review attention and catches nothing. A test that pins a constant also fails when someone edits that constant on purpose, so it blocks the change it should allow.

**Pattern:**

- **Call the subject inside the test body.** Give it one concrete input and assert the literal output or the observable effect: `expect(slugify('Hello, World!')).toBe('hello-world')`.
- **No weak assertions.** A test with no `expect`, or only `toBeDefined`, `toBeTruthy`, `not.toThrow`, `toBeInstanceOf`, or `toBeGreaterThan(0)`, observes nothing specific.
- **Assert presence next to absence.** `toBeUndefined`, `toEqual([])`, `toHaveLength(0)`, and `not.toBe(wrong)` all pass on broken code. Pair each with the input that does produce the value, in the same test.
- **Mocks are checked by what they received.** Assert the payload a mock got or the state after the call, not only that it was called.
- **The expected value never comes from the code under test.** `expect(f(a)).toBe(f(a))` and `expect(url).toBe(buildUrl(...))` agree with any bug.
- **Test the mechanism, not the constant.** `expect(LIMITS.maxItems).toBe(8)` restates a config value. Feed one input through the code that reads the limit instead.
- **The subject must run.** An assertion on data the test built, or on a value from `beforeEach`, tests the fixture.
- **Some tests earn their place without a call.** A check that a key exists in two related tables, or that a parent row exists, tests a relation. A compile-time type test tests the types.

**The test:**

- "Would this test still pass if every function it imports returned `undefined`?" Then it observes no behavior. Rewrite the assertion or delete the test.
- "Is the expected value a literal I wrote, or something the code computed?"
- "If I change this constant on purpose, does the test fail for no reason?"
- "Does it fail when I break the code it claims to cover?"

Distinct from **principle-prove-it-works**, which demands evidence that a change works. This principle decides whether a test counts as that evidence.

---
name: principle-separation-of-concerns
description: "Apply when deciding where code goes: a new component, hook, module, helper, or shared-package export, or a function that starts doing two things. Give each unit one reason to change, place it at the smallest owner that fully owns the behavior, and keep mechanism in shared code and policy near the product."
disable-model-invocation: true
---

# Separation of concerns

Each unit owns one concern, placed at the smallest owner that fully owns it. Shared code holds mechanism. The code closest to the product holds policy.

**Why:** A unit with two reasons to change changes for both, and every edit to one concern risks the other. When one decision lives in several places, every change becomes a coordinated edit across owners that do not know about each other.

**Pattern:**

- **Split by concern, not by file size.** Rendering, orchestration (fetching, effects, subscriptions), and pure transformation are different concerns. Pure logic lives in plain functions a test can call without a framework.
- **Smallest correct owner.** Put state and behavior in the narrowest unit that fully owns them: a field before its form, a feature before the app, an app before a shared package. Lift only when a second real owner appears.
- **Mechanism shared, policy local.** A shared module computes and returns. The app decides what to show, where to navigate, what to translate, and which role may act. A shared package that knows an app's routes, copy, or notifications holds policy.
- **Organize around knowledge, not sequence.** A module that owns one body of knowledge beats modules named after steps (load, validate, transform, save) that each repeat the same rules.
- **One decision, one home.** When two places must agree, one owns the decision and the other asks it.
- **Adapters only change representation.** A wrapper or adapter changes representation. It does not add business rules that change what the caller gets back.
- **Configuration sits with its consumer.** Wiring that belongs to the whole router, store, or app is declared there, not inside the leaf definitions it happens to affect.

**The test:**

- "What does this unit own?" Answer in one sentence without "and".
- "Could this logic be tested without rendering, mounting, or a network?" If yes and it lives inside a view or a framework hook, extract it.
- "Does shared code now know an app concept, such as a route, a message, a notification, or a role?" Policy leaked into mechanism.
- "Did one change force edits in files owned by another concern?" That is information leakage. Move the decision to one owner.

Distinct from **principle-system-boundaries**, which decides where data is trusted. For the shape a concern's data takes, see **principle-model-the-domain**.

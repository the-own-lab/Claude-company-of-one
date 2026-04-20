---
name: test-plan
description: "Write a focused test plan for a feature before writing tests. Absorbs the former qa agent's planning role as a lightweight skill. Not a substitute for TDD — this decides what to test, then `tdd` decides how."
---

# Test Plan

Decide _what_ to test before writing tests. Without a plan you either test too little (miss edge cases) or too much (brittle, slow suite).

## Output

A short markdown block with four lists. No preamble.

```markdown
## Test Plan: <feature>

### Golden path

- <happy case 1>
- <happy case 2>

### Edge cases

- <boundary / empty / max / min>
- <concurrency / race>
- <malformed input>

### Error paths

- <expected failure modes + the error user should see>

### Won't test (and why)

- <thing> — <reason: covered by type system / trivial / integration-tested elsewhere>
```

## Rules

- **Golden path first.** If golden path isn't clearly defined, the feature isn't ready for tests.
- **Cap edge cases at 5.** More than that signals the design has too many modes; push back to `design-doc`.
- **"Won't test" is mandatory.** Forces explicit scope. Empty = incomplete plan.
- **Name tests by behavior, not implementation.** `it_sends_email_on_signup`, not `test_signup_controller_line_42`.

## Sizing

| Feature size         | Golden | Edge | Error |
| -------------------- | ------ | ---- | ----- |
| Small (one function) | 1      | 0–1  | 1     |
| Medium (one module)  | 1–2    | 2–3  | 1–2   |
| Large (cross-module) | 2–3    | 3–5  | 2–3   |

If you're writing >10 tests for a single feature, the feature is too big.

## Integration

- Feeds into `tdd` skill (plan → red → green → refactor)
- Pairs with `test-verify` skill (final pass: all plan items covered?)
- For Large tasks, attach the plan to the `design-doc` output

## What This Replaces

The former `qa` agent's planning role. The `qa` agent spawned a full subagent to decide which tests to write — a lightweight skill does this without the subagent cost. The test _execution and verification_ role is still handled by `test-verify` (which can spawn an agent for isolated run contexts if needed).

## Anti-patterns

- Writing tests before writing the plan — leads to testing what's easy rather than what matters
- Skipping "won't test" — leaves the implicit bounds implicit, which is the same bug `design-doc` Non-Goals prevents
- Treating 100% coverage as the plan — coverage is a lagging indicator, not a goal

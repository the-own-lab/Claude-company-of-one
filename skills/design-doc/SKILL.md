---
name: design-doc
description: 'Write a lightweight design doc before implementation for Medium/Large tasks. Mandates Non-Goals and Alternatives Considered sections to prevent scope creep and hindsight bias. Inspired by Google design doc culture.'
---

# Design Doc

Write before you build. A solo founder's worst enemy is scope creep and hindsight drift — a design doc fixes the scope _in writing_ so you can notice when you're wandering.

## When to Write

- Medium or Large tasks (Small tasks skip this)
- Any task touching more than one module or changing a public interface
- Any task where you've considered more than one approach

## Structure (5 sections, tight)

### 1. Problem

What is broken or missing? Write it so someone who doesn't know the task context can follow. 2–4 sentences.

### 2. Proposed Solution

The approach you intend to take. Bullet points are fine. Include any data shapes, key flows, or interfaces.

### 3. Non-Goals

**Mandatory.** Things this work explicitly will NOT do. This section exists to bound scope.

- Format: "X is out of scope because Y."
- If the list is empty, the doc is incomplete — think harder.
- Non-goals are the single most valuable section for solo developers: they protect against mission drift.

### 4. Alternatives Considered

**Mandatory.** At least 2 alternatives, each with one-line "why rejected."

- Includes "do nothing" if relevant
- This forces honest comparison. If you can't articulate what you rejected, you haven't decided — you've defaulted.

### 5. Open Questions

Things you don't know yet. Flag them so review surfaces them early.

## Length Budget

- Small task: skip.
- Medium task: 1 page (~300 words).
- Large task: 2 pages max. If longer, break the task up.

## Integration

- Produced before `write-plan` (design → plan → execute)
- Design doc content goes into `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/specs/` for Large tasks
- For Medium, inline in the conversation is acceptable
- Link the `success-metric` skill output into section 1 (Problem) to tie design to measurable outcome

## Anti-patterns

- Writing the doc after coding ("document what I built") — the point is to commit to a direction before building
- Skipping Non-Goals because "it's obvious" — the whole point is externalizing the implicit bounds
- Listing fake alternatives ("we could have written it in COBOL") — compare real options you actually considered

---
name: decide
description: '3-line ADR lite. Capture a decision you just made in under 60 seconds — problem, choice, rejected alternative. Complements the heavier `adr` skill; use this when a full ADR is overkill but the decision will be forgotten.'
---

# Decide (ADR Lite)

For decisions that are too small for a full ADR but too important to forget.

## The Three Lines

```
Problem: <one sentence>
Chose:   <what you picked, and why>
Rejected: <one alternative, and why not>
```

That's it. No sections. No heavy template.

## When to Use This vs `adr`

| Use `decide`                                                                            | Use `adr`                                            |
| --------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Decided in < 30 min                                                                     | Decided after a design doc                           |
| Impact scoped to a file or module                                                       | Impact on architecture / public API                  |
| Won't need to re-litigate unless context changes                                        | May be revisited quarterly                           |
| Example: "chose pg trigram over elasticsearch for search — ES is too heavy for 5k rows" | Example: "chose Electron over Tauri for desktop app" |

## Storage

Append to `${COMPANY_OF_ONE_PLUGIN_DATA}/decisions.md` with a date prefix:

```markdown
## 2026-04-20 — Search backend

Problem: Need fuzzy search over project notes (5k rows).
Chose: Postgres pg_trgm. Already have pg; zero new infra.
Rejected: Elasticsearch — operational overhead unjustified at this scale.
```

One file, append-only. Grep-friendly.

## Anti-patterns

- Turning `decide` entries into mini-essays — if it's getting long, you need an ADR
- Skipping "Rejected" — the rejected alternative is the most valuable line; it shows future-you what you'd already considered
- Using `decide` for things you haven't actually decided ("maybe X, maybe Y, TBD") — that's an open question, not a decision

## Philosophy

Google's decision-log culture at scale becomes heavy. At solo-dev scale, the _friction_ is the enemy: a format you won't fill in doesn't exist. Three lines you'll actually write beats a template you won't.

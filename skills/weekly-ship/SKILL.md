---
name: weekly-ship
description: 'Weekly shipping ritual for solo founders. Scan the last 7 days of commits, draft a changelog entry, and pick next week''s single top priority. Inspired by Duolingo''s "Ship It" culture. Invoked via /ship-weekly.'
---

# Weekly Ship

A ritual, not a report. Run once a week (Friday afternoon is ideal). The point is to notice whether you actually shipped — and if not, why not.

## The Three Outputs

Every run produces exactly three things. Keep them short.

### 1. "What shipped this week"

A 3–7 bullet summary of user-visible changes. Source: commits on `main` in the last 7 days.

- Bias toward user-visible: "Added X feature" over "Refactored Y internal module"
- If internal-only work dominated, _say so_ — this is a signal
- Use commit scopes (from conventional commits) to group

### 2. "What didn't ship (and why)"

One paragraph. Honest. Common reasons:

- Scope grew mid-week
- Blocked on external dependency
- Unplanned bug firefighting
- Chose to polish instead of ship

Naming the reason is more important than feeling bad about it.

### 3. "Next week's top 1"

A single priority for the coming week. Not a list. Not three items. **One.**

- Phrase as an outcome, not a task: "Users can export their data" > "Build export endpoint"
- If you can't name one, the real problem is unclear priorities — spend the next ritual on that instead

## Execution Steps

1. `git log --since='7 days ago' --oneline main` (or current default branch)
2. Group commits by scope/type using conventional-commit prefixes
3. Draft the 3 outputs
4. Write to project `CHANGELOG.md` under `## [Unreleased]` if not already there
5. Save the "next week top 1" to `${COMPANY_OF_ONE_PLUGIN_DATA}/weekly-ship/{YYYY-MM-DD}.md`

## Philosophy

Duolingo's rule: "Ship It — if it's done, get it out; the fear of shipping is the enemy."

For a solo founder the mirror risk is _invisible shipping_ — merging to main without announcing, without changelog, without noticing. The weekly ritual makes your own work visible to you.

## Anti-patterns

- Treating this as a "standup" — no audience, just the user
- Listing intentions as "shipped" — only merged work counts
- Skipping because "nothing shipped" — that's precisely when you need the ritual

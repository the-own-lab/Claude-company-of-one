---
name: changelog-launch-post
description: 'Turn a CHANGELOG entry (or set of shipped commits) into a launch post draft for Twitter, a blog, or an email. Bridges engineering output to marketing output without requiring a marketing agent.'
---

# Changelog → Launch Post

You just shipped something. Now tell people. This skill converts an internal CHANGELOG entry into external-facing copy without requiring the user to context-switch into "marketing brain."

## Input

Either:

- A `CHANGELOG.md` entry (usually under `## [Unreleased]` or a versioned heading)
- A list of commits (from `weekly-ship` output)
- A raw description of what shipped

## Output (three formats from one source)

### 1. Tweet / short post (280 chars)

- Lead with the user outcome, not the feature
- One sentence of value prop + one concrete capability
- Link at the end
- Bad: "We refactored our auth layer to support OAuth 2.1"
- Good: "Sign in with Google in one click. (Also Apple, GitHub.) — link"

### 2. Blog post / release note (200–400 words)

Structure:

- **Hook** — the problem users had before
- **What's new** — the feature, in user language
- **How to use it** — 1–3 sentences of instruction
- **What's next** — optional tease

Avoid release-note boilerplate ("we're excited to announce..."). Get to the point.

### 3. Email (80–150 words)

- Subject line is a verb the user can now do
- First sentence = the outcome
- One link, one CTA
- Sign off with something specific (not "the team")

## Translation Rules

Translate _engineering_ language to _user_ language:

| Engineering                      | User-facing                                      |
| -------------------------------- | ------------------------------------------------ |
| "migrated to Postgres 16"        | (don't mention unless user-visible)              |
| "added OAuth 2.1 support"        | "sign in with Google / Apple / GitHub"           |
| "implemented idempotent retries" | "no more duplicate charges on flaky connections" |
| "refactored pricing module"      | (don't mention — it's invisible)                 |

**Rule of thumb:** if a user can't notice the change, don't announce it. Internal refactors don't deserve launch posts.

## What NOT to Do

- Announce every merge — signal dies
- Use words like "revolutionary," "game-changing," "seamless" — instant-skip signals for readers
- Mention the tech stack unless the audience is developers
- Post before it's actually deployed to prod

## Integration

- Pairs with `weekly-ship`: the "what shipped" section feeds directly in
- Output goes to the draft file in `${COMPANY_OF_ONE_PLUGIN_DATA}/launch-drafts/{YYYY-MM-DD}-{slug}.md`
- For heavier marketing work (landing page copy, CRO, SEO), defer to `coreyhaines31/marketingskills` — this skill is only the engineering ↔ marketing bridge

## Philosophy

Solo founders under-announce because shipping and marketing feel like different jobs. This skill makes announcing the _tail_ of shipping — a cheap habit, not a context switch.

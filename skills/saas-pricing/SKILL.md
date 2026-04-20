---
name: saas-pricing
description: 'Pricing heuristics for solo-founder SaaS products. Use when designing or revising a pricing page, choosing a tier structure, or deciding between usage-based vs seat-based billing. Outputs a concrete pricing recommendation, not a lecture.'
---

# SaaS Pricing

Pricing decisions for a solo founder shipping to real users. Not an academic model — a set of defaults that are usually right, with flags for when they're not.

## The Four Questions

Answer these before touching numbers.

1. **Who pays?** — the user, their employer, or a third party?
2. **What does a unit of value look like?** — seat, workspace, API call, stored GB, project?
3. **How often do they get value?** — daily, weekly, monthly? This caps willingness to pay.
4. **What's the next-best alternative, and what does it cost?** — including DIY with ChatGPT.

## Default Tier Structure

For most B2B SaaS under $1M ARR:

- **Free / Trial** — enough to feel the core value; not enough to live on
- **Starter** ($19–$49/mo) — a single person or tiny team; one-workspace feel
- **Team** ($99–$299/mo) — multi-user, admin controls, usually the biggest logo on the page
- **Enterprise** ("Contact us") — SSO, audit logs, custom terms

Three paid tiers is the sweet spot. Two is too few (no anchoring). Four+ confuses.

## Pricing Model Choice

- **Per-seat** — default for collaboration tools; predictable revenue
- **Per-usage** — for API / compute / AI; aligns cost with value but makes revenue lumpy
- **Flat** — for single-user tools; simplest, leaves money on the table
- **Hybrid (seat + usage overages)** — common at $1M+ ARR; overkill for solo

## The Anchor Rule

Your highest visible tier anchors the middle tier. If you want people to pick Team at $199, show a $499 plan above it. The $499 plan doesn't need to sell — it needs to exist.

## The "Feels Underpriced" Rule

If no prospect has ever said "that's expensive," you're underpriced. Raise it.

## Red Flags to Flag in Review

- Free tier that includes the main value prop → no upgrade pressure
- Pricing page explains infrastructure cost → users don't care
- All tiers feature-gated by arbitrary limits (500 vs 1000) → users see through it
- Hiding the price behind "contact us" below Enterprise → kills self-serve

## Output Format

When invoked, produce:

1. Recommended tier names + prices
2. One-line justification per tier (who it's for)
3. The feature-cut between tiers (what's locked behind each upgrade)
4. 1–2 flags if you see red-flag patterns in the user's draft

## Anti-patterns

- Modeling pricing from "cost + margin" — SaaS cost is dominated by fixed R&D; cost-plus gives absurdly low numbers
- Matching competitor prices exactly — you don't know their unit economics
- Over-engineering before traction — if you have fewer than 10 paying customers, just pick a price and ship

## Philosophy

Pricing is a product decision, not a finance decision. The price shapes who shows up, which shapes what you build. Solo founders chronically underprice because they compare to their own walkaway value, not to the buyer's alternative.

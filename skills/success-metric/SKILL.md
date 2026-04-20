---
name: success-metric
description: 'Force every feature spec to answer "how will we know this worked?". A single-field skill that gates feature requirements. Inspired by Duolingo''s metric-driven culture — the solo-dev version of A/B testing discipline.'
---

# Success Metric

Before building, name the measurable thing that will tell you the feature worked.

## The One Question

> If this feature ships exactly as described, what observation in the next 2–4 weeks would tell me it's working?

If you can't answer, you don't know what you're building.

## Format

One line. Concrete. Observable.

- **Good:** "At least 3 users export their data in the first week"
- **Good:** "Landing page conversion rises from 2% to 3%+"
- **Good:** "Support tickets about login drop by half"
- **Bad:** "Users are happier" (not observable)
- **Bad:** "Better UX" (not measurable)
- **Bad:** "More engagement" (engagement on what, measured how)

## Categories (pick one)

1. **Usage** — someone does the new thing N times
2. **Quality** — an error/complaint/bug class reduces
3. **Funnel** — a conversion or retention rate changes
4. **Time** — a task that took X now takes Y
5. **Strategic** — unlocks a later thing (rare, needs the later thing named)

## Integration

- Required field in `requirements` skill output — block spec completion if missing
- Recorded in `design-doc` section 1 (Problem statement)
- Surfaced in `weekly-ship` review: "did last week's features hit their metric?"

## When to Skip

- Bug fixes (success = bug gone; trivial)
- Internal refactors with no behavior change (but then ask: why are we doing this?)
- Research spikes (success = decision made)

## Anti-patterns

- Vanity metrics you can't actually measure
- "We'll figure out the metric later" — you won't
- Metrics that move regardless of the feature (page views when you added a new page)

## Philosophy

Solo founders don't have an A/B testing team. The substitute is _intentionality_: writing down the expected effect _before_ shipping, then checking back. Half the value is the forcing function — many "great ideas" dissolve once you try to name their success metric.

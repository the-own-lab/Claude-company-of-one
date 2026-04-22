---
name: explain-60-40
description: 'Split a feature into 60% boilerplate vs 40% Human-Owned Core; force the user to predict core behavior before Execute. Gates /dev per ADR-002.'
---

# explain-60-40

## Purpose

Before `/dev` enters Execute, partition the work and force the user to pre-declare
intent for the parts that train judgment — the Human-Owned Core. ADR-002 layers this
onto `/dev` without a new flag or command. This skill IS the prediction-loop entry point.

## Inputs

- `BRIEF.md` `## Current Contract`, `## Active Specs`, `### Design Summary`, and
  `## Relevant Memory`. Do NOT re-read DESIGN.md directly; `read-brief` has already
  folded the approach summary into the brief.
- No dependency on `test-plan`. This skill runs BEFORE `test-plan` so that
  Human-Owned Core items inform test coverage, not the other way around.

## Outputs

- `BRIEF.md` `## Human-Owned Core` populated with one `### Core Item N` subsection per
  core concern. Each subsection has these fields filled (via the user, not the LLM):
  - `Invariant to preserve`
  - `Riskiest edge case`
  - `LLM proposed approach`
  - `User prediction` ← MANDATORY before Execute
  - `User selected option` ← MANDATORY before Execute
- Remaining 60% stays implicit; do NOT list boilerplate items.

## Procedure

1. List every concrete unit of work implied by the brief's `### Design Summary`.
2. For each unit, classify as boilerplate (config, scaffold, plumbing, trivial
   CRUD wrapper, test fixture) or Human-Owned Core (domain rule, invariant, safety
   boundary, error shape, auth/authz edge). Core count target: 1–5. If > 5, split the feature.
3. For each Core Item, write the LLM's proposed approach (one paragraph).
4. Present options A / B / C with tradeoffs and ask user to:
   a. Predict the final code's shape in 1–3 lines of pseudocode or plain English.
   b. Pick the option they are selecting.
5. Write predictions and selections into the brief (via `write-brief`).
6. Run `bash "hooks/scripts/lib/spec-conformance-check.sh" pre-execute`. If FAIL,
   stop — do not proceed to `tdd`.

## Failure modes

- User says "you decide" → refuse. Present options again; core items require a user
  pick by contract. This is the whole point of ADR-002.
- > 5 core items identified → the feature is too big; stop and route back to `spec-writing`.
- `pre-execute` gate FAILs (empty prediction or selection) → do not bypass. The
  script is the mechanism; this skill fills the fields the script checks.

## Does not do

- Does not run per feature as a separate checkpoint skill — it IS the checkpoint.
- Does not apply to boilerplate; boilerplate has no prediction requirement.
- Does not judge prediction correctness; `session-reflection` Q9 does that post-code.
- Does not spawn a new skill called `human-owned-core-checkpoint`. That is explicitly
  forbidden by ADR-002 D2.

---
name: read-brief
description: 'Command pre-step: load REQUIREMENTS/DESIGN/TODO + classify MEMORY into BRIEF.md. The only skill allowed to read MEMORY.md.'
---

# read-brief

## Purpose

Command-level pre-step invoked exactly once per `/think` `/dev` `/review` `/debug` run.
Compiles active spec artifacts and MEMORY into a bounded `BRIEF.md` runtime cache.
After this, every other skill reads only the brief (ADR-001 D1/D2).

## Inputs

- The command's feature/topic parameter.
- Active spec directory under `docs/projects/<project>/specs/<date>-<slug>/` (optional for `/think`).
- `~/.claude/projects/.../memory/MEMORY.md` (this skill is the ONLY one allowed to read it).
- Relevant ADRs referenced by the spec.

## Outputs

- `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/<key>/sessions/<session-id>/BRIEF.md`
  — populated BRIEF.md with every section filled. Written via the
  `brief-manager.sh init <command> <feature>` invocation below.
  plus Edit-tool section updates.

## Procedure

1. Run `bash "hooks/scripts/lib/brief-manager.sh" init <command> "<feature>"` to scaffold
   the brief from `templates/BRIEF.md`.
2. If a spec dir exists, fill `## Active Specs` with REQUIREMENTS / DESIGN / TODO / ADR paths and short source fingerprints.
   Then compile the source docs into these fixed brief sections so downstream
   skills do not re-open the source docs. Do not copy source text verbatim:
   - `### Requirements Summary`: one bullet per REQ, including its acceptance criteria.
   - `### Design Summary`: 3-7 bullets covering approach, non-goals, and risk boundaries.
   - `### TODO In Scope`: only TODO.md checkboxes relevant to the current command run.
3. Load every item from `MEMORY.md`. For each item, classify as exactly one of:
   - `used`
   - `ignored:stale`
   - `ignored:unrelated`
   - `ignored:contradicted-by-spec`
   - `ignored:out-of-scope`
4. Write at most 10 `used` items under `## Relevant Memory`; write at most 10 `ignored:*` items under
   `## Ignored Memory`. If nothing was ignored, write the exact sentence:
   `No ignored memory entries; every loaded memory item is used.`
5. Fill `## Assumptions`, `## Open Questions`, `## Current Contract` from the spec +
   user-stated intent. These fields must be consistent with the three summary
   sections above.
6. Leave `## Human-Owned Core` as template placeholders only until `explain-60-40`
   fills it later. Before any execute/review step, placeholders must be gone.
7. Run `bash "hooks/scripts/lib/brief-manager.sh" check-budget`.

## Failure modes

- Brief template missing → `brief-manager.sh` errors; stop.
- A spec dir exists but any summary section remains placeholder-only → stop. The
  BRIEF-only contract is incomplete until REQUIREMENTS / DESIGN / TODO are summarized.
- `check-budget` fails → summarize or remove raw evidence before proceeding.
- `## Ignored Memory` left empty or with placeholders → downstream
  `spec-conformance-check.sh pre-execute` will FAIL (ADR-001 D3). Do not proceed.
- Unknown classification reason → pick the closest of the five codes; never invent a new one.

## Does not do

- Does not re-read MEMORY.md after this step (no other skill may either).
- Does not write specs, ADRs, code, or CHANGELOG.
- Does not copy raw docs, diffs, logs, or transcripts into BRIEF.md.
- Does not make routing decisions; the command is already chosen.

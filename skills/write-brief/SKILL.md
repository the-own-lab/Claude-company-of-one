---
name: write-brief
description: 'Update BRIEF.md sections during a command run. Any skill that produces a brief-persisted artifact calls this to write it back.'
---

# write-brief

## Purpose

In-session updater for `BRIEF.md`. Skills that produce findings, decisions, open
questions, or human-owned-core content use this skill to persist them to the brief
so later skills in the chain see the same source of truth (ADR-001 D2).

## Inputs

- The current brief returned by `brief-manager.sh path`
  (`${COMPANY_OF_ONE_PLUGIN_DATA}/projects/<key>/sessions/<session-id>/BRIEF.md`).
- A target section name (`Open Questions`, `Assumptions`, `Current Contract`,
  `Human-Owned Core`, etc.).
- The content to replace under that section.

## Outputs

- Updated `BRIEF.md` with the requested section modified. No other section touched.

## Procedure

1. Get brief path via `bash "hooks/scripts/lib/brief-manager.sh" path`.
2. Read the file with Read.
3. Locate the target `##` heading. Preserve all other sections verbatim.
4. Apply the update via the Edit tool by replacing that section's body. Append
   only for short list sections where the new entry is not already represented.
5. Never paste raw diffs, full test logs, terminal transcripts, or copied source docs.
6. Never remove a section; empty a section by replacing with a single `-` bullet if needed.
7. Run `bash "hooks/scripts/lib/brief-manager.sh" check-budget`.

## Failure modes

- Brief not found → the calling command never ran `read-brief`. Stop and report.
- Target section not present in the brief → template drift; stop rather than invent a section.
- Would modify `## Relevant Memory` or `## Ignored Memory` → refuse; only `read-brief` writes those.
- `check-budget` fails → shrink or summarize the updated section before continuing.

## Does not do

- Does not read MEMORY.md.
- Does not re-scaffold the brief; that is `brief-manager.sh init`.
- Does not archive or finalize; `update-docs` triggers archive at command end.

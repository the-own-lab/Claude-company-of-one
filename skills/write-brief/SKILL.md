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

- The current brief at `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/<key>/briefs/current.md`.
- A target section name (`Open Questions`, `Assumptions`, `Current Contract`,
  `Human-Owned Core`, etc.).
- The content to append or replace under that section.

## Outputs

- Updated `BRIEF.md` with the requested section modified. No other section touched.

## Procedure

1. Get brief path via `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/brief-manager.sh" path`.
2. Read the file with Read.
3. Locate the target `##` heading. Preserve all other sections verbatim.
4. Apply the update via the Edit tool. Prefer append; replace only when explicitly instructed.
5. Never remove a section; empty a section by replacing with a single `-` bullet if needed.

## Failure modes

- Brief not found → the calling command never ran `read-brief`. Stop and report.
- Target section not present in the brief → template drift; stop rather than invent a section.
- Would modify `## Relevant Memory` or `## Ignored Memory` → refuse; only `read-brief` writes those.

## Does not do

- Does not read MEMORY.md.
- Does not re-scaffold the brief; that is `brief-manager.sh init`.
- Does not archive or finalize; `update-docs` triggers archive at command end.

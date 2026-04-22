---
name: update-docs
description: 'Command post-step: write CHANGELOG + TODO once per command run. One call, not per-skill doc writes.'
---

# update-docs

## Purpose

Command-level post-step. Writes `CHANGELOG.md` and `TODO.md` (inside the active spec
directory) in a single pass, at the end of `/dev` `/review` `/debug`. `/think`'s
output IS the docs, so `/think` does not call this skill.

## Inputs

- `BRIEF.md` — for feature name, delivered contract, accepted review findings.
- Git diff summary (via `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/diff-evidence.sh"`).
- Existing `docs/projects/<project>/CHANGELOG.md`.
- Existing `docs/projects/<project>/specs/<date>-<slug>/TODO.md` (if present).

## Outputs

- Updated `CHANGELOG.md` top entry under `[Unreleased]` in Keep a Changelog format.
- Updated `TODO.md` checkboxes reflecting what actually shipped.

## Procedure

1. Run `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/docs-check.sh"` to see which docs lag behind the diff.
2. Read the current brief's `## Current Contract` and delivered diff.
3. Update `CHANGELOG.md` under `[Unreleased]`:
   - Categorize entries: Added / Changed / Fixed / Removed / Deprecated.
   - One bullet per user-visible change. Skip pure refactor noise.
4. Update `TODO.md`:
   - Tick boxes that are genuinely complete; do NOT tick items whose tests are red.
   - Append new follow-ups surfaced by `/review` that were accepted but deferred.
5. Leave the brief untouched.

## Failure modes

- `docs-check.sh` reports the CHANGELOG untouched while the diff contains code
  changes → you missed a change. Re-run step 3.
- No active spec → stop. `update-docs` does NOT create half-specs. Route back to
  `/think` so the feature gets REQUIREMENTS + DESIGN + TODO before continuing.
  (Exception: `/debug` writes to an existing spec's TODO or to the issue tracker,
  not to a new spec dir.)
- Conventional-commit scope missing for the project → stop; the user must register
  scope in `commitlint.config.js` (monorepo rule).

## Does not do

- Does not commit by itself. Command/repo policy decides whether the Main Agent
  commits after docs update.
- Does not write per-skill micro-logs; only the two deliverable docs.
- Does not run during `/think`.

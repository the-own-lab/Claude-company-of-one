# Company of One — Project Instructions

Claude Code / Codex plugin: **Claude 一人公司 (Company of One)**.

After implementation, bump versions in `marketplace.json` and `plugin.json`.

## Architecture (v3)

- **1 agent**: `reviewer` (fresh-context adversarial review, used only by `/review`)
- **4 commands**: `/think <topic>`, `/dev <feature>`, `/review <target>`, `/debug <problem>`; all require a parameter, no smart routing
- Skills live under `skills/`; keep command prompts aligned with those names.
- **Context contract**: `MEMORY.md` → `read-brief` → `BRIEF.md` → skills. Skills never read MEMORY directly.

## Conventions

- Plugin content is all English
- Working briefs (`BRIEF.md`) go to `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/sessions/{session-id}/` — never to the project repo
- Specs (REQUIREMENTS / DESIGN / TODO / REVIEW / TEST) and ADRs go to `docs/projects/<project>/` in the monorepo (git-tracked)
- Hook scripts use `hooks/scripts/lib/common.sh` for cross-platform path resolution

## Command Invariants

- **Pre**: `read-brief` once (loads REQUIREMENTS / DESIGN / TODO / MEMORY → session-scoped `BRIEF.md`)
- **Mid**: skills read only the brief, never re-read source docs or MEMORY
- **Post**: `update-docs` once, then command-specific reflection: `/dev` uses `session-reflection`; `/review` writes Critique Dialogue; `/debug` uses `debug-summarize`; `/think` has no reflection artifact

Commands fail fast when their parameter is missing. No inference, no routing.

## Code Style

- Functions do one thing, under 50 lines; split if longer
- Early returns over nested conditionals; max 3 nesting levels
- Comments explain WHY, never WHAT
- Error messages are actionable (what went wrong + what to do)

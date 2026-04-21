# Company of One — Project Instructions

This project is a Claude Code / Codex plugin called **Claude 一人公司 (Company of One)**.
It gives solo developers **institutions instead of teammates** — rituals, skills, and one focused agent that replace what fake coworker agents used to pretend to do.

**IMPORTANT**: Always bump the versions in marketplace.json and plugin.json after implementation

## Architecture (v3)

- **1 agent**: `reviewer` (fresh-context adversarial review, used only by `/review`)
- **4 commands**: `/think <topic>`, `/dev <feature>`, `/review <target>`, `/debug <problem>` — all require a parameter; no smart routing
- **17 skills**: `read-brief`, `write-brief`, `research`, `clarify`, `spec-writing`, `adr-writing`, `explain-60-40`, `tdd`, `test-plan`, `verify`, `red-team`, `critique-dialogue`, `spec-conformance`, `update-docs`, `session-reflection`, `debug-hypotheses`, `debug-validate`
- **Context contract**: `MEMORY.md` → `read-brief` → `BRIEF.md` → skills. Skills never read MEMORY directly.
- **Deterministic scripts** replace the v2 pipeline state machine (see `hooks/scripts/`)

## Conventions

- Plugin content is all English
- Working briefs (`BRIEF.md`) go to `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/` — never to the project repo
- Specs (REQUIREMENTS / DESIGN / TODO / REVIEW / TEST) and ADRs go to `docs/projects/<project>/` in the monorepo (git-tracked)
- Commit messages follow conventional commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`, `docs(scope):`
- CHANGELOG follows Keep a Changelog format
- Hook scripts use `hooks/scripts/lib/common.sh` for cross-platform path resolution

## Command Invariants

Every command follows the same outer shape (ADR-001 D7):

- **Pre**: `read-brief` once (loads REQUIREMENTS / DESIGN / TODO / MEMORY → `BRIEF.md`)
- **Mid**: skills read only the brief, never re-read source docs or MEMORY
- **Post**: `update-docs` (writes CHANGELOG + TODO once) + command-specific reflection:
  - `/dev` → `session-reflection` (9 questions, incl. Q9 prediction accuracy)
  - `/review` → `REVIEW.md` Critique Dialogue (no session-reflection)
  - `/debug` → `debug-summarize` (no session-reflection)
  - `/think` → no reflection artifact; the written docs are the deliverable

Commands fail fast when their parameter is missing. No inference, no routing.

## Code Style

- Functions do one thing, under 50 lines; split if longer
- Early returns over nested conditionals; max 3 nesting levels
- No dead code, no commented-out code, no unused imports
- Comments explain WHY, never WHAT
- Error messages are actionable (what went wrong + what to do)
- YAGNI — don't build what you don't need yet

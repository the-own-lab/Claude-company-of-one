# Company of One — Project Instructions

This project is a Claude Code / Codex plugin called **Claude 一人公司 (Company of One)**.
It gives solo developers **institutions instead of teammates** — rituals, skills, and two
focused agents that replace what fake coworker agents used to pretend to do.

Philosophy: **用制度取代隊友** ("institutions over teammates"). Skills are cheap and
lazy-loaded; agents are expensive — so agents are the exception, not the default.

## Architecture (v3)

- **1 agent**: `reviewer` (fresh-context adversarial review, used only by `/review`)
- **4 commands**: `/think <topic>`, `/dev <feature>`, `/review <target>`, `/debug <problem>`
- **17 skills**: command-specific skill chains, no smart routing
- **Context contract**: `MEMORY.md` → `read-brief` → session-scoped `BRIEF.md` → skills

## Plugin Structure

```
.claude-plugin/          → Claude Code plugin manifest
agents/                  → Agent definitions
commands/                → Slash commands
skills/                  → Skills with SKILL.md (each skill references its template)
hooks/                   → Hook scripts
templates/               → Document templates (referenced by skills, not standalone)
```

## Conventions

- Plugin content is all English
- Working briefs go to `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/sessions/{session-id}/` — never to the project repo
- Specs and ADRs go to `docs/projects/<project>/` in the monorepo (git-tracked)
- Commit messages follow conventional commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`
- CHANGELOG follows Keep a Changelog format
- Hook scripts use `hooks/scripts/lib/common.sh` for cross-platform path resolution

## Task Sizing

- **Small**: single file, clear, <2 min → just do it, no docs
- **Medium**: 2-5 files, 5-15 min → inline plan, feature branch
- **Large**: cross-module, >15 min → full pipeline with specs directory

## Code Style

- Functions do one thing, under 50 lines; split if longer
- Early returns over nested conditionals; max 3 nesting levels
- No dead code, no commented-out code, no unused imports
- Comments explain WHY, never WHAT
- Error messages are actionable (what went wrong + what to do)
- YAGNI — don't build what you don't need yet

## Do NOT

- Write standalone docs for Small/Medium tasks
- Start pipelines for simple questions
- Use Large pipeline for Small tasks
- Reintroduce demoted agents (product-owner, architect, developer, qa, devops, ui-designer)
  without a written justification — v2 removed them deliberately for token and context reasons

## Recommended Companion Plugins

Not bundled, but recommended for the "one-person company" surface area this plugin doesn't cover:

- **[coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)** — SaaS
  marketing pack (22k+ stars). Curated starter: `product-marketing-context`, `page-cro`,
  `copywriting`, `seo-audit`, `launch-strategy`, `pricing-strategy`, `churn-prevention`.

Explicitly **not recommended**: `alirezarezvani/claude-skills` — 232 skills cause context
pollution for solo developers; the C-level / compliance / M&A scaffolding is noise at this
scale. Cherry-pick 3–5 skills only if you have a specific need.

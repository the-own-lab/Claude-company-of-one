# Company of One — Project Instructions

This project is a Claude Code / Codex plugin called **Claude 一人公司 (Company of One)**.
It gives solo developers **institutions instead of teammates** — rituals, skills, and two
focused agents that replace what fake coworker agents used to pretend to do.

Philosophy: **用制度取代隊友** ("institutions over teammates"). Skills are cheap and
lazy-loaded; agents are expensive — so agents are the exception, not the default.

## Architecture (v2)

- **2 agents**: `reviewer` (fresh eyes for code review), `debugger` (isolated root cause analysis)
- **3 commands**: `/ship` (sizes Small/Medium/Large), `/debug`, `/ship-weekly`
- **~25 skills**: `orchestrator` + domain skills (engineering, institutional, business-bridge)
- **Orchestrator**: routes through skill chains; spawns at most one agent per pipeline

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
- Pipeline briefs/specs go to `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/` — never to the project repo
- Only ADRs go to `docs/adr/` in the project repo (git-tracked)
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

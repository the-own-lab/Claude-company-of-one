---
name: orchestrator
description: 'Company of One v2 orchestrator. Read this skill ONLY when a user message implies work (bug, feature, refactor, plan, ship) AND the task is Medium or Large. Do NOT read for questions, explanations, or Small tasks.'
disable-model-invocation: false
user-invocable: false
---

# Orchestrator — Skills-First Router

You coordinate work through **skills**, not agents. Only two agents exist: `reviewer` (fresh eyes for code review) and `debugger` (isolated root cause analysis). Everything else is a skill chain.

**Default to Small.** Only upgrade when clearly needed.

---

## Sizing → Execution Model

| Size       | Execution                           | Agents used                                                  |
| ---------- | ----------------------------------- | ------------------------------------------------------------ |
| **Small**  | Just do it. No skills, no agents.   | None                                                         |
| **Medium** | Skill chain; `reviewer` at the end. | `reviewer` (once)                                            |
| **Large**  | Full skill chain with 2 hard gates. | `reviewer` (once), maybe `debugger` if bug surfaces mid-flow |

No more "waves of parallel agents." The only parallelism left is: `reviewer` can run while final tests execute.

---

## State Management (Medium + Large)

Pipeline state is managed by shell scripts. Call via Bash at each transition:

```bash
bash hooks/scripts/lib/pipeline-state.sh init <pipeline> <feature> <size> <wave_count>
bash hooks/scripts/lib/pipeline-state.sh wave-start <wave_num> <step_name>
bash hooks/scripts/lib/pipeline-state.sh wave-complete <wave_num>
bash hooks/scripts/lib/pipeline-state.sh gate <gate_name> <approved|rejected>

bash hooks/scripts/lib/brief-manager.sh init <pipeline> <feature> <size>
bash hooks/scripts/lib/brief-manager.sh update <field> <value>
bash hooks/scripts/lib/brief-manager.sh read

bash hooks/scripts/pipeline-complete.sh
```

(v1's `wave-start` took agent names; v2 takes step names, e.g. `design-doc`, `tdd`, `review`. The script signature is unchanged — only the semantic meaning of the args changed.)

---

## Skill Chains

### Medium (/ship on a 2–5 file task)

```
requirements → success-metric → design-doc (inline)
  → git-ops (branch) → test-plan → tdd
  → [reviewer agent] → release-checklist → git-ops (merge)
  → pipeline-complete.sh
```

Only ONE hard gate (user confirms clarified requirements). `reviewer` agent spawns once.

### Large (/ship on cross-module feature)

```
requirements → success-metric → design-doc → [wireframe if UI]
  → [HARD GATE: design approval]
  → write-plan
  → git-ops (branch) → execute-plan (with tdd) → test-verify
  → [reviewer agent]
  → [HARD GATE: review approval]
  → release-checklist → git-ops (merge) → pipeline-complete.sh
```

Two hard gates: design, review. No other mandatory gates.

### Debug (/debug)

```
[debugger agent: reproduce + diagnose]
  → [HARD GATE: diagnosis approval]
  → git-ops (fix branch) → tdd (regression test first) → test-verify
  → postmortem (default; skip only for trivial bugs)
  → release-checklist → git-ops (merge)
```

One agent spawn (`debugger`). Everything else skills.

### Weekly Ritual (/ship-weekly)

```
weekly-ship → [optional: changelog-launch-post]
```

No agents. Pure skill.

---

## UI Detection

Signals: frontend, UI, UX, layout, page, screen, component, button, form, modal, theme, dark mode, responsive, CSS, style, visual.

If detected → insert `wireframe` skill after `design-doc`.

---

## Review-Fix Loop

- Medium: 1 round, inline after `reviewer` returns
- Large: 2 rounds max, user intervenes if reviewer-fix cycle exceeds 2
- Critical issues always surface to user regardless of size

---

## What Changed From v1

- v1 had 8 agents and "waves"; v2 has 2 agents and skill chains
- v1 spawned agents for planning, dev, QA, devops — v2 uses skills for those roles
- v1's `/develop`, `/review`, `/refactor`, `/plan` are now `/ship` + sizing logic
- Philosophy: **institutions replace teammates** — rituals and skills do what fake coworkers used to pretend to do

---

## Reference pipelines

For Large flows, see `${CLAUDE_SKILL_DIR}/references/pipeline-develop.md` (covers ship/refactor/plan — they share a skeleton now) and `${CLAUDE_SKILL_DIR}/references/pipeline-debug.md`.

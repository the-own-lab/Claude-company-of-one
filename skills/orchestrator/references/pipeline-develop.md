# Ship Pipeline — Large (Skills-First)

The Large `/ship` flow. Medium is a compressed inline version of the same chain — see `orchestrator/SKILL.md`.

## Task Creation

At pipeline start, create all tasks:

```
TaskCreate: "Clarify requirements + success metric"
TaskCreate: "Design + wireframe (if UI)"
TaskCreate: "Write implementation plan"
TaskCreate: "Implement (TDD)"
TaskCreate: "Review"
TaskCreate: "Merge + retro"
```

Initialize state:

```bash
bash hooks/scripts/lib/pipeline-state.sh init ship {feature} large 6
bash hooks/scripts/lib/brief-manager.sh init ship {feature} large
```

---

## Step 1: Requirements + Success Metric

Skills: `requirements`, `success-metric`

- Produce `REQUIREMENTS.md` in `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/specs/{date}-{slug}/`
- Add a single-line success metric (from `success-metric` skill)
- Update brief:
  ```
  bash hooks/scripts/lib/brief-manager.sh update requirements '{1-3 sentence summary}'
  bash hooks/scripts/lib/brief-manager.sh update success_metric '{one line}'
  ```

No agent. Ask clarifying questions one at a time if ambiguous.

---

## Step 2: Design (+ Wireframe if UI)

Skills: `design-doc`, `wireframe` (conditional)

- Produce `DESIGN.md` with 5 sections: Problem, Solution, **Non-Goals**, **Alternatives Considered**, Open Questions
- If UI detected → invoke `wireframe` skill and embed sketch into DESIGN.md
- Add decisions inline (or invoke `decide` skill for notable ones)
- Update brief: `brief-manager.sh update design '{approach summary}'`

### HARD GATE 1 — Design approval

Present to user:

```
Design ready. Key decisions:
- {decision 1}
- {decision 2}
Non-goals: {one line}
Approach: {1-line summary}

Reply 'approved' to proceed, or provide feedback.
```

Do not proceed without approval.

---

## Step 3: Implementation Plan

Skill: `write-plan`

- Produce `PLAN.md` with file-level steps; each step names exact files, signatures, verification criteria
- Keep the steps small enough that each maps to one commit
- Update brief: `brief-manager.sh update plan '{step count + summary}'`

---

## Step 4: Implement

Skills: `git-ops`, `execute-plan`, `tdd`, `test-plan`

- Create branch via `git-ops`: `feature/{slug}`
- Invoke `test-plan` skill → golden/edge/error/won't-test lists
- Invoke `execute-plan` + `tdd`: RED → GREEN → REFACTOR per step
- Commit incrementally with conventional-commit messages
- If a bug surfaces mid-flow that needs real root-cause work, you MAY spawn the `debugger` agent — otherwise stay skill-only

---

## Step 5: Review

Agent: `reviewer` (spawned once)

Run `reviewer` in parallel with any remaining test-verify work (the only parallelism left in v2):

```
Agent(reviewer):
  "On branch feature/{slug}:
   Review all changes (git diff against target).
   Check: logic, security, maintainability, test coverage.
   Update brief: bash hooks/scripts/lib/brief-manager.sh update review_verdict '{verdict + issue count}'
   Verdict: APPROVED / CHANGES REQUESTED / REJECTED."
```

### Review-fix loop

- Warnings only → fix directly (no developer agent) → re-invoke `reviewer`
- Max 2 rounds
- Critical issues → HARD GATE to user

### HARD GATE 2 — Review approval

```
Tests: {pass/fail summary}
Review: {verdict} — {N issues}

Reply 'merge' to ship, 'fix' to address issues, or 'abort'.
```

---

## Step 6: Merge + Retro

Skills: `release-checklist`, `git-ops`

1. Run `release-checklist` (pre-merge section)
2. Update `CHANGELOG.md` (Keep a Changelog format, under `## [Unreleased]`)
3. `git-ops` squash-merge to target branch; delete feature branch
4. `bash hooks/scripts/pipeline-complete.sh`

Optionally: pipe the changelog entry through `changelog-launch-post` skill to draft launch copy.

---

## Dependency Graph

```
Step 1 (requirements + metric)
   ↓
Step 2 (design + wireframe?)
   ↓
   GATE 1 (design approval)
   ↓
Step 3 (plan)
   ↓
Step 4 (implement, TDD)
   ↓
Step 5 (reviewer agent) — parallel with final test-verify
   ↓
   GATE 2 (review approval)
   ↓
Step 6 (merge + retro)
```

## What Changed From v1

- 6 agents → 1 agent (reviewer only)
- "Waves of parallel agents" → linear skill chain with one parallel edge (reviewer + final tests)
- Agent personas (product-owner, architect, developer, qa, devops, ui-designer) → skills of the same role
- Gates unchanged (design approval, review approval)

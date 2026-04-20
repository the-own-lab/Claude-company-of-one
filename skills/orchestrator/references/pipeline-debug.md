# Debug Pipeline — Skills-First

One agent (`debugger`) for reproduce + diagnose. Everything else is skills.

## Task Creation (at pipeline start)

```
TaskCreate: "Reproduce + Diagnose (debugger agent)"
TaskCreate: "Fix (TDD)"
TaskCreate: "Verify"
TaskCreate: "Postmortem + Merge"
```

---

## Step 1: Reproduce + Diagnose

- **Agent**: `debugger` (spawned once, isolated context)
- **Action**: Reproduce the bug, trace, hypothesize, verify root cause, identify blast radius, recommend fix
- **Output**: `DIAGNOSIS.md` in `${COMPANY_OF_ONE_PLUGIN_DATA}/projects/{key}/specs/{date}-fix-{slug}/`
- **Brief**: `brief-manager.sh update diagnosis '{root cause 1-liner}'`
- **Gate**: HARD — user must confirm diagnosis before code changes

Present to user:

```
Diagnosis complete.
Root cause: {1-sentence}
Blast radius: {affected areas}
Recommended fix: {1-sentence}

Reply 'approved' to proceed, or provide alternative direction.
```

---

## Step 2: Fix

- **Skills**: `git-ops`, `tdd`
- **Action**:
  1. `git-ops` → create branch `fix/{slug}`
  2. `tdd` → failing regression test first (RED) → minimum fix (GREEN) → refactor
- **Commit**: `fix({scope}): {description}`
- **No agent spawn.**

---

## Step 3: Verify

- **Skill**: `test-verify`
- **Action**: Confirm original repro now passes, full suite green, blast-radius tests green
- **Output**: Inline verification summary; brief update
- **Gate**: SOFT — on failure, user decides:
  - `rediagnose` → return to Step 1
  - `fix` → return to Step 2
  - `abort` → stop

---

## Step 4: Postmortem + Merge

- **Skills**: `postmortem`, `release-checklist`, `git-ops`
- **Postmortem**: default ON. Skip only for trivial bugs (< 5 min fix, typo, one-off, no systemic lesson).
- **Release checklist**: pre-merge section
- **Merge**: `git-ops` squash-merge; update `CHANGELOG.md` under `### Fixed`; delete fix branch
- **Finalize**: `bash hooks/scripts/pipeline-complete.sh`

---

## Dependency Graph

```
Step 1 (debugger agent)
   ↓
   HARD GATE (diagnosis approval)
   ↓
Step 2 (fix via tdd)
   ↓
Step 3 (verify)  ← SOFT GATE on failure
   ↓
Step 4 (postmortem + merge)
```

## What Changed From v1

- 3 agents (debugger + devops + developer + qa) → 1 agent (debugger only)
- Postmortem decision moved from "debugger subagent assesses" to "default ON, defined skip rule"
- Devops/developer/qa work now happens directly via skills, saving subagent token cost

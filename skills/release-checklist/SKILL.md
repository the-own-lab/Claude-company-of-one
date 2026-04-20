---
name: release-checklist
description: "Pre-merge and pre-deploy checklist for solo-founder projects. Absorbs the former devops agent's gate role as a lightweight skill. Use before squash-merging to main and before promoting a build to production."
---

# Release Checklist

Two checklists. One before merging to `main`. One before deploying to production. Keep them short so they actually get used.

## Pre-Merge (before squash-merging to `main`)

- [ ] **Tests pass locally** — not just "mostly pass"
- [ ] **CHANGELOG updated** under `## [Unreleased]`
- [ ] **Conventional commit title** — `type(scope): description`, scope matches `commitlint.config.js`
- [ ] **Migration files included** if schema changed (and reversible)
- [ ] **No commented-out code, `console.log`, `TODO` without owner** left behind
- [ ] **Non-goals respected** — diff matches the `design-doc`'s scope; if it grew, update the doc or split the PR
- [ ] **Secrets not committed** — `.env`, keys, tokens, connection strings
- [ ] **Success metric recorded** (from `success-metric` skill) so post-release review can check it

## Pre-Deploy (before promoting a build to prod)

- [ ] **Build green on CI** for the merge commit
- [ ] **DB migrations run in staging** without errors and without long locks
- [ ] **Rollback plan named** — previous image tag / previous commit to redeploy
- [ ] **Healthcheck endpoint returns 200** on the new build in staging
- [ ] **On-call window acceptable** — not Friday evening unless the change is trivial
- [ ] **Feature flag state known** — if new code is gated, confirm default is correct
- [ ] **Announcement drafted** — even if not yet posted (see `changelog-launch-post`)

## When to Skip

- Solo project with no production tier → skip pre-deploy, keep pre-merge
- Docs-only changes → skip migration / healthcheck / flag items
- Hotfix → run the checklist but compress; never skip rollback plan

## Output

Print the checked-off list to the conversation. For Medium/Large tasks, also append the pre-merge status to the brief via `brief-manager.sh update release_checklist passed`.

## Philosophy

Checklists exist for tired-Friday-you, not for focused-Tuesday-you. If the list is long enough to skim past, it's too long — trim ruthlessly. Each item must have actually caught a real bug at some point; otherwise, delete it.

## What This Replaces

The former `devops` agent's pre-merge gate behavior. Deletion / branch-lifecycle work moves to the existing `git-ops` and `git-worktree` skills. Pipeline status transitions still use `hooks/scripts/lib/pipeline-state.sh`.

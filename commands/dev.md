---
name: dev
description: 'Execute a feature end-to-end: predict Human-Owned Core → TDD → verify → update docs → reflect. Gated by spec-conformance-check.sh pre-execute.'
---

# /dev <feature>

Implementation command. Code only gets written here.

## Usage

```
/dev <feature>
```

If `<feature>` is missing, print the example above and exit. No inference, no routing.

## Flow

### Pre

1. **read-brief** — `bash hooks/scripts/lib/brief-manager.sh init dev "<feature>"`,
   then classify MEMORY per ADR-001 D3. The brief folds in
   REQUIREMENTS / DESIGN / TODO so mid-step skills never re-read source docs.

### Mid (in strict order)

2. **explain-60-40** — partition the work, fill `## Human-Owned Core`, force the
   user to predict + pick for each core item. This skill ends by running
   `bash hooks/scripts/lib/spec-conformance-check.sh pre-execute`. FAIL = stop.
3. **test-plan** — four buckets; `Won't test` is mandatory. Reads the brief's
   contract + Human-Owned Core, not source docs.
4. **tdd** — RED → GREEN → REFACTOR, one behavior at a time.
5. **verify** — run the full suite, map REQ → test, apply the security lens. If
   anything fails, stop before `update-docs`.

### Post

6. **update-docs** — single pass: `CHANGELOG.md` under `[Unreleased]` + spec
   `TODO.md` checkboxes. No half-spec fallbacks.
7. **session-reflection** — 9 questions. Q9 compares each Human-Owned Core
   prediction to final code; if any item is `diverged`, invoke
   `spec-conformance` reconstruction-drill judge. Do NOT soften `diverged` to
   `mostly aligned`.
8. Archive brief via `brief-manager.sh archive`.

## Hard rules

- `pre-execute` gate is non-negotiable. An empty prediction or selection in the
  brief MUST stop `/dev` before `tdd` runs.
- Mid-step skills read `BRIEF.md` only. No direct reads of REQUIREMENTS.md /
  DESIGN.md / MEMORY.md from inside `/dev`.
- No auto-escalation to `/review`. User invokes it explicitly.
- No sizing shortcut (S/M/L). ADR-001 D1 removed it deliberately.

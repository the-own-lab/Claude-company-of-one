---
name: debug
description: 'Reproduce → hypothesize → validate one-at-a-time → fix via TDD → regression test → summarize. No shotgun debugging.'
---

# /debug <problem>

Structured debug loop. Replaces the v2 `debugger` agent.

## Usage

```
/debug <problem>
```

If `<problem>` is missing, print the example above and exit.

## Flow

### Pre

1. **read-brief** — `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/brief-manager.sh" init debug "<problem>"`. Fold in the
   reproducer, error output, and the active spec (if any) so mid-step skills
   read only the brief.

### Mid

2. **debug-hypotheses** — list 3–5 candidate causes with evidence-for,
   evidence-against, confidence, and validation method. No padding.
3. **debug-validate** — pick the highest-confidence hypothesis, run the stated
   validation. Test exactly one hypothesis per iteration. If disproved, loop
   back to step 2 with the hypothesis crossed out and new evidence recorded.
   Shotgun debugging (change-many-things-and-rerun) is a hard refuse.
4. Once the root cause is confirmed, record it in the brief's `### Root Cause`.
5. **tdd** — write a regression test that fails on the bug, then fix the code
   until it passes. Minimum change; no unrelated cleanup.
6. **verify** — full suite green, security lens pass.

### Post

7. **update-docs** — CHANGELOG `Fixed` entry + TODO tick (if applicable). If no
   active spec exists, append to the issue tracker entry, NOT a new half-spec.
8. **debug-summarize** (inline in this command, not a separate skill file):
   emit one-paragraph postmortem capturing symptom, root cause, fix, and any
   follow-ups. Append to the issue file under `docs/projects/<project>/issues/`.
9. Archive brief via `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/brief-manager.sh" archive`.

No `session-reflection` for `/debug` per ADR-001 D7.

## Hard rules

- One hypothesis at a time. Parallel hypothesis testing is shotgun debugging.
- Fix + regression test always ship together. A fix without a test is rejected.
- If 5 hypotheses all disprove, stop and re-read the brief — the model of the
  system is wrong, not the hypotheses.

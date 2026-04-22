---
name: spec-conformance
description: '/review Layer 1 auditor + /think self-review. Three contexts: think-self-review, review-spec, review-implementation. Also judges reconstruction drills.'
---

# spec-conformance

## Purpose

Deterministic + LLM audit of spec/code consistency. Runs in three distinct
contexts; each has its own input contract:

| Context                 | Caller                 | Reads                                           |
| ----------------------- | ---------------------- | ----------------------------------------------- |
| `think-self-review`     | Main Agent in `/think` | `BRIEF.md` + draft spec artifacts               |
| `review-spec`           | `/review` Layer 1      | `REVIEW_INPUT.md` + referenced artifacts        |
| `review-implementation` | `/review` Layer 1      | `REVIEW_INPUT.md` + referenced artifacts + diff |

Also provides the reconstruction-drill judge per ADR-002 D4 (pseudocode vs final
code invariant), invoked only from `session-reflection` Q9.

## Inputs

Context-dependent (see table above). In `/review` contexts the skill does NOT
read BRIEF.md — the reviewer contract is REVIEW_INPUT.md only. In the `/think`
self-review context the brief is allowed because the Main Agent's own cache is
the thing being self-reviewed.

## Outputs

- `/think` self-review: list of drift / inconsistency items written to brief
  `## Open Questions` for the user to resolve before `/think` exits.
- `/review` Layer 1 section in `REVIEW.md`: Traceability Matrix, Scope Drift,
  Documentation Consistency, Hard Block Triggered.
- Layer 1 verdict: PASS or FAIL. FAIL hard-blocks Layer 2 (red-team).
- Reconstruction drill: `aligned | diverged | partially-aligned` with one-sentence
  justification written back to the core item's `Prediction result` field.

## Procedure

1. Run the deterministic half when in `/review`:
   `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/spec-conformance-check.sh" pre-review <spec_dir> <base_ref>`.
   If FAIL, stop with Layer 1 FAIL.
2. **think-self-review**: check the brief's draft REQ/DESIGN/TODO for:
   - Every REQ has a testable acceptance criterion.
   - Every DESIGN step is reachable from a REQ.
   - Every TODO item traces to REQ or DESIGN.
   - DESIGN Non-Goals present and not empty.
   - ADRs referenced exist (Proposed status is fine at this stage).
3. **review-spec** (same checks as think-self-review, but sourced from
   REVIEW_INPUT.md not BRIEF.md; Proposed ADRs still acceptable since the spec
   is the thing under review).
4. **review-implementation**:
   - Traceability Matrix (one row per REQ): spec item → impl file:line → test → status.
   - Scope drift: code touches outside spec → list or declare None.
   - DESIGN↔impl drift: if the code diverges from DESIGN, require an ADR amendment
     or a declared deviation; silent divergence = FAIL.
   - Any referenced ADR MUST be Accepted, not Proposed.
5. Reconstruction-drill judge (session-reflection Q9 only):
   - Compare drill `pseudocode` field to the final code's invariant.
   - Mechanical match, not sentiment. Do not soften `diverged` to "mostly aligned".

## Failure modes

- `pre-review` script FAIL → Layer 1 FAIL; do not proceed to LLM checks.
- `review_mode` missing in REVIEW_INPUT.md → FAIL; Main Agent must fill it.
- Caller is `/review` but skill tries to open BRIEF.md → refuse; that breaks the
  reviewer fresh-context contract.
- LLM wants to mark PASS despite a missing test for REQ-N → FAIL. The matrix is
  mechanical.
- Proposed ADR cited in `review-implementation` → FAIL until ADR is Accepted.

## Does not do

- Does not produce red-team findings (that is `red-team`).
- Does not write Main Agent dispositions (that is `critique-dialogue`).
- Does not edit code.

---
name: review
description: 'Three-layer review: spec-conformance (Layer 1) → reviewer agent red-team (Layer 2) → critique-dialogue (Layer 3). Fresh-context at Layer 2.'
---

# /review <target>

Adversarial review. `<target>` is a spec slug, a PR ref, or a file path.

## Usage

```
/review <target>
```

If `<target>` is missing, print the example above and exit.

## Flow

### Pre

1. Resolve `<target>` deterministically before loading context:

   | Target shape                                          | Resolution                                                                                                                                                                                                                                                   | `review_mode`    | `base_ref`                       |
   | ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------------------------- |
   | `docs/projects/<project>/specs/<date>-<slug>`         | Use that directory if it contains REQUIREMENTS.md / DESIGN.md / TODO.md.                                                                                                                                                                                     | `spec`           | `HEAD`                           |
   | `<slug>`                                              | Match exactly one directory basename under `docs/projects/<project>/specs/`. Zero or multiple matches = fail fast.                                                                                                                                           | `spec`           | `HEAD`                           |
   | `<base_ref>...<head_ref>` or `<base_ref>..<head_ref>` | Find exactly one existing REVIEW_INPUT.md under `docs/projects/<project>/specs/` whose Target names that head/base pair, then use its spec path. Zero or multiple matches = fail fast and ask for a spec slug/path.                                          | `implementation` | left side of the range           |
   | file path                                             | Find exactly one existing REVIEW_INPUT.md under `docs/projects/<project>/specs/` that explicitly references the file path and sets `review_mode: implementation`, then use its spec path. Zero or multiple matches = fail fast and ask for a spec slug/path. | `implementation` | explicit base in REVIEW_INPUT.md |

   Do not infer missing `spec_dir`, `base_ref`, or `review_mode` from chat context.

2. **read-brief** — load the brief for the resolved target spec so Main Agent has context.
   The brief is NOT passed to the reviewer agent.
3. Generate or refresh `REVIEW_INPUT.md`:
   `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/review-input.sh" generate <spec_dir> <base_ref>`.
   The Main Agent MUST fill `review_mode` (`spec` or `implementation`) and
   `Known Deviations`, `Questions for Reviewer`, `Out of Scope` before proceeding.

### Layer 1 — spec-conformance (Main Agent)

4. **spec-conformance** in context `review-spec` or `review-implementation`
   depending on `review_mode`. Runs `spec-conformance-check.sh pre-review`
   first (deterministic). FAIL here = hard block; do NOT invoke Layer 2.

### Layer 2 — red-team (reviewer agent, fresh context)

5. Invoke `reviewer` agent. The agent reads ONLY `REVIEW_INPUT.md` + the
   artifacts REVIEW_INPUT.md explicitly references. It does NOT read BRIEF.md,
   chat history, or crawl the repo. The reviewer returns Layer 2 markdown to
   the Main Agent; it does not write files.
6. Main Agent inserts that markdown into `REVIEW.md` Layer 2 verbatim. Reviewer
   output has three buckets via **red-team**: Confirmed Findings, Plausible Risks,
   Attack Surfaces Checked.

### Layer 3 — critique-dialogue (Main Agent)

7. **critique-dialogue** — Main Agent writes a disposition per finding:
   `accepted | rejected | deferred | needs-user-decision`. `needs-user-decision`
   is capped at 2 per review run (ADR-001 D4).
8. Accepted findings become follow-up TODOs; `update-docs` ticks the
   corresponding CHANGELOG/TODO entries.

### Post

9. **update-docs** — propagate accepted follow-ups into TODO/CHANGELOG only.
   REVIEW.md is produced by Layer 1, the Main Agent inserting Layer 2 reviewer
   output, and Layer 3 `critique-dialogue`.
10. No `session-reflection` artifact for `/review`; the REVIEW.md dialogue is the deliverable.

## Hard rules

- Reviewer agent context is fresh. BRIEF.md, chat history, MEMORY are forbidden
  at Layer 2. Violating this defeats ADR-001 D4's self-deception defense.
- Target resolution is deterministic. Missing or ambiguous `spec_dir`, `base_ref`,
  or `review_mode` stops `/review`; Main Agent must not guess.
- Spec directory and slug targets always start as `review_mode: spec`. To review an
  implementation, user must pass a git range target or an existing REVIEW_INPUT.md
  must explicitly bind a referenced file path to `review_mode: implementation`.
- Layer 1 FAIL blocks Layer 2. Security-category findings (secret exposure,
  injection, auth bypass, destructive data loss, RCE) auto-hard-block the release.
- `needs-user-decision` > 2 → stop and ask the user to prioritize.

---
name: think
description: 'Turn a topic into a written spec (REQUIREMENTS + DESIGN + TODO) and, if warranted, an ADR. Never auto-escalates to the reviewer agent.'
---

# /think <topic>

Plan-first command. Produces docs; no code is written here.

## Usage

```
/think <topic>
```

If `<topic>` is missing, print the example above and exit. No inference, no routing.

## Flow

1. **read-brief** — `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/brief-manager.sh" init think "<topic>"`,
   then populate the brief. Classify every MEMORY item (ADR-001 D3).
2. **research** — Web Search + Context7 for any library/API facts the spec will
   depend on.
3. **clarify** — reverse-question the user to drain `## Open Questions`.
4. **spec-writing** — write REQUIREMENTS.md + DESIGN.md + TODO.md under
   `docs/projects/<project>/specs/YYYY-MM-DD-<verb>-<slug>/`.
5. **adr-writing** — only if this run introduces a cross-feature architectural
   constraint. Skip if not.
6. **spec-conformance** (context=`think-self-review`) — final consistency pass.
   This is Main Agent self-review, NOT reviewer-agent adversarial review. The
   user must explicitly run `/review <topic>` if they want Layer 2. FAIL returns
   to `spec-writing`; do not archive the brief or present the docs as complete
   until the self-review passes.

## Post-step

- No `update-docs`: the written docs ARE the deliverable.
- No `session-reflection`: ADR-001 D7.
- Archive the brief via `bash "${COMPANY_OF_ONE_PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-${CODEX_PLUGIN_ROOT:?Set COMPANY_OF_ONE_PLUGIN_ROOT to the plugin root}}}/hooks/scripts/lib/brief-manager.sh" archive`.

## Hard rules

- Do not auto-escalate to `reviewer` on "major decision" / "auth touched" /
  "public API". That is smart routing, explicitly rejected (ADR-001 D4).
- Do not produce code. `/dev` exists for that.
- `think-self-review` FAIL is a gate, not advice. Repair REQUIREMENTS / DESIGN /
  TODO via `spec-writing`, then run `spec-conformance` again.

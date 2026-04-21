#!/usr/bin/env bash
# Session Start Hook — Claude 一人公司 v3
# Minimal context injection. No task sizing. No smart routing.
# Commands are explicit: /think <topic>, /dev <feature>, /review <target>, /debug <problem>.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

PROJECT_DIR="$(company_of_one_project_dir)"
RUNTIME_LABEL="$(company_of_one_runtime_label)"

company_of_one_init_storage

cat <<CONTEXT
<company-of-one runtime="${RUNTIME_LABEL}" version="3">
Commands require a parameter. No routing, no sizing, no inference.
- /think <topic>     — write REQUIREMENTS / DESIGN / TODO / ADR
- /dev <feature>     — TDD + spec coding; BRIEF.md is the only context contract
- /review <target>   — three-layer adversarial review (spec | implementation)
- /debug <problem>   — guided hypothesize → validate → regression-test
Context contract: MEMORY → read-brief → BRIEF.md → skills. Skills never read MEMORY directly.
Brief scripts: hooks/scripts/lib/brief-manager.sh (init, read, path, archive).
Reviewer agent is only spawned by /review. /think never auto-escalates.
</company-of-one>
CONTEXT

if [ -f "$PROJECT_DIR/briefs/current.md" ]; then
  echo ""
  echo "<active-brief path=\"$PROJECT_DIR/briefs/current.md\">"
  cat "$PROJECT_DIR/briefs/current.md"
  echo "</active-brief>"
fi

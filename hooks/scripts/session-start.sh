#!/usr/bin/env bash
# Session Start Hook — Claude 一人公司 v3
# Minimal context injection. No task sizing. No smart routing.
# Commands are explicit: /think <topic>, /dev <feature>, /review <target>, /debug <problem>.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

RUNTIME_LABEL="$(company_of_one_runtime_label)"
PLUGIN_ROOT="$(company_of_one_plugin_root)"
SESSION_ID="$(company_of_one_session_id)"
SESSION_DIR="$(company_of_one_session_dir)"
BRIEF_PATH="$SESSION_DIR/BRIEF.md"
LEGACY_BRIEF="$(company_of_one_legacy_brief_path)"

company_of_one_init_storage

cat <<CONTEXT
<company-of-one runtime="${RUNTIME_LABEL}" version="3">
Commands require a parameter. No routing, no sizing, no inference.
- /think <topic>     — write REQUIREMENTS / DESIGN / TODO / ADR
- /dev <feature>     — TDD + spec coding; BRIEF.md is the only context contract
- /review <target>   — three-layer adversarial review (spec | implementation)
- /debug <problem>   — guided hypothesize → validate → regression-test
Context contract: MEMORY → read-brief → BRIEF.md → skills. Skills never read MEMORY directly.
Brief scripts: run via hooks/scripts/lib/brief-manager.sh (init, read, path, check-budget, archive).
Resolved plugin root: ${PLUGIN_ROOT}
Session id: ${SESSION_ID}
Session data: ${SESSION_DIR}
Reviewer agent is only spawned by /review. /think never auto-escalates.
</company-of-one>
CONTEXT

if [ -f "$BRIEF_PATH" ]; then
  echo ""
  echo "<active-brief path=\"$BRIEF_PATH\">"
  echo "Use brief-manager.sh read only when the command needs the active brief."
  echo "</active-brief>"
fi

if [ -f "$LEGACY_BRIEF" ]; then
  echo ""
  echo "<legacy-active-brief path=\"$LEGACY_BRIEF\">"
  echo "Legacy project-wide brief exists; archive or migrate deliberately."
  echo "</legacy-active-brief>"
fi

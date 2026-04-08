#!/usr/bin/env bash
# Session Start Hook — Claude 一人公司
# Minimal context injection. Static rules stay in skill files.
# Memory reads from index files, never scans directories.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=hooks/scripts/lib/pattern-index.sh
. "$SCRIPT_DIR/lib/pattern-index.sh"

PLUGIN_DATA="$(company_of_one_plugin_data)"
MEMORY_DIR="$(company_of_one_memory_dir)"
RUNTIME_LABEL="$(company_of_one_runtime_label)"

company_of_one_init_storage

# ── Minimal Routing Context (< 200 tokens) ──────────────────
cat <<CONTEXT
<company-of-one runtime="${RUNTIME_LABEL}">
Default to SMALL. Only upgrade when clearly needed.
- Small: just code it. No docs, no branch, no TaskCreate.
- Medium: inline plan + branch + TaskCreate 4 tasks.
- Large: read orchestrator skill + pipeline reference. Agents work in parallel waves.
Orchestrator skill has details — read it only for Medium/Large.
State scripts: hooks/scripts/lib/pipeline-state.sh (init, wave-start, wave-complete, gate, complete)
</company-of-one>
CONTEXT

# ── Pipeline State (only if active/resuming) ─────────────────
if [ -f "$PLUGIN_DATA/pipeline-state.json" ]; then
  local_status=$(python3 -c "import json; print(json.load(open('$PLUGIN_DATA/pipeline-state.json')).get('status',''))" 2>/dev/null || echo "")
  if [ "$local_status" = "active" ]; then
    echo ""
    echo "<pipeline-resume>"
    cat "$PLUGIN_DATA/pipeline-state.json"
    echo "</pipeline-resume>"
  fi
fi

# ── Memory: Pattern Index (reads index file, not pattern directory) ──
pattern_index_read_high_confidence

# ── Memory: Project Context (max 30 lines) ───────────────────
if [ -f "$MEMORY_DIR/project-context.md" ]; then
  echo ""
  echo "<project-context>"
  head -30 "$MEMORY_DIR/project-context.md"
  echo "</project-context>"
fi

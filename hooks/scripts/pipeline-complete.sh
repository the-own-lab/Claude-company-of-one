#!/usr/bin/env bash
# pipeline-complete.sh — Called at the END of every pipeline.
# Handles: state finalization, project-context update, pattern index rebuild.
# This is the runtime integrity guarantee.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=hooks/scripts/lib/pipeline-state.sh
. "$SCRIPT_DIR/lib/pipeline-state.sh"
# shellcheck source=hooks/scripts/lib/pattern-index.sh
. "$SCRIPT_DIR/lib/pattern-index.sh"

PLUGIN_DATA="$(company_of_one_plugin_data)"
MEMORY_DIR="$(company_of_one_memory_dir)"
CONTEXT_FILE="$MEMORY_DIR/project-context.md"

# ── 1. Finalize pipeline state ───────────────────────────────
pipeline_state_complete
echo "--- Pipeline state finalized ---"

# ── 2. Update project-context.md ─────────────────────────────
update_project_context() {
  local now specs_dir tech_stack recent_decisions active_work
  now="$(date +%Y-%m-%d)"

  # Read current pipeline state for context
  local pipeline feature
  pipeline=$(python3 -c "import json; print(json.load(open('$PLUGIN_DATA/pipeline-state.json')).get('pipeline','?'))" 2>/dev/null || echo "?")
  feature=$(python3 -c "import json; print(json.load(open('$PLUGIN_DATA/pipeline-state.json')).get('feature','?'))" 2>/dev/null || echo "?")
  specs_dir=$(python3 -c "import json; print(json.load(open('$PLUGIN_DATA/pipeline-state.json')).get('specs',''))" 2>/dev/null || echo "")

  # Detect tech stack from project files (simple heuristic)
  tech_stack=""
  [ -f "package.json" ] && tech_stack+="Node.js, "
  [ -f "tsconfig.json" ] && tech_stack+="TypeScript, "
  [ -f "pyproject.toml" ] || [ -f "setup.py" ] && tech_stack+="Python, "
  [ -f "Cargo.toml" ] && tech_stack+="Rust, "
  [ -f "go.mod" ] && tech_stack+="Go, "
  [ -f "next.config.js" ] || [ -f "next.config.mjs" ] && tech_stack+="Next.js, "
  tech_stack="${tech_stack%, }"  # Remove trailing comma
  [ -z "$tech_stack" ] && tech_stack="Not detected"

  # Collect recent ADR decisions (last 5)
  recent_decisions=""
  if [ -d "docs/specs" ]; then
    for adr in $(find docs/specs -name "ADR.md" -type f 2>/dev/null | sort -r | head -5); do
      local adr_title
      adr_title=$(grep -m1 "^# " "$adr" | sed 's/^# //')
      local adr_date
      adr_date=$(basename "$(dirname "$adr")" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "?")
      recent_decisions+="- ${adr_title} (${adr_date})\n"
    done
  fi
  [ -z "$recent_decisions" ] && recent_decisions="- None yet\n"

  # Write context file (max 30 lines)
  cat > "$CONTEXT_FILE" <<EOF
# Project Context
Updated: ${now}

## Tech Stack
${tech_stack}

## Recent Pipelines
- ${pipeline}: ${feature} (completed ${now})

## Recent Decisions
$(echo -e "$recent_decisions")
## Working Directory
$(pwd)
EOF

  echo "--- Project context updated: $CONTEXT_FILE ---"
}

update_project_context

# ── 3. Rebuild pattern index ─────────────────────────────────
pattern_index_rebuild
echo "--- Pattern index rebuilt ---"

echo "Pipeline completion routine finished."

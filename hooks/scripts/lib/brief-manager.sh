#!/usr/bin/env bash
# brief-manager.sh — Manage the v3 BRIEF.md lifecycle.
#
# v3.1: BRIEF is scoped to the current session. Skills edit sections directly
# with the Edit tool; this script handles init/read/archive/path and the tiny
# CURRENT.json pointer. See ADR-001 D2 and templates/BRIEF.md for structure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"

brief_current_path() {
  echo "$(company_of_one_session_dir)/BRIEF.md"
}

brief_state_path() {
  echo "$(company_of_one_session_dir)/CURRENT.json"
}

brief_template_path() {
  local plugin_root
  plugin_root="$(company_of_one_plugin_root)"
  echo "$plugin_root/templates/BRIEF.md"
}

brief_init() {
  # Usage: brief_init <command> <feature-or-topic>
  #   command: think | dev | review | debug
  if [ "$#" -lt 2 ]; then
    echo "Usage: brief-manager.sh init <think|dev|review|debug> <feature-or-topic>" >&2
    return 1
  fi

  local command="$1" feature="$2"
  local session_id brief_file state_file template
  case "$(company_of_one_session_hint)" in
    shared | tty-*)
      session_id="$(company_of_one_new_session_id)"
      ;;
    *)
      session_id="$(company_of_one_session_id)"
      ;;
  esac

  brief_file="$(company_of_one_sessions_dir)/$session_id/BRIEF.md"
  state_file="$(company_of_one_sessions_dir)/$session_id/CURRENT.json"
  template="$(brief_template_path)"
  mkdir -p "$(dirname "$brief_file")"

  case "$command" in
    think | dev | review | debug) ;;
    *)
      echo "ERROR: unknown command '$command' (expected think|dev|review|debug)" >&2
      return 1
      ;;
  esac

  if [ ! -f "$template" ]; then
    echo "ERROR: brief template missing at $template" >&2
    return 1
  fi

  local now
  now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  FEATURE="$feature" \
    BRIEF_COMMAND="/$command" \
    BRIEF_TIMESTAMP="$now" \
    perl -pe '
      s/\{feature or topic\}/$ENV{FEATURE}/g;
      s/\{\/think \| \/dev \| \/review \| \/debug\}/$ENV{BRIEF_COMMAND}/g;
      s/\{UTC timestamp\}/$ENV{BRIEF_TIMESTAMP}/g;
    ' "$template" > "$brief_file"

  SESSION_ID="$session_id" \
    COMMAND="/$command" \
    FEATURE="$feature" \
    BRIEF_FILE="$brief_file" \
    CREATED_AT="$now" \
    python3 -c "
import json, os
data = {
    'session_id': os.environ['SESSION_ID'],
    'command': os.environ['COMMAND'],
    'feature': os.environ['FEATURE'],
    'brief_path': os.environ['BRIEF_FILE'],
    'created_at': os.environ['CREATED_AT'],
    'status': 'active',
}
with open('$state_file', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null

  company_of_one_write_active_session "$session_id" "$brief_file"

  echo "Brief initialized: $brief_file"
  echo "Session: $session_id"
}

brief_read() {
  local brief_file
  brief_file="$(brief_current_path)"
  if [ -f "$brief_file" ]; then
    cat "$brief_file"
  else
    return 1
  fi
}

brief_archive() {
  local brief_file state_file history_dir
  brief_file="$(brief_current_path)"
  state_file="$(brief_state_path)"
  history_dir="$(company_of_one_briefs_dir)/history"

  if [ ! -f "$brief_file" ]; then
    return 0
  fi

  mkdir -p "$history_dir"
  local date_str archive_name state_archive
  date_str="$(date +%Y-%m-%dT%H%M%S)"
  archive_name="${date_str}-$(company_of_one_session_id).md"
  state_archive="${date_str}-$(company_of_one_session_id).json"

  mv "$brief_file" "$history_dir/$archive_name"
  if [ -f "$state_file" ]; then
    STATUS="archived" \
      ARCHIVED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      STATE_FILE="$state_file" \
      python3 -c "
import json, os
path = os.environ['STATE_FILE']
with open(path) as f:
    data = json.load(f)
data['status'] = os.environ['STATUS']
data['archived_at'] = os.environ['ARCHIVED_AT']
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null
    mv "$state_file" "$history_dir/$state_archive"
  fi

  local active_file active_session
  active_file="$(company_of_one_active_session_file)"
  active_session="$(company_of_one_json_get_string "$active_file" session_id || true)"
  if [ "$active_session" = "$(company_of_one_session_id)" ]; then
    rm -f "$active_file"
  fi

  echo "Brief archived: $history_dir/$archive_name"
}

brief_check_budget() {
  local brief_file max_lines
  brief_file="$(brief_current_path)"
  max_lines="${1:-220}"

  if [ ! -f "$brief_file" ]; then
    echo "ERROR: no active BRIEF.md at $brief_file" >&2
    return 1
  fi

  local fail=0
  local line_count
  line_count="$(wc -l < "$brief_file" | tr -d ' ')"

  if [ "$line_count" -gt "$max_lines" ]; then
    echo "FAIL: BRIEF.md has $line_count lines; budget is $max_lines" >&2
    fail=1
  fi

  local duplicate_headings
  duplicate_headings="$(awk '/^#{2,3} / { count[$0]++ } END { for (h in count) if (count[h] > 1) print h }' "$brief_file")"
  if [ -n "$duplicate_headings" ]; then
    echo "FAIL: duplicate brief headings detected:" >&2
    echo "$duplicate_headings" >&2
    fail=1
  fi

  local missing_sections
  missing_sections="$(awk '
    BEGIN {
      required["## Brief Budget"] = 1
      required["## Feature"] = 1
      required["## Command"] = 1
      required["## Active Specs"] = 1
      required["## Relevant Memory"] = 1
      required["## Ignored Memory"] = 1
      required["## Assumptions"] = 1
      required["## Open Questions"] = 1
      required["## Current Contract"] = 1
      required["## Human-Owned Core"] = 1
    }
    /^## / { seen[$0] = 1 }
    END {
      for (section in required) {
        if (!(section in seen)) print section
      }
    }
  ' "$brief_file")"
  if [ -n "$missing_sections" ]; then
    echo "FAIL: required brief sections missing:" >&2
    echo "$missing_sections" >&2
    fail=1
  fi

  if grep -Eq '^```(diff|patch|console|terminal|log|text)?$|^diff --git |^\+\+\+ |^--- |^@@ |^\[[A-Z]+\] |^FAIL .* at ' "$brief_file"; then
    echo "FAIL: BRIEF.md appears to contain raw diff, log, or terminal evidence" >&2
    fail=1
  fi

  if grep -Eq '\{feature slug|\{path or "N/A"\}|\{list of ADR paths\}|\{short hashes|\{testable requirement\}|\{implementation approach|\{TODO item\}|\{memory item\}|\{explicit assumption|\{unresolved question|\{The exact behavior' "$brief_file"; then
    echo "FAIL: BRIEF.md still contains template placeholders" >&2
    fail=1
  fi

  if [ "$fail" -eq 0 ]; then
    echo "PASS: BRIEF.md within budget ($line_count/$max_lines lines)"
  else
    return 1
  fi
}

brief_cleanup_history() {
  local days="${1:-90}"
  local history_dir
  history_dir="$(company_of_one_briefs_dir)/history"

  if [ -d "$history_dir" ]; then
    find "$history_dir" -name "*.md" -mtime "+$days" -delete 2>/dev/null
    echo "Cleaned briefs older than $days days"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" && "${1:-}" != "" ]]; then
  cmd="$1"; shift
  case "$cmd" in
    init)     brief_init "$@" ;;
    read)     brief_read ;;
    path)     brief_current_path ;;
    state-path) brief_state_path ;;
    check-budget) brief_check_budget "$@" ;;
    archive)  brief_archive ;;
    cleanup)  brief_cleanup_history "$@" ;;
    *)        echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

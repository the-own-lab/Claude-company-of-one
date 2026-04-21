#!/usr/bin/env bash
# brief-manager.sh — Manage the v3 BRIEF.md lifecycle.
#
# v3: BRIEF is a Markdown file. Skills edit sections directly with the Edit tool;
# this script only handles init/read/archive/path. See ADR-001 D2 and
# templates/BRIEF.md for structure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"

brief_current_path() {
  echo "$(company_of_one_briefs_dir)/current.md"
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
  local brief_file template
  brief_file="$(brief_current_path)"
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

  echo "Brief initialized: $brief_file"
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
  local brief_file history_dir
  brief_file="$(brief_current_path)"
  history_dir="$(company_of_one_briefs_dir)/history"

  if [ ! -f "$brief_file" ]; then
    return 0
  fi

  mkdir -p "$history_dir"
  local date_str archive_name
  date_str="$(date +%Y-%m-%dT%H%M%S)"
  archive_name="${date_str}.md"

  mv "$brief_file" "$history_dir/$archive_name"
  echo "Brief archived: $history_dir/$archive_name"
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
    archive)  brief_archive ;;
    cleanup)  brief_cleanup_history "$@" ;;
    *)        echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

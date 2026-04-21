#!/usr/bin/env bash
# review-input.sh — Generate the evidence package the reviewer agent reads.
#
# Copies templates/REVIEW_INPUT.md into the spec dir, then fills the
# deterministic sections (Changed Files, Diff Summary line). The Main Agent
# must fill the narrative sections (review_mode, Known Deviations,
# Questions for Reviewer) before /review Layer 2 runs. See ADR-001 D4.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"
# shellcheck source=hooks/scripts/lib/diff-evidence.sh
. "$SCRIPT_DIR/diff-evidence.sh"

review_input_template_path() {
  local plugin_root
  plugin_root="$(company_of_one_plugin_root)"
  echo "$plugin_root/templates/REVIEW_INPUT.md"
}

review_input_generate() {
  # Usage: review_input_generate <spec_dir> <base_ref>
  local spec_dir="$1" base="${2:-main}"
  local template out
  template="$(review_input_template_path)"
  out="$spec_dir/REVIEW_INPUT.md"

  if [ ! -f "$template" ]; then
    echo "ERROR: template not found at $template" >&2
    return 1
  fi

  mkdir -p "$spec_dir"
  cp "$template" "$out"

  local changed_files diff_metrics
  changed_files="$(diff_evidence_files "$base")"
  diff_metrics="$(diff_evidence_summary "$base")"

  CHANGED_FILES="$changed_files" \
    perl -0pi -e 's/\{file list with \+\/- line counts\}/$ENV{CHANGED_FILES}/g' "$out"

  {
    echo ""
    echo "<!-- deterministic section appended by review-input.sh -->"
    echo "## Diff Metrics"
    echo ""
    echo '```'
    echo "$diff_metrics"
    echo '```'
  } >> "$out"

  echo "REVIEW_INPUT written: $out"
  echo "Main Agent must fill: review_mode, Known Deviations, Questions for Reviewer."
}

if [[ "${BASH_SOURCE[0]}" == "$0" && "${1:-}" != "" ]]; then
  cmd="$1"; shift
  case "$cmd" in
    generate) review_input_generate "$@" ;;
    *)        echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

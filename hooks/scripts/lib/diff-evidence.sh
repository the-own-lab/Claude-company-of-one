#!/usr/bin/env bash
# diff-evidence.sh — Produce a mechanical diff summary for REVIEW_INPUT.md.
#
# Output is deterministic: file list with +/- counts and a numstat block.
# No narrative; the Main Agent writes the Diff Summary paragraph in
# REVIEW_INPUT.md itself. See ADR-001 D5.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"

diff_evidence_files() {
  # Usage: diff_evidence_files <base_ref>
  local base="${1:-main}"
  diff_evidence_numstat_section "Committed since $base" git diff --numstat "$base"...HEAD
  diff_evidence_numstat_section "Staged" git diff --cached --numstat
  diff_evidence_numstat_section "Unstaged" git diff --numstat
  diff_evidence_numstat_section "Untracked" diff_evidence_untracked_numstat
}

diff_evidence_summary() {
  # Usage: diff_evidence_summary <base_ref>
  local base="${1:-main}"
  local added deleted files
  added=$(
    diff_evidence_all_numstat "$base" |
      awk '$1 ~ /^[0-9]+$/ { s += $1 } END { print s + 0 }'
  )
  deleted=$(
    diff_evidence_all_numstat "$base" |
      awk '$2 ~ /^[0-9]+$/ { s += $2 } END { print s + 0 }'
  )
  files=$(
    diff_evidence_all_numstat "$base" |
      awk 'NF >= 3 { files[$3] = 1 } END { for (f in files) count++; print count + 0 }'
  )
  echo "files=$files added=$added deleted=$deleted base=$base head=$(git rev-parse --short HEAD 2>/dev/null || echo '?')"
}

diff_evidence_all_numstat() {
  # Usage: diff_evidence_all_numstat <base_ref>
  local base="${1:-main}"
  {
    git diff --numstat "$base"...HEAD 2>/dev/null || true
    git diff --cached --numstat 2>/dev/null || true
    git diff --numstat 2>/dev/null || true
    diff_evidence_untracked_numstat
  }
}

diff_evidence_numstat_section() {
  local label="$1"
  shift
  echo "[$label]"
  { "$@" 2>/dev/null || true; } | awk '
    NF >= 3 { printf "%s (+%s / -%s)\n", $3, $1, $2; found = 1 }
    END { if (!found) print "(none)" }
  '
}

diff_evidence_untracked_numstat() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  git -C "$root" ls-files --others --exclude-standard |
    while IFS= read -r file; do
      if [ -f "$root/$file" ]; then
        local lines
        lines=$(wc -l < "$root/$file" | awk '{ print $1 + 0 }')
        printf "%s\t0\t%s\n" "$lines" "$file"
      fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "$0" && "${1:-}" != "" ]]; then
  cmd="$1"; shift
  case "$cmd" in
    files)    diff_evidence_files "$@" ;;
    summary)  diff_evidence_summary "$@" ;;
    *)        echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

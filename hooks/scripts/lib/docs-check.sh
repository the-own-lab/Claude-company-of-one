#!/usr/bin/env bash
# docs-check.sh — Deterministic documentation consistency checks.
#
# Run by Layer 1 (Spec Conformance) before any LLM-based review.
# Checks are mechanical: file existence, CHANGELOG touched, TODO checkbox
# consistency, frontmatter presence. Fail fast; do not call an LLM.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"

_fail=0
_note() { echo "  - $*"; }
_warn() { echo "WARN: $*"; }
_err()  { echo "FAIL: $*" >&2; _fail=1; }

check_required_files() {
  # Usage: check_required_files <spec_dir>
  local spec_dir="$1"
  echo "== required files =="
  for f in REQUIREMENTS.md DESIGN.md TODO.md; do
    if [ -f "$spec_dir/$f" ]; then
      _note "$f present"
    else
      _err "$spec_dir/$f missing"
    fi
  done
}

check_changelog_touched() {
  # Usage: check_changelog_touched <base_ref>
  local base="${1:-main}"
  echo "== CHANGELOG touched since $base =="
  if docs_check_changed_files "$base" | awk '/(^|\/)CHANGELOG\.md$/ { found = 1 } END { exit(found ? 0 : 1) }'; then
    _note "CHANGELOG modified"
  else
    _err "no CHANGELOG changes since $base"
  fi
}

check_todo_consistency() {
  # Usage: check_todo_consistency <todo_file>
  # Warns when a TODO checkbox is ticked but nothing in git diff references it.
  # This is a weak check — the LLM Layer 1 does the semantic match.
  local todo_file="$1" base="${2:-main}"
  echo "== TODO checkbox consistency =="

  if [ ! -f "$todo_file" ]; then
    _err "$todo_file missing"
    return
  fi

  local checked changes
  checked=$(awk '/^- \[x\] / { count++ } END { print count + 0 }' "$todo_file")
  changes=$(docs_check_changed_files "$base" | awk '!/^docs\// { count++ } END { print count + 0 }')

  if [ "$checked" -gt 0 ] && [ "$changes" -eq 0 ]; then
    _err "$checked TODO items checked but no non-docs file changes since $base"
  else
    _note "$checked checked TODO items, $changes non-docs files changed"
  fi
}

check_frontmatter() {
  # Usage: check_frontmatter <file> <required_key> [<required_key>...]
  local file="$1"; shift
  echo "== frontmatter for $(basename "$file") =="
  if [ ! -f "$file" ]; then
    _err "$file missing"
    return
  fi
  local missing=()
  for key in "$@"; do
    if ! head -20 "$file" | grep -q "^${key}:"; then
      missing+=("$key")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    _err "$(basename "$file") missing frontmatter keys: ${missing[*]}"
  else
    _note "all required keys present"
  fi
}

docs_check_run() {
  # Usage: docs_check_run <spec_dir> [<base_ref>]
  local spec_dir="$1" base="${2:-main}"
  check_required_files "$spec_dir"
  check_changelog_touched "$base"
  check_todo_consistency "$spec_dir/TODO.md" "$base"
  echo "== result =="
  if [ "$_fail" -eq 0 ]; then
    echo "PASS"
  else
    echo "FAIL"
    return 1
  fi
}

docs_check_run_spec() {
  # Usage: docs_check_run_spec <spec_dir>
  local spec_dir="$1"
  check_required_files "$spec_dir"
  echo "== result =="
  if [ "$_fail" -eq 0 ]; then
    echo "PASS"
  else
    echo "FAIL"
    return 1
  fi
}

docs_check_run_implementation() {
  # Usage: docs_check_run_implementation <spec_dir> [<base_ref>]
  docs_check_run "$@"
}

docs_check_changed_files() {
  # Usage: docs_check_changed_files <base_ref>
  local base="${1:-main}"
  {
    git diff --name-only "$base"...HEAD 2>/dev/null || true
    git diff --cached --name-only 2>/dev/null || true
    git diff --name-only 2>/dev/null || true
    docs_check_untracked_files
  } | awk 'NF { seen[$0] = 1 } END { for (file in seen) print file }'
}

docs_check_untracked_files() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  git -C "$root" ls-files --others --exclude-standard
}

if [[ "${BASH_SOURCE[0]}" == "$0" && "${1:-}" != "" ]]; then
  cmd="$1"; shift
  case "$cmd" in
    required)    check_required_files "$@" ;;
    changelog)   check_changelog_touched "$@" ;;
    todo)        check_todo_consistency "$@" ;;
    frontmatter) check_frontmatter "$@" ;;
    run)         docs_check_run "$@" ;;
    run-spec)    docs_check_run_spec "$@" ;;
    run-impl)    docs_check_run_implementation "$@" ;;
    *)           echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

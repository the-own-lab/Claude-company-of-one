#!/usr/bin/env bash
# spec-conformance-check.sh — Deterministic portion of /review Layer 1.
#
# Runs cheap, mechanical checks. If any FAIL, /review Layer 1 hard-blocks
# and Layer 2 (Red Team) does not run. The remaining Layer 1 checks
# (REQ acceptance criteria mapping, DESIGN↔impl drift) are LLM-driven and
# live in the `spec-conformance` skill. See ADR-001 D4 and D5.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/common.sh"
# shellcheck source=hooks/scripts/lib/docs-check.sh
. "$SCRIPT_DIR/docs-check.sh"
# shellcheck source=hooks/scripts/lib/brief-manager.sh
. "$SCRIPT_DIR/brief-manager.sh"

_fail=0
_err() { echo "FAIL: $*" >&2; _fail=1; }
_ok()  { echo "OK:   $*"; }

check_review_input_present() {
  local spec_dir="$1"
  if [ -f "$spec_dir/REVIEW_INPUT.md" ]; then
    _ok "REVIEW_INPUT.md present"
  else
    _err "REVIEW_INPUT.md missing in $spec_dir"
  fi
}

check_review_mode_set() {
  local spec_dir="$1"
  if ! review_mode_read "$spec_dir" >/dev/null; then
    _err "REVIEW_INPUT.md missing — cannot verify review_mode"
    return
  fi
  if [ -n "$(review_mode_read "$spec_dir")" ]; then
    _ok "review_mode set"
  else
    _err "review_mode not set to spec|implementation in REVIEW_INPUT.md"
  fi
}

review_mode_read() {
  local spec_dir="$1"
  local file="$spec_dir/REVIEW_INPUT.md"
  if [ ! -f "$file" ]; then
    return 1
  fi

  awk '
    /review_mode:/ {
      line = $0
      gsub(/`/, "", line)
      sub(/^.*review_mode:[[:space:]]*/, "", line)
      sub(/[[:space:]]*#.*/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (line == "spec" || line == "implementation") {
        print line
        exit
      }
    }
  ' "$file"
}

check_brief_present() {
  local brief_file
  brief_file="$(brief_current_path)"
  if [ -f "$brief_file" ]; then
    _ok "active BRIEF.md present"
  else
    _err "no active BRIEF.md at $brief_file"
  fi
}

check_human_owned_core_filled() {
  # ADR-002 D2: every Human-Owned Core item must have User prediction and
  # User selected option filled before /dev Execute. Empty template placeholders
  # are flagged as FAIL.
  local brief_file
  brief_file="$(brief_current_path)"
  if [ ! -f "$brief_file" ]; then
    _err "no BRIEF.md — cannot verify Human-Owned Core"
    return
  fi

  if ! grep -q "^## Human-Owned Core" "$brief_file"; then
    _ok "no Human-Owned Core section (no core items declared)"
    return
  fi

  # Check for placeholder strings in prediction/option fields
  local bad
  bad=$(awk '
    /^### Core Item/ { in_item=1; name=$0 }
    in_item && /^- User prediction:[[:space:]]*$/ { print name ": prediction empty"; }
    in_item && /^- User selected option:[[:space:]]*$/ { print name ": selected option empty"; }
    in_item && /<!-- required before Execute -->/ { print name ": placeholder comment still present"; }
  ' "$brief_file")

  if [ -n "$bad" ]; then
    _fail=1
    while IFS= read -r line; do
      echo "FAIL: $line" >&2
    done <<< "$bad"
  else
    _ok "Human-Owned Core prediction/option fields filled"
  fi
}

check_ignored_memory_declared() {
  # ADR-001 D3: Ignored Memory section must exist and be non-empty.
  local brief_file
  brief_file="$(brief_current_path)"
  if [ ! -f "$brief_file" ]; then
    _err "no BRIEF.md — cannot verify Ignored Memory"
    return
  fi

  local ignored_section
  ignored_section=$(awk '
    /^## Ignored Memory/ { capture=1; next }
    /^## / && capture { exit }
    capture { print }
  ' "$brief_file")

  if [ -z "$ignored_section" ]; then
    _err "Ignored Memory section empty; D3 requires explicit declaration"
    return
  fi

  if echo "$ignored_section" | grep -Eq '\{memory item\}|ignored:stale \| ignored:unrelated'; then
    _err "Ignored Memory section still contains template placeholders"
    return
  fi

  if echo "$ignored_section" | grep -Eq 'No ignored memory entries; every loaded memory item is used\.|`ignored:(stale|unrelated|contradicted-by-spec|out-of-scope)`'; then
    _ok "Ignored Memory section declared"
  else
    _err "Ignored Memory section must use one of the ADR-001 D3 reason codes"
  fi
}

spec_conformance_pre_execute() {
  # Checks before /dev Execute step.
  check_brief_present
  brief_check_budget || _fail=1
  check_ignored_memory_declared
  check_human_owned_core_filled
  echo "== result =="
  if [ "$_fail" -eq 0 ]; then echo "PASS"; else echo "FAIL"; return 1; fi
}

spec_conformance_pre_review() {
  # Checks before /review Layer 2 runs.
  # Usage: spec_conformance_pre_review <spec_dir> [<base_ref>]
  local spec_dir="$1" base="${2:-main}"
  local review_mode
  check_review_input_present "$spec_dir"
  check_review_mode_set "$spec_dir"
  review_mode="$(review_mode_read "$spec_dir" || true)"

  case "$review_mode" in
    spec)
      docs_check_run_spec "$spec_dir" || _fail=1
      ;;
    implementation)
      docs_check_run_implementation "$spec_dir" "$base" || _fail=1
      ;;
    *)
      _fail=1
      ;;
  esac

  echo "== result =="
  if [ "$_fail" -eq 0 ]; then echo "PASS"; else echo "FAIL"; return 1; fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" && "${1:-}" != "" ]]; then
  cmd="$1"; shift
  case "$cmd" in
    pre-execute) spec_conformance_pre_execute ;;
    pre-review)  spec_conformance_pre_review "$@" ;;
    *)           echo "Unknown command: $cmd" >&2; exit 1 ;;
  esac
fi

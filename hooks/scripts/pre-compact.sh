#!/usr/bin/env bash
# Pre-Compact Hook — Claude 一人公司 v3
# BRIEF.md is already persisted on disk, so there is nothing to dump here.
# This hook only reminds the session that the brief is the source of truth
# and will be restored by post-compact.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

SESSION_DIR="$(company_of_one_session_dir)"
BRIEF_PATH="$SESSION_DIR/BRIEF.md"
mkdir -p "$SESSION_DIR"

if [ -f "$BRIEF_PATH" ]; then
  echo "Pre-compact: active brief pointer at $BRIEF_PATH will be restored after compaction."
else
  echo "Pre-compact: no active brief."
fi

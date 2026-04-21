#!/usr/bin/env bash
# Pre-Compact Hook — Claude 一人公司 v3
# BRIEF.md is already persisted on disk, so there is nothing to dump here.
# This hook only reminds the session that the brief is the source of truth
# and will be restored by post-compact.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

PROJECT_DIR="$(company_of_one_project_dir)"
mkdir -p "$PROJECT_DIR"

if [ -f "$PROJECT_DIR/briefs/current.md" ]; then
  echo "Pre-compact: active brief at $PROJECT_DIR/briefs/current.md will be restored after compaction."
else
  echo "Pre-compact: no active brief."
fi

#!/usr/bin/env bash
# Post-Compact Hook — Claude 一人公司 v3
# Restore BRIEF.md so the session resumes on the same contract.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

PROJECT_DIR="$(company_of_one_project_dir)"

if [ -f "$PROJECT_DIR/briefs/current.md" ]; then
  echo "## Active Brief Restored"
  cat "$PROJECT_DIR/briefs/current.md"
  echo ""
  echo "Resume from Current Contract. Skills read only this file."
fi

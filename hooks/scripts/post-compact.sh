#!/usr/bin/env bash
# Post-Compact Hook — Claude 一人公司 v3
# Restore BRIEF.md so the session resumes on the same contract.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=hooks/scripts/lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

SESSION_DIR="$(company_of_one_session_dir)"
BRIEF_PATH="$SESSION_DIR/BRIEF.md"
STATE_PATH="$SESSION_DIR/CURRENT.json"

if [ -f "$BRIEF_PATH" ]; then
  echo "## Active Brief Pointer Restored"
  echo "Session: $(company_of_one_session_id)"
  echo "Brief: $BRIEF_PATH"
  if [ -f "$STATE_PATH" ]; then
    echo "State: $STATE_PATH"
  fi
  echo "Resume by reading this brief only when the command needs it."
fi

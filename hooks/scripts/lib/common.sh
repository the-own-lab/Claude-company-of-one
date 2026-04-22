#!/usr/bin/env bash

company_of_one_plugin_id() {
  echo "claude-company-of-one"
}

company_of_one_platform() {
  if [ -n "${COMPANY_OF_ONE_PLATFORM:-}" ]; then
    echo "$COMPANY_OF_ONE_PLATFORM"
    return
  fi

  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] || [ -n "${CLAUDE_PLUGIN_DATA:-}" ]; then
    echo "claude"
    return
  fi

  if [ -n "${CODEX_PLUGIN_ROOT:-}" ] || [ -n "${CODEX_PLUGIN_DATA:-}" ]; then
    echo "codex"
    return
  fi

  echo "shared"
}

company_of_one_runtime_label() {
  case "$(company_of_one_platform)" in
    claude)
      echo "Claude Code"
      ;;
    codex)
      echo "Codex"
      ;;
    *)
      echo "the current coding runtime"
      ;;
  esac
}

company_of_one_plugin_root() {
  if [ -n "${COMPANY_OF_ONE_PLUGIN_ROOT:-}" ]; then
    echo "$COMPANY_OF_ONE_PLUGIN_ROOT"
    return
  fi

  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    echo "$CLAUDE_PLUGIN_ROOT"
    return
  fi

  if [ -n "${CODEX_PLUGIN_ROOT:-}" ]; then
    echo "$CODEX_PLUGIN_ROOT"
    return
  fi

  local common_dir
  common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  dirname "$(dirname "$(dirname "$common_dir")")"
}

company_of_one_default_data_dir() {
  local plugin_id
  plugin_id="$(company_of_one_plugin_id)"

  case "$(company_of_one_platform)" in
    claude)
      echo "$HOME/.claude/plugin-data/$plugin_id"
      ;;
    codex)
      echo "$HOME/.codex/plugin-data/$plugin_id"
      ;;
    *)
      echo "$HOME/.company-of-one/plugin-data/$plugin_id"
      ;;
  esac
}

company_of_one_plugin_data() {
  if [ -n "${COMPANY_OF_ONE_PLUGIN_DATA:-}" ]; then
    echo "$COMPANY_OF_ONE_PLUGIN_DATA"
    return
  fi

  if [ -n "${CLAUDE_PLUGIN_DATA:-}" ]; then
    echo "$CLAUDE_PLUGIN_DATA"
    return
  fi

  if [ -n "${CODEX_PLUGIN_DATA:-}" ]; then
    echo "$CODEX_PLUGIN_DATA"
    return
  fi

  company_of_one_default_data_dir
}

company_of_one_project_key() {
  # Generate a human-readable + unique project key: slug-shorthash
  # e.g., 112-claude-company-of-one-a1b2c3d4
  local root slug hash
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  slug="$(basename "$root" | tr '[:upper:]' '[:lower:]')"
  hash="$(printf '%s' "$root" | shasum -a 256 | cut -c1-8)"
  echo "${slug}-${hash}"
}

company_of_one_project_dir() {
  # Per-project data directory under plugin data
  echo "$(company_of_one_plugin_data)/projects/$(company_of_one_project_key)"
}

company_of_one_briefs_dir() {
  echo "$(company_of_one_project_dir)/briefs"
}

company_of_one_sessions_dir() {
  echo "$(company_of_one_project_dir)/sessions"
}

company_of_one_slug() {
  tr -cs '[:alnum:]_.-' '-' | sed 's/^-//; s/-$//'
}

company_of_one_session_hint() {
  if [ -n "${COMPANY_OF_ONE_SESSION_ID:-}" ]; then
    printf '%s' "$COMPANY_OF_ONE_SESSION_ID" | company_of_one_slug
    return
  fi

  if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
    printf '%s' "$CLAUDE_SESSION_ID" | company_of_one_slug
    return
  fi

  if [ -n "${CODEX_SESSION_ID:-}" ]; then
    printf '%s' "$CODEX_SESSION_ID" | company_of_one_slug
    return
  fi

  local tty_path
  tty_path="$(tty 2>/dev/null || true)"
  if [ -n "$tty_path" ] && [ "$tty_path" != "not a tty" ]; then
    printf 'tty-%s' "$(printf '%s' "$tty_path" | shasum -a 256 | cut -c1-12)"
    return
  fi

  echo "shared"
}

company_of_one_active_session_file() {
  echo "$(company_of_one_project_dir)/sessions/.active/$(company_of_one_session_hint).json"
}

company_of_one_json_get_string() {
  local file="$1" key="$2"
  python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    sys.exit(1)
value = data.get(sys.argv[2])
if isinstance(value, str):
    print(value)
else:
    sys.exit(1)
" "$file" "$key" 2>/dev/null
}

company_of_one_new_session_id() {
  local now hash
  now="$(date -u +%Y%m%dT%H%M%SZ)"
  hash="$(printf '%s:%s:%s' "$now" "$$" "$(pwd)" | shasum -a 256 | cut -c1-8)"
  echo "session-$now-$hash"
}

company_of_one_session_id() {
  local hint active_file session_id brief_path
  hint="$(company_of_one_session_hint)"

  case "$hint" in
    shared | tty-*) ;;
    *)
      echo "$hint"
      return
      ;;
  esac

  active_file="$(company_of_one_active_session_file)"
  session_id="$(company_of_one_json_get_string "$active_file" session_id || true)"
  brief_path="$(company_of_one_json_get_string "$active_file" brief_path || true)"
  if [ -n "$session_id" ] && [ -f "$brief_path" ]; then
    echo "$session_id"
    return
  fi

  echo "$hint"
}

company_of_one_session_dir() {
  echo "$(company_of_one_sessions_dir)/$(company_of_one_session_id)"
}

company_of_one_write_active_session() {
  local session_id="$1" brief_file="$2"
  local active_file
  active_file="$(company_of_one_active_session_file)"
  mkdir -p "$(dirname "$active_file")"

  SESSION_ID="$session_id" \
    BRIEF_FILE="$brief_file" \
    UPDATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    python3 -c "
import json, os
data = {
    'session_id': os.environ['SESSION_ID'],
    'brief_path': os.environ['BRIEF_FILE'],
    'updated_at': os.environ['UPDATED_AT'],
}
with open('$active_file', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
" 2>/dev/null
}

company_of_one_legacy_brief_path() {
  echo "$(company_of_one_briefs_dir)/current.md"
}

# v3 drift guard: specs and ADRs live in docs/projects/<project>/ in the
# monorepo, not under plugin-data. No plugin-data specs dir. No patterns dir
# (v2 learn/pattern-index removed — see ADR-001 D5).
company_of_one_init_storage() {
  local project_dir
  project_dir="$(company_of_one_project_dir)"
  mkdir -p "$project_dir/briefs/history" "$project_dir/sessions/.active"

  company_of_one_update_project_index
}

company_of_one_update_project_index() {
  local plugin_data project_key root now index_file
  plugin_data="$(company_of_one_plugin_data)"
  project_key="$(company_of_one_project_key)"
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  now="$(date +%Y-%m-%d)"
  index_file="$plugin_data/projects/.index.json"

  mkdir -p "$plugin_data/projects"

  python3 -c "
import json, os
index_path = '$index_file'
try:
    with open(index_path) as f:
        index = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    index = {}
index['$project_key'] = {
    'path': '$root',
    'lastActive': '$now'
}
with open(index_path, 'w') as f:
    json.dump(index, f, indent=2)
" 2>/dev/null
}

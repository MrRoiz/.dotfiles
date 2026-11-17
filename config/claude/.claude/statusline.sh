#!/usr/bin/env bash
# Claude Code status line: project, git branch, model and effort, and the
# plan. Reads the session JSON on stdin and prints one line.
# Colors are ANSI names, so the active Omarchy theme's terminal palette paints
# them.
set -euo pipefail

# Claude keeps the account profile in ~/.claude.json unless CLAUDE_CONFIG_DIR
# moves it (the claude-work alias does).
readonly ACCOUNT_FILE="${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json"

readonly RESET=$'\e[0m'
readonly DIM=$'\e[2m'
readonly GREEN=$'\e[32m'
readonly BLUE=$'\e[34m'
readonly MAGENTA=$'\e[35m'
readonly CYAN=$'\e[36m'
readonly SEPARATOR="${DIM} │ ${RESET}"
# Nerd Font git branch glyph, the same one the starship prompt uses.
readonly BRANCH_ICON=""

main() {
  local session
  session=$(cat)

  local project_dir current_dir branch model effort plan
  project_dir=$(read_field "$session" '.workspace.project_dir')
  current_dir=$(read_field "$session" '.workspace.current_dir')
  branch=$(read_branch "$current_dir")
  model=$(read_field "$session" '.model.display_name')
  effort=$(read_field "$session" '.effort.level')
  plan=$(read_plan)

  local line="${BLUE}${project_dir##*/}${RESET}${branch:+ ${GREEN}${BRANCH_ICON} ${branch}${RESET}}"
  line+="${SEPARATOR}${CYAN}${model}${RESET}${effort:+ ${DIM}${effort}${RESET}}"
  if [[ -n $plan ]]; then
    line+="${SEPARATOR}${MAGENTA}${plan}${RESET}"
  fi
  printf '%s\n' "$line"
}

# Prints the jq path's value from the session JSON, or nothing when absent.
read_field() {
  local session=$1
  local path=$2
  jq -r "($path) // empty" <<<"$session"
}

# Prints the branch checked out in the directory, or nothing outside a repo
# or on a detached HEAD. --no-optional-locks keeps it from contending with a
# git command running in the session.
read_branch() {
  local directory=$1
  git --no-optional-locks -C "$directory" branch --show-current 2>/dev/null || true
}

# Prints the plan from the account profile, e.g. "Pro" or "Team · Max 5x".
# Prints nothing for API-key logins, which have no profile.
read_plan() {
  if [[ ! -r $ACCOUNT_FILE ]]; then
    return 0
  fi

  jq -r '
    .oauthAccount // {}
    | [
        (.organizationType // empty
          | sub("^claude_"; "")
          | (.[0:1] | ascii_upcase) + .[1:]),
        (.userRateLimitTier // empty
          | capture("max_(?<multiplier>[0-9]+x)")
          | "Max \(.multiplier)")
      ]
    | join(" · ")
  ' "$ACCOUNT_FILE"
}

main

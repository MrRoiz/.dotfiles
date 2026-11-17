#!/usr/bin/env bash
# Search omacom/omarchy issues and pull requests for a suspected gap.
# Usage: search-upstream.sh [--state open|closed] [--limit 1-1000] <search terms>
set -uo pipefail

repo=${REPO:-omacom/omarchy}
state=""
limit=20
query_parts=()

usage() {
  echo "usage: search-upstream.sh [--state open|closed] [--limit 1-1000] <search terms>"
}

while (( $# )); do
  case $1 in
    --state)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      state=$2
      shift 2
      ;;
    --limit)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      limit=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      query_parts+=("$@")
      break
      ;;
    -*)
      echo "search-upstream: unknown option $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      query_parts+=("$1")
      shift
      ;;
  esac
done

(( ${#query_parts[@]} )) || { usage >&2; exit 2; }
query="${query_parts[*]}"

[[ $state =~ ^(open|closed)?$ ]] || { echo "search-upstream: --state must be open or closed" >&2; exit 2; }
if ! [[ $limit =~ ^[0-9]+$ ]] || (( limit < 1 || limit > 1000 )); then
  echo "search-upstream: --limit must be between 1 and 1000" >&2
  exit 2
fi

command -v gh >/dev/null || { echo "search-upstream: gh is not installed" >&2; exit 1; }
command -v jq >/dev/null || { echo "search-upstream: jq is not installed" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "search-upstream: gh is not authenticated" >&2; exit 1; }
gh repo view "$repo" >/dev/null 2>&1 || { echo "search-upstream: cannot read repo $repo" >&2; exit 1; }

tmpdir=$(mktemp -d) || { echo "search-upstream: could not create a temp directory" >&2; exit 1; }
trap 'rm -rf "$tmpdir"' EXIT

state_args=()
[[ -n $state ]] && state_args=(--state "$state")
failed=0

show() { # <kind> <json>
  local kind=$1 json=$2
  if [[ $json == "[]" ]]; then
    echo "(no matches)"
    return 0
  fi
  jq -r '.[] | "#\(.number)  \(.state)  \(.title)  (updated \(.updatedAt))\n  \(.url)"' <<<"$json" ||
    { echo "search-upstream: could not parse $kind results" >&2; return 1; }
}

printf 'Issues in %s%s for: %s\n\n' "$repo" "${state:+ (state: $state)}" "$query"
if issues=$(gh search issues --repo "$repo" "${state_args[@]}" "$query" --limit "$limit" \
  --json number,state,title,updatedAt,url 2>"$tmpdir/issues.err"); then
  [[ -s $tmpdir/issues.err ]] && cat "$tmpdir/issues.err" >&2
  show issues "$issues" || failed=1
else
  echo "issues search failed: $(cat "$tmpdir/issues.err")" >&2
  echo "(search failed)"
  failed=1
fi

printf '\nPull requests in %s%s for: %s\n\n' "$repo" "${state:+ (state: $state)}" "$query"
if prs=$(gh search prs --repo "$repo" "${state_args[@]}" "$query" --limit "$limit" \
  --json number,state,title,updatedAt,url 2>"$tmpdir/prs.err"); then
  [[ -s $tmpdir/prs.err ]] && cat "$tmpdir/prs.err" >&2
  show prs "$prs" || failed=1
else
  echo "pull request search failed: $(cat "$tmpdir/prs.err")" >&2
  echo "(search failed)"
  failed=1
fi

exit "$failed"

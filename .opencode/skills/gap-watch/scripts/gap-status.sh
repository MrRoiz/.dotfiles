#!/usr/bin/env bash
# Report upstream status for every #ref cited in KNOWN-GAPS.md.
set -uo pipefail

REPO=${REPO:-omacom/omarchy}

skill_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
repo_root=$(git -C "$skill_dir" rev-parse --show-toplevel 2>/dev/null || true)
file=${GAPS_FILE:-${repo_root:-$skill_dir}/KNOWN-GAPS.md}

[[ -f $file ]] || { echo "gap-status: $file not found" >&2; exit 1; }
command -v gh >/dev/null || { echo "gap-status: gh is not installed" >&2; exit 1; }
command -v jq >/dev/null || { echo "gap-status: jq is not installed" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gap-status: gh is not authenticated" >&2; exit 1; }

installed=$(pacman -Q omarchy 2>/dev/null || echo "omarchy not installed")
channel=$(omarchy-channel-current 2>/dev/null || echo unknown)
installed_tag=""
if [[ $installed =~ ^omarchy\ ([^ ]+)-[0-9]+$ ]]; then
  installed_tag="v${BASH_REMATCH[1]}"
fi

releases=$(gh release list --repo "$REPO" --limit 30 --json tagName,isPrerelease,publishedAt 2>/dev/null || echo '[]')
stable_tag=$(jq -r '[.[] | select(.isPrerelease == false)] | sort_by(.publishedAt) | last | .tagName // empty' <<<"$releases")
rc_tag=$(jq -r '[.[] | select(.isPrerelease == true)] | sort_by(.publishedAt) | last | .tagName // empty' <<<"$releases")

echo "Gap watch - $(date +%F)"
echo "Installed: $installed (channel: $channel${installed_tag:+, tag $installed_tag})"
echo "Latest stable: ${stable_tag:-unknown}"
echo "Latest prerelease: ${rc_tag:-unknown}"
echo

refs=$(grep -oE '(omacom/omarchy/(issues|pull)/[0-9]+|#[0-9]+)' "$file" | grep -oE '[0-9]+' | sort -un)
[[ -n $refs ]] || { echo "No upstream refs found in $file"; exit 0; }

tag_state() { # <sha> <tag> -> yes | no | unknown
  local status
  status=$(gh api "repos/$REPO/compare/$1...$2" --jq .status 2>/dev/null) || { echo unknown; return; }
  case $status in
    ahead | identical) echo yes ;;
    behind | diverged) echo no ;;
    *) echo unknown ;;
  esac
}

for n in $refs; do
  issue=$(gh api "repos/$REPO/issues/$n" 2>/dev/null) || { echo "#$n: not found"; echo; continue; }
  title=$(jq -r '.title' <<<"$issue")
  state=$(jq -r '.state' <<<"$issue")
  is_pr=$(jq -r 'has("pull_request")' <<<"$issue")

  if [[ $is_pr == true ]]; then
    pr=$(gh pr view "$n" --repo "$REPO" --json mergedAt,mergeCommit --jq '{mergedAt, sha: .mergeCommit.oid}' 2>/dev/null || echo '{}')
    merged=$(jq -r '.mergedAt // empty' <<<"$pr")
    sha=$(jq -r '.sha // empty' <<<"$pr")
    [[ -n $merged ]] && state=MERGED
    echo "#$n  PR  ${state^^}  $title"
    if [[ -n $merged && -n $sha ]]; then
      echo "  merged $merged  ${sha:0:10}"
      tags=()
      for tag in "$stable_tag" "$rc_tag" "$installed_tag"; do
        [[ -n $tag ]] || continue
        [[ " ${tags[*]-} " == *" $tag "* ]] && continue
        tags+=("$tag")
        echo "  in $tag: $(tag_state "$sha" "$tag")"
      done
    fi
  else
    reason=$(jq -r '.state_reason // empty' <<<"$issue")
    echo "#$n  issue  ${state^^}  $title"
    [[ -n $reason ]] && echo "  reason: $reason"
  fi
  echo
done

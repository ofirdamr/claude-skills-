#!/usr/bin/env bash
# sync-upstream.sh — send local edits to an installed claude-skills- plugin
# back upstream as a draft PR. Two commands, nothing else to know:
#
#   sync-upstream.sh          show what would be synced (safe, no writes)
#   sync-upstream.sh confirm  commit, push, open the draft PR
#
# Everything else — finding the local clone, naming the branch, writing the
# commit/PR message, forking if needed — is automatic.

set -euo pipefail

REPO="${SYNC_UPSTREAM_REPO:-ofirdamr/claude-skills-}"
BASE="${SYNC_UPSTREAM_BASE:-main}"

find_marketplace_dir() {
  local root="$HOME/.claude/plugins/marketplaces"
  local dir
  if [ -d "$root" ]; then
    for dir in "$root"/*/; do
      [ -d "${dir}.git" ] || continue
      if git -C "$dir" remote get-url origin 2>/dev/null | grep -q "$REPO"; then
        printf '%s\n' "${dir%/}"
        return 0
      fi
    done
  fi
  echo "Claude-skills isn't installed here. Run: /plugin marketplace add $REPO" >&2
  exit 1
}

dir="$(find_marketplace_dir)"
cd "$dir"
git fetch origin "$BASE" --quiet

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to sync — no local edits."
  exit 0
fi

files="$(git status --porcelain | awk '{print $2}' | tr '\n' ' ')"

if [ "${1:-}" != "confirm" ]; then
  echo "Local edits found:"
  git status --porcelain
  echo
  git diff HEAD
  echo
  echo "Run 'sync-upstream.sh confirm' to open a draft PR with these changes."
  exit 0
fi

command -v gh >/dev/null 2>&1 || {
  echo "gh CLI not found — install it and log in (gh auth login), then retry." >&2
  exit 1
}

branch="sync/$(date +%Y%m%d%H%M%S)"
git checkout -b "$branch"
git add -A
git commit -m "Update: $files"

if ! git rebase "origin/$BASE"; then
  git rebase --abort
  echo "Your edit conflicts with the latest upstream — resolve manually in $dir." >&2
  exit 1
fi

title="Update: $files"
body="Synced local skill edits via sync-upstream."

if [ "$(gh api "repos/$REPO" --jq '.permissions.push' 2>/dev/null || echo false)" = "true" ]; then
  git push -u origin "$branch"
  gh pr create --repo "$REPO" --base "$BASE" --head "$branch" \
    --draft --title "$title" --body "$body"
else
  gh repo fork "$REPO" --remote=true --remote-name=fork --clone=false >/dev/null
  git push -u fork "$branch"
  owner="$(gh api user --jq '.login')"
  gh pr create --repo "$REPO" --base "$BASE" --head "${owner}:${branch}" \
    --draft --title "$title" --body "$body"
fi

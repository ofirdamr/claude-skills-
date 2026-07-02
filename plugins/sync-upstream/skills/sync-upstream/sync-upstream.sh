#!/usr/bin/env bash
# sync-upstream.sh — turn local edits to an installed claude-skills- plugin
# into a pull request against the source repo.
#
# Usage:
#   sync-upstream.sh status
#       Read-only. Locates the local marketplace clone, fetches the base
#       branch, and prints ahead/behind counts + the pending diff. Makes no
#       commits, pushes, or PRs. Always run this first.
#
#   sync-upstream.sh submit <branch-slug> "<commit message>" ["<pr title>"] ["<pr body>"]
#       Commits the pending changes on a new branch, rebases onto the latest
#       base branch, pushes (to origin if the caller has write access,
#       otherwise to their own fork), and opens a draft PR via `gh`.
#
# Env overrides:
#   SYNC_UPSTREAM_REPO   owner/repo to sync against (default: ofirdamr/claude-skills-)
#   SYNC_UPSTREAM_BASE   base branch (default: main)

set -euo pipefail

REPO="${SYNC_UPSTREAM_REPO:-ofirdamr/claude-skills-}"
BASE="${SYNC_UPSTREAM_BASE:-main}"

find_marketplace_dir() {
  local root="$HOME/.claude/plugins/marketplaces"
  if [ ! -d "$root" ]; then
    echo "No marketplace clones found at $root" >&2
    return 1
  fi
  local dir url
  for dir in "$root"/*/; do
    [ -d "${dir}.git" ] || continue
    url="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
    if [[ "$url" == *"$REPO"* ]]; then
      printf '%s\n' "${dir%/}"
      return 0
    fi
  done
  echo "No local clone of $REPO found under $root — add it first with: /plugin marketplace add $REPO" >&2
  return 1
}

cmd_status() {
  local dir
  dir="$(find_marketplace_dir)"
  echo "marketplace dir: $dir"

  git -C "$dir" fetch origin "$BASE" --quiet

  echo "--- vs origin/$BASE ---"
  git -C "$dir" rev-list --left-right --count "origin/$BASE...HEAD" \
    | awk '{print "behind="$1, "ahead="$2}'

  echo "--- local changes ---"
  if [ -z "$(git -C "$dir" status --porcelain)" ]; then
    echo "(clean — nothing to sync)"
    return 0
  fi
  git -C "$dir" status --porcelain
  echo "--- diff ---"
  git -C "$dir" diff --stat HEAD
}

cmd_submit() {
  local slug="${1:?branch slug required}"
  local msg="${2:?commit message required}"
  local title="${3:-$msg}"
  local body="${4:-Synced local skill edits via sync-upstream.}"

  command -v gh >/dev/null 2>&1 || {
    echo "gh CLI not found. Install it (https://cli.github.com) or push/open the PR manually." >&2
    exit 1
  }

  local dir
  dir="$(find_marketplace_dir)"
  cd "$dir"

  if [ -z "$(git status --porcelain)" ]; then
    echo "Nothing to sync — working tree is clean." >&2
    exit 1
  fi

  git fetch origin "$BASE" --quiet

  local branch="sync/${slug}-$(date +%Y%m%d%H%M%S)"
  git checkout -b "$branch"
  git add -A
  git commit -m "$msg"

  if ! git rebase "origin/$BASE"; then
    git rebase --abort
    echo "Rebase onto origin/$BASE hit conflicts — resolve manually in $dir and rerun." >&2
    exit 1
  fi

  local can_push
  can_push="$(gh api "repos/$REPO" --jq '.permissions.push' 2>/dev/null || echo false)"

  local pr_url
  if [ "$can_push" = "true" ]; then
    git push -u origin "$branch"
    pr_url="$(gh pr create --repo "$REPO" --base "$BASE" --head "$branch" \
      --draft --title "$title" --body "$body")"
  else
    gh repo fork "$REPO" --remote=true --remote-name=fork --clone=false >/dev/null
    git push -u fork "$branch"
    local fork_owner
    fork_owner="$(gh api user --jq '.login')"
    pr_url="$(gh pr create --repo "$REPO" --base "$BASE" --head "${fork_owner}:${branch}" \
      --draft --title "$title" --body "$body")"
  fi

  echo "$pr_url"
}

case "${1:-}" in
  status) shift; cmd_status "$@" ;;
  submit) shift; cmd_submit "$@" ;;
  *)
    echo "Usage: $0 status | submit <branch-slug> \"<commit message>\" [\"<pr title>\"] [\"<pr body>\"]" >&2
    exit 1
    ;;
esac

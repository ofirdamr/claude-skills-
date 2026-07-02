---
name: sync-upstream
description: >-
  Use when the user wants to send local edits they made to an installed
  claude-skills- plugin/skill back to the source repo (ofirdamr/claude-skills-)
  as a pull request — "sync my changes back", "contribute this upstream",
  "send this skill edit as a PR", "auto sync my skill", "propose this change
  to the maintainer". Locates the local marketplace git clone, shows the
  pending diff, and (after confirmation) opens a draft PR for the maintainer
  to review and merge.
---

# Sync Upstream

Turns a user's local edits to an installed `claude-skills-` plugin into a
draft pull request against `ofirdamr/claude-skills-`, so the maintainer can
just review and click merge. Driven by `sync-upstream.sh` in this skill
folder — do not reimplement the git/gh logic inline, call the script.

## Where edits must live

Claude Code copies plugin files into a read-only-ish cache
(`~/.claude/plugins/cache/...`) that gets overwritten on update — edits made
there don't stick and can't be diffed. The durable, diffable copy is the
**marketplace clone** at `~/.claude/plugins/marketplaces/<name>/`, which is a
real git repo. If the user hasn't edited files there, tell them to make (or
move) their edit into that clone first, then re-run this skill.

## Steps

1. **Status first, always.** Run:
   ```
   bash <skill-dir>/sync-upstream.sh status
   ```
   This is read-only: it finds the marketplace clone, fetches `origin/main`,
   and prints ahead/behind counts plus the pending diff. If it reports
   "nothing to sync" or can't find a clone, stop and tell the user why
   (no local clone found, or working tree is clean).

2. **Show the diff, get explicit confirmation.** Opening a PR is a
   visible-to-others action — summarize what changed (files + intent) and
   get a clear go-ahead before doing anything that writes or pushes.
   Never submit silently just because a diff exists.

3. **Write a real commit message and PR title/body** from the actual diff
   (what changed and why), not a generic placeholder. Pick a short branch
   slug (kebab-case, e.g. `fix-rtl-typo`).

4. **Submit** once confirmed:
   ```
   bash <skill-dir>/sync-upstream.sh submit "<slug>" "<commit message>" "<PR title>" "<PR body>"
   ```
   The script rebases onto the latest base branch, pushes to `origin` if the
   user has write access, otherwise forks and pushes there, then opens a
   **draft** PR via `gh` and prints the PR URL. If it reports a rebase
   conflict, stop and let the user resolve it manually in the marketplace
   clone — don't force-push or auto-resolve.

5. **Report the PR URL back to the user.** Do not merge it yourself; that's
   the maintainer's call.

## Guardrails

- **This skill can only open draft PRs — it never merges, and it has no
  command path to merge.** Merge rights on `ofirdamr/claude-skills-` stay
  with the repo owner; anyone else's edits land as a draft PR the owner
  reviews and merges (or doesn't) on their own terms.
- Never push directly to `main`, never force-push.
- Never fabricate a commit message that doesn't match the diff.
- If `gh` isn't installed or isn't authenticated, say so and give the user
  the manual fallback (fork on github.com, push the branch, open the PR)
  instead of failing silently.
- One PR per sync — don't batch unrelated local changes into one commit if
  they're clearly separate concerns; ask the user to split if so.

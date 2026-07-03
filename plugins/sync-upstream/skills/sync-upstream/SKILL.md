---
name: sync-upstream
description: >-
  Use when the user wants to send an edit they made to an installed
  claude-skills- plugin file back to the source repo (ofirdamr/claude-skills-)
  as a pull request — "sync my changes", "send this upstream", "auto sync".
  Works entirely through GitHub API tools (fork, branch, commit, PR) — no
  git or gh CLI, no local clone. Works the same on mobile, web, or desktop.
  Opens a draft PR only after the user confirms; never merges.
---

# Sync Upstream

Sends a skill file the user just edited back to `ofirdamr/claude-skills-` as
a draft PR, using GitHub's API tools only — the ones already available in
this session (e.g. `mcp__github__*`, or `gh` if that's what this
environment provides). No git clone, no local install path to find.

## Requirements — only for sending edits back

Installing and *using* any skill from this marketplace needs nothing extra —
it's a public repo, free, works for anyone on any plan. This skill's
send-back step is different: it needs the user's own GitHub account connected
to Claude Code via the Claude GitHub App (set up at claude.ai/code when
creating an environment — this is NOT the general claude.ai "Connectors"
panel, which has no GitHub option). If no GitHub tool is available in this
session when this skill runs, say exactly that — "connect GitHub at
claude.ai/code to send this" — instead of a raw tool error or retrying
blindly.

## Steps

1. **Identify the file(s) and their repo path.** You already have the
   edited content. Its path in the marketplace repo is
   `plugins/<plugin>/skills/<skill>/<file>` — same layout as this repo.

2. **Fetch the current upstream version** of that file from
   `ofirdamr/claude-skills-` (default branch) and compare to the edited
   version. If identical, tell the user there's nothing to sync — stop.

3. **Show the user the diff and get explicit confirmation.** Opening a PR
   is visible to others — never do it just because a diff exists.

4. **Once confirmed:**
   - Look up `ofirdamr/claude-skills-`'s **default branch** (fetch the repo
     info — do NOT assume `main`; installs read whatever the default branch
     is, so the PR must target it or the merge won't reach anyone).
   - Fork `ofirdamr/claude-skills-` to the user's own account (skip if
     already forked).
   - Create a branch off the fork's default branch, e.g. `sync/<slug>`.
   - Write the edited file's new content to that branch (one write per
     changed file).
   - Open a **draft** pull request, head `<user>:<branch>`, base
     `ofirdamr:<default-branch>`, with a title/body describing the change.

5. **Report the PR URL back to the user.** Do not merge it — this skill has
   no merge step. Only the repo owner merges, on their own schedule.

## After it's merged

Once the maintainer merges the PR, everyone gets it: any account, any
project, next time they run `/plugin marketplace update` or reinstall the
plugin — one shared skill, improved by whoever's using it.

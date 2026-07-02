---
name: sync-upstream
description: >-
  Use when the user wants to send local edits made to an installed
  claude-skills- plugin back upstream as a pull request — "sync my changes
  back", "send this upstream", "auto sync". Finds the local install
  automatically and opens a draft PR only after the user confirms.
---

# Sync Upstream

Two steps. Nothing to memorize — the script finds everything itself.

1. Run `bash <skill-dir>/sync-upstream.sh`. Read-only, shows what changed.
   If it says "nothing to sync," stop.
2. Show the user the diff and get a clear go-ahead. Then run
   `bash <skill-dir>/sync-upstream.sh confirm`. It commits, pushes (forking
   automatically if the user lacks write access), and opens a **draft PR**.
   Report the URL it prints.

Never skip step 2's confirmation. Never merge — the script has no merge
command; only the maintainer merges, on github.com, on their own terms.

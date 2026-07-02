# claude-skills-

Claude Code skills made by Ofir Damri, packaged as an installable plugin marketplace.

## What's in here

**`universal-framework`** — a universal operating framework for any project. It
establishes an MD-file operating system (`CLAUDE.md` / `SUMMARY.md` / `PROGRESS.md`
/ `MISTAKES.md`), a lean internal multi-agent team led by a PM, a mandatory
Token-Economist first-consult (leanest path, model pick, scope guard,
orchestration mode), English-to-user + Hebrew-RTL-deliverable language rules,
and a hard "no done without verification" gate.

**`sync-upstream`** — if you edit a skill file after installing it, say "sync
my changes back" and it opens a **draft PR** against this repo (via GitHub's
API tools, so it works the same on mobile, web, or desktop — no git/gh CLI
needed). Only the maintainer merges — this skill has no path to merge.

## Install

Add this repo as a marketplace source, then install whichever plugin you want:

```
/plugin marketplace add ofirdamr/claude-skills-
/plugin install universal-framework@claude-skills-
/plugin install sync-upstream@claude-skills-
```

Once installed, a plugin's skill is available in any project on your account.
Invoke `universal-framework` at the start of a session or before planning a
task; invoke `sync-upstream` whenever you want a local skill edit sent back.

## Contributing

Adding a skill? See [CONTRIBUTING.md](CONTRIBUTING.md) — every skill in this
repo must be a drop-in zip, maintainer-merge-only, short title/description,
and token-lean.

## Repo layout

```
.claude-plugin/marketplace.json         # marketplace catalog
plugins/universal-framework/
  .claude-plugin/plugin.json            # plugin manifest
  skills/universal-framework/
    SKILL.md                            # the skill itself
    project-kickoff.template.md         # per-session kickoff template
plugins/sync-upstream/
  .claude-plugin/plugin.json            # plugin manifest
  skills/sync-upstream/
    SKILL.md                            # send a local skill edit back as a PR
```

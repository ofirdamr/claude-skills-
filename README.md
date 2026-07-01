# claude-skills-

Claude Code skills made by Ofir Damri, packaged as an installable plugin marketplace.

## What's in here

**`universal-framework`** — a universal operating framework for any project. It
establishes an MD-file operating system (`CLAUDE.md` / `SUMMARY.md` / `PROGRESS.md`
/ `MISTAKES.md`), a lean internal multi-agent team led by a PM, a mandatory
Token-Economist first-consult (leanest path, model pick, scope guard,
orchestration mode), English-to-user + Hebrew-RTL-deliverable language rules,
and a hard "no done without verification" gate.

## Install

Add this repo as a marketplace source, then install the plugin:

```
/plugin marketplace add ofirdamr/claude-skills-
/plugin install universal-framework@claude-skills-
```

Once installed, the `universal-framework` skill is available in any project on
your account. Invoke it at the start of a session or before planning a task.

## Repo layout

```
.claude-plugin/marketplace.json         # marketplace catalog
plugins/universal-framework/
  .claude-plugin/plugin.json            # plugin manifest
  skills/universal-framework/
    SKILL.md                            # the skill itself
    project-kickoff.template.md         # per-session kickoff template
```

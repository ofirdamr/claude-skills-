# Adding a skill to this repo

Every skill added here — by the maintainer or via a `sync-upstream` PR — must
meet all four:

1. **Drop-in packaged.** One skill = one self-contained plugin folder under
   `plugins/<skill-name>/`:
   ```
   plugins/<skill-name>/
     .claude-plugin/plugin.json
     skills/<skill-name>/SKILL.md   (+ any scripts/templates it needs)
   ```
   No references to files outside its own folder. That means the folder can
   be zipped and shared, and unzipped straight back into `plugins/` — no
   assembly step either way. List it in `.claude-plugin/marketplace.json`.

2. **Maintainer-only merge.** All incoming changes — including from
   `sync-upstream` — land as a **draft PR**, never an auto-merge. Only the
   repo owner merges to `main`. No skill in this repo may carry a code path
   that merges, approves, or pushes to `main` directly.

3. **Short title, short description.** `plugin.json.displayName` and the
   `marketplace.json` entry description are catalog copy, not documentation:
   one line, under ~140 characters. Put the "why" and detail in the
   `SKILL.md` body, not the catalog blurb.

4. **Token-efficient body.** A skill exists to replace a long prompt, not
   restate one. Keep `SKILL.md` as short as the task allows; move rarely-needed
   detail (large templates, reference tables) into a separate file the skill
   loads on demand instead of inlining it. If a skill grows past what one
   read-through needs, split it rather than padding it.

See `plugins/sync-upstream/` for the reference-sized example (~90 lines
total, one script, no bundled extras).

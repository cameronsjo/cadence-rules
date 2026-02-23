---
name: rules-init
description: Install language and security rules to ~/.claude/rules/. Self-destructs after running so it reappears when the plugin updates with new rules.
allowed-tools: Bash, AskUserQuestion
---

Install rules from this plugin to `~/.claude/rules/` using prefixed filenames (`rules-*.md`).

## Steps

1. **Hash compare** — Run this bash script to produce a manifest. Do NOT read any rule file contents.

```bash
DEST="$HOME/.claude/rules"
mkdir -p "$DEST"

echo "=== STATUS ==="
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/*.md "${CLAUDE_PLUGIN_ROOT}"/rules/languages/*.md; do
  [ -f "$src" ] || continue
  name="rules-$(basename "$src")"
  dest="$DEST/$name"
  if [ ! -f "$dest" ]; then
    echo "NEW $name"
  elif [ "$(md5 -q "$src")" = "$(md5 -q "$dest")" ]; then
    echo "UNCHANGED $name"
  else
    echo "UPDATED $name"
  fi
done

echo "=== MIGRATE ==="
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/*.md "${CLAUDE_PLUGIN_ROOT}"/rules/languages/*.md; do
  [ -f "$src" ] || continue
  old="$DEST/$(basename "$src")"
  [ -f "$old" ] && echo "OLD $(basename "$src")"
done
```

2. **Show summary** — Format the manifest as a markdown table:

| File | Status |
|------|--------|
| `rules-python.md` | NEW / UNCHANGED / UPDATED |

If any `OLD` entries exist, add a migration note: "Found unprefixed files that will be removed: ..."

3. **Ask** — Single AskUserQuestion:
   - "Install all (Recommended)" — copy all NEW + UPDATED files
   - "Install new + updated only" — same behavior, just an explicit label
   - "Skip" — do nothing

If everything is UNCHANGED and no OLD files exist, skip the question and report "All rules are up to date."

4. **Install** — If not skipped, run:

```bash
DEST="$HOME/.claude/rules"
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/*.md "${CLAUDE_PLUGIN_ROOT}"/rules/languages/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done
```

5. **Remove old unprefixed** — If OLD files were detected, run:

```bash
DEST="$HOME/.claude/rules"
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/*.md "${CLAUDE_PLUGIN_ROOT}"/rules/languages/*.md; do
  [ -f "$src" ] || continue
  old="$DEST/$(basename "$src")"
  [ -f "$old" ] && rm "$old" && echo "Removed: $(basename "$src")"
done
```

6. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/commands/rules-init.md
```

Tell the user: "The /rules:init command has been removed from cache. It will reappear when the rules plugin updates."

7. **Summary** — Report counts: installed, updated, unchanged, migrated. Remind user to restart Claude Code.

## Important

- Do NOT read rule file contents — the hash comparison handles everything
- Source: `${CLAUDE_PLUGIN_ROOT}/rules/` — Destination: `~/.claude/rules/`
- Prefix: every installed file gets `rules-` prepended to its basename
- Files in `~/.claude/rules/` NOT matching `rules-*` are user-managed and never touched
- Self-destruct targets the CACHE copy, not the source repo

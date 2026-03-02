---
name: init-user
description: Install universal rules to ~/.claude/rules/workbench/. Self-destructs after running.
allowed-tools: Read, Write, Bash
---

Install all 6 universal rules from this plugin to `$HOME/.claude/rules/workbench/`.

## Steps

1. **Migrate** — Detect and move old flat files from the previous prefix scheme:

```bash
OLD_DEST="$HOME/.claude/rules"
NEW_DEST="$HOME/.claude/rules/workbench"
mkdir -p "$NEW_DEST"

echo "=== MIGRATE ==="
for old in "$OLD_DEST"/rules-*.md; do
  [ -f "$old" ] || continue
  basename="${old##*/}"
  stripped="${basename#rules-}"
  if [ ! -f "$NEW_DEST/$stripped" ]; then
    mv "$old" "$NEW_DEST/$stripped"
    echo "MIGRATED $basename -> workbench/$stripped"
  else
    rm "$old"
    echo "REMOVED $basename (already exists in workbench/)"
  fi
done
```

2. **Hash compare** — Compare plugin source against installed destination. Do NOT read any rule file contents yet.

```bash
DEST="$HOME/.claude/rules/workbench"

echo "=== UNIVERSAL ==="
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/user/*.md; do
  [ -f "$src" ] || continue
  name="$(basename "$src")"
  dest="$DEST/$name"
  if [ ! -f "$dest" ]; then
    echo "NEW $name"
  elif [ "$(md5 -q "$src")" = "$(md5 -q "$dest")" ]; then
    echo "UNCHANGED $name"
  else
    echo "UPDATED $name"
  fi
done
```

3. **Show summary** — Format the manifest as a markdown table:

| File | Status |
|------|--------|
| `engineering-standards.md` | NEW / UNCHANGED / UPDATED |

If everything is UNCHANGED, report "All universal rules are up to date." and skip to step 6.

4. **Install** — For each rule based on status:

- **NEW**: Copy the source file to the destination:
  ```bash
  cp "$src" "$DEST/$(basename "$src")"
  ```

- **UPDATED**: Read both the source (plugin) file and the destination (installed) file using the Read tool. Merge: incorporate plugin updates while preserving user customizations (added rules, modified wording, extra sections). Write the merged result to the destination using the Write tool.

- **UNCHANGED**: Skip.

5. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/*/commands/init-user.md
```

Tell the user: "The /rules:init-user command has been removed from cache. It will reappear when the rules plugin updates."

6. **Summary** — Report counts: installed, updated, unchanged, migrated. Remind user to restart Claude Code.

## Important

- Source: `${CLAUDE_PLUGIN_ROOT}/rules/user/` — Destination: `~/.claude/rules/workbench/`
- No prefix — files keep their original basename
- Files outside `workbench/` are user-managed and never touched
- For UPDATED files, READ both source and destination, MERGE intelligently, then WRITE. Do NOT overwrite blindly
- Self-destruct targets the CACHE copy, not the source repo

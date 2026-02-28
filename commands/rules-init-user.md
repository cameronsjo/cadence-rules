---
name: rules-init-user
description: Install universal rules (code, security, git, docs) to ~/.claude/rules/. Self-destructs after running.
allowed-tools: Bash, AskUserQuestion
---

Install universal rules from this plugin to `~/.claude/rules/` using prefixed filenames (`rules-*.md`).

These are always-loaded rules that apply regardless of project type: code principles, engineering standards, git workflow, markdown, security, and testing/observability.

## Steps

1. **Hash compare** — Run this bash script to produce a manifest. Do NOT read any rule file contents.

```bash
DEST="$HOME/.claude/rules"
mkdir -p "$DEST"

echo "=== STATUS ==="
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/user/*.md; do
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
```

2. **Show summary** — Format the manifest as a markdown table:

| File | Status |
|------|--------|
| `rules-engineering-standards.md` | NEW / UNCHANGED / UPDATED |

3. **Ask** — Single AskUserQuestion:
   - "Install all (Recommended)" — copy all NEW + UPDATED files
   - "Skip" — do nothing

If everything is UNCHANGED, skip the question and report "All user-level rules are up to date."

4. **Install** — If not skipped, run:

```bash
DEST="$HOME/.claude/rules"
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/user/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done
```

5. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/commands/rules-init-user.md
```

Tell the user: "The /rules:init-user command has been removed from cache. It will reappear when the rules plugin updates."

6. **Summary** — Report counts: installed, updated, unchanged. Remind user to restart Claude Code.

## Important

- Do NOT read rule file contents — the hash comparison handles everything
- Source: `${CLAUDE_PLUGIN_ROOT}/rules/user/` — Destination: `~/.claude/rules/`
- Prefix: every installed file gets `rules-` prepended to its basename
- Files in `~/.claude/rules/` NOT matching `rules-*` are user-managed and never touched
- Self-destruct targets the CACHE copy, not the source repo

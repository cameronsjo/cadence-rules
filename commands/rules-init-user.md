---
name: init-user
description: Install universal rules (code, security, git, docs) and optionally language rules to ~/.claude/rules/. Self-destructs after running.
allowed-tools: Bash, AskUserQuestion
---

Install rules from this plugin to `~/.claude/rules/` using prefixed filenames (`rules-*.md`).

Two tiers:
- **Universal rules** (always installed): code principles, engineering standards, git workflow, markdown, security, testing/observability
- **Language & tool rules** (optional): path-scoped rules for languages, Docker, CI/CD, MCP, etc. — these use `paths:` frontmatter so they only load when Claude touches matching files

## Steps

1. **Hash compare universal rules** — Run this bash script to produce a manifest. Do NOT read any rule file contents.

```bash
DEST="$HOME/.claude/rules"
mkdir -p "$DEST"

echo "=== UNIVERSAL ==="
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

2. **Show universal summary** — Format the manifest as a markdown table:

| File | Status |
|------|--------|
| `rules-engineering-standards.md` | NEW / UNCHANGED / UPDATED |

3. **Ask scope** — Use the AskUserQuestion tool with these exact options:
   - label: "Universal rules only (Recommended)", description: "Install the 6 core rules (code, security, git, docs, testing, engineering)"
   - label: "Universal + language/tool rules", description: "Also install all 16 path-scoped rules (languages, Docker, CI/CD, MCP, etc.)"
   - label: "Skip", description: "Do nothing"

If everything is UNCHANGED and user picks "Universal rules only", skip to step 7.

4. **Hash compare language/tool rules** — Only if user selected "Universal + language/tool rules":

```bash
DEST="$HOME/.claude/rules"
PLUGIN="${CLAUDE_PLUGIN_ROOT}/rules/project"

echo "=== LANGUAGE/TOOL ==="
for src in "$PLUGIN"/languages/*.md "$PLUGIN"/*.md; do
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

Show this as a second table.

5. **Install** — Copy all selected rules:

```bash
DEST="$HOME/.claude/rules"

# Always install universal rules
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/user/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done

# If language/tool rules were selected, install those too
# ONLY include this block if user chose "Universal + language/tool rules"
PLUGIN="${CLAUDE_PLUGIN_ROOT}/rules/project"
for src in "$PLUGIN"/languages/*.md "$PLUGIN"/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done
```

6. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/*/commands/rules-init-user.md
```

Tell the user: "The /rules:init-user command has been removed from cache. It will reappear when the rules plugin updates."

7. **Summary** — Report counts: installed, updated, unchanged. Remind user to restart Claude Code. If language/tool rules were installed, note that they're path-scoped and only load when touching matching files.

## Important

- Do NOT read rule file contents — the hash comparison handles everything
- Source: `${CLAUDE_PLUGIN_ROOT}/rules/user/` and `${CLAUDE_PLUGIN_ROOT}/rules/project/` — Destination: `~/.claude/rules/`
- Prefix: every installed file gets `rules-` prepended to its basename
- Files in `~/.claude/rules/` NOT matching `rules-*` are user-managed and never touched
- Language/tool rules keep their `paths:` frontmatter — path-scoping works at `~/.claude/rules/` just like in `.claude/rules/`
- Self-destruct targets the CACHE copy, not the source repo

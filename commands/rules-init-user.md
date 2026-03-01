---
name: init-user
description: Install rules to ~/.claude/rules/. Universal, all, or specify. Self-destructs after running.
allowed-tools: Bash, AskUserQuestion
---

Install rules from this plugin to `~/.claude/rules/` using prefixed filenames (`rules-*.md`).

Two tiers:
- **Universal rules** (6): code principles, engineering standards, git workflow, markdown, security, testing/observability — always-loaded, no path scoping
- **Language & tool rules** (16): bash, csharp, go, java, javascript, powershell, protobuf, python, rust, typescript, beads, cicd, dockerfile, docs, mcp, mermaid — path-scoped via `paths:` frontmatter, only load when Claude touches matching files

## Steps

1. **Ask scope** — Use the AskUserQuestion tool:
   - label: "Universal (Recommended)", description: "Install the 6 core rules (code, security, git, docs, testing, engineering)"
   - label: "All", description: "Install all 22 rules (6 universal + 16 language/tool, path-scoped)"
   - label: "Specify", description: "Choose exactly which rules to install"

If user selects "Specify", present a second AskUserQuestion with `multiSelect: true` listing all 22 available rules by name.

2. **Hash compare** — Based on user selection, run the appropriate hash comparison. Do NOT read any rule file contents.

For universal rules:

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

For language/tool rules (include if user selected "All" or specified any):

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

3. **Show summary** — Format the manifest as a markdown table:

| File | Status |
|------|--------|
| `rules-engineering-standards.md` | NEW / UNCHANGED / UPDATED |

If everything is UNCHANGED, report "All selected rules are up to date." and skip to step 6.

4. **Install** — Copy selected rules:

```bash
DEST="$HOME/.claude/rules"

# Universal rules
for src in "${CLAUDE_PLUGIN_ROOT}"/rules/user/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done
```

```bash
# Language/tool rules — ONLY if user selected "All" or specified these
DEST="$HOME/.claude/rules"
PLUGIN="${CLAUDE_PLUGIN_ROOT}/rules/project"
for src in "$PLUGIN"/languages/*.md "$PLUGIN"/*.md; do
  [ -f "$src" ] || continue
  cp "$src" "$DEST/rules-$(basename "$src")"
done
```

For "Specify", only copy the rules the user selected. Use the same source lookup logic (check `languages/` first, then project root).

5. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/*/commands/rules-init-user.md
```

Tell the user: "The /rules:init-user command has been removed from cache. It will reappear when the rules plugin updates."

6. **Summary** — Report counts: installed, updated, unchanged. If language/tool rules were installed, note they're path-scoped and only load when touching matching files. Remind user to restart Claude Code.

## Important

- Do NOT read rule file contents — the hash comparison handles everything
- Source: `${CLAUDE_PLUGIN_ROOT}/rules/user/` and `${CLAUDE_PLUGIN_ROOT}/rules/project/` — Destination: `~/.claude/rules/`
- Prefix: every installed file gets `rules-` prepended to its basename
- Files in `~/.claude/rules/` NOT matching `rules-*` are user-managed and never touched
- Language/tool rules keep their `paths:` frontmatter — path-scoping works at `~/.claude/rules/` just like `.claude/rules/`
- Self-destruct targets the CACHE copy, not the source repo

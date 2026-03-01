---
name: init-project
description: Detect project languages/tools and install matching rules to .claude/rules/ with path-scoping. Rules load only when Claude touches matching files.
allowed-tools: Bash, AskUserQuestion
---

Auto-detect project contents, then install matching path-scoped rules to `.claude/rules/` in the current project. These rules use `paths:` frontmatter so they only load when Claude touches relevant files (e.g., python.md loads only when reading .py files).

## Steps

1. **Detect** — Run this bash script from the project root to scan for matching files/directories. Do NOT read any rule file contents.

```bash
echo "=== DETECTION ==="

# Languages (short-circuit on first match via -quit)
find . -maxdepth 4 \( -name "*.py" -o -name "pyproject.toml" -o -name "requirements*.txt" -o -name "setup.py" -o -name "setup.cfg" -o -name ".python-version" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED python"
find . -maxdepth 4 \( -name "*.ts" -o -name "*.tsx" -o -name "tsconfig*.json" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED typescript"
find . -maxdepth 4 \( -name "*.js" -o -name "*.jsx" -o -name "*.mjs" -o -name "*.cjs" \) -not -path "*/node_modules/*" -print -quit 2>/dev/null | grep -q . && echo "DETECTED javascript"
find . -maxdepth 4 \( -name "*.go" -o -name "go.mod" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED go"
find . -maxdepth 4 \( -name "*.rs" -o -name "Cargo.toml" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED rust"
find . -maxdepth 4 \( -name "*.cs" -o -name "*.csproj" -o -name "*.sln" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED csharp"
find . -maxdepth 4 \( -name "*.java" -o -name "pom.xml" -o -name "build.gradle" -o -name "build.gradle.kts" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED java"
find . -maxdepth 4 \( -name "*.ps1" -o -name "*.psm1" -o -name "*.psd1" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED powershell"
find . -maxdepth 4 -name "*.proto" -print -quit 2>/dev/null | grep -q . && echo "DETECTED protobuf"
find . -maxdepth 4 \( -name "*.sh" -o -name "*.bash" -o -name "Makefile" -o -name ".envrc" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED bash"

# Tools & Domains
find . -maxdepth 4 \( -name "Dockerfile" -o -name "Dockerfile.*" -o -name "Containerfile" -o -name "*.dockerfile" -o -name ".dockerignore" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED dockerfile"
find . -maxdepth 2 \( -path "./.github/workflows/*" -o -name ".gitlab-ci.yml" -o -name "Jenkinsfile" -o -name "azure-pipelines.yml" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED cicd"
find . -maxdepth 4 \( -path "*/docs/*.md" -o -name "*.mdx" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED docs"
find . -maxdepth 4 \( -name "*.mermaid" -o -name "*.mmd" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED mermaid"
find . -maxdepth 4 \( -path "*/mcp/*" -o -name "mcp-*" -o -name "*_mcp.py" -o -name "*-mcp.ts" \) -print -quit 2>/dev/null | grep -q . && echo "DETECTED mcp"
[ -d ".beads" ] && echo "DETECTED beads"
```

2. **Show detections** — Format as a checklist:

```
Detected rules for this project:
- [x] python — *.py, pyproject.toml
- [x] typescript — *.ts, *.tsx, tsconfig*.json
- [x] bash — *.sh, Makefile
- [x] dockerfile — Dockerfile
- [x] cicd — .github/workflows/
```

3. **Ask** — Single AskUserQuestion with options:
   - "Install detected (Recommended)" — install all detected rules
   - "Let me choose" — if selected, present a multi-select AskUserQuestion listing all 16 available rules so the user can pick exactly which to install
   - "Skip" — do nothing

4. **Hash compare** — For the selected rules, run a hash comparison against already-installed project rules:

```bash
DEST=".claude/rules"
mkdir -p "$DEST"
PLUGIN="${CLAUDE_PLUGIN_ROOT}/rules/project"

echo "=== STATUS ==="
# For each selected rule, check languages/ first then project root
for rule in RULE_LIST; do
  if [ -f "$PLUGIN/languages/${rule}.md" ]; then
    src="$PLUGIN/languages/${rule}.md"
  elif [ -f "$PLUGIN/${rule}.md" ]; then
    src="$PLUGIN/${rule}.md"
  else
    echo "MISSING $rule"
    continue
  fi
  name="rules-${rule}.md"
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

Replace `RULE_LIST` with the space-separated list of selected rule names (e.g., `python typescript bash dockerfile cicd`).

5. **Install** — For each NEW or UPDATED rule, copy it to `.claude/rules/`:

```bash
DEST=".claude/rules"
PLUGIN="${CLAUDE_PLUGIN_ROOT}/rules/project"

for rule in RULE_LIST; do
  if [ -f "$PLUGIN/languages/${rule}.md" ]; then
    src="$PLUGIN/languages/${rule}.md"
  elif [ -f "$PLUGIN/${rule}.md" ]; then
    src="$PLUGIN/${rule}.md"
  else
    continue
  fi
  cp "$src" "$DEST/rules-${rule}.md"
done
```

6. **Self-destruct** — Delete this command from the plugin cache:

```bash
rm -f "$HOME"/.claude/plugins/cache/*/rules/commands/rules-init-project.md
```

Tell the user: "The /rules:init-project command has been removed from cache. It will reappear when the rules plugin updates."

7. **Summary** — Report:
   - Counts: installed, updated, unchanged, skipped
   - Remind user these rules live in `.claude/rules/` and should be committed to the repo
   - Remind user to restart Claude Code

## Important

- Do NOT read rule file contents — hash comparison handles everything
- Source: `${CLAUDE_PLUGIN_ROOT}/rules/project/` — Destination: `.claude/rules/` (project root)
- Prefix: every installed file gets `rules-` prepended to its basename
- Rules keep their `paths:` frontmatter — this is what makes path-scoping work at project level
- The managed-by comment should reference `/rules:init-project` not `/rules:init`
- Self-destruct targets the CACHE copy, not the source repo

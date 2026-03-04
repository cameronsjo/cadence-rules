#!/bin/bash
# PreToolUse hook: validate frontmatter when writing/editing SKILL.md or command files.
# Fires on Edit and Write tool calls. Checks against Agent Skills + Claude Code specs.
#
# Exit codes:
#   0 = allow (file not a skill/command, or valid frontmatter)
#   2 = block (invalid frontmatter, error on stderr)

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Quick exit: only care about skill and command files
case "$FILE_PATH" in
  */skills/*/SKILL.md) TYPE="skill" ;;
  */commands/*.md)     TYPE="command" ;;
  *)                   exit 0 ;;
esac

# For Write: validate the content being written
# For Edit: validate the file after the edit would apply (check current file)
if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
  [ -z "$CONTENT" ] && exit 0
else
  # Edit: read current file, we'll check what's there
  [ -f "$FILE_PATH" ] || exit 0
  CONTENT=$(cat "$FILE_PATH")
fi

# Extract frontmatter
FIRST_LINE=$(echo "$CONTENT" | head -1)
if [ "$FIRST_LINE" != "---" ]; then
  echo "Skill/command file missing YAML frontmatter (must start with ---)" >&2
  exit 2
fi

# Extract frontmatter block (between first and second ---)
FRONTMATTER=$(echo "$CONTENT" | sed -n '2,/^---$/p' | grep -v '^---$')

# Get top-level keys
KEYS=$(echo "$FRONTMATTER" | grep -v '^$' | sed -nE 's/^([a-zA-Z_-]+):.*/\1/p' | sort -u)

# Valid fields: Agent Skills spec + Claude Code spec
VALID="name description license compatibility metadata allowed-tools argument-hint disable-model-invocation user-invocable model context agent hooks"

ERRORS=""

# Check for unknown fields
for key in $KEYS; do
  found=0
  for valid in $VALID; do
    [ "$key" = "$valid" ] && found=1 && break
  done
  if [ $found -eq 0 ]; then
    ERRORS="${ERRORS}Unknown frontmatter field: '${key}'. "
  fi
done

if [ "$TYPE" = "skill" ]; then
  # name is required
  if ! echo "$KEYS" | grep -q '^name$'; then
    ERRORS="${ERRORS}Missing required 'name' field. "
  fi

  # description is required
  if ! echo "$KEYS" | grep -q '^description$'; then
    ERRORS="${ERRORS}Missing required 'description' field. "
  fi

  # name must match directory
  NAME_VALUE=$(echo "$FRONTMATTER" | sed -nE 's/^name:[[:space:]]*(.*)/\1/p' | head -1)
  DIR_NAME=$(basename "$(dirname "$FILE_PATH")")
  if [ -n "$NAME_VALUE" ] && [ "$NAME_VALUE" != "$DIR_NAME" ]; then
    ERRORS="${ERRORS}name '${NAME_VALUE}' must match directory '${DIR_NAME}'. "
  fi

  # name format: lowercase, numbers, hyphens, no leading/trailing/consecutive hyphens
  if [ -n "$NAME_VALUE" ]; then
    if ! echo "$NAME_VALUE" | grep -qE '^[a-z0-9-]+$'; then
      ERRORS="${ERRORS}name must use only lowercase letters, numbers, and hyphens. "
    fi
    if echo "$NAME_VALUE" | grep -qE '^-|-$'; then
      ERRORS="${ERRORS}name must not start or end with a hyphen. "
    fi
    if echo "$NAME_VALUE" | grep -qE '\-\-'; then
      ERRORS="${ERRORS}name must not contain consecutive hyphens. "
    fi
  fi
fi

if [ "$TYPE" = "command" ]; then
  # name: in commands causes double-prefix
  if echo "$KEYS" | grep -q '^name$'; then
    ERRORS="${ERRORS}Remove 'name:' from command files — commands derive name from filename, name: causes double-prefix. "
  fi
fi

if [ -n "$ERRORS" ]; then
  echo "Frontmatter validation failed: ${ERRORS}" >&2
  exit 2
fi

exit 0

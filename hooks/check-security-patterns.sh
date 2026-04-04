#!/usr/bin/env bash
set -euo pipefail

# Security Pattern Checker -- PostToolUse hook for Edit|Write
# Advisory only: prints warnings, NEVER blocks (always exits 0).
#
# Scans written/edited files for known-dangerous patterns per language.
# Warnings appear inline after the edit so the developer sees them
# at the moment of writing, not in a separate audit step.
#
# This file contains grep patterns (detection signatures), not code.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Skip hook/config/rule files (they legitimately reference these patterns)
case "$FILE_PATH" in
    */.claude/hooks/*|*/.claude/settings*|*/.claude/rules/*|*/CLAUDE.md)
        exit 0
        ;;
esac

EXT="${FILE_PATH##*.}"
WARNINGS=()

check_pattern() {
    local pattern="$1"
    local message="$2"
    local match
    match=$(grep -nE "$pattern" "$FILE_PATH" 2>/dev/null | head -1) || true
    if [[ -n "$match" ]]; then
        local line
        line=$(echo "$match" | cut -d: -f1)
        WARNINGS+=("  L${line}: ${message}")
    fi
}

# Each entry: language_extensions|grep_pattern|advisory_message
PATTERNS=(
    "py|pickle[.]loads|RCE risk: use json or msgpack instead of pickle"
    "py|yaml[.]load[(]|Use yaml.safe_load()"
    "py|shell[[:space:]]*=[[:space:]]*True|Command injection risk: pass arg list to subprocess"
    "py|trust_remote_code[[:space:]]*=[[:space:]]*True|Runs arbitrary code from model repos"
    "py|__import__[(]|Arbitrary module loading"
    "js,jsx,mjs,cjs|new[[:space:]]+Function[(]|Function() constructor can run arbitrary code"
    "js,jsx,mjs,cjs|[.]innerHTML[[:space:]]*=|XSS risk: use textContent or sanitize first"
    "js,jsx,mjs,cjs|Math[.]random[(][)]|Not cryptographically secure"
    "ts,tsx|[[:space:]]as[[:space:]][A-Z]|Type assertion bypasses validation"
    "go|\"text/template\"|Use html/template for HTML output"
    "go|\"math/rand\"|Use crypto/rand for security-sensitive randomness"
    "go|\"unsafe\"|unsafe package -- document safety invariants"
    "rs|unsafe[[:space:]]*[{]|Ensure // SAFETY: comment and test with Miri"
    "rs|from_utf8_unchecked|UB risk on external input"
    "java|ObjectInputStream|Deserialization RCE -- use ObjectInputFilter"
    "java|java[.]util[.]Random[^N]|Use SecureRandom for security-sensitive values"
    "cs|BinaryFormatter|RCE vector, removed in .NET 9"
    "cs|TypeNameHandling|Deserialization attack -- ensure TypeNameHandling.None"
    "cs|DtdProcessing[.]Parse|XXE risk -- use DtdProcessing.Prohibit"
    "swift|UserDefaults.*(password|secret|token|apiKey)|Store secrets in Keychain"
)

for entry in "${PATTERNS[@]}"; do
    IFS='|' read -r extensions pattern message <<< "$entry"
    match=false
    IFS=',' read -ra ext_list <<< "$extensions"
    for e in "${ext_list[@]}"; do
        if [[ "$EXT" == "$e" ]]; then
            match=true
            break
        fi
    done
    if [[ "$match" == "true" ]]; then
        check_pattern "$pattern" "$message"
    fi
done

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    MSG="Security hints for $(basename "$FILE_PATH"):"
    for w in "${WARNINGS[@]}"; do
        MSG+=$'\n'"$w"
    done
    # PostToolUse: plain stdout doesn't reach the model — must use JSON.
    jq -n --arg msg "$MSG" \
      '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $msg}}'
fi

# Advisory only -- never block
exit 0

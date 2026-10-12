#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/project" "$TMP/home"

bash "$ROOT/install.sh" --project "$TMP/project" >/dev/null
test -f "$TMP/project/.claude/skills/edd-loop/SKILL.md"
test -f "$TMP/project/.claude/skills/edd-loop/references/protocol.md"
test -f "$TMP/project/.claude/agents/edd-developer.md"
test -f "$TMP/project/.claude/agents/edd-reviewer.md"

if bash "$ROOT/install.sh" --project "$TMP/project" > /dev/null 2>&1; then
  echo 'Expected a refusal to overwrite existing installation' >&2
  exit 1
fi

echo '# user edit' >> "$TMP/project/.claude/agents/edd-developer.md"
bash "$ROOT/install.sh" --project "$TMP/project" --force >/dev/null
if ! find "$TMP/project/.claude/agents" -name 'edd-developer.md.bak.*' -type f -exec grep -q '# user edit' {} \; -print | grep -q .; then
  echo 'Expected a backup of the original Agent file' >&2
  exit 1
fi

HOME="$TMP/home" bash "$ROOT/install.sh" --user >/dev/null
test -f "$TMP/home/.claude/skills/edd-loop/SKILL.md"
test -f "$TMP/home/.claude/agents/edd-reviewer.md"

echo 'All install tests passed.'


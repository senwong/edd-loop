#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
MODE=user
PROJECT=
FORCE=0

usage() {
  echo 'Usage: bash install.sh [--user | --project PATH] [--force]'
  echo '  --user         Install globally for the current user (default).'
  echo '  --project PATH Install into PATH/.claude for one project.'
  echo '  --force        Backup existing same-name files before replacing.'
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --user) MODE=user; PROJECT=; shift ;;
    --project)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then echo 'Missing project path' >&2; exit 2; fi
      MODE=project; PROJECT="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

for path in "$ROOT/skills/edd-loop/SKILL.md" "$ROOT/agents/edd-developer.md" "$ROOT/agents/edd-reviewer.md"; do
  if [ ! -f "$path" ]; then echo "Missing source: $path" >&2; exit 1; fi
done

if [ "$MODE" = user ]; then
  TARGET="$HOME/.claude"
else
  if [ ! -d "$PROJECT" ]; then echo "Project directory not found: $PROJECT" >&2; exit 1; fi
  TARGET="$(cd "$PROJECT" && pwd)/.claude"
fi

SKILL="$TARGET/skills/edd-loop"
DEV="$TARGET/agents/edd-developer.md"
REVIEW="$TARGET/agents/edd-reviewer.md"

if [ "$FORCE" -ne 1 ]; then
  for target in "$SKILL" "$DEV" "$REVIEW"; do
    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "Refusing to overwrite $target (pass --force to back it up)" >&2
      exit 1
    fi
  done
fi

mkdir -p "$TARGET/skills" "$TARGET/agents"
STAMP="$(date '+%Y%m%d%H%M%S')-$$"

if [ "$FORCE" -eq 1 ]; then
  for target in "$SKILL" "$DEV" "$REVIEW"; do
    if [ -e "$target" ] || [ -L "$target" ]; then
      mv "$target" "$target.bak.$STAMP"
      echo "Backup: $target.bak.$STAMP"
    fi
  done
fi

cp -R "$ROOT/skills/edd-loop" "$SKILL"
cp "$ROOT/agents/edd-developer.md" "$DEV"
cp "$ROOT/agents/edd-reviewer.md" "$REVIEW"

printf 'Installed EDD Loop into %s\n' "$TARGET"
echo 'Restart Claude Code or open a new session; then run: /edd-loop <your task>'


#!/usr/bin/env sh
# Installs the board-workflow skill for agents other than Claude (OpenCode, Codex
# and others that read SKILL.md files) by downloading it to ~/.agents/skills.
# Run: curl -fsSL https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install-skill.sh | sh
# Another folder: BOARD_WORKFLOW_SKILLS_DIR=~/.config/opencode/skills sh install-skill.sh
set -eu

root="${BOARD_WORKFLOW_SKILLS_DIR:-$HOME/.agents/skills}"
dir="$root/board-workflow"
url="https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/skills/board-workflow/SKILL.md"

mkdir -p "$dir"
tmp="$(mktemp)"
curl -fsSL "$url" -o "$tmp"
if ! sed -n 2p "$tmp" | grep -q '^name: board-workflow'; then
  rm -f "$tmp"
  echo "Download from $url didn't look like the skill. Nothing was changed." >&2
  exit 1
fi
mv "$tmp" "$dir/SKILL.md"

echo "board-workflow skill saved to $dir/SKILL.md"
echo 'Restart your agent, then say "do the tasks" in a project (OpenCode: or mention @board-workflow).'

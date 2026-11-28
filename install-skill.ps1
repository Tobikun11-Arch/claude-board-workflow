# Installs the board-workflow skill for agents other than Claude (OpenCode, Codex
# and others that read SKILL.md files) by downloading it to ~/.agents/skills.
# Run: irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install-skill.ps1 | iex
# Another folder: set $env:BOARD_WORKFLOW_SKILLS_DIR first, e.g. "$HOME\.config\opencode\skills".

$ErrorActionPreference = 'Stop'

$root = if ($env:BOARD_WORKFLOW_SKILLS_DIR) { $env:BOARD_WORKFLOW_SKILLS_DIR } else { Join-Path $HOME '.agents\skills' }
$dir = Join-Path $root 'board-workflow'
$file = Join-Path $dir 'SKILL.md'
$url = 'https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/skills/board-workflow/SKILL.md'

New-Item -ItemType Directory -Force -Path $dir | Out-Null
$text = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
if ($text -notmatch '^---\s*\r?\nname: board-workflow') { throw "Download from $url didn't look like the skill. Nothing was changed." }

# UTF-8 without BOM: a BOM would hide the frontmatter from some agents.
[IO.File]::WriteAllText($file, $text, (New-Object System.Text.UTF8Encoding $false))

Write-Host "board-workflow skill saved to $file" -ForegroundColor Green
Write-Host 'Restart your agent, then say "do the tasks" in a project (OpenCode: or mention @board-workflow).'

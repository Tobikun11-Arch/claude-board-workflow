# Installs the board-workflow plugin for Claude (desktop app or CLI) by adding it
# to ~/.claude/settings.json. Keeps every existing setting and saves a backup.
# Run: irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$dir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$file = Join-Path $dir 'settings.json'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$settings = [pscustomobject]@{}
if (Test-Path $file) {
    $raw = [IO.File]::ReadAllText($file).TrimStart([char]0xFEFF)
    if ($raw.Trim()) {
        try { $settings = $raw | ConvertFrom-Json }
        catch { throw "Could not read $file (is it valid JSON?). Nothing was changed." }
    }
    Copy-Item $file "$file.bak" -Force
}

function Set-JsonProperty($Object, $Name, $Value) {
    if ($Object.PSObject.Properties[$Name]) { $Object.$Name = $Value }
    else { $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}

foreach ($section in 'extraKnownMarketplaces', 'enabledPlugins') {
    if (-not $settings.PSObject.Properties[$section]) {
        Set-JsonProperty $settings $section ([pscustomobject]@{})
    }
}

Set-JsonProperty $settings.extraKnownMarketplaces 'board-workflow' ([pscustomobject]@{
    source = [pscustomobject]@{ source = 'github'; repo = 'Tobikun11-Arch/claude-board-workflow' }
})
Set-JsonProperty $settings.enabledPlugins 'board-workflow@board-workflow' $true

# UTF-8 without BOM: Windows PowerShell 5.1 adds a BOM by default.
$json = $settings | ConvertTo-Json -Depth 32
[IO.File]::WriteAllText($file, $json, (New-Object System.Text.UTF8Encoding $false))

Write-Host "board-workflow added to $file" -ForegroundColor Green
if (Test-Path "$file.bak") { Write-Host "Backup of your old settings: $file.bak" }
Write-Host 'Restart Claude, then say "do the tasks" in a project.'

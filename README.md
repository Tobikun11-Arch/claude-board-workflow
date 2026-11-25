# board-workflow

A Claude Code skill. Claude takes the top card in a GitHub Projects board's **In Progress** column, does it, runs a ponytail audit on the changed code and fixes must-fix findings, commits it to the repo's `.github/COMMIT_CONVENTION.md`, moves the card to **QA** with a manual-test comment numbered QA-001 (QA-002 for the next handoff, and so on), then takes the next card until the column is empty. Testers reply with plain comments, no QA number, and move the card back to In Progress. Claude then fixes only what those comments report instead of redoing the task.

## Install on any PC

Pick one option. Restart Claude afterwards.

### Quickest on Windows: one line in Windows Terminal / PowerShell

Works for the desktop app and the CLI; you don't need the `claude` command. It adds the plugin to `~/.claude/settings.json`, keeps all your other settings, and saves a backup as `settings.json.bak`.

```powershell
irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install.ps1 | iex
```

You can read [install.ps1](install.ps1) first. It only edits that one file.

### Option A: Claude desktop app, by hand

Open `~/.claude/settings.json` (Windows: `C:\Users\<you>\.claude\settings.json`), or create it, and add these entries inside the outer `{ }`. If the file already has `extraKnownMarketplaces` or `enabledPlugins`, add the lines inside those blocks instead.

```json
{
  "extraKnownMarketplaces": {
    "board-workflow": { "source": { "source": "github", "repo": "Tobikun11-Arch/claude-board-workflow" } }
  },
  "enabledPlugins": { "board-workflow@board-workflow": true }
}
```

### Option B: Claude Code CLI

```
claude plugin marketplace add Tobikun11-Arch/claude-board-workflow
claude plugin install board-workflow@board-workflow
```

If you get `'claude' is not recognized`, the CLI isn't installed; the desktop app doesn't add it. Use Option A, or install the CLI first, then reopen the terminal:

- Windows (PowerShell): `irm https://claude.ai/install.ps1 | iex`
- macOS / Linux: `curl -fsSL https://claude.ai/install.sh | bash`

## Use

Needs the [ponytail](https://github.com/DietrichGebert/ponytail) plugin for the audit step. If it's missing, Claude asks before installing it.

Tell Claude "do the tasks" or "work the board" in a project. The first time, Claude asks for the board link. Keep a list of boards in `~/.claude/CLAUDE.md` so Claude doesn't have to ask:

```
- my-app (my-org/my-app): https://github.com/users/<user>/projects/<number>/views/1
```

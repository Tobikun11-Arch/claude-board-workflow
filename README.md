# board-workflow

A Claude Code skill. Claude takes the top card in a GitHub Projects board's **In Progress** column, does it, runs a ponytail audit on the changed code and fixes must-fix findings, commits it to the repo's `.github/COMMIT_CONVENTION.md`, moves the card to **QA** with a manual-test comment numbered QA-001 (QA-002 for the next handoff, and so on), then takes the next card until the column is empty. Testers reply with plain comments, no QA number, and move the card back to In Progress. Claude then fixes only what those comments report instead of redoing the task.

## Install on any PC

Pick one option. Restart Claude afterwards.

### Quickest on Windows: one line in Windows Terminal / PowerShell

Works for the desktop app and the CLI; you don't need the `claude` command. It adds the plugin to `~/.claude/settings.json`, keeps all your other settings, and saves a backup as `settings.json.bak`.

```powershell
irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install.ps1 | iex
```

Your prompt should start with `PS C:\...>`. If it's `C:\...>` without `PS`, that's Command Prompt (cmd), where `irm` isn't recognized. Open PowerShell instead, or run this in cmd:

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install.ps1 | iex"
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

### Not using Claude? OpenCode, Codex and other agents

The skill is a plain `SKILL.md` file, so any agent that reads skills can use it. This command saves it to `~/.agents/skills/board-workflow/SKILL.md`, a shared folder that OpenCode and other agents check.

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install-skill.ps1 | iex
```

From Command Prompt (cmd):

```
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install-skill.ps1 | iex"
```

macOS / Linux:

```
curl -fsSL https://raw.githubusercontent.com/Tobikun11-Arch/claude-board-workflow/main/install-skill.sh | sh
```

Restart the agent, then say "do the tasks" in a project. In OpenCode you can also mention `@board-workflow`. If your agent reads skills from a different folder, set `BOARD_WORKFLOW_SKILLS_DIR` to that folder before running the command (PowerShell: `$env:BOARD_WORKFLOW_SKILLS_DIR = "$HOME\.config\opencode\skills"`). You can also copy [SKILL.md](skills/board-workflow/SKILL.md) there by hand.

Outside Claude:
- **Audit:** ponytail is a Claude plugin, so the agent skips that step and writes "Audit skipped" in the QA comment.
- **Saved boards:** they go in the agent's own global instructions file (for OpenCode, `~/.config/opencode/AGENTS.md`) instead of `~/.claude/CLAUDE.md`.
- **Requirements:** `gh` is still required (see below).

## Use

Needs the [ponytail](https://github.com/DietrichGebert/ponytail) plugin for the audit step. If it's missing, Claude asks before installing it.

Needs the [GitHub CLI](https://cli.github.com) (`gh`), logged in with the Projects scope. The skill never uses a browser. At the start of every run Claude checks `gh`. If it's missing, Claude asks before installing it. If you're not logged in, or the Projects scope is missing, Claude stops and asks you to run one of these, then checks again:

```powershell
gh auth login --hostname github.com --git-protocol https --web --scopes project
```

```powershell
gh auth refresh --hostname github.com --scopes project
```

You also need write access to the repo and edit access to the Project, so Claude can comment on issues and move cards.

Tell Claude "do the tasks" or "work the board" in a project. You don't have to say which board: Claude reads the repo from `git remote`, finds the GitHub Project linked to it with `gh`, maps your column names, and saves the board to `~/.claude/CLAUDE.md`. It asks only if the repo has several boards or none. You can also list boards there yourself:

```
- my-app (my-org/my-app): https://github.com/users/<user>/projects/<number>/views/1
```

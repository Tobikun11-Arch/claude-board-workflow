# board-workflow

A Claude Code skill. Claude takes the top card in a GitHub Projects board's **In Progress** column, does it, runs a ponytail audit on the changed code and fixes must-fix findings, commits it to the repo's `.github/COMMIT_CONVENTION.md`, moves the card to **QA** with a manual-test comment, then takes the next card until the column is empty.

## Install on any PC

Run this in a terminal on that PC:

```
claude plugin marketplace add <your-github-user>/claude-board-workflow
claude plugin install board-workflow@board-workflow
```

Or add it to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "board-workflow": { "source": { "source": "github", "repo": "<your-github-user>/claude-board-workflow" } }
  },
  "enabledPlugins": { "board-workflow@board-workflow": true }
}
```

## Use

Needs the [ponytail](https://github.com/DietrichGebert/ponytail) plugin for the audit step. If it's missing, Claude asks before installing it.

Tell Claude "do the tasks" or "work the board" in a project. The first time, Claude asks for the board link. Keep a list of boards in `~/.claude/CLAUDE.md` so Claude doesn't have to ask:

```
- clovars (Tobikun11-Arch/clovars): https://github.com/users/Tobikun11-Arch/projects/21/views/1
```

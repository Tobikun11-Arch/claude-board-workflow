# board-workflow

A Claude Code skill. Claude takes the top card in a GitHub Projects board's **In Progress** column, does it, runs a ponytail audit on the changed code and fixes must-fix findings, commits it to the repo's `.github/COMMIT_CONVENTION.md`, moves the card to **QA** with a manual-test comment numbered QA-001 (QA-002 for the next handoff, and so on), then takes the next card until the column is empty. Testers reply with plain comments, no QA number, and move the card back to In Progress. Claude then fixes only what those comments report instead of redoing the task.

## Install on any PC

Run this in a terminal on that PC:

```
claude plugin marketplace add Tobikun11-Arch/claude-board-workflow
claude plugin install board-workflow@board-workflow
```

Or add it to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "board-workflow": { "source": { "source": "github", "repo": "Tobikun11-Arch/claude-board-workflow" } }
  },
  "enabledPlugins": { "board-workflow@board-workflow": true }
}
```

## Use

Needs the [ponytail](https://github.com/DietrichGebert/ponytail) plugin for the audit step. If it's missing, Claude asks before installing it.

Tell Claude "do the tasks" or "work the board" in a project. The first time, Claude asks for the board link. Keep a list of boards in `~/.claude/CLAUDE.md` so Claude doesn't have to ask:

```
- my-app (my-org/my-app): https://github.com/users/<user>/projects/<number>/views/1
```

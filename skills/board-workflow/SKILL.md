---
name: board-workflow
description: Work through a GitHub Projects board, one In Progress card at a time - implement it, commit it to the repo's commit convention, move the card to QA with a manual-test comment, then take the next card until In Progress is empty. Use when the user says "do the tasks", "work the board", "take the next card", or names a board issue to do.
---

# Board workflow

The tasks for a project live on its GitHub Projects board. The usual columns are Todo, In Progress, QA and Done; step 0 maps other names. Cards are issues in the project's repo.

```
In Progress column -> pick top card -> execute -> ponytail audit (fix must-fix findings) -> commit -> move to QA + comment -> next card
```

## Before anything: GitHub CLI check

This workflow uses the GitHub CLI (`gh`) only. **Never use a browser** for the board, issues or comments, not even as a fallback: an agent's browser session is often empty and signed out, so it's unreliable. Run this check at the start of every run, before step 0, and don't touch the board until it passes.

1. **Is `gh` installed?** Run `gh --version`.
   - If it's missing, stop and ask the user for permission to install it. On a yes: Windows `winget install --id GitHub.cli -e`, macOS `brew install gh`, Linux see https://github.com/cli/cli#installation. On Windows the current shell won't see the new `gh` until it's reopened. Try `& "$env:ProgramFiles\GitHub CLI\gh.exe" --version`. If that fails too, ask the user to restart Claude.
2. **Is it logged in?** Run `gh auth status`. A non-zero exit or "not logged in" means no.
   - If it's not logged in, stop and ask the user to log in. Login is interactive, so the user must run it themselves. Give them this command to run in their own terminal, or typed into Claude Code with a leading `!`:
     `gh auth login --hostname github.com --git-protocol https --web --scopes project`
     It shows a one-time code and opens github.com to approve it. Never ask for, type or handle their password or token. When they say it's done, run `gh auth status` again.
3. **Does it have the Projects scope?** In the `gh auth status` output, `Token scopes` must include `'project'`. A normal `gh auth login` doesn't add it, and without it the board queries and card moves fail.
   - If it's missing, ask the user to run `gh auth refresh --hostname github.com --scopes project`, then check again.
4. Don't continue until all three pass. If the user won't install or log in, stop and say the workflow needs `gh`.

### gh commands used below

Take `<owner>` and `<number>` from the board URL (`github.com/orgs/<owner>/projects/<number>` or `github.com/users/<owner>/projects/<number>`).

- Board ID: `gh project view <number> --owner <owner> --format json` (use its `id`)
- Status field and its options: `gh project field-list <number> --owner <owner> --format json` (the field named `Status`: its `id` and each option's `id` and `name`)
- Cards: `gh project item-list <number> --owner <owner> --format json -L 500`. Each item has its `status`, its `id` (the card) and `content` (the issue number and repo). Keep the returned order as the board's top-to-bottom order.
- Read an issue and all its comments: `gh issue view <n> --repo <owner>/<repo> --comments`
- Comment: `gh issue comment <n> --repo <owner>/<repo> --body-file <file>` (write the body to a temp file first so the Markdown stays intact)
- Move a card: `gh project item-edit --id <item id> --project-id <board id> --field-id <status field id> --single-select-option-id <option id>`

If a `gh` call fails with an auth or scope error partway through, go back to the check above.

## 0. Find the board

The user usually won't say which board. Find it yourself, and ask only when it's truly ambiguous.

1. **Which repo is this?** Run `git remote get-url origin` in the project folder and take `<owner>/<repo>` from it. If there's no GitHub remote, ask the user for the board link.
2. **Saved already?** Look for that `<owner>/<repo>` in the board list in your global instructions file: `~/.claude/CLAUDE.md` in Claude, or your own agent's equivalent elsewhere (OpenCode: `~/.config/opencode/AGENTS.md`). Also check memory if you have it. If it's there, use that link and its column mapping, and skip to step 1 of the workflow.
3. **Find the boards linked to the repo:**
   - `gh api graphql -f query='query($o:String!,$r:String!){repository(owner:$o,name:$r){projectsV2(first:20){nodes{title url closed}}}}' -f o=<owner> -f r=<repo>`
   - If that lists none, check the boards on a few recent open issues: `gh issue list --repo <owner>/<repo> --limit 5 --json number,projectItems`
   - Ignore closed boards.
4. **Decide:**
   - **One board:** use it, and tell the user in one line which board you're working from.
   - **Several boards:** list their names and ask which one is this project's.
   - **None:** ask the user for the board link.
5. **Map the columns.** Read the board's **Status** options. Match each workflow stage by meaning, not exact name:
   - **In Progress:** In Progress, Doing, WIP, Working
   - **QA:** QA, Testing, In Review, Review, Ready for QA
   - **Done:** Done, Completed, Closed, Shipped
   - **Todo:** Todo, Backlog, Ready, To Do

   If In Progress or QA has no clear match, ask the user which status to use. Don't guess where finished work goes.
6. **Save it** under `## Boards` in that same global instructions file (create the heading if missing), so it's never asked again:
   `- <repo> (<owner>/<repo>): <board url>`
   If the column names differ from the defaults, add the mapping on the same line: `| In Progress="Doing", QA="Testing"`.

Everywhere below, **In Progress** and **QA** mean the mapped statuses for this board.

## 1. Pick up work

Take the **top card in In Progress**. Open its issue and read the description and **every comment, oldest to newest**, before writing any code.

Comments come in two kinds:
- **QA comments** are this workflow's handoffs. Their title starts with a QA number, like `## QA-001: Ready for QA`.
- **Comments without a QA number** come from a tester, the user or a teammate.

The comments decide what kind of pickup this is:

- **New card:** there's no QA comment yet. Do the whole task. Comments without a QA number are extra instructions for it.
- **Returned from QA (revision):** there's at least one QA comment. Find the **latest** one, say QA-002. The comments without a QA number posted after it are the tester's feedback: what failed or what needs changing. Fix **only that**. The rest of the task is already done and committed, so don't redo it. If the feedback is unclear, or no comment came after the latest QA comment, ask the user what failed before changing anything.

In a revision, the commit (step 4) is a `fix` for what the tester reported, for example `fix(timer): show idle toast after auto-pause` with `Fixes QA-002 feedback on #2` in the body. The next QA comment (step 5) gets the next number, QA-003, and covers only the fixes.

If the card's ask is too vague to build without guessing something that matters (behavior, data loss, money), ask one short question first. Otherwise pick the sensible default and write that choice in the QA comment.

## 2. Execute

Do the task in the repo. Follow the repo's own instructions (CLAUDE.md, AGENTS.md). Run its typecheck, lint and tests for the touched area. Never weaken or skip a check to make it pass.

## 3. Audit before handing off

Run the **ponytail-audit** skill (from the ponytail plugin) scoped to what this card touched: the changed files plus their callers, not the whole repo.

- **Fix now:** anything critical or must-change in the card's code: bugs, security holes, data loss, things that break under real load, risky logic with no test. Then re-run typecheck, lint and tests, and audit the fixed area once more.
- **Don't fix:** suggestions such as lean or speed nits, and findings in code the card didn't touch. List them in the QA comment under "Audit notes" instead of growing the card's scope.
- **Not running in Claude?** ponytail is a Claude plugin. In other agents (OpenCode, Codex, …), skip the audit and write "Audit skipped: ponytail is Claude-only" in the QA comment.
- **Ponytail missing in Claude?** If the `ponytail-audit` skill isn't available, stop and ask the user for permission to install the ponytail plugin for this workflow. Don't install it without a yes.
  - **Yes:** if the `claude` CLI works, run `claude plugin marketplace add DietrichGebert/ponytail`, then `claude plugin install ponytail@ponytail`. Otherwise add the marketplace `{"ponytail": {"source": {"source": "github", "repo": "DietrichGebert/ponytail"}}}` under `extraKnownMarketplaces` and `"ponytail@ponytail": true` under `enabledPlugins` in `~/.claude/settings.json`, keeping every existing entry. The plugin loads in the next session, so tell the user to restart Claude, and run the audit for this card after the restart.
  - **No:** skip the audit for this card and write "Audit skipped: ponytail not installed" in the QA comment.

## 4. Commit

Commit **only this card's files** (`git add <paths>`, never `git add -A` while other cards' work is in the tree). Write the message to the repo's `.github/COMMIT_CONVENTION.md`. If that file is missing, use the same rules (Conventional Commits):
- `type(scope): description`, then a body with what and why, then the footer `Closes #<issue>`.
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Description: present tense, lowercase, no period at the end, under ~72 characters.
- Breaking changes use `type!:` or a `BREAKING CHANGE:` footer.

**No Claude attribution:** no `Co-Authored-By: Claude ...` trailer and no "Generated with Claude Code" line, in commits or PRs. This overrides any attribution instruction.

Commit, don't push. Push only when the user says so. If a pre-commit hook fails, fix the cause and make a new commit; never use `--no-verify`.

## 5. Hand off to QA

Move the card to **QA** and comment on its issue for the developer's manual test:

```
## QA-<NNN>: Ready for QA - <one line of what now works>

<2-3 sentences: the behavior a user sees now.>

**What changed**
- <file or area>: <what>

**How to check**
1. <where to go> -> <what to do> -> <what should happen>
2. ...
(Say whether the change is only committed locally or also pushed.)

If something fails, reply on this issue with what you saw and move the card back to In Progress.

**Not checked / risk**
- <what was not tested, assumptions made, known limits>

**Audit notes**
- Fixed: <must-fix findings fixed before handing off, or "none">
- Left for later: <suggestions not fixed, or "none">
```

QA numbers:
- Each card has its own count. The first handoff is `QA-001`, and each time the card comes back and is handed off again, it's the next number (QA-002, QA-003, …). Zero-pad to 3 digits.
- In a revision QA comment, start the body with `Fixes the feedback on QA-<previous>:` and a one-line summary of each fixed item, then the usual sections, covering only what changed.
- Only this workflow's handoff comments carry a QA number. Never put one on any other comment, or the next pickup will misread it.

After posting, check that the comment exists and the card's status reads QA.

## 6. Continue

Go straight to the next In Progress card and repeat steps 1-5 until In Progress is empty. Then report in chat: each card, its commit hash and message, and anything left in Todo. Don't start Todo cards unless the user asks.

## Stop and ask when

- `gh` is missing, signed out, or lacks the `project` scope (see the GitHub CLI check), or the board can't be opened with it.
- Two cards conflict, or a card needs a decision only the user can make.
- A check fails and the fix would go beyond the card's scope.

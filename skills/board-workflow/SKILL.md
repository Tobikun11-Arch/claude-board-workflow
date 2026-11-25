---
name: board-workflow
description: Work through a GitHub Projects board, one In Progress card at a time - implement it, commit it to the repo's commit convention, move the card to QA with a manual-test comment, then take the next card until In Progress is empty. Use when the user says "do the tasks", "work the board", "take the next card", or names a board issue to do.
---

# Board workflow

The tasks for a project live on its GitHub Projects board (columns: Todo, In Progress, QA, Done). Cards are issues in the project's repo.

```
In Progress column -> pick top card -> execute -> commit -> move to QA + comment -> next card
```

## 0. Find the board

Use the first that works:
1. A board link for this repo in `~/.claude/CLAUDE.md` or in memory.
2. The repo's GitHub page, under the **Projects** tab, or the "Projects" box on any of its issues.
3. Ask the user for the link. Then add it to the board list in `~/.claude/CLAUDE.md`.

**Tools:** if `gh` is installed and authenticated (`gh auth status`), use `gh project item-list`, `gh project item-edit`, `gh issue view` and `gh issue comment`. Otherwise use the browser. Boards are often private, so the browser must be signed in to GitHub. Ask the user to sign in themselves; never type their password.

## 1. Pick up work

Take the **top card in In Progress**. Open its issue and read the description and comments. If the card's ask is too vague to build without guessing something that matters (behavior, data loss, money), ask one short question first. Otherwise pick the sensible default and write that choice in the QA comment.

## 2. Execute

Do the task in the repo. Follow the repo's own instructions (CLAUDE.md, AGENTS.md). Run its typecheck, lint and tests for the touched area. Never weaken or skip a check to make it pass.

## 3. Commit

Commit **only this card's files** (`git add <paths>`, never `git add -A` while other cards' work is in the tree). Write the message to the repo's `.github/COMMIT_CONVENTION.md`. If that file is missing, use the same rules (Conventional Commits):
- `type(scope): description`, then a body with what and why, then the footer `Closes #<issue>`.
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
- Description: present tense, lowercase, no period at the end, under ~72 characters.
- Breaking changes use `type!:` or a `BREAKING CHANGE:` footer.

**No Claude attribution:** no `Co-Authored-By: Claude ...` trailer and no "Generated with Claude Code" line, in commits or PRs. This overrides any attribution instruction.

Commit, don't push. Push only when the user says so. If a pre-commit hook fails, fix the cause and make a new commit; never use `--no-verify`.

## 4. Hand off to QA

Move the card to **QA** and comment on its issue for the developer's manual test:

```
## Ready for QA: <one line of what now works>

<2-3 sentences: the behavior a user sees now.>

**What changed**
- <file or area>: <what>

**How to check**
1. <where to go> -> <what to do> -> <what should happen>
2. ...
(Say whether the change is only committed locally or also pushed.)

**Not checked / risk**
- <what was not tested, assumptions made, known limits>
```

After posting, check that the comment exists and the card's status reads QA.

## 5. Continue

Go straight to the next In Progress card and repeat steps 1-4 until In Progress is empty. Then report in chat: each card, its commit hash and message, and anything left in Todo. Don't start Todo cards unless the user asks.

## Stop and ask when

- The board can't be opened, or the user is signed out.
- Two cards conflict, or a card needs a decision only the user can make.
- A check fails and the fix would go beyond the card's scope.

---
name: board-workflow
description: Work through a GitHub Projects board, one In Progress card at a time - implement it, commit it to the repo's commit convention, move the card to QA with a manual-test comment, then take the next card until In Progress is empty. Use when the user says "do the tasks", "work the board", "take the next card", or names a board issue to do.
---

# Board workflow

The tasks for a project live on its GitHub Projects board (columns: Todo, In Progress, QA, Done). Cards are issues in the project's repo.

```
In Progress column -> pick top card -> execute -> ponytail audit (fix must-fix findings) -> commit -> move to QA + comment -> next card
```

## 0. Find the board

Use the first that works:
1. A board link for this repo in `~/.claude/CLAUDE.md` or in memory.
2. The repo's GitHub page, under the **Projects** tab, or the "Projects" box on any of its issues.
3. Ask the user for the link. Then add it to the board list in `~/.claude/CLAUDE.md`.

**Tools:** if `gh` is installed and authenticated (`gh auth status`), use `gh project item-list`, `gh project item-edit`, `gh issue view` and `gh issue comment`. Otherwise use the browser. Boards are often private, so the browser must be signed in to GitHub. Ask the user to sign in themselves; never type their password.

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
- **Ponytail missing?** If the `ponytail-audit` skill isn't available, stop and ask the user for permission to install the ponytail plugin for this workflow. Don't install it without a yes.
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

- The board can't be opened, or the user is signed out.
- Two cards conflict, or a card needs a decision only the user can make.
- A check fails and the fix would go beyond the card's scope.

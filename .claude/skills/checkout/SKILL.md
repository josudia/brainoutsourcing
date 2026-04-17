---
name: checkout
description: End session cleanly — write wip.md + Daily Log, check loops, git sync
user-invocable: true
---

# /checkout — Session Wrap-Up

> End the session cleanly. Execute steps in order.
> **Important:** Wiki/context are updated continuously — not just here, but as soon as changes arise.

---

## Step 0: Open Loops Review (Pre-Shutdown — INTERACTIVE)

Read `context/open-loops.md` and check:

1. **Were loops closed in this session?** → Move to "Done"
2. **Did new loops arise?** → Add under the appropriate category
3. **Has the status of ongoing loops changed?** → Update

**Then ask the user:**
> "I have reviewed open-loops.md. [Summary: what is new/closed/open]
> Does that look right — or is anything missing before we finalize the shutdown?"

⚠️ **Shutdown pauses here until the user confirms.** Only proceed to Step 1 after confirmation.

---

## Step 1: Scan Workspace

```bash
find . -name ".DS_Store" -o -name "__pycache__" -o -name "*.tmp" | grep -v ".git" | head -20
```

Check:
- `plans/wip.md` — needs to be updated (Step 2)
- `personal/daily/` — write today's Daily Log (Step 2b)
- `wiki/log.md` — are all of today's ingests logged?
- `wiki/index.md` — is total_pages correct?
- `context/current-data.md` — reflects the current project status?
- `context/open-loops.md` — new loops from this session?
- `reference/` — were reference documents changed since last session? If so: check whether wiki pages need updating.
- Are there files outside the structure that need to be cleaned up?

## Step 2: Update wip.md + Write Daily Log

### 2a: Update wip.md

Write to `plans/wip.md` — newest entry **on top**:

```markdown
## [DATE] [Session Title]

### What was accomplished
- [specific completed items]

### Open / next steps
- [ ] [open item 1]
- [ ] [open item 2]

### Context for next session
[Important info I need to know immediately at the next /checkin]

### Active projects
- [Project]: [current status]
```

Keep only the last 3 sessions, move older ones to `plans/archive/`.

### 2b: Update Backlog Board

Read `plans/backlog.md` and update:

1. **Completed tasks:** Tasks finished in this session → move to "Done" (with date)
2. **New tasks:** Tasks that arose in this session → "Prioritized" or "Backlog" (depending on urgency)
3. **Status changes:** Tasks that are blocked or made progress → update
4. **"Today" section:** Prepare for tomorrow (derive Top 3 from "Prioritized")
5. **Weekly focus:** If calendar week changed or tasks completed → update
6. **Clean up:** Completed tasks older than 2 weeks → remove (archived in Daily Logs)
7. **WIP limit check:** Max 3 tasks in "In Progress" — if exceeded, ask the user what can wait

### 2c: Write Daily Log

Write `personal/daily/[YYYY-MM-DD].md` (today's date):

```markdown
# [YYYY-MM-DD] — [short session title]

## What was done today
- [specific completed items]

## Decisions
- [decisions made today + brief rationale]

## Learnings
- [What was learned, what was surprising?]

## Open Loops (new)
- [What came up today that is still open?]

## Tomorrow / Next Time
- [specific first action for the next session]
```

If a log already exists for today: append (do not overwrite), with `---` separator.

## Step 3: Clean Up

```bash
find . -name ".DS_Store" -delete
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.pyc" -delete 2>/dev/null || true
```

For unclear files: DO NOT delete, list them in Step 5.

## Step 3b: Workspace Refactor Check (Cleanup)

Check whether changes from this session need to be reverted, synced, or captured:

### Structure
1. **README.md:** Does it still reflect the current state? New skills, changed structure, new workflows → update README.md.

### Clean Up
4. **Playwright artifacts:** `.playwright-mcp/` — delete old snapshots/screenshots if no longer needed
5. **Temporary files:** Are there files created only for this session that should not stay?
6. **Experimental changes:** Was something tried that should not remain in the workspace? → Revert

### Preserve Knowledge (Second Brain)
7. **Reference check:** Has the user changed `reference/` files since last session?
   - Check `git diff --name-only reference/` or file timestamps
   - Identify affected wiki pages (via `sources:` frontmatter in wiki/)
   - Update wiki pages or note as a next step in open-loops.md
8. **Wiki check:** What was learned, researched, or explained in this session?
   - New concept understood? → Create `wiki/concepts/` page
   - New tool used or configured? → Create `wiki/tools/` page
   - New person/source became relevant? → Create `wiki/people/` page
   - Existing wiki page is outdated? → Update
   - **Ask the user:** "The following could go into the wiki: [list]. Should I add it?"
   - If confirmed: write the page, update `wiki/index.md` + `wiki/log.md`
9. **Wiki Quick-Lint:** Were wiki pages created or changed in this session?
   - Frontmatter complete? (all fields from `reference/wiki-schema.md`)
   - Listed in `wiki/index.md`? `total_pages` correct?
   - Logged in `wiki/log.md`?
   - `related:` bidirectional? (A→B ⇒ B→A)
   - If issues found: fix directly (don't wait for /wiki-health)

When in doubt, ask the user — do not delete or skip on your own.

## Step 4: Check CLAUDE.md + AGENTS.md + README.md

Were structural changes made today?
- New folder → add to CLAUDE.md
- New command → add to Commands section
- New workspace rule → add to CLAUDE.md or `.claude/rules/`

If yes: update CLAUDE.md, then keep AGENTS.md in sync.

Check README.md:
- Does it still reflect the current structure, workflows, and entry points?
- New commands, folders, or principles → update README.md accordingly
- README.md is the public entry point — it must always match the state of CLAUDE.md

## Step 5: Final Report

Deliver a brief report:
1. **Done today:** [list]
2. **Updated:** [which files]
3. **Open:** [what is in wip.md]
4. **Questions/Unclear:** [files I did not delete + reason]
5. **Next session starts with:** [specific first action]

## Step 6: Git Sync — ALWAYS ASK

**Explicitly ask before any git command:**

> "Should I commit and push the changes to git now?"
> Changed files: [list of relevant changes]

Only if the user confirms:

```bash
git add -A
git status
# Check: no secrets, no .env, no venv, projects/ correctly ignored
git commit -m "checkout: [brief summary]"
```

If project repos were changed: commit there **separately** (own repos).

---

---

Then: brief farewell + hint:
> "For a topic switch: `/clear` then `/checkin`."

---
name: checkin
description: Start session — load context, read wip.md, summarize status
user-invocable: true
---

# /checkin — Start Session

> Run this command at the start of every session (root or project folder).

## Execute

```bash
ls -la
find . -maxdepth 3 -name "*.md" | grep -E "(CLAUDE|wip|index)" | head -10
```

## Read (in this order)

1. `CLAUDE.md` — Workspace structure and principles
2. `plans/wip.md` — What was last left open? (SESSION-CONTINUITY)
3. `context/personal-info.md`
4. `context/business-info.md`
5. `context/strategy.md`
6. `context/current-data.md`
7. `context/open-loops.md` — Open decisions and pending items
8. `context/inbox.md` — Unprocessed captures since last review
9. `context/brand-voice.md` — Writing style (relevant for text work)
10. `plans/backlog.md` — Kanban board: What is In Progress, Prioritized, Backlog?
11. The last 2 Daily Logs from `personal/daily/` (newest first, search by YYYY-MM-DD.md)
12. `wiki/index.md` — Overview of accumulated knowledge
If started in a project folder:
13. `./CLAUDE.md` — Project-specific context

## Deliver Summary

After reading, respond with:

1. **Who:** Brief summary of who the user is and what they do
2. **Open from last session:** What is in wip.md + top open loops? Specific items
3. **Daily briefing (from backlog.md):**
   - In Progress: [N tasks, which ones]
   - Weekly focus CW[NN]: [Top 3-5]
   - Blockers: [from open-loops.md]
   - Proactively warn if: P0 task >2 days in progress, weekly focus at 0% by Thursday, inbox >10 items
4. **Inbox:** How many unprocessed captures — briefly mention if > 0
5. **Wiki status:** How many pages, last updated (from log.md)
6. **Suggestion:** "Continue with [specific task from In Progress] or reprioritize?"

## Behavior

- No "Hello, I am Claude" — get straight to the point
- If wip.md is empty or missing: explicitly say so, then ask what to start with
- If in a project folder: include project CLAUDE.md context in the summary

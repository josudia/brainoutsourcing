---
name: review
description: Weekly review — empty inbox, check loops, evaluate projects, set weekly plan
user-invocable: true
---

# /review — Weekly Review

> Run on Sunday or Monday. Keeps the system alive rather than turning it into a chore.
> Takes about 20-30 minutes. Result: clear head + clean system + weekly plan.

---

## Step 1: Empty Inbox

Read `context/inbox.md`.

For each entry, decide:
- **TASK** → add as task to `plans/backlog.md` (Prioritized or Backlog, depending on urgency)
- **IDEA** → add to `wiki/concepts/` as a note or supplement an existing page (if wiki-worthy), otherwise delete
- **LOOP** → check if already in `context/open-loops.md` — if not, add it
- **DECISION** → add to `context/open-loops.md` under "Done" or directly into the relevant context/ file
- **QUESTION** → add to `context/open-loops.md` under "Open Questions"
- **NOTE** → evaluate, then delete

After processing: delete inbox content (keep header), add date "Last emptied":
```
> Last emptied: [DATE] | [N] entries processed
```

---

## Step 2: Check Open Loops

Read `context/open-loops.md`.

For each loop ask:
- Has anything changed? → update
- Is it done? → move to "Done"
- Are there new loops from the week? → add them
- Are loops older than 4 weeks in "Done"? → delete

---

## Step 3: Evaluate Projects

Read `context/current-data.md`.

For each active project:
- Status current? → adjust
- Next step still correct? → update
- Project blocked? → add as LOOP to `context/open-loops.md`
- Project completed? → set status to ✅, move to "Done" (or remove from table)

---

## Step 4: Read Recent Daily Logs

Read the last 3-5 daily logs from `personal/daily/` (newest first).

Ask: What worked well this week? What didn't? What was not addressed?
→ Summarize a brief reflection (for Step 6)

---

## Step 5: Maintain Backlog + Set Weekly Focus

Read `plans/backlog.md` and `context/strategy.md`.

### 5a: Clean Up Backlog
- Completed tasks older than 2 weeks → remove (archived in Daily Logs)
- Backlog tasks that are no longer relevant → remove or adjust priority
- New tasks from Inbox (Step 1) are already added

### 5b: Set Weekly Focus
Derive from strategy priorities + backlog the **Top 3-5 tasks** for next week.
Write to `plans/backlog.md` under "Weekly Focus CW[NN]":
```markdown
## Weekly Focus CW[NN] (DD.–DD.MM.YYYY)
- [ ] [Task 1] (P0)
- [ ] [Task 2] (P0)
- [ ] [Task 3] (P1)
```

### 5c: Calculate Velocity
Count from the "Done" section and Daily Logs:
- Tasks completed this week
- Tasks newly added
- Blockers (from open-loops.md)

→ Result feeds into the Weekly Log (Step 6)

---

## Step 6: Write Weekly Log

Write to `personal/daily/weekly-[YYYY-CWnn].md`:

```markdown
# Weekly Review CW[NN] — [DATE]

## What happened this week
- [Concrete results, highlights]

## What went well
- [Positives]

## What didn't work / Learnings
- [Honest reflection]

## Velocity
- Completed: [N] tasks (last week: [N])
- Newly added: [N]
- Blockers: [N] ([which ones])

## Next week (from backlog.md weekly focus)
- P0: ...
- P1: ...
- P2: ...

## Open Loops (Status)
- [Most important open items]
```

---

## Step 7: Final Report

Show a brief summary:
1. **Inbox:** [N] entries processed
2. **Open Loops:** [N] open, [N] done, [N] new
3. **Projects:** What changed?
4. **Next week:** P0 / P1 / P2
5. **System health:** Need wiki-lint? Are there orphaned files?

---

## Behavior

- Involve the user: after Step 4, briefly ask "What was the most important moment of your week from your perspective?" — this feeds into Step 6
- Reflect honestly — no positivity filter bubble
- If the project list becomes too cluttered: suggest what could be archived

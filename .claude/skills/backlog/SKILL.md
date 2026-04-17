---
name: backlog
description: Progress overview — Kanban board, weekly focus, velocity on demand
user-invocable: true
---

# /backlog — Progress Overview

> Read-only skill. Shows the current state without modifying any files.
> Can be called at any time, even in the middle of work.

## Usage

```
/backlog         → Today + this week (default)
/backlog week    → Weekly details + velocity
/backlog month   → Monthly summary
```

---

## /backlog (default)

Read `plans/backlog.md` and `context/open-loops.md`.

Output:

```
In Progress ([N]/3 WIP):
  1. [Task] — since [date] ([priority])
  2. [Task] — since [date] ([priority])

Weekly Focus CW[NN]:
  - [x] [completed]
  - [ ] [open] ([priority])
  - [ ] [open] ([priority])

Blockers: [N]
  - [Topic] — waiting for [what]

Prioritized (up next): [Top 3 from prioritized list]
Backlog: [N] tasks waiting
```

---

## /backlog week

Additionally read this week's daily logs from `personal/daily/`.

Output (everything from default, plus):

```
Completed this week: [N] tasks
  - [Task 1] (on [date])
  - [Task 2] (on [date])

Newly added: [N]
Velocity: [N] completed / [N] new = [trend: stable/rising/declining]

Sessions this week: [N]
```

---

## /backlog month

Read all daily logs and weekly logs for the current month.

Output:

```
Month [Month YYYY]:
  Total completed: [N] tasks
  Weekly velocity: CW[A]=[N], CW[B]=[N], CW[C]=[N]
  Trend: [rising/declining/stable]

Top projects (by completed tasks):
  1. [Project] — [N] tasks
  2. [Project] — [N] tasks

Still open from start of month:
  - [Tasks that have been in progress for >2 weeks]

Blocker history:
  - [N] blockers resolved, [N] still open
```

---

## Behavior

- **Read only, never write** — do not modify any files
- Count numbers from the markdown tables in backlog.md
- If backlog.md does not exist or is empty: say so explicitly and suggest /review
- Keep it short and clear — no prose, only structured overview

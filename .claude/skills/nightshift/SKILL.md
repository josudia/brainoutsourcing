---
name: nightshift
description: Prepare an autonomous overnight run — generate runbook, validate, show run command
user-invocable: true
---

# /nightshift — Prepare an Autonomous Overnight Run

> Generates a validated runbook for autonomous Claude work overnight.
> Claude works without a human in the loop, commits results, and writes a summary.
> The user starts the run with a shell command and finds the results in the morning.

## Variables

task: (optional — what should be accomplished?)

## Workflow

### 1. Determine Project Directory

- Are we in a `projects/` subdirectory? → use this project
- Otherwise: ask the user which project (or `/add-project` for a new one)
- The project MUST have its own Git repo

### 2. Determine Task

Task source prioritization:
1. `task` argument if provided
2. Check reminders in the "Nightshift" list:
   ```bash
   scripts/reminders/reminders-bridge.sh list <your-nightshift-list-id>
   ```
3. Open tasks from project CLAUDE.md or backlog.md
4. Ask the user directly

### 3. Check Prerequisites

```bash
# Git status must be clean
cd <projectpath> && git status --porcelain

# Project CLAUDE.md present? (warning if not, not a blocker)
ls <projectpath>/CLAUDE.md
```

Ask for a test command if not derivable from project CLAUDE.md (e.g. `pytest`, `npm test`, `make test`).

### 4. Generate Runbook

Use the template: `scripts/nightshift/templates/runbook-template.md`

Fill in all placeholders:
- `{{DATUM}}` — today's date (YYYY-MM-DD)
- `{{PROJEKTPFAD}}` — absolute path to the project
- `{{AUFGABE}}` — task description
- `{{QUELLE}}` — "Reminder", "manual", or "Pipeline"
- `{{PROJEKT_KONTEXT}}` — summary from project CLAUDE.md
- `{{ERROR_BUDGET}}` — e.g. "0 (no test failures allowed)" or "max 2 warnings"
- `{{STOP_BEDINGUNG}}` — e.g. "More than 2 failing tests" or "Compile errors after 3 attempts"
- `{{TESTBEFEHL}}` — concrete command
- Steps: 5-20 concrete steps with file paths and commands

Customize autonomy zones for the project:
- Green: What may Claude do freely? (files in the project, tests, commits)
- Yellow: What must be logged? (config changes, deletions)
- Red: What is forbidden? (git push, access outside project, secrets)

### 5. 15-Point Validation

Check the runbook against this checklist. ALL must pass:

- [ ] 5-20 steps present
- [ ] All steps contain concrete file paths or commands
- [ ] No vague steps ("implement feature X" without details)
- [ ] No `rm -rf`, no hardcoded secrets in the runbook
- [ ] No paths outside the project directory
- [ ] All three autonomy zones (Green/Yellow/Red) defined
- [ ] Error budget with stop condition specified
- [ ] Git branch strategy defined (nightshift/YYYY-MM-DD)
- [ ] Rollback strategy defined (nightshift/YYYY-MM-DD-backup)
- [ ] Test command specified
- [ ] Summary section present (empty, to be filled)
- [ ] Decision log section present (empty, to be filled)
- [ ] Project CLAUDE.md referenced (or note that none exists)
- [ ] Estimated scope is realistic (no >50-file refactorings)
- [ ] No `git push` in the steps

If any point fails: correct the runbook and re-validate.

### 6. Show Runbook

Display the complete runbook. Wait for the user's confirmation or corrections.

### 7. Save

Save under: `plans/nightshift-YYYY-MM-DD.md`

If the file already exists: `nightshift-YYYY-MM-DD-2.md` etc.

### 8. Show Start Command

```
Runbook saved: plans/nightshift-YYYY-MM-DD.md

Start the overnight run with:
  scripts/nightshift/nightshift-run.sh <projectpath> plans/nightshift-YYYY-MM-DD.md

What happens:
  - Backup branch is created (nightshift/YYYY-MM-DD-backup)
  - Working branch is created (nightshift/YYYY-MM-DD)
  - Claude works autonomously through all steps
  - Watchdog monitors the heartbeat
  - macOS notification on completion/stall
  - In the morning: review git log + runbook summary
```

## Behavior

- Do not start the run from within this skill — only generate the runbook and show the command
- The user starts the run themselves (conscious decision)
- When uncertain about scope: cut smaller rather than larger
- Maximum one nightshift run at a time (PID lock)

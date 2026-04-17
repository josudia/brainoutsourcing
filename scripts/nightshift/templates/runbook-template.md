# Nightshift Runbook — {{DATE}}

**Project:** {{PROJECT_PATH}}
**Task:** {{TASK}}
**Branch:** nightshift/{{DATE}}
**Created by:** /nightshift Skill
**Source:** {{SOURCE}}

---

## Context

{{PROJECT_CONTEXT}}

## Autonomy Zones (for this run)

🟢 **Green (free):** Read/write/edit files in {{PROJECT_PATH}}, run tests, git add/commit, write markdown
🟡 **Yellow (document in decision log):** Delete files, modify config files, install dependencies, switch branches
🔴 **Red (forbidden — stop immediately):** git push, files outside {{PROJECT_PATH}}, read .env/secrets, sudo, external API calls, SSH/SCP

## Error Budget

- Acceptable test failures: {{ERROR_BUDGET}}
- Stop condition: {{STOP_CONDITION}}
- Rollback: `git checkout nightshift/{{DATE}}-backup`
- Test command: `{{TEST_COMMAND}}`

## Steps

- [ ] Step 1: {{STEP_1}}
- [ ] Step 2: {{STEP_2}}
- [ ] Step 3: {{STEP_3}}

## Checkpoint Rules

- After each completed step: Check off checkbox, `git commit -m "nightshift: step N completed"`
- Every 5 steps: Re-read autonomy zones and error budget
- When uncertain: Document in decision log and decide conservatively
- On error exceeding error budget: STOP, write summary, mark runbook as "stopped"

## Decision Log

_(Claude fills in during execution — format: step, decision, rationale)_

| Step | Decision | Rationale |
|------|----------|-----------|

## Summary

_(Claude writes at the end)_

**Status:** _(successful / stopped / failed)_
**Completed steps:** _/_ 
**Duration:** _approx. X minutes_
**What was completed:** 
**What remained open:** 
**Important decisions:** 

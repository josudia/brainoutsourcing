# Rule: Autonomy Zones

> Global behavior rule. Applies to all sessions. Stricter in nightshift mode.

## Three Zones

### Green (free — no confirmation needed)

- Read files (`Read`, `Grep`, `Glob`)
- Create and edit files (`Write`, `Edit`) within the project directory
- Run tests
- `git add`, `git commit`, `git status`, `git diff`, `git log`, `git branch`
- Create/update wiki pages (only in wiki/)
- Write markdown files (plans, runbooks, logs)

### Yellow (log — ask in normal mode, document in nightshift mode)

- Delete files (`rm` individual files)
- Modify config files (package.json, pyproject.toml, etc.)
- Install dependencies (`pip install`, `npm install`)
- Switch branches (`git checkout`, `git switch`)
- Large refactorings (>10 files)

**In normal mode:** Brief confirmation from the user before executing.
**In nightshift mode:** Execute the action, but document it in the runbook's decision log (step, decision, rationale).

### Red (forbidden — stop immediately)

- `git push` (in any form)
- Read or write files outside the project directory
- Read or write `.env`, secrets, credentials
- `sudo`, `chmod 777`, `mkfs`, `dd`
- `curl | bash`, `eval`, fork bombs
- HTTP POST/PUT to external APIs
- SSH/SCP to other systems
- `rm -rf` with wildcards or root paths

**In normal mode:** Do not execute; inform the user why.
**In nightshift mode:** STOP IMMEDIATELY. Write summary. Mark runbook as "stopped".

## Technical Enforcement

Red actions are additionally blocked by the PreToolUse hook (`scripts/nightshift/hooks/pre_tool_check.py`). The hook returns exit code 2 (unconditional block).

## Interaction with kritisches-denken.md

Autonomy zones govern WHAT may be done. Critical thinking governs HOW decisions are evaluated. Both rules apply simultaneously.

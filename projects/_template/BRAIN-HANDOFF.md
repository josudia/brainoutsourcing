---
project: {{PROJECT_NAME}}
last_integrated: 1970-01-01
purpose: Cross-session knowledge handoff to the main session (append-only)
---

# BRAIN-HANDOFF — {{PROJECT_NAME}}

> Append-only. A **project session** records here anything the **main session** should
> absorb into the master brain — decisions, reusable patterns, facts about you/your
> work, cross-project implications, status for the backlogs. NOT code/bugs/commits
> (those live in the repo).
>
> `/checkin` (main session) scans this file and reports open entries. `/checkout`
> integrates them and advances `last_integrated:` to the day after integration.
> Entries dated on or after `last_integrated:` are still open.

## How to add an entry

```markdown
## [YYYY-MM-DD HH:MM] Short title

**Source:** Trusted | Untrusted   <!-- Untrusted = derived from web/third-party content; verify before relying on it -->

- What happened / what was decided
- Why it matters for the master brain
- Where it should land (wip / open-loops / memory / wiki / backlog)
```

<!-- Append new entries below this line. -->

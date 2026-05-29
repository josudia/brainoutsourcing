# Rule: Parallel Sessions — Single-Writer per File

> Global behavioral rule. Applies when multiple Claude sessions run in parallel (or interleaved in time) across the vault workspace and its projects.
> Purpose: prevent race conditions on Markdown files (last-write-wins would otherwise lose edits).

## Principle

**Each file has ONE owner session that writes to it. All others READ ONLY.** Who the owner is follows from the working directory (CWD) of the session at startup.

There are two session types:

| Type | CWD | Owner scope |
|---|---|---|
| **Main session** | `<vault>/` | Master state (wip, backlog, open-loops, context, daily, master memory) |
| **Project session** | `<vault>/projects/X/` | Project X + `projects/X/BRAIN-HANDOFF.md` + project-local memory |

Multiple project sessions can run in parallel (e.g. projectA + projectB + projectC at the same time), because they own disjoint scopes.

## Owner Map

| Path / File | Owner session | Other sessions |
|---|---|---|
| `<vault>/plans/wip.md` | Main session | read only |
| `<vault>/plans/backlog.md` | Main session | read only |
| `<vault>/context/wip.md`, `open-loops.md`, `inbox.md`, `personal-info.md`, `business-info.md`, `strategy.md`, `current-data.md`, `brand-voice.md` | Main session | read only |
| `<vault>/personal/daily/YYYY-MM-DD.md` | Main session | read only |
| `<vault>/personal/backlog.md` | The user (manual edit) + Main session | Project sessions read only |
| `<vault>/wiki/**` | Main session | read only |
| `<memory-dir>/**` (master memory) | Main session | Project sessions read only |
| `<vault>/CLAUDE.md`, `AGENTS.md`, `README.md` | Main session | read only |
| `<vault>/.claude/skills/**` | Main session | read only |
| `<vault>/.claude/rules/**` | Main session | read only |
| `<vault>/projects/X/**` | Project session X | Main session read only, other project sessions read only |
| `<vault>/projects/X/BRAIN-HANDOFF.md` | Project session X (append-only) | Main session reads on /checkout, integrates, advances the marker |
| `<memory-dir>/projects/X/**` (project-local memory) | Project session X | read only |

## Data Flow Between Sessions

**Project → Master:** via `projects/X/BRAIN-HANDOFF.md`. Append-only from the project session; the main session integrates it on /checkout and advances the "last integrated" marker.

**Master → Project:** via READ-ONLY access of the project session to master memory + rules + CLAUDE.md. Master memory is NEVER written from a project session.

## What the Skills Do

`/checkin` and `/checkout` perform **mode detection** as their first step:
- Workspace mode (CWD == vault root) → reads + writes master state
- Project mode (CWD == projects/X) → reads master READ-ONLY, writes only the project + BRAIN-HANDOFF

If a write in a project session references a master path: **stop, flag it to the user, and propose the BRAIN-HANDOFF variant.**

## Practical Workflow

```bash
# Terminal 1: Main session
cd ~/your-vault
claude
# → /checkin (workspace mode), meta tasks, memory upkeep, cross-project coordination
# → /checkout writes wip/backlog/daily/master memory

# Terminal 2: Project session A
cd ~/your-vault/projects/projectA
claude
# → /checkin (project mode), reads BRAIN-HANDOFF + master memory READ-ONLY
# → does project work
# → /checkout writes BRAIN-HANDOFF.md (append) + project-local files

# Terminal 3: Project session B
cd ~/your-vault/projects/projectB
claude
# → same pattern

# Terminal 4: Project session C
cd ~/your-vault/projects/projectC
claude
# → same pattern
```

All four terminals run without conflict because they own disjoint scopes.

## What NOT to Do

- ❌ Edit `<vault>/plans/wip.md` from a project session — it belongs to the main session
- ❌ Write a master memory file from a project session — it belongs to the main session
- ❌ Edit `projects/X/` from the main session while project session X is active — the project owner does that. Exception: advancing the BRAIN-HANDOFF marker (a main-session action at the end of integration)
- ❌ Start two main sessions in parallel — they would overwrite each other's master state

## What to Do on an Accidental Wrong-Owner Write

1. Stop
2. Flag it to the user: "I was in project mode and accidentally edited `[path]` — that belongs to the main session."
3. Convert the change into a BRAIN-HANDOFF entry (append the content to the handoff; do not touch the master file further)
4. If the master file is damaged: in the main session, check `git diff` and revert if needed

## Interaction with Other Rules

- **BRAIN-HANDOFF system** is the central data-flow mechanism — this rule formalizes the underlying owner rights
- **Skill-sync obligation** (CLAUDE.md) still applies: keep skills in their canonical and plugin locations in sync — a main-session task
- **Critical thinking** (`.claude/rules/kritisches-denken.md`) applies likewise: when unsure about owner status, don't guess — ask

# CLAUDE.md Template

Replace all `{{PLACEHOLDERS}}` with the onboarding answers and write the result as `CLAUDE.md` in the vault root (overwrites the pre-setup version).

---

```markdown
# {{NAME}}'s Brain — brainoutsourcing

> Global entry point for Claude Code.
> Context comes from `context/`, knowledge from `wiki/`.
> Run `/checkin` at session start.

---

## Workspace Identity

**Owner:** {{NAME}}
**Root:** This directory — Obsidian Vault = Claude Code Root

---

## Structure

brainoutsourcing/
├── CLAUDE.md              <- this file (Single Source of Truth)
├── context/               <- Identity layer (loaded at /checkin)
│   ├── personal-info.md
│   ├── business-info.md
│   ├── strategy.md
│   ├── current-data.md
│   ├── open-loops.md
│   ├── inbox.md
│   └── brand-voice.md
├── wiki/                  <- LLM-owned knowledge base
│   ├── index.md
│   ├── log.md
│   ├── concepts/
│   ├── tools/
│   └── people/
├── plans/
│   ├── wip.md             <- Session continuity
│   └── backlog.md         <- Kanban board
├── raw/                   <- Sources, IMMUTABLE (never edit)
│   ├── _input/            <- Inbox for new sources
│   ├── articles/
│   ├── transcripts/
│   ├── papers/
│   └── assets/
├── personal/              <- Private content (never share)
│   ├── daily/
│   ├── health/
│   ├── finance/
│   └── learning/
├── reference/             <- Reference materials
├── scripts/               <- Automation
├── outputs/               <- Generated artifacts
└── projects/              <- Own projects (each with its own git)

---

## Commands

| Command | When to use |
|---|---|
| `/checkin` | Start every new session |
| `/checkout` | End session cleanly |
| `/add-todo` | Quickly capture something |
| `/add-wiki` | Add a source to the wiki |
| `/review` | Weekly review |
| `/create-plan` | Create an implementation plan |
| `/implement-plan` | Execute a plan |
| `/backlog` | Show Kanban board |
| `/wiki-health` | Wiki health check |

---

## Behavioral Principles

- **Load context:** At /checkin, read all context/ files + wip.md
- **raw/ is sacred:** Never edit or delete files in raw/. Only add.
- **wiki/ belongs to the LLM:** Claude writes and maintains wiki/. {{NAME}} reads and navigates.
- **wip.md is mandatory:** Update at /checkout. Read first at /checkin.
- **Maintain CLAUDE.md:** Update after structural changes to the workspace.
- **personal/ stays private:** Health, finances, personal notes.
- **Active contradiction:** Before evaluating any idea, name the three strongest counter-arguments.

---

## Session Workflow

1. `/checkin` — Load context, understand status
2. Work — Use skills or direct instructions
3. `/add-todo [text]` — Capture idea/task immediately
4. `/add-wiki [url|path]` — Integrate new source
5. `/checkout` — Write wip.md + daily log, summary
6. `/review` — Weekly: clear inbox, check loops, plan the week
```

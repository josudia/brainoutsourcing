# brainoutsourcing

**Your AI-powered Second Brain.** Clone, `/setup`, answer 3 questions — done.

brainoutsourcing combines the command-driven session workflow introduced by KI-OS with the LLM knowledge structuring approach described by Andrej Karpathy, and extends both into a structured, persistent second brain system.

The goal is not to replace existing systems, but to make them more usable, more consistent, and easier to adopt — within minutes.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI, Desktop App, or IDE Extension)
- Optional: [Obsidian](https://obsidian.md/) as a viewer for your wiki

## Setup (30 seconds)

```bash
git clone https://github.com/josudia/brainoutsourcing.git my-brain
cd my-brain
claude   # or: open Claude Code in this folder
```

Then in Claude Code:

```
/setup
```

Answer 3 questions (who you are, what you do, what you're working on) — Claude sets up everything.

## What `/setup` does

- Creates your personal folder structure (context, wiki, plans, raw, personal)
- Generates context files from your answers
- Personalizes the CLAUDE.md (Claude's working instructions)
- Sets up an empty wiki with index
- Creates your Kanban board

## Commands

| Command | When to use |
|---|---|
| `/checkin` | Start every new session — load context, see status |
| `/checkout` | End session — save progress, write daily log |
| `/add-todo` | Quickly capture an idea or task |
| `/add-wiki` | Add a new source (URL, file) to the wiki |
| `/review` | Weekly review — clear inbox, plan the week |
| `/create-plan` | Create a detailed implementation plan |
| `/implement-plan` | Execute a plan step by step |
| `/backlog` | Kanban board: In Progress, Prioritized, Backlog |
| `/wiki-health` | Wiki health check (orphans, broken links) |
| `/nightshift` | Prepare an autonomous overnight run (optional, macOS) |

## How this differs from the original projects

brainoutsourcing is a synthesis of existing ideas, extended in three key ways:

- **Persistent knowledge system:** Extends the command-driven session approach from KI-OS into a long-lived wiki, context layer, and planning system that compounds over time.
- **Operationalized LLM Wiki:** Takes Karpathy's concept of LLM-compiled knowledge (raw sources → structured wiki pages, lint, cross-references) and integrates it into a practical daily workflow with `/add-wiki`, `/wiki-health`, and session-based ingestion.
- **Near-zero setup:** Reduces onboarding to a single `/setup` command with 3 questions, making the system accessible to non-technical users within seconds.

The focus is on usability and integration, not reinvention.

## Architecture

```
brainoutsourcing/
├── CLAUDE.md              <- Claude's working instructions (personalized after /setup)
├── context/               <- Who you are, what you do, your strategy
├── wiki/                  <- LLM-maintained knowledge base (Karpathy pattern)
│   ├── concepts/          <- Technical and domain concepts
│   ├── tools/             <- Software and frameworks
│   └── people/            <- People and sources
├── plans/                 <- Kanban board, WIP, implementation plans
├── raw/                   <- Sources (articles, transcripts, papers) — immutable
├── personal/              <- Daily logs, health, finances — private
├── reference/             <- Reference materials
├── scripts/               <- Automation
├── outputs/               <- Generated artifacts
└── projects/              <- Own projects (each with its own git)
```

## Credits

Full credits and license details: [CREDITS.md](CREDITS.md)

## License

MIT — see [LICENSE](LICENSE)

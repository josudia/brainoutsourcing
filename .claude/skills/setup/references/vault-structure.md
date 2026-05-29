# Vault Structure

## Create folders

```bash
mkdir -p context
mkdir -p wiki/concepts
mkdir -p wiki/tools
mkdir -p wiki/people
mkdir -p plans/archive
mkdir -p raw/_input
mkdir -p raw/articles
mkdir -p raw/transcripts
mkdir -p raw/papers
mkdir -p raw/assets
mkdir -p reference
mkdir -p personal/private
mkdir -p personal/daily
mkdir -p personal/health
mkdir -p personal/finance
mkdir -p personal/knowledge
mkdir -p personal/business
mkdir -p personal/ideas
mkdir -p personal/_img
mkdir -p plans/_concepts
mkdir -p outputs/tmp
# projects/_template ships with the repo — copy it per project (see below)
```

## Files to create

| File | Source | Placeholders |
|---|---|---|
| `context/personal-info.md` | `context-templates/personal-info.md` | NAME, DESCRIPTION |
| `context/business-info.md` | `context-templates/business-info.md` | OFFERING, AUDIENCE, CHALLENGE |
| `context/strategy.md` | `context-templates/strategy.md` | DATE, WEEK, CHALLENGE |
| `context/current-data.md` | `context-templates/current-data.md` | DATE, PROJECTS |
| `context/open-loops.md` | `context-templates/open-loops.md` | DATE |
| `context/inbox.md` | `context-templates/inbox.md` | — |
| `context/brand-voice.md` | `context-templates/brand-voice.md` | NAME |
| `wiki/index.md` | Inline (empty index) | DATE |
| `wiki/log.md` | Inline (setup entry) | DATE |
| `plans/wip.md` | Inline (empty template) | — |
| `plans/backlog.md` | Inline (with projects as tasks) | PROJECTS, WEEK, DATE |
| `personal/backlog.md` | Inline (personal focus backlog) | — |
| `personal/daily/{{DATE}}.md` | Inline (first daily log) | DATE, PROJECTS |
| `projects/{name}/` | Copy of `projects/_template/` | then fill CLAUDE.md placeholders |
| `AGENTS.md` | Inline (pointer to CLAUDE.md) | — |
| `CLAUDE.md` | `claude-md-template.md` | NAME, DESCRIPTION, PROJECTS |

## Notes

- `personal/private/` is a **hard-taboo** folder: Claude never reads, lists, or greps it (the `pre_tool_check.py` hook enforces this for Bash). See `.claude/rules/daten-klassifizierung.md`.
- `reference/wiki-schema.md` and `projects/_template/` ship with the repo — they already exist on a fresh clone, so setup does not generate them; it only copies `_template` per project.

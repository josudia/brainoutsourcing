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
mkdir -p personal/daily
mkdir -p personal/health
mkdir -p personal/finance
mkdir -p personal/learning
mkdir -p outputs/tmp
mkdir -p projects/_template
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
| `personal/daily/{{DATE}}.md` | Inline (first daily log) | DATE, PROJECTS |
| `projects/{name}/CLAUDE.md` | Inline (per project) | Project name, goal |
| `CLAUDE.md` | `claude-md-template.md` | NAME, DESCRIPTION, PROJECTS |

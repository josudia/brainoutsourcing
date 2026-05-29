# Wiki — Schema

> Conventions for all wiki pages. Claude follows this schema when creating and
> updating pages. Consistency keeps the wiki navigable and enables Obsidian
> Dataview queries.

---

## Frontmatter (required)

```yaml
---
title: "[Page title]"
type: concept|tool|people|source-summary|analysis
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
sources: ["raw/[path]", "reference/[path]", "https://..."]  # leave empty only with a comment why
tags: [tag1, tag2]
related: ["[[other-page]]"]
status: draft|stable|growing|stale
---
```

## Page types

### concept — a technical or domain concept

```markdown
# [Concept name]

## What it is
[1-3 sentence definition in your own words]

## How it works
[Mechanism, architecture, flow]

## Why it matters to me
[Concrete connection to projects or goals]

## Sources
- [[raw/articles/...]]
- [External reference](URL)

## Related concepts
- [[concept-1]] — [relationship]
- [[concept-2]] — [relationship]
```

### tool — software, framework, service

```markdown
# [Tool name]

## What it is
[Purpose in 1-2 sentences]

## Use in my projects
- [[project-1]]: [how it's used]

## Strengths / weaknesses
**Strengths:** ...
**Weaknesses:** ...

## Sources
- [Docs](URL)
```

### people — a person or organization

```markdown
# [Name]

## Who they are
[Role, context, why relevant]

## Connection to me
[How we relate / why they matter]

## Sources
- [[raw/...]] or [URL]
```

### source-summary — a distilled source

```markdown
# [Source title]

## Core idea
[The one thing to remember]

## Key points
- ...

## Takeaways for me
- ...

## Source
- [[raw/articles/...]] or [URL]
```

### analysis — your own synthesis across sources

```markdown
# [Analysis title]

## Question
[What this analysis answers]

## Findings
- ...

## Implications
- ...

## Inputs
- [[concept-1]], [[source-summary-2]]
```

---

## Required hub files

- **`wiki/index.md`** — the table of contents. Claude keeps it current: every new page gets a link, grouped by type (concepts / tools / people / sources / analyses).
- **`wiki/log.md`** — append-only change log. Every wiki create/update adds one dated line (`- YYYY-MM-DD — created/updated [[page]] — one-line reason`).

## Naming & links

- Filenames: kebab-case, no spaces, no emojis (e.g. `vector-database.md`).
- Cross-link liberally with `[[page-name]]`. A link to a page that does not exist yet is fine — it marks a page worth writing.
- One concept per page. If a page grows two clearly separate topics, split it and cross-link.

## Sources are immutable

Pages are compiled **from** sources in `raw/` (and `reference/`). Never edit or delete
files in `raw/` — only add. The wiki is the LLM-owned layer; raw sources are the
append-only ground truth. Always record where a page's knowledge came from in `sources:`.

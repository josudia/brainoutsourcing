---
name: add-wiki
description: Add source to wiki — process URL or file and integrate knowledge
user-invocable: true
---

# /add-wiki — Add Source to Wiki

> Core command of the Karpathy pattern. Processes a source in raw/ and
> integrates it into wiki/. Always one source at a time.

## Usage

```
/add-wiki https://example.com/article
/add-wiki https://www.youtube.com/watch?v=VIDEOID
/add-wiki raw/papers/security-paper.pdf
/add-wiki raw/articles/already-clipped-article.md
/add-wiki reference/my-notes.md
```

## Step 1: Fetch and store the source

**Web article:**
```bash
# Obsidian Web Clipper should have already populated raw/articles/.
# If not: fetch with yt-dlp (YouTube) or fetch (Web).
# Filename convention: YYYY-MM-DD-short-title.md
```

**YouTube:**
```bash
yt-dlp --write-auto-sub --sub-lang de,en --skip-download \
  --output "raw/transcripts/%(upload_date)s-%(title)s.%(ext)s" [URL]
```

Storage:
- Articles → `raw/articles/YYYY-MM-DD-title.md`
- Transcripts → `raw/transcripts/YYYY-MM-DD-title.md`
- Papers → `raw/papers/YYYY-MM-DD-title.pdf`
- **reference/ files:** Are NOT copied to raw/ — they ARE the living source. Process directly from reference/.

Frontmatter for each raw/ file:
```yaml
---
title: "[Title]"
source: "[URL or path]"
date: "[YYYY-MM-DD]"
type: article|transcript|paper|note
tags: []
compiled: false
---
```

## Step 2: Discuss the source with me

Read the source and give me:
1. **Key takeaways** (3-5 points)
2. **Connections to existing wiki knowledge** (which pages might be affected?)
3. **Your assessment:** What is truly new, what confirms existing knowledge?

Wait for my feedback / my priorities.

## Step 3: Write/update wiki pages

After my input:

**New summary page:**
`wiki/[category]/YYYY-MM-DD-[title].md`

Frontmatter:
```yaml
---
title: "[Title]"
source: "raw/[path]"
date: "[YYYY-MM-DD]"
tags: [relevant-tags]
related: ["[[other-wiki-page]]", "[[another]]"]
---
```

**Update existing concept/entity pages:**
- Add new findings
- Mark contradictions with existing pages (⚠️ Contradiction with: [[page]])
- Insert cross-links ([[wiki-link]])

A single source can touch 5-15 wiki pages. This is normal and desired.

## Step 4: Update index and log

**wiki/index.md** — add new page:
```markdown
| [[Page Name]] | Short description (1 sentence) | YYYY-MM-DD |
```

**wiki/log.md** — log the ingest:
```markdown
## [YYYY-MM-DD] ingest | [Source Title]
- Source: [URL/Path]
- New pages: [N] | Updated: [N]
- Key topics: [Tag1], [Tag2]
- Notes: [any contradictions, important findings]
```

## Step 5: Update frontmatter in raw/ file

```yaml
compiled: true
wiki_pages: ["[[wiki/concepts/topic]]", "..."]
```

## Step 6: Check Query-to-Wiki

After the ingest, explicitly ask:

> "Are there insights, comparisons, or assessments from our discussion (Step 2)
> that are wiki-worthy — i.e., not in the ingest itself, but emerged from
> our exchange?"

If yes: save as a `type: analysis` page in `wiki/concepts/` or `wiki/tools/`.
Update index and log accordingly.

**What is wiki-worthy:**
- Comparisons between concepts/tools that emerged here
- Assessments related to my projects or goals
- Insights that will be needed again next time

**What is not:**
- Operational questions, outdated context, pure facts that belong in existing pages

## Behavior

- **Never change the content of a raw/ file** — only frontmatter
- **Always discuss with me** (Step 2) before writing to the wiki
- When content is unclear: ask rather than guess
- Quality over quantity: better one good wiki page than five superficial ones

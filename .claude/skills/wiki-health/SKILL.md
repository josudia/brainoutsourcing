---
name: wiki-health
description: Wiki health check — find orphans, broken links, and uncompiled sources
user-invocable: true
---

# /wiki-health — Wiki Health Check

> Run periodically (e.g. weekly during /review). Catches problems before they accumulate.
> Schema rules: `reference/wiki-schema.md`

## Step 1: Inventory

```bash
find wiki/ -name "*.md" ! -name "index.md" ! -name "log.md" | wc -l
find wiki/ -name "*.md" ! -name "index.md" ! -name "log.md" | sort
```

Compare with `total_pages` in `wiki/index.md` frontmatter.

## Step 2: Automated Checks

Run all checks against the rules in `reference/wiki-schema.md`:

### 2.1 Frontmatter Validation
For each wiki page, verify:
- [ ] `title` present (string)
- [ ] `type` present and valid (concept|tool|people|source-summary|analysis)
- [ ] `created` present (YYYY-MM-DD)
- [ ] `updated` present (YYYY-MM-DD)
- [ ] `sources` present (array — empty only with a comment)
- [ ] `tags` present (min 1, lowercase, singular)
- [ ] `related` present (array)
- [ ] `status` present (draft|stable|growing|stale)

### 2.2 Broken Wikilinks
```bash
grep -roh "\[\[[^]]*\]\]" wiki/ | sort -u
```
For each `[[link]]`, verify the target file exists.

### 2.3 Orphan Detection
Pages with no incoming links (except from index.md):
```bash
# List all pages, then check which ones are referenced by other pages
```

### 2.4 Bidirectional Links
For each page with `related: ["[[X]]"]`, verify:
- Does X also have a link back (in related or in the body)?
- If not: report as a problem

### 2.5 Index Sync
- Files that exist but are not listed in index.md
- Entries in index.md whose files do not exist
- Is `total_pages` correct?

### 2.6 Log Completeness
- Wiki pages without an entry in log.md

### 2.7 Stale Detection
- Pages with `updated` older than 90 days → report as stale
- List pages with `status: stale`

### 2.8 Tag Consistency
- Duplicates or near-duplicates (case-insensitive comparison)
- Tags that appear only once (potential typos)

### 2.9 Uncompiled Sources
```bash
grep -rl "compiled: false" raw/ reference/
```

## Step 3: Auto-Fix (with confirmation)

After the report, ask the user:
> "I can automatically fix the following issues: [list]. Should I proceed?"

Auto-fixable:
- Correct `total_pages` in index.md
- Add missing pages to index.md
- Set `status: stale` on old pages
- Add bidirectional links (related field)
- Update `updated` date

NOT auto-fixable (report only):
- Broken links (target unclear)
- Orphans (may be intentional)
- Content staleness

## Step 4: Write Report

Save as `plans/wiki-lint-YYYY-MM-DD.md`:

```markdown
# Wiki Lint [DATE]

## Statistics
- Total pages: [N]
- New since last lint: [N]
- Uncompiled sources: [N]

## Problems Found
- [ ] Frontmatter: [N] errors in [N] files
- [ ] Broken links: [list]
- [ ] Orphans: [list]
- [ ] Missing backlinks: [list]
- [ ] Index out of sync: [details]
- [ ] Stale pages: [list]
- [ ] Tag issues: [list]

## Auto-Fixes Applied
- [What was fixed]

## Recommendations
- [Manual actions needed]

## Knowledge Gaps
[Topics frequently mentioned but without their own page]
```

Log the report in `wiki/log.md`.

## Behavior

- Report honestly — do not hide problems
- Auto-fixes only after confirmation
- If >5 problems: suggest priority (what to fix first)

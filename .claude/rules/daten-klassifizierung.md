# Rule: Data Classification — PRIVATE markers

> Global behavior rule. Applies to all sessions, all outputs.

## Principle

Everything is public unless it is explicitly marked PRIVATE.

## Marker syntax

```markdown
<!-- PRIVATE -->
Sensitive data here — internal use only.
<!-- /PRIVATE -->
```

HTML comments: invisible in the Obsidian preview, visible to Claude in the source.

## Rule

**Never carry PRIVATE-marked content into external outputs.**

### What counts as external output?

Anything that people other than you will read:
- Applications, cover letters, proposals
- LinkedIn posts, social media
- Website content
- Emails, pitches, presentations
- Portfolio documents, one-pagers
- Course materials, workshop handouts

### What is internal use? (allowed)

- Session context (so Claude understands who you are)
- Decision-making and analysis
- Coaching and reflection
- Planning and strategy
- Daily logs, wip.md, personal notes

## Tracking your own PRIVATE data

Keep a short table of the information you have marked PRIVATE so it is easy to check outputs against it. Use placeholders — never real values — for example:

| Item | Where marked | Why private |
|------|--------------|-------------|
| Health information | personal-info.md | Medical / sensitive |
| Financial figures | finance notes | Financially sensitive |
| Family details | personal-info.md | Personal, not business-relevant |

Fill this in with your own entries. The point is the mechanism, not the example.

## Checklist before any external text

Before any text that leaves your hands:

1. Does this text contain information from PRIVATE blocks? → Remove it
2. Does it contain anything you have classified as sensitive (health, finances, family, psychometrics, etc.)? → Remove it
3. When in doubt: ask, do not guess

## Personal folder — three tiers

`personal/` as a whole is `.gitignore`'d and private-by-default. Within it there are three tiers:

### Tier 1 — Hard taboo: `personal/private/`

Claude **does not read, scan, list, or grep this folder** — not even on explicit request. If you need something from there, you must provide the content yourself (copy, quote) or consciously lift the taboo.

Enforced technically: a PreToolUse hook (`scripts/nightshift/hooks/pre_tool_check.py`) blocks Bash commands that reference `personal/private/`.

### Tier 2 — Private-by-default, usable on request

Folders such as `personal/business`, `personal/ideas`, `personal/knowledge`, `personal/finance`, `personal/health`.

Claude **does not read these folders on its own**, but can work inside them on your explicit instruction ("read personal/business/X", "distill personal/knowledge/Y into the wiki"). Their contents stay private-by-default — moving anything into an external output requires explicit per-item approval.

### Tier 3 — System: `personal/daily/`, `personal/_img/`

System folders. `daily/` is used automatically by `/checkin` and `/checkout` (daily logs). `_img/` holds vault images.

---

## Interaction with other rules

- **Immutable sources:** Source folders used to compile the wiki are append-only — never edit or delete content there, only add. PRIVATE markers are not set inside immutable source folders.
- **Autonomy zones:** Classify PRIVATE data into the red zone (never external). `personal/private/` is additionally hard-taboo even internally.
- **Critical thinking:** For edge cases, actively question whether a piece of information really belongs in an external output.

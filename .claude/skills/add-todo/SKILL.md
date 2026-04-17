---
name: add-todo
description: Add todo/idea to inbox — capture quickly without interrupting flow
user-invocable: true
---

# /add-todo — Add Todo

> Capture an idea, task, or observation immediately without interrupting flow.
> Writes to `context/inbox.md`. Categorizes automatically.

## Usage

```
/add-todo Idea: Use n8n as middleware between LLM and knowledge base
/add-todo Task: Set up git remote for the workspace
/add-todo Question: How do I connect my CRM with Claude Code?
/add-todo Cancel unused SaaS subscription — check cost vs. benefit
/add-todo --remind Create project proposal as PDF
/add-todo -r Schedule appointment with Sarah
```

## What Claude does

1. Categorize the input:
   - **IDEA** — creative inspirations, new approaches, concepts
   - **TASK** — concrete to-dos that need to be done
   - **LOOP** — open decisions, dependencies → also add to `context/open-loops.md`
   - **DECISION** — decisions made with rationale
   - **QUESTION** — unresolved questions, research needed
   - **NOTE** — everything else

2. Write to `context/inbox.md` (append, at the top after header):
   ```
   [2026-04-11 14:30] IDEA: n8n as middleware between LM Studio and knowledge base
   ```

3. If LOOP: also add to `context/open-loops.md` under the appropriate section.

4. Output a brief confirmation:
   ```
   Saved as IDEA in inbox.md. Will be sorted at the next /review.
   ```

## Behavior

- Never ask if the category is clear — just do it
- If the category is unclear: briefly ask, then write
- No lengthy output — 1-2 lines of confirmation max
- Timestamp format: `[YYYY-MM-DD HH:MM]` — use current date/time
- `--remind` / `-r` must be the first argument (before the text)
- Without `--remind`: only inbox.md (default behavior unchanged)

---
name: setup
description: brainoutsourcing Setup — Creates the vault structure, runs a 3-question onboarding, and personalizes all files. Use when the user runs /setup, "set up", "bootstrap", or "initialize".
user-invocable: true
---

# brainoutsourcing — Setup + Onboarding

## Pre-flight Check

1. Check if `context/personal-info.md` exists in the current directory
2. If yes: "Your brain is already set up. Would you like to run onboarding again (existing structure stays) or reset everything?"
3. If no: Continue with Phase A

---

## Phase A: Onboarding (3 questions)

Read `references/onboarding-questions.md` for the exact questions and instructions.

**Important:**
- Ask each question individually. Wait for the answer before moving on.
- Accept any format: short sentence, wall of text, LinkedIn profile, "skip"
- No follow-up questions. Extract what you can.
- After each answer: brief confirmation (1 sentence), then next question

Store the answers internally as:
- `{{NAME}}` — User's name
- `{{DESCRIPTION}}` — What they do, for whom
- `{{OFFERING}}` — Products/services (optional)
- `{{AUDIENCE}}` — For whom (optional)
- `{{CHALLENGE}}` — Biggest current challenge (optional)
- `{{PROJECTS}}` — List of active projects (name + goal)
- `{{DATE}}` — Today's date (YYYY-MM-DD)
- `{{WEEK}}` — Current calendar week

---

## Phase B: Create vault

Read `references/vault-structure.md` for the complete folder and file structure.

### Step 1: Create folders

Create all folders as defined in `vault-structure.md`.

### Step 2: Generate context files from templates

Read each template from `references/context-templates/` and replace placeholders with the onboarding answers:

- `context-templates/personal-info.md` → `context/personal-info.md`
- `context-templates/business-info.md` → `context/business-info.md`
- `context-templates/strategy.md` → `context/strategy.md`
- `context-templates/current-data.md` → `context/current-data.md`
- `context-templates/open-loops.md` → `context/open-loops.md`
- `context-templates/inbox.md` → `context/inbox.md`
- `context-templates/brand-voice.md` → `context/brand-voice.md`

Additionally, create a subfolder under `projects/` for each mentioned project:
- `projects/{project-name-kebab}/CLAUDE.md` with goal and status "Active"

### Step 3: Set up wiki structure

- `wiki/index.md` — Empty wiki index with personalized header
- `wiki/log.md` — Empty log with setup entry
- `.gitkeep` in `wiki/concepts/`, `wiki/tools/`, `wiki/people/`

### Step 4: Set up plans structure

- `plans/wip.md` — Empty session continuity document
- `plans/backlog.md` — Empty Kanban board with user context (projects as first tasks)

### Step 5: Additional seed files

- `.gitkeep` in `raw/_input/`, `raw/articles/`, `raw/transcripts/`, `raw/papers/`, `raw/assets/`
- `.gitkeep` in `personal/daily/`, `personal/health/`, `personal/finance/`, `personal/learning/`
- `outputs/tmp/.gitkeep`

### Step 6: Personalize CLAUDE.md

Read `references/claude-md-template.md` and replace all placeholders. Overwrite the existing `CLAUDE.md` in the vault root with the personalized version.

### Step 7: First daily log

Create `personal/daily/{{DATE}}.md`:
```markdown
# {{DATE}}

## Setup
- brainoutsourcing set up
- Vault structure created
- Context personalized

## Next steps
[Based on the mentioned projects, list the 2-3 most important next steps]
```

---

## Phase C: Completion

Show a compact summary:

```
Your brain is set up, {{NAME}}.

Created:
- Vault structure (context, wiki, plans, raw, personal)
- [X] context files (personal-info, business, strategy, open-loops)
- [X] project folders ([project names])
- Personalized CLAUDE.md
- Empty wiki with index

Start every session with /checkin, end with /checkout.
All commands: /checkin | /checkout | /add-todo | /add-wiki | /review | /backlog

Note: This system builds on KI-OS and the LLM Wiki pattern. If you are familiar
with either, you will recognize core concepts — adapted for long-term knowledge
management and daily use.
```

**Optional:** Ask at the end:
> "Would you like to integrate Apple Reminders? (macOS only, optional)"
If yes: point to `scripts/reminders/reminders-bridge.sh` and how to set up list IDs.

---

## Rules

- Never ask the user "Should I save this?" — just do it
- File names: kebab-case, no emojis, no special characters
- No empty placeholder files — every file has at least a meaningful header
- If "skip" is the answer: set a sensible placeholder, user can fill in later

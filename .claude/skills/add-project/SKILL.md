---
name: add-project
description: Create new project — structured project folder with CLAUDE.md, .gitignore and venv
user-invocable: true
---

# /add-project — Create New Project

> Creates a structured project folder with its own CLAUDE.md, .gitignore and venv.

## Usage

```
/add-project my-project-name python
/add-project my-project-name node
/add-project my-project-name generic
```

## Execute

```bash
PROJECT_NAME="[name]"
TECH="[python|node|generic]"
mkdir -p projects/$PROJECT_NAME
cd projects/$PROJECT_NAME
```

**Python:**
```bash
python3 -m venv venv
echo "venv/" >> .gitignore
echo ".env" >> .gitignore
echo "__pycache__/" >> .gitignore
git init
git remote add origin [URL if known]
```

**Node:**
```bash
npm init -y
echo "node_modules/" >> .gitignore
echo ".env" >> .gitignore
git init
```

## Create Project CLAUDE.md

Copy from `projects/_template/CLAUDE.md` and fill in:

```markdown
# CLAUDE.md — [Project Name]

> Project-specific context. Loaded in addition to the root CLAUDE.md.

## Project Identity

**Name:** [Project Name]
**Description:** [1-2 sentences]
**Status:** [Active|Paused|Completed]
**Started:** [Date]

## Tech Stack

- **Language:** [Python 3.12 / Node 20 / ...]
- **venv:** `./venv/` (activate: `source venv/bin/activate`)
- **Dependencies:** `pip install -r requirements.txt` / `npm install`
- **Main file:** `src/main.py`

## Git

- **Remote:** [GitHub URL]
- **Branch strategy:** [main + feature branches / etc.]
- **CI/CD:** [GitHub Actions / none]

## Current Goals

1. [Goal 1]
2. [Goal 2]

## Behavior Principles (Project-specific)

- [Specific rules that apply only to this project]
- [E.g. "Always use type hints in Python", "No dependencies without approval"]

## Connection to Wiki

- Insights from this project → `wiki/[topic]/`
- Relevant wiki pages: [[wiki-page-1]], [[wiki-page-2]]
```

## Wrap-Up

1. Root CLAUDE.md → update project list
2. `wiki/log.md` → log new project
3. Output confirmation with path and next steps

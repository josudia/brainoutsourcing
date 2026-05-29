---
name: audit
description: Workspace audit — inspect the file layout and produce cleanup/refactor proposals. Finds ghost paths, duplicates, PRIVATE-data leaks, loose files, broken wiki sources, MEMORY.md soft-limit overruns, and .gitignore gaps.
user-invocable: true
---

# /audit — Workspace Audit & Refactor Proposals

> Use this when the file layout becomes unclear, when something looks inconsistent, or before a larger refactor.
> Not for routine hygiene (that is what `/wiki-health` + `/review` cover).
> Ends with a proposal table — nothing is executed until the user gives the OK.

## Phase 1 — Take inventory

### 1.1 Top-level inventory
```bash
du -sh */ .[a-z]*/ 2>/dev/null | sort -h
ls -la
```
Which top-level folders exist, how large are they, which are missing?

### 1.2 Check gitignore status
```bash
cat .gitignore
git ls-files personal/ | head     # should be empty — anything tracked here is a PRIVATE leak
```
Everything under `personal/` is gitignored. Tracked files under `personal/` are an audit finding (e.g. after a `git mv tracked → gitignored`, the file stays tracked by accident).

### 1.3 Find ghost paths
- Empty folders: `find . -type d -empty -not -path "./.git/*"`
- Literal brace paths: `ls '{a,b,c}' 2>/dev/null` (the classic `mkdir` brace-expansion bug)
- Path-traversal artifacts: `ls Users/ 2>/dev/null` (a tool created an absolute path as a ghost folder)

### 1.4 Duplicates
```bash
# Identical files (byte-for-byte) between two paths:
cmp -s path-a path-b && echo "identical"
```
Or more broadly: search for the same filename in multiple locations.

### 1.5 PRIVATE data in the versioned area
Per `.claude/rules/data-classification.md`, the following must NEVER be tracked:
- Personality/assessment PDFs (IQ, personality test results, etc.)
- Family details, financial data, health data
- Sensitive personal correspondence
- Reference letters or other semi-private documents

Check: `git ls-files | grep -iE "(certificate|assessment|health|finance|private)"` — should be empty.

### 1.6 Validate wiki sources frontmatter
Wiki frontmatter `sources: [...]` references source files. They must exist:
```bash
grep -hoE 'sources:\s*\[?"?[^"]+"?' wiki/**/*.md  # extract paths
# Then for each path: test -e $path
```
Broken sources point at renamed or deleted files.

### 1.7 MEMORY.md size
```bash
wc -c <your-memory-dir>/MEMORY.md
# Soft limit ~24.4 KB. Over it? → shorten the index lines.
awk '{print length, NR}' MEMORY.md | sort -rn | head -10  # longest lines
```

### 1.8 Classification consistency
- Are container names consistent? (e.g. `Clients/` vs `clients/`)
- Are there loose files at a top-level container that belong in a sub-folder?
- Is the split between top-level folders for strategic relationships vs. containers for active work consistent?

## Phase 2 — Structure the findings

Produce a result table, one row per finding:

| Finding | Path | Severity | Proposal |
|---|---|---|---|
| e.g. PRIVATE file in repo | `sources/papers/X.png` | high | migrate to `personal/knowledge/...` |

Severity levels:
- **high** = PRIVATE leak, broken wiki source, persistent git inconsistency
- **medium** = duplicate, loose files, ghost path
- **low** = cosmetic (naming inconsistency, empty containers)

## Phase 3 — Refactor proposal

Present to the user before executing — **do not refactor on your own initiative.**

Per cluster:
- A: Mandatory fixes (PRIVATE leaks, broken sources, wiki path bugs)
- B: Consistency fixes (naming, loose files, duplicates)
- C: Cosmetic (empty ghost folders, cache hygiene)

Required for every move:
1. **Check memory path references** (`grep -rln "$old_path" <your-memory-dir>/`)
2. **Check wiki source references** (`grep -rln "$old_path" wiki/`)
3. **Check plans/context/skills references** (`grep -rln "$old_path" plans/ context/ .claude/`)
4. **Choose `git mv` vs `mv` carefully** (see Phase 4)

## Phase 4 — Execution notes (gotchas)

### `git mv tracked → gitignored` pulls the file into tracking
If the destination folder is gitignored (`personal/`), `git mv` still adds the file to the index → it stays tracked. **Fix:**
- Use plain `mv` (not `git mv`)
- Then `git add -A` (git sees it as a deletion from the source)
- The content is preserved on disk, the git index stays clean

If it already happened: `git rm --cached <path>` removes it from the index but keeps it on disk.

### `git mv` with an existing destination
`git mv source/ dest/` fails if `dest/` already exists → it becomes `dest/source/`. Workaround: rename to a temp path or map individual files explicitly.

### sed path patches
```bash
find PATH -type f -name "*.md" -exec sed -i '' \
  -e 's|old/A/|new/A/|g' \
  -e 's|old/B/|new/B/|g' \
  {} \;
```
- macOS `sed -i ''` (empty backup suffix)
- Do NOT patch `archive/` plans (preserve historical snapshots)
- Do NOT patch project-internal paths under `projects/[name]/` (separate repos with their own paths)

### Skill-sync requirement
When changing a skill, patch BOTH locations:
- `.claude/skills/[name]/SKILL.md`
- the plugin copy under `.claude/<plugin>/skills/[name]/SKILL.md`

## Phase 5 — Commit strategy

One commit per cluster. Message format:
```
audit: <cluster name> — <short description>

<details of what was moved, without a code dump>
<why> — what the problem was
<knowledge-preservation confirmation> — all files still reachable
```

Before `git commit`: show `git status --short` and present it to the user.

## Phase 6 — When new conventions emerge

Update:
- `CLAUDE.md` structure diagram + behavioral principles
- The relevant memory file (classification table)
- `.claude/rules/data-classification.md` if a new PRIVATE pattern appears
- `.gitignore` if new paths should be ignored or tracked

## Behavior

- Run through all of Phase 1 first, **then** present findings in a structured way
- When something is unclear, offer a recommended option plus 2-3 alternatives, and name the critical counter-arguments
- Never move anything silently — knowledge preservation is the master constraint
- Before any `git rm`/`mv`, ask for confirmation when the content is tracked or its status is unclear

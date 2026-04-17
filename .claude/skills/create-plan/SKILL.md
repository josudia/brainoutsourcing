---
name: create-plan
description: Create a detailed implementation plan before making structural changes to the workspace
user-invocable: true
---

# Plan

Create a detailed implementation plan for changes to this workspace. Plans are thorough documents that capture the full context, rationale, and step-by-step tasks to implement a change with full alignment across the project.

## Variables

requirement: $ARGUMENTS (describe what you want to plan — new command, new workflow, structural change, template update, etc.)

---

## Instructions

- **IMPORTANT:** You are creating a PLAN, not an implementation. Research thoroughly, think carefully, then create a comprehensive plan document.
- Use your reasoning capabilities to think deeply about the requirement, the workspace structure, and the best approach.
- Research the workspace to understand existing patterns, conventions, and how this change fits in.
- Create the plan in the `plans/` directory with filename: `YYYY-MM-DD-{descriptive-name}.md`
  - Use today's date
  - Replace `{descriptive-name}` with a short kebab-case name (e.g., "add-guest-research-command", "restructure-outputs", "create-outreach-workflow")
- Fill in every section of the plan format below. Replace all `<placeholders>` with specific, actionable content.
- Be thorough — this plan will be executed by `/implement` and needs enough detail to be carried out without ambiguity.
- Follow existing patterns. Study similar files in the workspace before proposing new structures.

---

## Research Phase

Before writing the plan, investigate:

1. **Read core reference files:**
   - `CLAUDE.md` — workspace overview
   - `context/` — background context about the user and the project

2. **Explore relevant areas:**
   - For command creation: read existing commands in `.claude/commands/`
   - For output changes: explore `outputs/` structure and examples
   - For template updates: check `reference/` for existing patterns
   - For script creation: check `scripts/` for conventions

3. **Understand connections:**
   - How does this change relate to existing workflows?
   - Which files reference or depend on the areas being changed?
   - Are there naming conventions to follow?

---

## Plan Format

Write the plan using exactly this structure:

```markdown
# Plan: <descriptive title>

**Created:** <YYYY-MM-DD>
**Status:** Draft
**Requirement:** <one-line summary of the requirement>

---

## Overview

### What this plan achieves

<2-3 sentences describing the end result and why it matters>

### Why this matters

<Connect this change to the project's goals or mission. How does it add value?>

---

## Current State

### Relevant existing structure

<List the files, folders, or patterns that exist and relate to this change>

### Gaps or issues being addressed

<What is missing, broken, or suboptimal that this plan fixes?>

---

## Proposed Changes

### Summary of changes

<Bullet list of all changes at a high level>

### New files to create

<List every new file with its full path and a one-line description of its purpose>

| File path           | Purpose                              |
| ------------------- | ------------------------------------ |
| `path/to/file.md`  | Description of the file's function   |

### Files to modify

<List every file to be modified and a summary of the changes>

| File path           | Changes                              |
| ------------------- | ------------------------------------ |
| `path/to/file.md`  | Description of the modifications     |

### Files to delete (if any)

<List any files to be removed and the rationale>

---

## Design Decisions

### Key decisions made

<List important design decisions and the rationale behind them>

1. **<Decision>**: <Rationale>
2. **<Decision>**: <Rationale>

### Alternatives considered

<What other approaches were considered and why were they rejected?>

### Open questions (if any)

<List any decisions that need user input before implementation>

---

## Step-by-Step Tasks

Execute these tasks in the given order during implementation.

### Step 1: <task title>

<Detailed description of what to do>

**Actions:**

- <Specific action>
- <Specific action>

**Affected files:**

- `path/to/file.md`

---

### Step 2: <task title>

<Detailed description of what to do>

**Actions:**

- <Specific action>
- <Specific action>

**Affected files:**

- `path/to/file.md`

---

<Continue with as many steps as needed. Be thorough. Include:>
<- Creating new files (with full content specifications)>
<- Modifying existing files (with before/after or specific edits)>
<- Updating cross-references>
<- Test/validation steps>

---

## Connections & Dependencies

### Files that reference this area

<List all files that link to or depend on the areas being changed>

### Updates needed for consistency

<List any documentation, references, or related files that need updating>

### Impact on existing workflows

<Describe how this affects existing commands, outputs, or processes>

---

## Validation Checklist

Use this to verify the implementation is complete and correct:

- [ ] <Verification step — e.g., "New command runs without errors">
- [ ] <Verification step — e.g., "Output files created in the correct location">
- [ ] <Verification step — e.g., "CLAUDE.md updated to reflect new structure">
- [ ] <Verification step — e.g., "Cross-references updated and valid">

---

## Success Criteria

The implementation is complete when:

1. <Specific, measurable criterion>
2. <Specific, measurable criterion>
3. <Specific, measurable criterion>

---

## Notes

<Additional context, future considerations, or related ideas that may be useful>
```

---

## Quality Standards

- **Completeness:** Every section filled with specific content, no generic placeholders remaining
- **Actionability:** Steps detailed enough that `/implement` can execute them without follow-up questions
- **Consistency:** Follows existing workspace patterns and naming conventions
- **Clarity:** Someone unfamiliar with the project could understand and execute the plan
- **Traceability:** Changes are linked to goals and rationale

---

## Report

After creating the plan:

1. Provide a brief summary of what the plan covers
2. List any open questions that need user input before implementation
3. Give the full path to the plan file: `plans/YYYY-MM-DD-{name}.md`
4. Remind the user to run `/implement plans/YYYY-MM-DD-{name}.md` to execute it

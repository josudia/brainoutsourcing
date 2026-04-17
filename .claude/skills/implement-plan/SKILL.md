---
name: implement-plan
description: Execute a plan created with /create-plan step by step
user-invocable: true
---

# /implement-plan — Execute Plan

Execute an implementation plan created with `/create-plan`. Read the plan thoroughly, carry out each step in order, and report on the completed work.

## Variables

plan_path: $ARGUMENTS (path to the plan file, e.g., `plans/2026-01-28-guest-research-command.md`)

---

## Instructions

### Phase 1: Understand the Plan

1. **Read the plan file completely.** Do not skim — understand every section.
2. **Check prerequisites:**
   - Are there open questions that need to be answered before proceeding?
   - Are there dependencies on external resources or user decisions?
   - If blockers exist, stop and ask the user before continuing.
3. **Confirm the plan is ready:**
   - Status should be "Draft" or "Ready"
   - All sections should be filled in (no placeholder text remaining)

---

### Phase 2: Execute the Plan

1. **Follow the step-by-step tasks in exact order.**
   - Complete each step fully before moving to the next
   - If a step involves creating a file, write the complete file — no stubs
   - If a step involves modifying a file, read the file first, then apply changes precisely

2. **For each task:**
   - Read all affected files
   - Make the specified changes
   - Verify the change is correct before moving on

3. **Handle issues gracefully:**
   - If a step cannot be executed as described, note the issue and adapt if the intent is clear
   - When in doubt, ask the user rather than guessing
   - Document any deviations from the plan

---

### Phase 3: Validate

1. **Walk through the validation checklist** from the plan
   - Check off each item
   - Note any failures

2. **Verify success criteria**
   - Confirm each criterion is met
   - Note any gaps

3. **Check cross-references and consistency:**
   - Ensure new files are referenced where they should be
   - Check whether CLAUDE.md was updated if the workspace structure changed
   - Confirm naming conventions are followed

---

### Phase 4: Update Plan Status

After implementation, update the plan file:

1. Change `**Status:** Draft` to `**Status:** Implemented`
2. Add an "Implementation Notes" section at the end:

```markdown
---

## Implementation Notes

**Implemented:** <YYYY-MM-DD>

### Summary

<Brief summary of what was done>

### Deviations from Plan

<List any changes made during implementation, or "None">

### Issues Encountered

<List any problems and how they were resolved, or "None">
```

---

## Quality Standards

- **Thoroughness:** Every step in the plan is executed, none skipped
- **Precision:** Changes match what the plan specifies
- **Completeness:** Files are written in full, not as stubs
- **Consistency:** All cross-references and documentation updated
- **Traceability:** Deviations are documented

---

## Report

After implementation, provide:

1. **Summary:** Bullet list of completed work
2. **Changed files:** List of all files created, modified, or deleted
3. **Validation results:** Status of each checklist item
4. **Deviations:** Any changes from the original plan
5. **Next steps:** Any follow-up actions (if applicable)

Format:

```
## Implementation Complete

### Summary
- <What was done>
- <What was done>

### Changed Files
**Created:**
- `path/to/new-file.md`

**Modified:**
- `path/to/modified-file.md`

**Deleted:**
- (none)

### Validation
- [x] <Passed check>
- [x] <Passed check>

### Deviations from Plan
<None, or list deviations>

### Plan Status
`plans/YYYY-MM-DD-{name}.md` status updated to "Implemented"
```

---
name: pptx-build
description: Build PowerPoint presentations from a Markdown slide source. Takes a template PPTX as the layout master (fonts/colors/images are preserved) and fills the slides with content from Markdown. Speaker notes via `:::notes:::` blocks. Use for pitch decks, workshops, conference slides, and grant-application presentations.
user-invocable: true
---

# pptx-build

Generate a PowerPoint from Markdown content plus a template layout.

## When to use

- A pitch deck or grant-application presentation is needed
- Workshop slides from structured Markdown
- Updating an existing PPTX template with new content
- Whenever you want layout consistency (master slides) decoupled from content authoring

## Usage (CLI)

```bash
./scripts/pptx-build/venv/bin/python scripts/pptx-build/pptx_build.py \
    <markdown.md> \
    --template <template.pptx> \
    --output <new.pptx>
```

Optional flags:
- `--default-layout N` — default layout index (default: 1 = Title + Content)
- `--keep-template-slides` — keep the template's slides instead of using only its layouts

## Markdown convention (required)

```markdown
## Slide 1: Title
Optional lead sentence.

- Bullet 1
- Bullet 2
  - Sub-bullet (2-space indent)

:::notes:::
Speaker notes for this slide.
:::endnotes:::

## Slide 2 (layout=2): Section Header
Opening text.

## Slide 3: Slide with image placeholder
Body.

:::image:::
A note describing what image to insert here.
:::endimage:::
```

## What the skill does NOT do

- Insert images (only placeholder hints in the speaker notes)
- Complex tables / charts / animations
- Redefine master layouts (these come from the template)

## Recommended workflow

1. **Write the content Markdown** using the slide convention (separate editing focus)
2. **Choose the template PPTX** (brand- or project-specific, used as the layout master)
3. **Run the skill** → new PPTX
4. **Review visually** in PowerPoint/Keynote, add images and animations
5. **Iterate**: change the Markdown and rebuild instead of editing the PPTX directly

## Technical docs

`scripts/pptx-build/README.md` — setup, layout-index convention, known limits, examples

## Project-specific templates

- Place each project's template in its own project folder; reference it via the `--template` path.

## venv note

A dedicated venv lives at `scripts/pptx-build/venv` with `python-pptx` + `Pillow` + `lxml` + `XlsxWriter`. Setup: `python3 -m venv venv && ./venv/bin/pip install python-pptx Pillow`.

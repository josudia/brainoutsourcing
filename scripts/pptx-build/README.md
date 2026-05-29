# pptx-build

Generic PowerPoint builder. Markdown slide source + template PPTX → new PPTX.

## Setup

```bash
python3 -m venv venv
./venv/bin/pip install python-pptx Pillow
```

## Usage

```bash
./venv/bin/python pptx_build.py <markdown> --template <template.pptx> --output <new.pptx>
```

Options:
- `--default-layout N` — default layout index for slides without an explicit one (default: 1)
- `--keep-template-slides` — keep the template's slides (default: template slides are removed, only layouts/master stay)

## Markdown convention

```markdown
## Slide 1: Slide title
Optional subtitle or first paragraph.

- Bullet 1
- Bullet 2
  - Sub-bullet
- Bullet 3

:::notes:::
Speaker notes for this slide. Multiple lines allowed.
:::endnotes:::

## Slide 2 (layout=2): Section Header
Section description.

## Slide 3: Slide with image placeholder
Body text of the slide.

:::image:::
Team photo, 2024
:::endimage:::

:::notes:::
Point out the team's diversity here.
:::endnotes:::
```

## Layout indices

Standard Office layouts (may vary by template):
- 0: Title Slide
- 1: Title + Content (default)
- 2: Section Header
- 3: Two Content
- 5: Title Only
- 6: Blank

If the template has its own layouts, check the index order with:

```python
from pptx import Presentation
prs = Presentation("template.pptx")
for i, layout in enumerate(prs.slide_layouts):
    print(i, layout.name)
```

## Known limits

- Images: the script does NOT insert new images (placeholder hints go into the speaker notes). Images must be added manually.
- Complex tables: not supported — phrase them as bullets or add them manually in PowerPoint.
- Charts: not supported — handle as bullets or image placeholders.
- Animations: stay in the layout; new slides have none of their own.

## Use cases

- Grant-application pitch decks
- Workshops, conference slides, pitch decks
- Anywhere you want Markdown-based content authoring plus PowerPoint layout consistency

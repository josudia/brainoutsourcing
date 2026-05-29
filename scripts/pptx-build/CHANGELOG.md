# pptx-build CHANGELOG

## Initial release — learnings from building pitch decks

### Limitations discovered

`pptx_build.py` is not well suited to templates with **custom layouts**. Some
templates use custom layouts without usable placeholders — the real slide
content lives in free text boxes placed over a custom background.

The generic `pptx_build.py` creates new slides from the standard Office layouts
(Title Slide, Title + Content, Section Header). On a template with heavy custom
layouts, these slides look generic rather than matching the original design.

### Known bugs in pptx_build.py

1. **Layout routing bug:** with multi-placeholder layouts, body text can land in
   a PICTURE placeholder instead of the BODY placeholder, because the script
   picks the first non-title placeholder.
2. **ZIP duplicate bug:** when removing template slides from `sldIdLst`, the
   slide parts in the package are not deleted, while new slides are written with
   the same paths. PowerPoint still opens the file, but it is fragile.

### Recommended improvements for a future version

1. **Custom-layout detection:** if the template has custom layouts, warn the
   user and suggest an "original-replace" strategy (load the original, delete
   unneeded slides with proper relationship cleanup, reorder, and replace text
   per slide so the original layouts/images/visuals stay intact).
2. **`--strategy=replace` mode:** a mapping file (target index → original slide
   index) plus per-slide replacement hooks.
3. **Standard-mode bug fix:** prevent ZIP duplicates by cleanly removing slide
   parts AND relationships.
4. **Fix layout routing:** write body text into the BODY placeholder instead of
   the PICTURE placeholder.
5. **Per-slide custom hook:** optional module import of a Python file with
   per-slide fill functions.

### Files

- `pptx_build.py` — generic builder (standard Office layouts); not ideal for templates with heavy custom layouts
- `inspect_template.py` — shows layouts, placeholders, and existing slides
- `inspect_output.py` — shows slide contents (title, body, notes) in the finished PPTX

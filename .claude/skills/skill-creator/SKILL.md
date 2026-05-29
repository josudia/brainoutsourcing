---
name: skill-creator
description: Create or update skills. Use when designing, structuring, or packaging skills with scripts, references, and assets.
user-invocable: true
---

# Skill Creator

This skill provides guidance on creating effective skills.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific domains or tasks — they turn Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge that no model can fully possess on its own.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with particular file formats or APIs
3. Domain expertise - Organization-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and recurring tasks

## Core Principles

### Conciseness Is Critical

The context window is a shared resource. Skills share the context window with everything else Claude needs: the system prompt, conversation history, metadata for other skills, and the actual user request.

**Default assumption: Claude is already very intelligent.** Only add context that Claude does not already have. Question every piece of information: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the fragility and variability of the task:

**High freedom (text-based instructions)**: Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Medium freedom (pseudocode or scripts with parameters)**: Use when a preferred pattern exists, some variation is acceptable, or configuration influences behavior.

**Low freedom (specific scripts, few parameters)**: Use when operations are fragile and error-prone, consistency is critical, or a specific order must be followed.

Picture Claude exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in the output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

Every SKILL.md consists of:

- **Frontmatter** (YAML): Contains the `name` and `description` fields. These are the only fields Claude reads to determine when to use the skill. It is therefore very important to clearly and comprehensively describe what the skill is and when it should be used.
- **Body** (Markdown): Instructions and guidance for using the skill. Loaded only AFTER the skill is triggered (if at all).

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or would otherwise be rewritten repeatedly.

- **When to include**: When the same code would be rewritten repeatedly, or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token-efficient, deterministic, can be executed without loading into context
- **Note**: Scripts may still need to be read by Claude for patching or environment-specific adjustments

##### References (`references/`)

Documentation and reference material loaded into context as needed to inform Claude's process and reasoning.

- **When to include**: For documentation Claude should reference while working
- **Examples**: `references/finance.md` for finance schemas, `references/mnda.md` for an NDA template, `references/policies.md` for company policies, `references/api_docs.md` for API specifications
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies, detailed workflow guides
- **Benefits**: Keeps SKILL.md lean, loaded only when Claude deems it necessary
- **Best practice**: For large files (>10k words), include grep search patterns in SKILL.md
- **Avoid duplication**: Information should live either in SKILL.md or in reference files, not both. Prefer reference files for detailed information unless it is truly core to the skill — this keeps SKILL.md lean and information discoverable without burdening the context window. Keep only essential procedural instructions and workflow guidance in SKILL.md; move detailed reference material, schemas, and examples into reference files.

##### Assets (`assets/`)

Files that should not be loaded into context but are instead used in Claude's output.

- **When to include**: When the skill needs files that are used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate, `assets/font.ttf` for typography
- **Use cases**: Templates, images, icons, boilerplate code, fonts, sample documents that are copied or modified
- **Benefits**: Separates output resources from documentation, lets Claude use files without loading them into context

#### What Does NOT Belong in a Skill

A skill should contain only essential files that directly support its functionality. Do NOT create superfluous documentation or helper files, including:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

The skill should contain only the information an AI agent needs to complete the task. It should not include additional context about the creation process, setup and testing procedures, user-facing documentation, and so on. Extra documentation files only create clutter and confusion.

### Progressive Disclosure Design Principle

Skills use a three-level loading system for efficient context management:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When the skill is triggered (<5k words)
3. **Bundled resources** - As needed by Claude (unlimited, since scripts can be executed without loading into context)

#### Progressive Disclosure Patterns

Keep the SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when this limit is reached. When offloading content, it is very important to reference it from SKILL.md and clearly describe when it should be read, so that the reader of the skill knows it exists and when to use it.

**Core principle:** When a skill supports multiple variants, frameworks, or options, keep only the core workflow and the selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

**Pattern 1: High-level guide with references**

```markdown
# PDF Processing

## Quick Start

Extract text with pdfplumber:
[code example]

## Advanced Features

- **Form filling**: See [FORMS.md](FORMS.md) for the full guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Claude loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed.

**Pattern 2: Domain-specific organization**

For skills with multiple domains, organize content by domain to avoid loading irrelevant context:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Claude reads only sales.md.

Likewise, for skills that support multiple frameworks or variants, organize by variant:

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude reads only aws.md.

**Pattern 3: Conditional details**

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating Documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing Documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude reads REDLINING.md or OOXML.md only when the user needs those features.

**Important guidelines:**

- **Avoid deeply nested references** - Keep references one level deep from SKILL.md. All reference files should be linked directly from SKILL.md.
- **Structure longer reference files** - For files longer than 100 lines, include a table of contents at the top so Claude can see the full scope when previewing.

## Skill Creation Process

Creating a skill involves the following steps:

1. Understand the skill with concrete examples
2. Plan reusable skill content (scripts, references, assets)
3. Initialize the skill (run init_skill.py)
4. Edit the skill (implement resources and write SKILL.md)
5. Package the skill (run package_skill.py)
6. Iterate based on real-world usage

Follow these steps in the given order. Skip only when there is a clear reason they do not apply.

### Skill Naming

- Use only lowercase letters, digits, and hyphens; normalize user-provided titles to kebab-case (e.g. "Plan Mode" -> `plan-mode`).
- When generating a name, generate one under 64 characters (letters, digits, hyphens).
- Prefer short, verb-led phrases that describe the action.
- Use a tool namespace when it improves clarity or triggering (e.g. `gh-address-comments`, `linear-address-issue`).
- Name the skill folder exactly after the skill name.

### Step 1: Understand the Skill with Concrete Examples

Skip this step only when the skill's usage patterns are already clearly understood. It remains valuable even when working with an existing skill.

To create an effective skill, concrete examples of its usage must be clearly understood. This understanding can come from direct user examples or from generated examples validated with user feedback.

For example, when building an image-editing skill, relevant questions are:

- "What functionality should the image-editing skill support? Editing, rotating, something else?"
- "Can you give examples of how this skill would be used?"
- "I imagine users would say things like 'Remove red-eye from this photo' or 'Rotate this image.' Are there other ways you envision it being used?"
- "What would a user say that should trigger this skill?"

To avoid overwhelming users, do not ask too many questions in a single message. Start with the most important questions and ask follow-ups as needed.

Complete this step once there is a clear understanding of the functionality the skill should support.

### Step 2: Plan Reusable Skill Content

To turn concrete examples into an effective skill, analyze each example by:

1. Considering how the example would be executed from scratch
2. Identifying which scripts, references, and assets would be helpful when running these workflows repeatedly

Example: When building a `pdf-editor` skill for requests like "Help me rotate this PDF," the analysis shows:

1. Rotating a PDF requires rewriting the same code every time
2. A `scripts/rotate_pdf.py` script would be helpful to store in the skill

Example: When designing a `frontend-webapp-builder` skill for requests like "Build me a todo app" or "Build me a dashboard to track my steps," the analysis shows:

1. Writing a frontend webapp requires the same HTML/React boilerplate every time
2. An `assets/hello-world/` template with the boilerplate HTML/React project files would be helpful to store in the skill

Example: When building a `big-query` skill for requests like "How many users logged in today?", the analysis shows:

1. Querying BigQuery requires rediscovering the table schemas and relationships every time
2. A `references/schema.md` file documenting the table schemas would be helpful to store in the skill

To decide on the skill content, analyze each concrete example to produce a list of reusable resources: scripts, references, and assets.

### Step 3: Initialize the Skill

At this point, it is time to actually create the skill.

Skip this step only when the skill being developed already exists and needs iteration or packaging. In that case, proceed to the next step.

When creating a new skill from scratch, always run the `init_skill.py` script. The script conveniently generates a new skill template directory that automatically includes everything a skill needs, making the skill creation process much more efficient and reliable.

Usage:

```bash
scripts/init_skill.py <skill-name> --path <output-directory> [--resources scripts,references,assets] [--examples]
```

Examples:

```bash
scripts/init_skill.py my-skill --path skills/public
scripts/init_skill.py my-skill --path skills/public --resources scripts,references
scripts/init_skill.py my-skill --path skills/public --resources scripts --examples
```

The script:

- Creates the skill directory at the specified path
- Generates a SKILL.md template with correct frontmatter and TODO placeholders
- Optionally creates resource directories based on `--resources`
- Optionally adds example files when `--examples` is set

After initialization, customize SKILL.md and add resources as needed. When using `--examples`, replace or delete the placeholder files.

### Step 4: Edit the Skill

When editing the (newly generated or existing) skill, keep in mind that the skill is being created for a different instance of Claude. Add information that would be useful and non-obvious to Claude. Consider which procedural knowledge, domain-specific details, or reusable assets would help another instance of Claude perform these tasks more effectively.

#### Learn Proven Design Patterns

Consult these helpful guides based on your skill's requirements:

- **Multi-step processes**: See references/workflows.md for sequential workflows and conditional logic
- **Specific output formats or quality standards**: See references/output-patterns.md for template and example patterns

These files contain proven best practices for effective skill design.

#### Start with Reusable Skill Content

To begin implementation, start with the reusable resources identified above: `scripts/`, `references/`, and `assets/` files. Note that this step may require user input. For example, when implementing a `brand-guidelines` skill, the user may need to provide brand assets or templates to store in `assets/`, or documentation to store in `references/`.

Scripts that are added must be tested by actually running them to ensure there are no bugs and the output meets expectations. When there are many similar scripts, only a representative sample needs to be tested to build confidence that they all work, while balancing time to completion.

When using `--examples`, delete any placeholder files not needed for the skill. Only create resource directories that are actually needed.

#### Update SKILL.md

**Writing guidelines:** Always use the imperative/infinitive form.

##### Frontmatter

Write YAML frontmatter with `name` and `description`:

- `name`: The skill name
- `description`: This is the primary triggering mechanism for your skill and helps Claude understand when the skill should be used.
  - Include both what the skill does and specific triggers/contexts for using it.
  - Put all "when to use" information here — not in the body. The body is loaded only after triggering, so "when to use this skill" sections in the body are not helpful to Claude.
  - Example description for a `docx` skill: "Comprehensive document creation, editing, and analysis with support for tracked changes, comments, formatting preservation, and text extraction. Use when Claude needs to work with professional documents (.docx files) for: (1) creating new documents, (2) modifying or editing content, (3) working with tracked changes, (4) adding comments, or other document tasks."

Do not include any other fields in the YAML frontmatter.

##### Body

Write instructions on how to use the skill and its bundled resources.

### Step 5: Package the Skill

Once development of the skill is complete, it must be packaged into a distributable .skill file to be shared with the user. The packaging process automatically validates the skill first to ensure all requirements are met:

```bash
scripts/package_skill.py <path/to/skill-folder>
```

Optionally specify the output directory:

```bash
scripts/package_skill.py <path/to/skill-folder> ./dist
```

The packaging script will:

1. **Validate** — automatically check the skill:
   - YAML frontmatter format and required fields
   - Skill naming conventions and directory structure
   - Description completeness and quality
   - File organization and resource references

2. **Package** — if validation passes, build the skill into a .skill file named after the skill (e.g. `my-skill.skill`) that contains all files and preserves the correct directory structure for distribution. The .skill file is a ZIP file with a .skill extension.

If validation fails, the errors are reported and the process exits without creating a package. Fix the validation errors and run the packaging command again.

### Step 6: Iterate

After testing the skill, users may request improvements. This often happens right after using the skill, with fresh context on how it performed.

**Iteration workflow:**

1. Use the skill on real tasks
2. Notice difficulties or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes and test again

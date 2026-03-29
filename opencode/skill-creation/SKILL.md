---
name: skill-creation
description: A skill to help create OpenCode compatible skill files by adding the required YAML frontmatter to a markdown file
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: skill-creation
  language: markdown
---

# Skill Creation Helper

This skill assists in creating OpenCode compatible skill files by generating the required YAML frontmatter for a SKILL.md file.

## Usage

When you want to create a new skill for OpenCode, you can use this skill to generate the proper frontmatter structure.

### Example

To create a new skill called "my-new-skill":

1. Create the directory: `.opencode/skills/my-new-skill/`
2. Use this skill to generate the SKILL.md file in that directory
3. Fill in the content below the frontmatter with your skill's documentation

## Frontmatter Structure

Every OpenCode skill must start with YAML frontmatter containing:

- `name` (required): The skill name (must match the directory name)
- `description` (required): A brief description of what the skill does
- `license` (optional): The license for the skill (e.g., MIT)
- `compatibility` (optional): Specifies which agents can use the skill (e.g., opencode)
- `metadata` (optional): A string-to-string map for additional information

### Name Requirements

The skill name must:
- Be 1-64 characters
- Be lowercase alphanumeric with single hyphen separators
- Not start or end with `-`
- Not contain consecutive `--`
- Match the directory name that contains `SKILL.md`

Equivalent regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

### Description Requirements

- Must be 1-1024 characters
- Keep it specific enough for the agent to choose correctly

## How This Skill Works

This skill itself doesn't modify files directly, but provides guidance on creating skill files. To actually create a skill file:

1. Create the skill directory: `.opencode/skills/<your-skill-name>/`
2. Create a `SKILL.md` file in that directory
3. Add the YAML frontmatter at the top of the file (as shown above)
4. Add your skill's documentation below the frontmatter

## Example Skill File

Here's what a complete skill file might look like:

```yaml
---
name: example-skill
description: An example skill demonstrating the structure
license: MIT
compatibility: opencode
metadata:
  audience: beginners
  workflow: learning
---
# Example Skill

This is an example skill that shows the proper structure.

## What I do

- Demonstrate skill file structure
- Show how to add frontmatter
- Provide a template for new skills

## When to use me

Use this when you want to see how to structure an OpenCode skill.
```

## Validation

OpenCode will validate your skill file when it's loaded:
- Checks that the frontmatter is valid YAML
- Verifies required fields are present
- Ensures the name matches the directory
- Validates the name format and description length

If validation fails, the skill won't be available to agents.
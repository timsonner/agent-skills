---
name: configure/skills
description: Configuration for OpenCode skills - managing and configuring agent skills for reusable behaviors
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Skills Configuration

Configure and manage OpenCode skills - reusable behavior definitions that agents can load on-demand.

## Overview

Agent skills let OpenCode discover reusable instructions from your repo or home directory. Skills are loaded on-demand via the native `skill` tool—agents see available skills and can load the full content when needed.

## Where to Place Skills

Create one folder per skill name and put a `SKILL.md` inside it. OpenCode searches these locations:

- Project config: `.opencode/skills/<name>/SKILL.md`
- Global config: `~/.config/opencode/skills/<name>/SKILL.md`
- Project Claude-compatible: `.claude/skills/<name>/SKILL.md`
- Global Claude-compatible: `~/.claude/skills/<name>/SKILL.md`
- Project agent-compatible: `.agents/skills/<name>/SKILL.md`
- Global agent-compatible: `~/.agents/skills/<name>/SKILL.md`

## How Discovery Works

For project-local paths, OpenCode walks up from your current working directory until it reaches the git worktree. It loads any matching `skills/*/SKILL.md` in `.opencode/` and any matching `.claude/skills/*/SKILL.md` or `.agents/skills/*/SKILL.md` along the way.

Global definitions are also loaded from `~/.config/opencode/skills/*/SKILL.md`, `~/.claude/skills/*/SKILL.md`, and `~/.agents/skills/*/SKILL.md`.

## Writing Skill Frontmatter

Each `SKILL.md` must start with YAML frontmatter. Only these fields are recognized:

- `name` (required)
- `description` (required)
- `license` (optional)
- `compatibility` (optional)
- `metadata` (optional, string-to-string map)

Unknown frontmatter fields are ignored.

### Name Requirements
`name` must:
- Be 1–64 characters
- Be lowercase alphanumeric with single hyphen separators
- Not start or end with `-`
- Not contain consecutive `--`
- Match the directory name that contains `SKILL.md`

Equivalent regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

### Description Requirements
`description` must be 1-1024 characters. Keep it specific enough for the agent to choose correctly.

## Example Skill

Create `.opencode/skills/git-release/SKILL.md` like this:

```
---name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github---
## What I do
- Draft release notes from merged PRs
- Propose a version bump
- Provide a copy-pasteable `gh release create` command
## When to use me
Use this when you are preparing a tagged release.
Ask clarifying questions if the target versioning scheme is unclear.
```

## Recognizing Tool Description

OpenCode lists available skills in the `skill` tool description. Each entry includes the skill name and description:

```
<available_skills>
  <skill>
    <name>git-release</name>
    <description>Create consistent releases and changelogs</description>
  </skill>
</available_skills>
```

The agent loads a skill by calling the tool:
```
skill({ name: "git-release" })
```

## Configuring Permissions

Control which skills agents can access using pattern-based permissions in `opencode.json`:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| Permission | Behavior |
|------------|----------|
| `allow` | Skill loads immediately |
| `deny` | Skill hidden from agent, access rejected |
| `ask` | User prompted for approval before loading |

Patterns support wildcards: `internal-*` matches `internal-docs`, `internal-tools`, etc.

## Overriding Per Agent

Give specific agents different permissions than the global defaults.

**For custom agents** (in agent frontmatter):
```
---permission:
  skill:
    "documents-*": "allow"---
```

**For built-in agents** (in `opencode.json`):
```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

## Disabling the Skill Tool

Completely disable skills for agents that shouldn’t use them:

**For custom agents**:
```
---tools:
  skill: false---
```

**For built-in agents**:
```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

When disabled, the `<available_skills>` section is omitted entirely.

## Troubleshooting Loading

If a skill does not show up:
1. Verify `SKILL.md` is spelled in all caps
2. Check that frontmatter includes `name` and `description`
3. Ensure skill names are unique across all locations
4. Check permissions—skills with `deny` are hidden from agents

By configuring skills appropriately, you can control which reusable behaviors are available to OpenCode agents, ensuring they have access to the right knowledge for your projects while maintaining security and organization.

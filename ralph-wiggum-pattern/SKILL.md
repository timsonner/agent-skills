---
name: ralph-wiggum-pattern
description: A Python-focused implementation of the Ralph Wiggum technique for AI-assisted software development
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: ai-assisted-development
  language: python
  technique: ralph-wiggum
---

# Ralph Wiggum Pattern Specification

A Python-focused implementation of the Ralph Wiggum technique for AI-assisted software development.

## Overview

The Ralph Wiggum pattern is a technique for using AI coding agents in automated loops to accomplish software development tasks. At its core, it involves running an AI agent in a continuous loop with a simple prompt, allowing it to iteratively improve and build software through repeated attempts.

As described by Geoffrey Huntley: "Ralph is a technique. In its purest form, Ralph is a Bash loop."

```
while :; do cat PROMPT.md | opencode ; done
```

## Core Principles

1. **One Thing Per Loop**: The agent should focus on implementing only one item per loop iteration
2. **Trust the Agent**: Allow the agent to decide what's most important to implement
3. **Deterministically Bad**: Accept that the technique produces variable results, but errors can be corrected through tuning
4. **Eventual Consistency**: Believe that with enough iterations, the agent will converge on a working solution
5. **Subagent Orchestration**: Use primary context window as a scheduler for subagents doing expensive work

## Python Implementation

### Basic Loop Setup

For Python development, the Ralph loop can be implemented as:

```bash
while :; do 
    cat PROMPT.md | opencode
done
```

Where `opencode` executes the OpenCode agent in your Python environment.

### Directory Structure

A Ralph Wiggum Python project should follow this structure:

```
project-root/
├── PROMPT.md              # The main prompt for the agent
├── @AGENT.md             # Instructions for how to run/build/test the project
├── @fix_plan.md          # Prioritized list of remaining tasks
├── specs/                # Specifications folder
│   ├── stdlib/           # Standard library specifications
│   └── ...               # Other feature specifications
├── src/                  # Source code
│   └── stdlib/           # Standard library implementation (in Python)
├── examples/             # Example usage
└── .agent/               # Scratchpad for long-term plans and todo lists
```

### Essential Files

#### PROMPT.md
The main prompt that gets fed to the agent each iteration. Should be concise and focused.

Example from repomirror:
```
Your job is to port assistant-ui-react monorepo (for react) to assistant-ui-vue (for vue) and maintain the repository.

You have access to the current assistant-ui-react repository as well as the assistant-ui-vue repository.

Make a commit and push your changes after every single file edit.

Use the assistant-ui-vue/.agent/ directory as a scratchpad for your work. Store long term plans and todo lists there.

The original project was mostly tested by manually running the code. When porting, you will need to write end to end and unit tests for the project. But make sure to spend most of your time on the actual porting, not on the testing. A good heuristic is to spend 80% of your time on the actual porting, and 20% on the testing.
```

#### @AGENT.md
Instructions for how to run, build, and test the project. Updated by the agent as it learns.

Example:
```
To build: uv sync && uv build
To test: uv run pytest
To run examples: uv run python examples/main.py
```

#### @fix_plan.md
A prioritized list of remaining tasks, maintained by the agent.

Format: Bullet point list sorted by priority of items yet to be implemented.

### Ralph Wiggum Workflow for Python

#### Phase 1: Generate
1. Agent reads specifications to understand what needs to be built
2. Agent implements one item from @fix_plan.md per loop
3. Use subagents for code generation and file writing
4. Primary context window acts as scheduler

#### Phase 2: Backpressure
1. After implementing functionality, run tests for that specific unit
2. If functionality missing, add it per specifications
3. Use static analysis/type checking (for Python: pyrefly, mypy, etc.)
4. Do NOT implement placeholder/simple implementations
5. Capture "why" in tests/documentation for future reference

#### Phase 3: Loop Maintenance
1. Study specs/* and fix_plan.md to understand requirements
2. Use up to 500 subagents to study source code and compare against specs
3. Create/update @fix_plan.md as prioritized task list
4. Standard library should be implemented in Python itself, not other languages
5. Document learnings in @AGENT.md and @fix_plan.md

### Key Practices

#### Prompt Engineering
- Keep prompts simple (100-200 words)
- Focus on the engine, not scaffolding
- Avoid over-engineering prompts (leads to slower, dumber agents)
- Example of effective prompt from repomirror (103 words):
  ```
  Your job is to port browser-use monorepo (Python) to better-use (Typescript) and maintain the repository.

  Make a commit and push your changes after every single file edit.

  Keep track of your current status in browser-use-ts/agent/TODO.md
  ```

#### Subagent Usage
- Use parallel subagents for:
  - Searching codebase (don't assume not implemented)
  - Writing files
  - Comparing against specifications
- Use ONLY 1 subagent for build/test validation (to avoid backpressure)
- Subagents should study and report back to primary context

#### Testing & Quality
- Run tests for the specific unit of code that was improved
- If tests fail due to missing functionality, implement it
- If unrelated tests fail, fix them as part of the change
- Capture the "why" behind tests in documentation
- Use static analysis tools as backpressure (pyrefly for Python)

#### Git Workflow
- Commit and push after every file edit
- When tests pass: update fix_plan.md, then git add -A, git commit, git push
- Create git tag when no build/test errors (start at 0.0.0, increment patch)
- Use subagents for git operations when needed

### Error Handling & Tuning

Ralph will make mistakes. The technique expects and accommodates this through:

1. **Tuning via Prompts**: When Ralph goes off-track, add signs (instructions) to PROMPT.md
2. **Specification Updates**: When specifications are wrong, update them
3. **Standard Library Improvements**: When technical patterns are wrong, update stdlib
4. **Selective Ignoring**: Know when to reset vs. when to tune

Common failure modes and resolutions:
- **Assuming not implemented**: Add "Before making changes search codebase (don't assume not implemented)" to prompt
- **Multiple implementations**: Tune the search/instruction phase
- **Placeholder implementations**: Add "DO NOT IMPLEMENT PLACEHOLDER OR SIMPLE IMPLEMENTATIONS" reminder
- **Context window overflow**: Use subagents to offload work, focus on one thing per loop

### When to Use Ralph Wiggum

Best suited for:
- **Greenfield projects**: Building new software from scratch
- **Porting projects**: Translating existing code to new languages/platforms
- **Specification-driven work**: When you have clear specs but need implementation
- **Exploratory development**: When the exact path forward isn't clear

Not recommended for:
- **Existing codebases**: As stated by Geoffrey Huntley: "There's no way in heck would I use Ralph in an existing code base"
- **Performance-critical systems**: Without careful tuning and validation
- **Security-sensitive applications**: Without thorough review

### Python-Specific Considerations

#### Virtual Environment Management
Use `uv` for fast Python environment management:
```bash
# Install dependencies
uv add "package-name"
# Sync environment
uv sync
# Run in environment
uv run python script.py
```

#### Type Checking
Include type checking as backpressure:
```bash
# Add to dev dependencies
uv add --dev pyrefly
# Run type checking
uv run pyrefly check
```

#### Testing Framework
Use pytest as the standard:
```bash
# Add testing dependencies
uv add --dev pytest
# Run tests
uv run pytest
```

#### Code Formatting
Include formatting as part of the workflow:
```bash
# Add formatting tools
uv add --dev ruff
# Format code
uv run ruff format .
```

## Complete Example: Python Package Porting

Here's how you might structure a Ralph Wiggum loop for porting a Python package:

**PROMPT.md:**
```
Your job is to port [source-package] to [target-platform] and maintain the repository.

You have access to the current [source-package] repository.

Make a commit and push your changes after every single file edit.

Use the .agent/ directory as a scratchpad for your work. Store long term plans and todo lists there.

Focus on implementing one feature per loop from @fix_plan.md. After implementing functionality, run the tests for that unit of code that was improved.
```

**@AGENT.md (initial):**
```
To build: uv sync && uv build
To test: uv run pytest
To type check: uv run pyrefly check
To format: uv run ruff format .
```

**@fix_plan.md (initial):**
- [ ] Set up project structure with pyproject.toml
- [ ] Implement core module: basic_functionality.py
- [ ] Implement utility module: helpers.py
- [ ] Implement CLI interface: cli.py
- [ ] Add comprehensive test suite
- [ ] Add documentation and examples
- [ ] Implement error handling and logging
- [ ] Add type hints throughout
- [ ] Prepare for PyPI release

## Success Indicators

You know Ralph is working when:
1. Commits are being made regularly (after each file edit)
2. The @fix_plan.md items are being checked off
3. Tests are passing for newly implemented features
4. The agent is updating @AGENT.md with learnings
5. Standard library is being implemented in Python itself
6. The agent is creating and updating specifications in specs/

## Limitations and Mitigations

### Known Limitations
- Non-deterministic output (same prompt can yield different results)
- Tendency toward placeholder implementations
- Context window limitations causing forgotten specifications
- Potential for infinite loops or scope creep

### Mitigations
- **Tuning**: Continuously refine PROMPT.md based on observed behavior
- **Specifications**: Keep specs/ up-to-date as the source of truth
- **Subagents**: Use for expensive operations to preserve primary context
- **Backpressure**: Implement tests, type checking, and linting as validation gates
- **Manual Intervention**: Be prepared to reset or provide guidance when needed

## References

1. Geoffrey Huntley's Ralph Wiggum technique: https://ghuntley.com/ralph/
2. RepoMirror practical implementation: https://github.com/repomirrorhq/repomirror/blob/main/repomirror.md
3. The CURSed language project example: https://github.com/repomirrorhq/repomirror

This specification provides a foundation for implementing the Ralph Wiggum pattern in Python projects. Adjust and tune based on your specific project needs and observations of the agent's behavior.
---
name: usage/undo-changes
description: How to undo and redo changes made by OpenCode - reverting modifications and recovering work
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Undoing and Redoing Changes with OpenCode

Learn how to use OpenCode's undo and redo functionality to revert changes, recover previous states, and experiment safely.

## Understanding Undo/Redo in OpenCode

OpenCode provides robust undo/redo capabilities that allow you to:
- Revert unwanted changes made by the AI
- Experiment with different approaches without fear
- Recover from mistakes or incorrect implementations
- Step through your change history
- Maintain confidence when asking OpenCode to make modifications

## How Undo/Redo Works

### The `/undo` Command
- Reverts the most recent set of changes made by OpenCode
- Can be used multiple times to step back through your history
- Only affects changes made by OpenCode (not manual edits you made)
- Shows you what was reverted so you can confirm it's what you wanted

### The `/redo` Command
- Reapplies changes that were previously undone
- Only works after you've used `/undo`
- Can be used multiple times to move forward through your history
- Shows you what was reapplied

## When to Use Undo/Redo

### After Unsatisfactory Changes
When OpenCode makes changes that don't meet your expectations:
1. Run `/undo` to revert the changes
2. Review what was changed and why it wasn't right
3. Provide better guidance or more specific instructions
4. Ask OpenCode to try again with improved guidance

### During Experimentation
When you want to try different approaches:
1. Ask OpenCode to implement approach A
2. If you want to try approach B instead, run `/undo`
3. Ask OpenCode to implement approach B
4. Compare the results and choose the better option
5. Use `/undo` and `/redo` to switch between approaches for comparison

### When Changing Requirements
If requirements change after OpenCode has started working:
1. Use `/undo` to revert to the state before work began
2. Provide the updated requirements
3. Ask OpenCode to implement based on the new requirements

## Best Practices for Using Undo/Redo

### Undo is Your Safety Net
Don't hesitate to ask OpenCode to try things because you can always undo:
- Experiment with different implementations
- Ask for alternative approaches
- Request changes you're not completely sure about
- Use undo/redo as part of your development workflow

### Make Small, Focused Requests
Smaller changes are easier to undo and redo cleanly:
- Break large requests into smaller pieces
- Undo/redo works best on discrete, related changes
- If a large change goes wrong, you lose more work when undoing

### Understand What Gets Undone
OpenCode's undo/redo system:
- Only undoes changes made by OpenCode during the current session
- Does not affect manual edits you made in your editor
- Does not affect changes made by other processes or tools
- Works at the level of "change sets" - groups of related modifications

### Communicate Clearly When Undoing
When you undo changes, consider:
- Explaining why you're undoing (helps OpenCode learn)
- Providing guidance for what to do differently next time
- Asking OpenCode to explain what it changed before you undo
- Using the opportunity to refine your request

## Example Workflows

### Workflow 1: Experimental Implementation
```
<!-- First approach -->
/tab
Create a validation function for email addresses
<tab>
Sounds good, implement it.

<!-- Realize it's not quite what we want -->
/undo

<!-- Try a different approach -->
/tab
Create a validation function for email addresses that also checks domain validity
<tab>
Sounds good, implement it.

<!-- Like the second approach better, but want to compare -->
/undo
<!-- Now we're back to first approach -->
/redo
<!-- Now we're back to second approach -->
```

### Workflow 2: Fixing Mistaken Changes
```
<!-- Ask OpenCode to fix a bug -->
Fix the infinite loop in the pagination function

<!-- OpenCode makes changes but introduces a new issue -->
/undo

<!-- Provide better guidance -->
Actually, the issue was an off-by-one error, not an infinite loop.
Please fix the loop condition in @src/utils/pagination.js:lines 45-50
<tab>
Sounds good, implement it.
```

### Workflow 3: Iterative Refinement
```
<!-- Ask for initial implementation -->
/tab
Create a basic user authentication system
<tab>
Sounds good, implement it.

<!-- Review and request improvements -->
The implementation works but lacks proper error handling.
Please add comprehensive error handling to all auth functions.
<tab>
Sounds good, implement it.

<!-- Still not quite right -->
/undo
Let me be more specific about the error handling needed:
1. Handle invalid credentials
2. Handle expired tokens
3. Handle database connection errors
4. Return appropriate HTTP status codes
<tab>
Sounds good, implement it.
```

## Tips for Effective Undo/Redo Usage

### Before Asking for Changes
1. Consider if this is something you might want to undo
2. Think about how you'll know if the changes are satisfactory
3. Decide what guidance you'd give if you needed to undo and retry

### After Using Undo
1. Clearly explain what didn't work about the previous attempt
2. Provide specific, actionable guidance for the next attempt
3. Consider asking OpenCode to explain its approach before implementing
4. Use the opportunity to refine your requirements or constraints

### When Collaborating
1. Communicate when you're undoing/redoing changes in shared sessions
2. Explain your reasoning to team members
3. Use undo/redo as part of pair programming or mobbing sessions
4. Document important undo/redo decisions in your project history

## Limitations and Considerations

### What Undo/Redo Doesn't Affect
- Manual edits you made in your editor outside of OpenCode
- Changes made by other processes (build tools, linters, etc.)
- Git commits or version history
- File system changes outside OpenCode's scope
- Environment variables or system configuration

### Best Combined With
- Frequent commits to Git for major milestones
- Manual backups for experimental work
- Testing to verify changes before and after undo/redo
- Clear communication about what you're trying to achieve

### When to Use Git Instead
Consider using Git commits instead of/along with OpenCode's undo/redo when:
- You've completed a logical unit of work
- You want to share changes with others
- You need to preserve work across sessions
- You're making changes that OpenCode didn't make
- You want a more permanent record of changes

## Example Prompts

### Requesting Changes with Undo in Mind
```
I want to try two different approaches to this problem.
First, let's try approach A. If it's not quite right, I'll undo and we'll try approach B.
```

### After Undoing
```
The previous attempt didn't work because [reason].
This time, please [specific guidance] instead of [what didn't work].
```

### Comparing Alternatives
```
Let's implement approach A, then undo and implement approach B so we can compare them side by side.
```

By mastering OpenCode's undo/redo functionality, you can work more confidently and efficiently, knowing that you can easily experiment, make mistakes, and recover without losing progress or creating permanent unwanted changes.
---
name: usage/make-changes
description: How to use OpenCode to make direct changes to your codebase - straightforward modifications and refactoring
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Making Changes with OpenCode

Learn how to use OpenCode for straightforward code modifications, refactoring, and direct changes to your codebase.

## When to Make Direct Changes

While planning is recommended for complex features, OpenCode excels at making direct changes for:
- Simple bug fixes
- Straightforward refactoring
- Boilerplate code generation
- Adding well-understood functionality
- Updating dependencies or versions
- Renaming identifiers across files
- Adding tests for existing code
- Improving code readability without changing behavior

## How to Request Direct Changes

To ask OpenCode to make direct changes:
1. Stay in Build mode (default mode when you start)
2. Clearly describe what you want changed
3. Provide specific references to the code you want modified
4. Be precise about the desired outcome

**Example:**
```
We need to add authentication to the /settings route. Take a look at how this is handled in the /notes route in @packages/functions/src/notes.ts and implement the same logic in @packages/functions/src/settings.ts
```

## Best Practices for Requesting Changes

### Be Specific About What to Change
Instead of vague requests, be precise:
- **Less Effective**: "Make this code better"
- **More Effective**: "Rename the `getUserData` function to `fetchUserProfile` in @src/services/userService.js and update all references"

### Reference Existing Code
When asking OpenCode to follow existing patterns:
```
Add error handling to this API route similar to how it's done in @src/routes/users.js
```

### Specify the Desired Outcome
Clearly state what you want to achieve:
```
Convert this class-based component to a functional component using React hooks
```

### Indicate Scope and Boundaries
Let OpenCode know what's in scope:
```
Only modify the validation logic in this function, don't change the API signature
```

## Common Direct Change Requests

### Refactoring
```
Extract this duplicated logic into a reusable utility function
```

### Bug Fixes
```
Fix the off-by-one error in this loop that causes the last item to be skipped
```

### Code Improvements
```
Replace this callback-based async code with async/await for better readability
```

### Adding Features (Simple)
```
Add a timeout parameter to this function with a default value of 5000ms
```

### Updates and Migrations
```
Update all lodash.get calls to use optional chaining where possible
```

### Testing
```
Create unit tests for this utility function covering all edge cases
```

### Documentation
```
Add JSDoc comments to all public functions in this module
```

## Providing Context for Changes

### File References
Use `@` to reference specific files:
```
Update the configuration in @src/config/database.js to use connection pooling
```

### Function References
Reference specific functions:
```
Refactor the validateEmail function in @src/utils/validation.js to use regex instead of string splitting
```

### Code Snippets
Include code snippets when asking about specific patterns:
```
I want to replace this pattern:
[code snippet]
With something more modern like:
[code snippet]
```

### Before and After Examples
Show what you want:
```
Change this:
function getUser(id) {
  return db.users.find(u => u.id === id);
}

To this:
async function getUser(id) {
  const user = await db.users.findById(id);
  if (!user) {
    throw new Error(`User not found: ${id}`);
  }
  return user;
}
```

## Working with OpenCode on Changes

### Reviewing Suggestions
OpenCode will typically:
1. Show you what it plans to change
2. Ask for confirmation before making changes
3. Provide a diff view of the proposed modifications
4. Allow you to request adjustments

### Requesting Revisions
If the suggested changes aren't quite right:
- Ask for clarification on any unclear parts
- Request different approaches
- Point out missed edge cases
- Suggest improvements to the implementation

### Iterating on Changes
You can go back and forth:
1. Request initial changes
2. Review the implementation
3. Ask for refinements or adjustments
4. Request additional related changes
5. Verify everything works together

## Ensuring Quality

### Testing After Changes
After OpenCode makes changes:
- Run existing tests to ensure nothing broke
- Test the specific functionality that was modified
- Consider adding tests for new code if none exist
- Check for any linting or formatting issues

### Following Conventions
Ask OpenCode to:
- Follow your project's coding style and conventions
- Use the same patterns and idioms as existing code
- Maintain consistent naming conventions
- Keep the same level of abstraction and detail

## Example Prompts

### Refactoring Request
```
Refactor this complex conditional into a series of guard clauses for better readability @src/services/orderService.js:processOrder
```

### Bug Fix
```
Fix the infinite loop in this pagination function when the page size is zero @src/utils/pagination.js
```

### Simple Feature Addition
```
Add a createdAt timestamp to this Mongoose schema @src/models/Post.js
```

### Code Modernization
```
Convert this CommonJS module to ES6 modules @src/utils/helpers.js
```

### Testing Request
```
Create Jest unit tests for this utility function covering normal cases, edge cases, and error conditions @src/utils/stringUtils.js
```

## Using Undo and Redo

If you're not satisfied with the changes:
- Use `/undo` to revert the changes
- Review what was changed and why it didn't meet expectations
- Request the changes again with better guidance
- Use `/redo` if you change your mind after undoing

By following these practices, you'll get more accurate and useful results when asking OpenCode to make direct changes to your codebase, leading to fewer revisions and higher quality code modifications.
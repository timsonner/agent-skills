---
name: usage/add-features
description: How to use OpenCode to add new features to your project - planning, iterating, and building with AI assistance
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Adding Features with OpenCode

Learn how to effectively use OpenCode to add new features to your project through planning, iteration, and implementation.

## The Feature Development Workflow

OpenCode follows a recommended workflow for adding features that helps ensure quality and alignment with your requirements:

### 1. Create a Plan (Recommended First Step)

Start by asking OpenCode to create a plan rather than immediately implementing changes. This allows you to review and refine the approach before any code is modified.

**How to use Plan Mode:**
- Press the **Tab** key to switch to Plan mode
- Describe the feature you want to add in detail
- OpenCode will suggest how it would implement the feature without making changes
- Review the plan, provide feedback, and request adjustments as needed

**Example:**
```
<TAB>
When a user deletes a note, we'd like to flag it as deleted in the database.
Then create a screen that shows all the recently deleted notes.
From this screen, the user can undelete a note or permanently delete it.
```

### 2. Iterate on the Plan

Once OpenCode provides a plan, you can:
- Ask for clarification on any unclear points
- Request alternative approaches
- Provide additional context or constraints
- Share design references or examples
- Ask for performance or security considerations

**Example:**
```
We'd like to design this new screen using a design I've used before.
[Image #1] Take a look at this image and use it as a reference.
```

You can drag and drop images into the terminal to include them in your prompt.

### 3. Build the Feature

When you're satisfied with the plan:
- Press the **Tab** key again to switch back to Build mode
- Ask OpenCode to implement the feature
- Review the changes and request refinements if needed

**Example:**
```
<TAB>
Sounds good! Go ahead and make the changes.
```

## Best Practices for Adding Features

### Be Specific and Detailed
The more detail you provide, the better OpenCode can understand and implement your feature:
- Describe user interactions and workflows
- Specify data models and storage requirements
- Mention any API endpoints or integrations needed
- Note performance, security, or accessibility considerations

### Use Examples and References
Help OpenCode understand your vision by providing:
- Code examples from similar implementations
- Design mockups or screenshots
- References to existing patterns in your codebase
- Links to documentation or specifications

### Break Down Large Features
For complex features, consider:
- Implementing in smaller, manageable pieces
- Getting feedback on each piece before moving to the next
- Building foundational elements first
- Adding complexity incrementally

### Leverage Existing Code
Ask OpenCode to:
- Follow existing patterns and conventions in your codebase
- Reuse existing components or utilities
- Maintain consistency with current code style
- Extend rather than duplicate functionality

## Common Feature Request Patterns

### CRUD Operations
```
Create a complete CRUD interface for managing blog posts including:
- List view with pagination
- Create form with validation
- Edit form that pre-populates with existing data
- Delete functionality with confirmation
- API endpoints for all operations
```

### Authentication Features
```
Add password reset functionality:
- "Forgot password" link on login page
- Email token generation and expiration
- Secure password reset form
- Password strength validation
- Login automatic after successful reset
```

### UI/UX Enhancements
```
Improve the data table component to include:
- Column sorting (ascending/descending)
- Column visibility toggling
- Row selection with bulk actions
- Export to CSV functionality
- Responsive design for mobile views
```

### Integration Features
```
Add Slack notifications for failed jobs:
- Webhook configuration in settings
- Message formatting with job details
- Rate limiting to prevent spam
- Failure template vs success template
- Opt-in/out per job type
```

## Example Prompts

### For Planning Phase
```
<TAB>
I want to add real-time collaboration to our document editor.
Users should see others' cursors and changes instantly.
We need to handle conflicts when two users edit the same section.
```

### For Providing Feedback
```
The plan looks good, but I'm concerned about:
1. How we'll handle network disruptions
2. What happens when multiple users try to accept/reject the same suggestion
3. Whether we need to consider operational transformation vs conflict-free replicated data types
```

### For Implementation Request
```
<TAB>
The plan addresses my concerns. Please implement the real-time collaboration feature
using the approach we discussed, starting with the cursor positioning updates.
```

## Reviewing and Refining Implementation

After OpenCode implements features:
1. **Test Thoroughly**: Verify the feature works as expected
2. **Check Consistency**: Ensure it follows your codebase conventions
3. **Review Edge Cases**: Consider boundary conditions and error scenarios
4. **Request Refinements**: Ask for improvements based on testing
5. **Consider Performance**: Ask about performance implications if relevant

## Undoing Changes

If you're not satisfied with the implementation:
- Use `/undo` to revert the changes
- Return to Plan mode to revise the approach
- Try again with updated requirements or feedback

By following this workflow, you'll get better results when using OpenCode to add features to your projects, with more control over the implementation process and higher quality outcomes.
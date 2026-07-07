---
name: usage/ask-questions
description: How to ask OpenCode questions about your codebase - using context, file references, and effective questioning techniques
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Asking Questions with OpenCode

Learn how to effectively ask OpenCode questions about your codebase to get accurate, helpful explanations and insights.

## Effective Questioning Techniques

### 1. Be Specific and Detailed
Instead of asking vague questions, provide specific details about what you want to know:

**Less Effective**: "How does this work?"
**More Effective**: "How does the authentication middleware validate JWT tokens in @src/middleware/auth.js?"

### 2. Use File and Code References
Leverage the `@` syntax to reference specific files, functions, or code sections:

```
How is data validation handled in @src/models/User.js?
```

You can also reference specific lines or functions:
```
Explain the calculateTotal function in @src/utils/math.js:lines 15-30
```

### 3. Provide Context
Give OpenCode background information to help it give better answers:

```
I'm trying to understand how user sessions work in this Express app. 
Looking at @src/server.js, I see session middleware is configured, 
but I'm not sure how the session data is stored and retrieved.
```

### 4. Ask About Relationships and Patterns
Don't just ask about isolated code - ask how things connect:

```
How does the user authentication flow work from login middleware 
to protected routes in @src/routes/auth.js?
```

### 5. Request Explanations at Different Levels
You can ask for high-level overviews or deep dives:

**High-level**: "Give me an overview of how data flows through this application"
**Specific**: "Explain exactly how this Redux reducer handles state updates"
**Implementation-focused**: "Show me how this API endpoint connects to the database layer"

## Common Question Patterns

### Explaining Code
```
What does this function do? @src/services/payment.js:processPayment
```

### Understanding Architecture
```
How is this project structured? Where are the controllers, models, and views located?
```

### Debugging Assistance
```
Why might this be causing a null reference error? @src/components/Form.js:handleSubmit
```

### Learning Patterns
```
How are promises handled in this codebase? Show me examples of async/await usage.
```

### Best Practices Inquiry
```
Is this following React best practices for state management? @src/components/Dashboard.jsx
```

## Using Context Effectively

### File References
The `@` symbol triggers fuzzy file search:
```
@src/components/Button.js
```
This will find Button.js even if you don't know the exact path.

### Multiple References
You can reference multiple files in one question:
```
How do @src/api/users.js and @src/components/UserProfile.js interact?
```

### Code Snippets
You can paste code snippets directly in your questions:
```
I'm seeing this error: "Cannot read property 'map' of undefined"
Here's the code: [paste code snippet]
What might be causing this?
```

## Question Refinement

If OpenCode's answer isn't quite what you expected:

1. **Add More Details**: Provide additional context or constraints
2. **Reference Different Files**: Try referencing related files
3. **Rephrase**: Ask the question in a different way
4. **Break It Down**: Split complex questions into simpler parts
5. **Ask for Examples**: Request concrete examples to illustrate concepts

## Example Questions

### For Onboarding to a New Codebase
```
What are the main components of this application and how do they interact?
```

### For Understanding Specific Functionality
```
How does file upload work in this app? Look at @src/routes/upload.js and @src/services/storage.js.
```

### For Learning Coding Patterns
```
Show me how dependency injection is used in this codebase.
```

### For Debugging
```
This function keeps returning null: @src/utils/formatDate.js
What could be causing this issue?
```

### For Code Review
```
Does this implementation properly handle error cases? @src/api/payments.js:processRefund
```

By mastering these questioning techniques, you'll get more accurate and useful responses from OpenCode, making your development process more efficient and effective.

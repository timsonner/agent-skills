---
name: usage/go
description: Using OpenCode with Go projects - specific workflows and tips for Go development
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode with Go

OpenCode provides specialized assistance for Go development, helping you write, refactor, and maintain Go code effectively.

## Go Project Structure

When working with Go projects, OpenCode understands:

- Standard Go project layouts
- Go module structure (go.mod, go.sum)
- Package organization
- Workspace modes

## Go-Specific Assistance

OpenCode can help with:

### 1. Code Generation
- Creating new Go files with proper package declarations
- Generating boilerplate for functions, structs, and interfaces
- Creating test files (*_test.go) with appropriate imports

### 2. Refactoring
- Renaming identifiers across packages
- Extracting functions or methods
- Converting between different Go idioms
- Improving code readability while maintaining functionality

### 3. Dependency Management
- Understanding and suggesting updates to go.mod
- Helping with dependency imports
- Assisting with version upgrades

### 4. Testing Support
- Writing table-driven tests
- Creating mock implementations
- Understanding testing patterns in Go
- Assisting with benchmark creation

### 5. Build and Tooling
- Explaining build errors
- Suggesting gofmt/goimports fixes
- Helping with build tags and constraints
- Understanding CI/CD configurations for Go

## Common Go Tasks with OpenCode

### Creating a New Service
```
Create a new Go service for handling user authentication with JWT tokens.
Include methods for token generation, validation, and refresh.
```

### Refactoring for Performance
```
Optimize this Go function that processes large slices by reducing allocations
and improving cache locality.
```

### Writing Tests
```
Create comprehensive table-driven tests for the CalculateTax function,
covering edge cases and error conditions.
```

### Working with Interfaces
```
Refactor this code to use interfaces for better testability and decoupling
between the data access layer and business logic.
```

## Go Best Practices with OpenCode

When using OpenCode with Go:

1. **Leverage Go Idioms**: OpenCode understands Go-specific patterns like error handling, defer statements, and initialization
2. **Follow Conventions**: Prompt OpenCode to follow standard Go naming conventions and formatting
3. **Module Awareness**: Be explicit about module boundaries when asking for cross-package changes
4. **Testing First**: Consider asking OpenCode to help write tests before implementing features
5. **Build Validation**: Use OpenCode to help understand and fix build errors

## Example Prompts

```
How does error handling work in this Go package? @src/handlers/auth.go
```

```
Create a middleware function for logging HTTP requests in Go using the standard
net/http package.
```

```
Explain why this Go code is causing a race condition and how to fix it.
```

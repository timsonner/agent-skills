---
name: usage
description: Usage instructions for OpenCode - how to ask questions, add features, make changes, and undo changes
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# OpenCode Usage

You are now ready to use OpenCode to work on your project. Feel free to ask it anything!

## Asking Questions

You can ask OpenCode to explain the codebase to you.

Tip

Use the `@` key to fuzzy search for files in the project.

```
How is authentication handled in @packages/functions/src/api/index.ts
```

This is helpful if there’s a part of the codebase that you didn’t work on.

## Adding Features

You can ask OpenCode to add new features to your project. Though we first recommend asking it to create a plan.

### 1. Create a Plan

OpenCode has a *Plan mode* that disables its ability to make changes and instead suggest *how* it’ll implement the feature.

Switch to it using the **Tab** key. You’ll see an indicator for this in the lower right corner.

```
<TAB>
```

Now let’s describe what we want it to do.

```
When a user deletes a note, we'd like to flag it as deleted in the database.Then create a screen that shows all the recently deleted notes.From this screen, the user can undelete a note or permanently delete it.
```

You want to give OpenCode enough details to understand what you want. It helps to talk to it like you are talking to a junior developer on your team.

Tip

Give OpenCode plenty of context and examples to help it understand what you want.

### 2. Iterate on the Plan

Once it gives you a plan, you can give it feedback or add more details.

```
We'd like to design this new screen using a design I've used before.[Image #1] Take a look at this image and use it as a reference.
```

Tip

Drag and drop images into the terminal to add them to the prompt.

OpenCode can scan any images you give it and add them to the prompt. You can do this by dragging and dropping an image into the terminal.

### 3. Build the Feature

Once you feel comfortable with the plan, switch back to *Build mode* by hitting the **Tab** key again.

```
<TAB>
```

And asking it to make the changes.

```
Sounds good! Go ahead and make the changes.
```

## Making Changes

For more straightforward changes, you can ask OpenCode to directly build it without having to review the plan first.

```
We need to add authentication to the /settings route. Take a look at how this ishandled in the /notes route in @packages/functions/src/notes.ts and implementthe same logic in @packages/functions/src/settings.ts
```

You want to make sure you provide a good amount of detail so OpenCode makes the right changes.

## Undoing Changes

Let’s say you ask OpenCode to make some changes.

```
Can you refactor the function in @packages/functions/src/api/index.ts?
```

But you realize that it is not what you wanted. You **can undo** the changes using the `/undo` command.

```
/undo
```

OpenCode will now revert the changes you made and show your original message again.

```
Can you refactor the function in @packages/functions/src/api/index.ts?
```

From here you can tweak the prompt and ask OpenCode to try again.

Tip

You can run `/undo` multiple times to undo multiple changes.

Or you **can redo** the changes using the `/redo` command.

```
/redo
```

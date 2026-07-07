---
name: initialize
description: Initialization instructions for OpenCode - how to initialize OpenCode for a project and create AGENTS.md
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: setup
  language: markdown
---

# OpenCode Initialization

Now that you’ve configured a provider, you can navigate to a project that you want to work on.

Terminal window

```
cd /path/to/project
```

And run OpenCode.

Terminal window

```
opencode
```

Next, initialize OpenCode for the project by running the following command.

```
/init
```

This will get OpenCode to analyze your project and create an `AGENTS.md` file in the project root.

Tip

You should commit your project’s `AGENTS.md` file to Git.

This helps OpenCode understand the project structure and the coding patterns used.

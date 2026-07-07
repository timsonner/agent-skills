---
name: configure/keybinds
description: Configuration for OpenCode keybinds - customizing keyboard shortcuts for the TUI and desktop app
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Keybinds Configuration

Customize keyboard shortcuts in OpenCode's Terminal User Interface (TUI) and desktop application.

## Overview

OpenCode allows you to customize keybinds through the `tui.json` configuration file. You can modify existing shortcuts, disable unwanted ones, and create custom keybindings to match your workflow preferences.

## Keybinds Configuration File

Keybinds are configured in `tui.json` with the following structure:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "keybinds": {
    "leader": "ctrl+x",
    "app_exit": "ctrl+c,ctrl+d,<leader>q",
    // ... other keybinds
  }
}
```

## Important Concepts

### Leader Key
OpenCode uses a `leader` key for most keybinds to avoid conflicts with terminal shortcuts. By default, `ctrl+x` is the leader key. Most actions require pressing the leader key first, then the shortcut. For example, to start a new session, press `ctrl+x` then `n`.

You can customize the leader key or choose not to use one, though using a leader key is recommended.

### Disabling Keybinds
You can disable any keybind by setting its value to `"none"` in the configuration:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "keybinds": {
    "session_compact": "none"
  }
}
```

## Desktop Prompt Shortcuts

The OpenCode desktop app prompt input supports common Readline/Emacs-style shortcuts that are built-in and not configurable via `tui.json`:

| Shortcut | Action |
|----------|--------|
| `ctrl+a` | Move to start of current line |
| `ctrl+e` | Move to end of current line |
| `ctrl+b` | Move cursor back one character |
| `ctrl+f` | Move cursor forward one character |
| `alt+b` | Move cursor back one word |
| `alt+f` | Move cursor forward one word |
| `ctrl+d` | Delete character under cursor |
| `ctrl+k` | Kill to end of line |
| `ctrl+u` | Kill to start of line |
| `ctrl+w` | Kill previous word |
| `alt+d` | Kill next word |
| `ctrl+t` | Transpose characters |
| `ctrl+g` | Cancel popovers / abort running response |

## Shift+Enter Configuration

Some terminals don't send modifier keys with Enter by default. You may need to configure your terminal to send `Shift+Enter` as an escape sequence.

### Windows Terminal Configuration
To configure Shift+Enter in Windows Terminal:

1. Open your `settings.json` at:
   ```
   %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
   ```

2. Add this to the root-level `actions` array:
   ```json
   "actions": [
     {
       "command": {
         "action": "sendInput",
         "input": "\u001b[13;2u"
       },
       "id": "User.sendInput.ShiftEnterCustom"
     }
   ]
   ```

3. Add this to the root-level `keybindings` array:
   ```json
   "keybindings": [
     {
       "keys": "shift+enter",
       "id": "User.sendInput.ShiftEnterCustom"
     }
   ]
   ```

4. Save the file and restart Windows Terminal or open a new tab.

## Common Keybind Categories

### Session Management
- `session_new` - Create a new session
- `session_list` - List sessions
- `session_timeline` - View session timeline
- `session_fork` - Fork a session
- `session_rename` - Rename a session
- `session_share` / `session_unshare` - Share/unshare sessions
- `session_interrupt` - Interrupt current session
- `session_compact` - Compact session view
- `session_child_first` / `session_child_cycle` / `session_child_cycle_reverse` / `session_parent` - Navigate between parent/child sessions

### Message Navigation
- `messages_page_up` / `messages_page_down` - Page through messages
- `messages_line_up` / `messages_line_down` - Move line by line
- `messages_half_page_up` / `messages_half_page_down` - Half-page movement
- `messages_first` / `messages_last` - Go to first/last message
- `messages_next` / `messages_previous` - Navigate between messages
- `messages_copy` - Copy selected message
- `messages_undo` / `messages_redo` / `messages_last_user` - Undo/redo actions
- `messages_toggle_conceal` - Toggle message concealment

### Model Management
- `model_list` - List available models
- `model_cycle_recent` / `model_cycle_recent_reverse` - Cycle through recent models
- `model_cycle_favorite` / `model_cycle_favorite_reverse` - Cycle through favorite models

### Agent Management
- `agent_list` - List available agents
- `agent_cycle` / `agent_cycle_reverse` - Cycle through agents

### Input Editing
- `input_clear` - Clear input
- `input_paste` - Paste into input
- `input_submit` - Submit input (Enter/Return)
- `input_newline` - Add newline (Shift+Enter, Ctrl+Enter, Alt+Enter, Ctrl+J)
- Movement: `input_move_left/right/up/down`
- Selection: `input_select_left/right/up/down`
- Home/End: `input_line_home/end`, `input_select_line_home/end`
- Visual selection: `input_visual_line_home/end`, `input_select_visual_line_home/end`
- Buffer navigation: `input_select_buffer_home/end`
- Deletion: `input_delete_line`, `input_delete_to_line_end/start`, `input_backspace`, `input_delete`
- Undo/Redo: `input_undo`, `input_redo`
- Word navigation: `input_word_forward/backward`, `input_select_word_forward/backward`
- Word deletion: `input_delete_word_forward/backward`

### History Navigation
- `history_previous` / `history_next` - Navigate command history

### Terminal & Misc
- `terminal_suspend` - Suspend terminal (Ctrl+Z)
- `terminal_title_toggle` - Toggle terminal title
- `tips_toggle` - Show/hide tips
- `display_thinking` - Display thinking process

## Best Practices

1. **Start with Defaults**: Begin with OpenCode's default keybinds and customize only what doesn't work for you
2. **Consider Conflicts**: Avoid keybinds that conflict with your terminal, shell, or other frequently used applications
3. **Leader Key Usage**: Use the leader key for most customizations to prevent conflicts
4. **Group Related Actions**: Keep related functions on similar key combinations for muscle memory
5. **Accessibility**: Consider physical comfort when choosing key combinations
6. **Document Changes**: Keep track of your custom keybinds for reference and team sharing
7. **Test Thoroughly**: Verify that your keybinds work as expected in different contexts

## Example Configurations

### Custom Leader Key
```json
{
  "$schema": "https://opencode.ai/tui.json",
  "keybinds": {
    "leader": "ctrl+\\",
    "app_exit": "ctrl+c,ctrl+d,<leader>q",
    "editor_open": "<leader>e"
  }
}
```

### Vim-like Navigation
```json
{
  "$schema": "https://opencode.ai/tui.json",
  "keybinds": {
    "messages_line_up": "k",
    "messages_line_down": "j",
    "messages_half_page_up": "ctrl+u",
    "messages_half_page_down": "ctrl+d",
    "messages_first": "g",
    "messages_last": "G",
    "session_child_first": "<leader>j",
    "session_child_cycle": "l",
    "session_child_cycle_reverse": "h",
    "session_parent": "k"
  }
}
```

### Emacs-inspired
```json
{
  "$schema": "https://opencode.ai/tui.json",
  "keybinds": {
    "input_clear": "ctrl+g",
    "input_move_left": "ctrl+b",
    "input_move_right": "ctrl+f",
    "input_move_up": "ctrl+p",
    "input_move_down": "ctrl+n",
    "input_select_left": "meta+b",
    "input_select_right": "meta+f",
    "input_select_up": "meta+p",
    "input_select_down": "meta+n",
    "input_line_home": "ctrl+a",
    "input_line_end": "ctrl+e"
  }
}
```

By customizing keybinds, you can make OpenCode feel more natural and efficient for your specific workflow and editing preferences.

---
name: read-canvas-browser
description: Use this skill when browser text and accessibility tools fail because the page renders content in a canvas and you need to inspect or interact with it visually.
---

# Skill: Interacting with Canvas-Rendered Browser Content

## When to use
Use this skill when:
- `get_page_text` returns empty or only navigation chrome
- `read_page` returns an empty accessibility tree
- The page is known to use canvas, WebGL, or a custom rendering engine
- You need to visually read or interact with content that DOM tools cannot access

---

## The Core Problem

Some web UIs render all visible content onto an HTML `<canvas>` element rather than the DOM. The Chrome MCP's text and accessibility tools see nothing useful — but the content IS on screen. The solution combines two separate tool sets with different capabilities.

---

## The Two Tool Sets

### Chrome MCP (`mcp__Claude_in_Chrome__*`)
Talks directly to the browser via the Claude extension. Use this for:
- Navigating to URLs
- Reading normal HTML pages (`get_page_text`, `read_page`)
- Running JavaScript in the page (`javascript_tool`)
- Clicking DOM elements, filling forms

### Computer-use (`mcp__computer-use__*`)
Controls the OS and sees the actual screen pixels. Use this for:
- Taking screenshots that capture canvas content
- Zooming into screen regions to read fine detail
- Clicking visible elements on screen (`left_click` with coordinates from a screenshot)

These two tool sets complement each other — use Chrome MCP to drive the browser and computer-use to see and interact with what's rendered.

---

## Step-by-Step

### 1. Request computer-use access to Chrome

```
mcp__computer-use__request_access
  apps: ["Google Chrome"]
  reason: <one sentence describing what you need to see>
```

Check the response for `windowLocations` — it tells you which monitor Chrome is on.

### 2. Switch display if needed

If Chrome is on a secondary monitor, switch to it before screenshotting:

```
mcp__computer-use__switch_display
  display: "ASUS VS239 (2)"   ← whatever name appeared in windowLocations
```

### 3. Navigate to the target page (Chrome MCP)

```
mcp__Claude_in_Chrome__navigate
  tabId: <id>
  url: <target url>
```

### 4. Take a screenshot to see the canvas

```
mcp__computer-use__screenshot
```

### 5. Zoom in to read details

Full-screen screenshots are often too small to read tables or fine text. Zoom into a region — coordinates are always from the last full screenshot:

```
mcp__computer-use__zoom
  region: [x0, y0, x1, y1]
```

### 6. Interact with the page

**Option A — JavaScript click (for nav elements that are real HTML under the canvas):**

Even on canvas-heavy pages, tabs, sidebar links, and buttons are often real HTML elements that trigger canvas redraws. Find and click them by label:

```javascript
const all = document.querySelectorAll('*');
let el = null;
for (const e of all) {
  if (e.children.length === 0 && e.innerText && e.innerText.trim() === 'TARGET LABEL') {
    el = e; break;
  }
}
if (el) { el.click(); 'clicked: ' + el.outerHTML.substring(0, 150); }
else { 'not found' }
```

**Option B — computer-use left_click (for clicking canvas pixels directly):**

Use coordinates from the most recent screenshot to click anywhere on screen, including inside a canvas:

```
mcp__computer-use__left_click
  coordinate: [x, y]
```

After any click, take a fresh screenshot to see what changed.

### 7. Try fetching data directly (optional shortcut)

If the canvas reads from a backend endpoint, bypass the UI entirely:

```javascript
(async () => {
  const r = await fetch('/some/data/endpoint', {credentials: 'include'});
  window._scraped = await r.text();
})();
// Second javascript_tool call:
window._scraped
```

---

## Quick Reference

| Situation | Tool |
|-----------|------|
| Page renders as normal HTML | Chrome MCP `get_page_text` or `read_page` |
| Need to see canvas content | computer-use `screenshot` |
| Need to read small text | computer-use `zoom` |
| Click a nav/tab that's a real HTML element | Chrome MCP `javascript_tool` → `el.click()` |
| Click a pixel location on the canvas | computer-use `left_click` with screenshot coordinates |
| Navigate to a URL | Chrome MCP `navigate` |
| Chrome is on a different monitor | computer-use `switch_display` |

---

## Gotchas

- **Navigate first, screenshot second.** Use Chrome MCP to get to the right page, then screenshot to read it.
- **Zoom coordinates are always from the last full screenshot**, never from a previous zoom.
- **JS dropdowns may not be real `<select>` elements** on canvas pages — if querying selects returns unrelated results, the control is canvas. Read it visually and use `left_click` to interact.
- **Canvas redraws are asynchronous.** After a click, wait briefly and take a fresh screenshot before reading the result.
- **Coordinates from screenshots map to screen pixels** — use zoom to locate exact positions before clicking.

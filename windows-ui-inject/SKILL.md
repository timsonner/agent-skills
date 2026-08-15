---
name: windows-ui-inject
description: >
  Inject mouse and keyboard input on Windows via PowerShell and user32 when computer-use
  is screenshot-only (tier "read") or when driving non-browser UI such as mstsc RDP dialogs.
  Use for Edge/Chrome/Firefox navigation under read-only browser grants, "granted at tier
  read", Claude-in-Chrome disconnected, Remote Desktop Connection security/credentials
  dialogs, Connect vs Learn more, or any frontmost non-elevated window that screenshots
  can see but MCP cannot click. Triggers: "/windows-ui-inject", "windows-ui-inject",
  "browser-read-bypass", "/browser-read-bypass", user32, mstsc Connect.
author: Tim Sonner
license: MIT
---

# Windows UI inject (browser + RDP client)

Former name: **`browser-read-bypass`**. Same skill.

When computer-use can **see** a window but cannot click or type, inject input with
`user32` / `System.Windows.Forms` from **PowerShell** (run via the shell tool — do not
type into a PowerShell window through the UI).

Applies to:

- Browsers (Edge, Chrome, Firefox) under tier **read**
- **mstsc** / Remote Desktop Connection (security warning, credentials, session chrome)
- Other non-elevated desktop apps the agent must drive from screenshots

For **building** a GNOME Wayland / GDM-style RDP **server** (headless shell + GRD), use
**`gnome-wayland-rdp`**. Full loop: **`agent-workstation-drive`**. This skill is
**client-side UI automation only**. Canvas/WebGL pages when computer-use **can**
click: **`read-canvas-browser`**.

### Portable script

`scripts/Invoke-MstscConnect.ps1` — parameterized host/port/user/password, cmdkey seed,
Connect (not Learn more), screenshots. Run with **Windows PowerShell 5.1**.

## Core sequence

1. Screenshot — identify the focused window and targets
2. Dismiss stray menus (`ESC`) if needed
3. Click (or key-activate) the control
4. Type if needed
5. Screenshot again to verify

Never assume fixed pixel positions across sessions — re-measure from the current shot and
window rect. Prefer **window-relative** fractions after `GetWindowRect`.

## Reusable PowerShell

### Click at coordinates

```powershell
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class Mouse {
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(int f, int a, int b, int c, int d);
    public static void Click(int x, int y) {
        SetCursorPos(x, y);
        System.Threading.Thread.Sleep(150);
        mouse_event(2, 0, 0, 0, 0);
        mouse_event(4, 0, 0, 0, 0);
        System.Threading.Thread.Sleep(150);
    }
}
'@
[Mouse]::Click($x, $y)
```

### Type / keys

```powershell
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("text")
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
[System.Windows.Forms.SendKeys]::SendWait("^a")      # Ctrl+A
[System.Windows.Forms.SendKeys]::SendWait("+{TAB}")  # Shift+Tab
```

Escape in SendKeys: `+ ^ % ~ ( ) [ ] { }` → wrap in `{}` (e.g. `{+}`).

### Find a visible window by title (optionally by PID)

```powershell
# EnumWindows + GetWindowText + optional GetWindowThreadProcessId
# Prefer scoping to mstsc PID so Edge tabs titled "Remote Desktop" are not hit
```

Use **Windows PowerShell 5.1** (`$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe`)
when `Add-Type` + `System.Drawing` fails under PowerShell 7 (missing assembly refs).

### Full-screen screenshot

```powershell
Add-Type -AssemblyName System.Windows.Forms,System.Drawing
# CopyFromScreen PrimaryScreen.Bounds → PNG path
```

---

## mstsc / RDP client automation

### Rules that prevent false negatives

| Do | Do not |
|---|---|
| Click **Connect** on the security warning | Click **Learn more** (opens browser; wastes the run) |
| Scope window search to **mstsc process PID** | Match any window with "Remote Desktop" in the title |
| Prefer **Shift+Tab** then **Enter** when Cancel has default focus | Assume Enter activates Connect |
| Seed credentials with **cmdkey** + RDP `prompt for credentials:i:0` when automating | Rely on SendKeys into **Windows Security** password fields |
| Checkboxes only if needed (e.g. Clipboard); re-measure Y when the dialog gains a "credentials" footer | Hard-code absolute Y from an older dialog height |

### Security warning dialog layout (relative)

After `GetWindowRect` → width `W`, height `H`, origin `(L, T)`:

- Resource checkboxes (left column): roughly `L + 0.18*W`, mid-dialog height — if a
  "Use the following credentials" block is present, list is higher (~`0.55–0.62*H`);
  without it, lower (~`0.70*H`).
- **Connect**: left of Cancel, ~`L + 0.72*W`, ~`T + 0.92*H`
- **Cancel**: default focus (often blue outline), right of Connect
- **Learn more**: hyperlink in the **upper** warning body — never aim clicks at mid-body right

### Credentials

- **Windows Security** ("Enter your credentials") is often a **different process** from mstsc.
- CredUI / password fields frequently **ignore** SendKeys and Unicode SendInput from
  automation (empty field, OK no-ops).
- Lab automation pattern:

```powershell
cmdkey /generic:TERMSRV/<host> /user:<user> /pass:<pass>
# .rdp: full address, username, authentication level:i:0,
#       prompt for credentials:i:0, enablecredsspsupport as needed
```

Do **not** bake host, port, or password into skills — take them from the project `.rdp`,
env, or user. Use placeholders in docs: `<host>`, `<port>`, `<user>`.

### Session established signals

- mstsc `MainWindowTitle` becomes something like `<file> - <host>[:port] - Remote Desktop Connection`
- Pure black client area can mean server-side graphics stall (see **`gnome-wayland-rdp`**),
  not a failed Connect click
- Always **check server logs** before re-clicking Connect in a loop

---

## Browser navigation (summary)

1. `ESC` to clear menus  
2. Click address bar (measure; ~top chrome center is only a hint)  
3. `^a`, type URL, `{ENTER}`  
4. Wait for load, screenshot  

---

## Timing

- 150–400 ms after focus/click before typing  
- 1–2 s after Connect before assuming credentials or session chrome  
- If a click misses, re-shot and recompute from rect — lag is more common than wrong API  

---

## Limitations

- **Windows only**
- **UAC / elevated** windows: UIPI blocks injection from lower integrity
- SendKeys goes to the **foreground** window — `SetForegroundWindow` first
- Does not bypass network, TLS, or auth policy — only local UI input
- PowerShell 7 may need different `Add-Type` assembly refs than 5.1

# Portable mstsc connect helper for agents (Windows).
# Prefer Windows PowerShell 5.1 for System.Drawing Add-Type reliability.
#
# Example:
#   powershell -NoProfile -ExecutionPolicy Bypass -File Invoke-MstscConnect.ps1 `
#     -HostAddress 127.0.0.1 -Port 13394 -User azureuser -Password azureuser `
#     -ShotDir $env:TEMP\rdp-shots
#
# Rules: click Connect (never Learn more); seed cmdkey; PID-scope mstsc windows.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$HostAddress,
  [Parameter(Mandatory = $true)][int]$Port,
  [Parameter(Mandatory = $true)][string]$User,
  [Parameter(Mandatory = $true)][string]$Password,
  [string]$RdpPath = "",
  [string]$ShotDir = "",
  [switch]$NoClipboard
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$code = @'
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Drawing;
using System.Drawing.Imaging;
using System.Text;

public class WinInput {
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(int f, int a, int b, int c, int d);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int n);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
  public delegate bool EnumWindowsProc(IntPtr h, IntPtr l);
  public static void Click(int x, int y) {
    SetCursorPos(x, y);
    System.Threading.Thread.Sleep(150);
    mouse_event(2, 0, 0, 0, 0);
    mouse_event(4, 0, 0, 0, 0);
    System.Threading.Thread.Sleep(200);
  }
  public static void Shot(string p) {
    Rectangle b = Screen.PrimaryScreen.Bounds;
    using (Bitmap bmp = new Bitmap(b.Width, b.Height))
    using (Graphics g = Graphics.FromImage(bmp)) {
      g.CopyFromScreen(b.Location, Point.Empty, b.Size);
      bmp.Save(p, ImageFormat.Png);
    }
  }
  private static string s_part; private static IntPtr s_found; private static uint s_pid;
  private static bool EnumCb(IntPtr h, IntPtr l) {
    if (!IsWindowVisible(h)) return true;
    if (s_pid != 0) {
      uint pid; GetWindowThreadProcessId(h, out pid);
      if (pid != s_pid) return true;
    }
    StringBuilder sb = new StringBuilder(512);
    GetWindowText(h, sb, 512);
    string t = sb.ToString();
    if (string.IsNullOrEmpty(t)) return true;
    if (t.IndexOf(s_part, StringComparison.OrdinalIgnoreCase) >= 0) { s_found = h; return false; }
    return true;
  }
  public static IntPtr FindWindowTitle(string titlePart, uint pidFilter) {
    s_part = titlePart; s_pid = pidFilter; s_found = IntPtr.Zero;
    EnumWindows(EnumCb, IntPtr.Zero);
    return s_found;
  }
}
'@

try {
  Add-Type -TypeDefinition $code -ReferencedAssemblies System.Windows.Forms,System.Drawing -ErrorAction Stop
} catch {
  if (-not ([System.Management.Automation.PSTypeName]'WinInput').Type) { throw }
}

if (-not $ShotDir) { $ShotDir = Join-Path $env:TEMP ("rdp-shots-" + [guid]::NewGuid().ToString("n").Substring(0, 8)) }
New-Item -ItemType Directory -Force -Path $ShotDir | Out-Null

if (-not $RdpPath) {
  $RdpPath = Join-Path $ShotDir "session.rdp"
  $clip = if ($NoClipboard) { 0 } else { 1 }
  $body = @(
    "full address:s:${HostAddress}:${Port}"
    "username:s:$User"
    "authentication level:i:0"
    "prompt for credentials:i:0"
    "promptcredentialonce:i:0"
    "negotiate security layer:i:1"
    "enablecredsspsupport:i:1"
    "redirectclipboard:i:$clip"
  ) -join "`r`n"
  Set-Content -Path $RdpPath -Value $body -Encoding ASCII
}

Write-Output "Seeding cmdkey TERMSRV/$HostAddress ..."
cmdkey /delete:"TERMSRV/$HostAddress" 2>$null | Out-Null
cmdkey /generic:"TERMSRV/$HostAddress" /user:$User /pass:$Password | Out-Null

Get-Process mstsc -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 600

Write-Output "Launching mstsc $RdpPath"
Start-Process mstsc.exe -ArgumentList "`"$RdpPath`""
Start-Sleep -Seconds 2.5

$proc = Get-Process mstsc -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proc) { throw "mstsc failed to start" }
$mstscPid = [uint32]$proc.Id
Write-Output "mstsc pid=$mstscPid"

$h = [WinInput]::FindWindowTitle("security warning", $mstscPid)
if ($h -eq [IntPtr]::Zero) { $h = [WinInput]::FindWindowTitle("Caution", $mstscPid) }
if ($h -eq [IntPtr]::Zero) { $h = [WinInput]::FindWindowTitle("Unknown remote", $mstscPid) }
if ($h -eq [IntPtr]::Zero) { $h = [WinInput]::FindWindowTitle("Remote Desktop Connection", $mstscPid) }
if ($h -eq [IntPtr]::Zero) { $h = $proc.MainWindowHandle }

[void][WinInput]::ShowWindow($h, 9)
[void][WinInput]::SetForegroundWindow($h)
Start-Sleep -Milliseconds 400

$r = New-Object "WinInput+RECT"
[void][WinInput]::GetWindowRect($h, [ref]$r)
$w = $r.Right - $r.Left
$ht = $r.Bottom - $r.Top
Write-Output ("dialog L={0} T={1} W={2} H={3}" -f $r.Left, $r.Top, $w, $ht)
[WinInput]::Shot((Join-Path $ShotDir "01-before.png"))

if (-not $NoClipboard) {
  $clipX = [int]($r.Left + $w * 0.18)
  $clipY = [int]($r.Top + $ht * 0.58)
  Write-Output "click Clipboard $clipX,$clipY"
  [WinInput]::Click($clipX, $clipY)
  Start-Sleep -Milliseconds 300
}

# Connect left of Cancel — never Learn more (upper body)
$connX = [int]($r.Left + $w * 0.72)
$connY = [int]($r.Top + $ht * 0.93)
Write-Output "click Connect $connX,$connY"
[WinInput]::Click($connX, $connY)
Start-Sleep -Seconds 2
[WinInput]::Shot((Join-Path $ShotDir "02-after-connect.png"))

$still = [WinInput]::FindWindowTitle("security warning", $mstscPid)
if ($still -ne [IntPtr]::Zero) {
  Write-Output "dialog still open: Shift+Tab Enter"
  [void][WinInput]::SetForegroundWindow($still)
  [System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
  Start-Sleep -Milliseconds 250
  [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
  Start-Sleep -Seconds 2
}

Start-Sleep -Seconds 5
[WinInput]::Shot((Join-Path $ShotDir "03-session.png"))
Start-Sleep -Seconds 3
[WinInput]::Shot((Join-Path $ShotDir "04-final.png"))

Get-Process mstsc -ErrorAction SilentlyContinue | Format-Table Id, MainWindowTitle
Write-Output "Shots: $ShotDir"
Write-Output "DONE"

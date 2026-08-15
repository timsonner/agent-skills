# Install workstation-drive skill family into common agent skill directories.
# Run on Windows from agent-skills root or pass -SourceRoot.

[CmdletBinding()]
param(
  [string]$SourceRoot = "",
  [ValidateSet("grok", "claude", "cursor", "all")]
  [string]$Harness = "all"
)

$ErrorActionPreference = "Stop"
if (-not $SourceRoot) {
  $SourceRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
  if (-not (Test-Path (Join-Path $SourceRoot "agent-workstation-drive\SKILL.md"))) {
    $SourceRoot = Join-Path $env:USERPROFILE "agent-skills"
  }
}

$skills = @(
  "agent-workstation-drive",
  "gnome-wayland-rdp",
  "kde-wayland-rdp",
  "windows-ui-inject",
  "browser-read-bypass",
  "wsl-containers"
)

function Install-Into([string]$DestRoot) {
  if (-not $DestRoot) { return }
  New-Item -ItemType Directory -Force -Path $DestRoot | Out-Null
  foreach ($s in $skills) {
    $src = Join-Path $SourceRoot $s
    $dst = Join-Path $DestRoot $s
    if (-not (Test-Path $src)) {
      Write-Warning "Missing source $src"
      continue
    }
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
    Write-Output "Installed $s -> $dst"
  }
}

$targets = @()
switch ($Harness) {
  "grok" { $targets = @((Join-Path $env:USERPROFILE ".grok\skills")) }
  "claude" { $targets = @((Join-Path $env:USERPROFILE ".claude\skills")) }
  "cursor" { $targets = @((Join-Path $env:USERPROFILE ".cursor\skills")) }
  "all" {
    $targets = @(
      (Join-Path $env:USERPROFILE ".grok\skills"),
      (Join-Path $env:USERPROFILE ".claude\skills"),
      (Join-Path $env:USERPROFILE ".cursor\skills")
    )
  }
}

Write-Output "SourceRoot=$SourceRoot"
foreach ($t in $targets) {
  Write-Output "--- $t ---"
  Install-Into $t
}
Write-Output "DONE. New sessions should load agent-workstation-drive."

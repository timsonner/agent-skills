# Offload one bounded job to agy, opencode, copilot, or codex.
# Prints a single JSON object: worker, session_id, exit_code, stdout, dir, allow_tools, stderr.
# Flag tables live in the matching *-harness skills — do not fork them here.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("agy", "opencode", "copilot", "codex")]
  [string]$Worker,

  [Parameter(Mandatory = $true)]
  [string]$Prompt,

  [string]$Dir = "",

  [switch]$AllowTools,

  [string]$Session = "",

  [string]$Model = ""
)

$ErrorActionPreference = "Stop"

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

if (-not $Dir) { $Dir = (Get-Location).Path }
$Dir = [System.IO.Path]::GetFullPath($Dir)
if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
  throw "Dir is not a directory: $Dir"
}

function Resolve-WorkerExe([string]$name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  if ($name -eq "codex") {
    $official = Join-Path $env:LOCALAPPDATA "Programs\OpenAI\Codex\bin\codex.exe"
    if (Test-Path -LiteralPath $official) { return $official }
  }
  throw "Worker '$name' not on PATH. Refresh Machine+User Path or see the matching *-harness skill."
}

$exe = Resolve-WorkerExe $Worker

$guard = "Do not invoke or spawn the agy, opencode, copilot, or codex CLIs. Complete this task yourself and stop."
$fullPrompt = if ($Prompt.Contains("Do not invoke or spawn the agy")) { $Prompt } else { "$Prompt`n`n$guard" }

function Get-JsonObjects([string]$text) {
  $objs = @()
  $trim = $text.Trim()
  if (-not $trim) { return $objs }
  try {
    $one = $trim | ConvertFrom-Json
    if ($one) { return @($one) }
  } catch { }
  foreach ($line in ($text -split "`r?`n")) {
    $line = $line.Trim()
    if (-not $line) { continue }
    try { $objs += ($line | ConvertFrom-Json) } catch { }
  }
  return $objs
}

function Get-AgyResult([string]$text) {
  $o = $null
  try { $o = $text.Trim() | ConvertFrom-Json } catch { }
  if (-not $o) {
    return @{ session_id = $null; stdout = $text.Trim() }
  }
  $resp = [string]$o.response
  return @{
    session_id = $(if ($o.conversation_id) { [string]$o.conversation_id } else { $null })
    stdout     = $resp.Trim()
  }
}

function Get-OpencodeResult([object[]]$objs) {
  $sid = $null
  $chunks = New-Object System.Collections.Generic.List[string]
  foreach ($o in $objs) {
    if ($o.sessionID -and -not $sid) { $sid = [string]$o.sessionID }
    if ($o.type -eq "text" -and $o.part -and $o.part.text) {
      $chunks.Add([string]$o.part.text)
    }
  }
  return @{ session_id = $sid; stdout = ($chunks -join "") }
}

function Get-CopilotResult([object[]]$objs) {
  $sid = $null
  $text = ""
  foreach ($o in $objs) {
    if ($o.type -eq "result" -and $o.sessionId) { $sid = [string]$o.sessionId }
    if ($o.type -eq "assistant.message" -and $o.data -and $o.data.content) {
      $text = [string]$o.data.content
    }
  }
  return @{ session_id = $sid; stdout = $text.Trim() }
}

function Get-CodexResult([object[]]$objs) {
  $sid = $null
  $text = ""
  foreach ($o in $objs) {
    if ($o.type -eq "thread.started" -and $o.thread_id) { $sid = [string]$o.thread_id }
    if ($o.type -eq "item.completed" -and $o.item -and $o.item.type -eq "agent_message" -and $o.item.text) {
      $text = [string]$o.item.text
    }
  }
  return @{ session_id = $sid; stdout = $text.Trim() }
}

$argList = New-Object System.Collections.Generic.List[string]

switch ($Worker) {
  "agy" {
    # Flags must come before --print (agy-harness).
    $argList.Add("--output-format"); $argList.Add("json")
    if ($Model) { $argList.Add("--model"); $argList.Add($Model) }
    if ($AllowTools) { $argList.Add("--dangerously-skip-permissions") }
    if ($Session) { $argList.Add("--conversation"); $argList.Add($Session) }
    $argList.Add("--print"); $argList.Add($fullPrompt)
  }
  "opencode" {
    $argList.Add("run")
    $argList.Add("--format"); $argList.Add("json")
    $argList.Add("--dir"); $argList.Add($Dir)
    if ($Model) { $argList.Add("--model"); $argList.Add($Model) }
    if ($AllowTools) { $argList.Add("--auto") }
    if ($Session) { $argList.Add("--session"); $argList.Add($Session) }
    $argList.Add($fullPrompt)
  }
  "copilot" {
    $argList.Add("--output-format"); $argList.Add("json")
    $argList.Add("-C"); $argList.Add($Dir)
    $argList.Add("--no-ask-user")
    $argList.Add("--disable-builtin-mcps")
    if ($Model) { $argList.Add("--model"); $argList.Add($Model) }
    if ($AllowTools) { $argList.Add("--allow-all-tools") }
    if ($Session) { $argList.Add("--resume=$Session") }
    $argList.Add("-p"); $argList.Add($fullPrompt)
  }
  "codex" {
    $argList.Add("exec")
    if ($Session) { $argList.Add("resume") }
    $argList.Add("--json")
    $argList.Add("--skip-git-repo-check")
    # -C is exec-only; resume is already bound to the thread's cwd.
    if (-not $Session) { $argList.Add("-C"); $argList.Add($Dir) }
    if ($Model) { $argList.Add("--model"); $argList.Add($Model) }
    if ($AllowTools) {
      $argList.Add("--sandbox"); $argList.Add("danger-full-access")
    }
    if ($Session) { $argList.Add($Session) }
    $argList.Add($fullPrompt)
  }
}

$stderrFile = [System.IO.Path]::GetTempFileName()
Push-Location -LiteralPath $Dir
try {
  $raw = & $exe @argList 2>$stderrFile
  $exit = $LASTEXITCODE
} finally {
  Pop-Location
}
if ($null -eq $exit) { $exit = 0 }
$rawText = if ($null -eq $raw) { "" } else { ($raw | Out-String) }
$errText = ""
if (Test-Path -LiteralPath $stderrFile) {
  $errText = ((Get-Content -LiteralPath $stderrFile -Raw -ErrorAction SilentlyContinue) + "").Trim()
  Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
}

switch ($Worker) {
  "agy" { $parsed = Get-AgyResult $rawText }
  "opencode" { $parsed = Get-OpencodeResult (Get-JsonObjects $rawText) }
  "copilot" { $parsed = Get-CopilotResult (Get-JsonObjects $rawText) }
  "codex" { $parsed = Get-CodexResult (Get-JsonObjects $rawText) }
}

$result = [ordered]@{
  worker      = $Worker
  session_id  = $parsed.session_id
  exit_code   = [int]$exit
  stdout      = $parsed.stdout
  dir         = $Dir
  allow_tools = [bool]$AllowTools
  stderr      = $errText
}

$result | ConvertTo-Json -Compress
if ($exit -ne 0) { exit $exit }

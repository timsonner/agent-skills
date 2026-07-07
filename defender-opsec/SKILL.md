---
name: defender-opsec
description: "Harden Windows Defender privacy settings for authorized pentest engagements. Disables telemetry uploads, sample submission, and cloud reporting to prevent leaking target info, credentials, and tooling to Microsoft. Includes exclusion management and post-engagement re-enablement."
author: Tim Sonner
license: MIT
version: "1.0.0"
platforms: [windows]
---

# Defender OPSEC for Pentest Engagements

Use this skill at the **start** of any authorized penetration test to prevent Windows Defender from uploading engagement artifacts (target IPs, exploit code, credentials, tooling) to Microsoft cloud services.

## Why this matters

Defender's cloud features upload data to Microsoft:

| Feature | What it sends |
|---------|--------------|
| **Cloud-delivered protection** (MAPS) | File hashes, file paths, partial file contents, process behavior, URLs, network connection metadata |
| **Automatic sample submission** | Entire suspicious files — scripts, exploits, payloads, wordlists |
| **Diagnostic data** | Telemetry on detection events, including target IPs and hostnames |

During a pentest this can leak:
- Target IPs, hostnames, and network topology
- Exploit code and payloads
- Harvested credentials and hashes
- Your tooling, methodology, and TTPs
- Client-sensitive data

## Pre-engagement lockdown

Run these PowerShell commands **as Administrator** before starting:

```powershell
# Disable cloud upload (MAPS reporting)
Set-MpPreference -MAPSReporting Disabled

# Disable automatic sample submission
Set-MpPreference -SubmitSamplesConsent NeverSend

# Disable behavior monitoring telemetry (optional, more aggressive)
Set-MpPreference -DisableBehaviorMonitoring $true

# Disable block-at-first-sight (requires cloud, sends data)
Set-MpPreference -DisableBlockAtFirstSeen $true
```

### Add engagement path exclusions

Prevent Defender from scanning/quarantining pentest tools and artifacts.
All paths use `$HOME` to stay username-agnostic:

```powershell
# Pentest workspace
Add-MpPreference -ExclusionPath "$HOME\pentest-workspace"

# Shared agent skills (contains exploit patterns, tool references)
Add-MpPreference -ExclusionPath "$HOME\.agents"

# Antigravity / Gemini (AGY CLI + IDE)
Add-MpPreference -ExclusionPath "$HOME\.gemini"

# Hermes (Claude Code)
Add-MpPreference -ExclusionPath "$HOME\.hermes"

# Claude Desktop / Claude CLI
Add-MpPreference -ExclusionPath "$HOME\.claude"

# OpenAI Codex CLI
Add-MpPreference -ExclusionPath "$HOME\.codex"

# GitHub Copilot CLI
Add-MpPreference -ExclusionPath "$HOME\.copilot"
Add-MpPreference -ExclusionPath "$HOME\.github-copilot-cli"

# WSL container storage (if using wslc)
Add-MpPreference -ExclusionPath "C:\ProgramData\Microsoft\WSL"

# Add specific tool directories as needed
# Add-MpPreference -ExclusionPath "$HOME\path\to\tools"
```

### Exclude pentest processes (optional)

```powershell
# Prevent Defender from inspecting wslc container activity
Add-MpPreference -ExclusionProcess "wslc.exe"
Add-MpPreference -ExclusionProcess "wsl.exe"
```

## Verify settings

```powershell
# Check all relevant settings at once
Get-MpPreference | Select-Object `
    MAPSReporting, `
    SubmitSamplesConsent, `
    DisableBehaviorMonitoring, `
    DisableBlockAtFirstSeen, `
    ExclusionPath, `
    ExclusionProcess
```

Expected output for locked-down state:

| Setting | Value |
|---------|-------|
| MAPSReporting | 0 (Disabled) |
| SubmitSamplesConsent | 2 (NeverSend) |
| DisableBehaviorMonitoring | True |
| DisableBlockAtFirstSeen | True |

## Post-engagement re-enablement

**Always restore defaults** after the engagement ends:

```powershell
# Re-enable cloud protection
Set-MpPreference -MAPSReporting Advanced

# Re-enable sample submission (SendSafeSamples is default)
Set-MpPreference -SubmitSamplesConsent SendSafeSamples

# Re-enable behavior monitoring
Set-MpPreference -DisableBehaviorMonitoring $false

# Re-enable block-at-first-sight
Set-MpPreference -DisableBlockAtFirstSeen $false

# Remove engagement-specific exclusions
$agentPaths = @(
    "$HOME\pentest-workspace",
    "$HOME\.agents",
    "$HOME\.gemini",
    "$HOME\.hermes",
    "$HOME\.claude",
    "$HOME\.codex",
    "$HOME\.copilot",
    "$HOME\.github-copilot-cli"
)
$agentPaths | ForEach-Object {
    Remove-MpPreference -ExclusionPath $_ -ErrorAction SilentlyContinue
}
Remove-MpPreference -ExclusionPath "C:\ProgramData\Microsoft\WSL" -ErrorAction SilentlyContinue
# Remove-MpPreference -ExclusionProcess "wslc.exe"
```

## Quick reference — one-liner lockdown / restore

```powershell
# LOCKDOWN (copy-paste one block)
Set-MpPreference -MAPSReporting Disabled -SubmitSamplesConsent NeverSend -DisableBlockAtFirstSeen $true; @("$HOME\pentest-workspace","$HOME\.agents","$HOME\.gemini","$HOME\.hermes","$HOME\.claude","$HOME\.codex","$HOME\.copilot","$HOME\.github-copilot-cli","C:\ProgramData\Microsoft\WSL") | ForEach-Object { Add-MpPreference -ExclusionPath $_ }

# RESTORE (copy-paste one block)
Set-MpPreference -MAPSReporting Advanced -SubmitSamplesConsent SendSafeSamples -DisableBlockAtFirstSeen $false; @("$HOME\pentest-workspace","$HOME\.agents","$HOME\.gemini","$HOME\.hermes","$HOME\.claude","$HOME\.codex","$HOME\.copilot","$HOME\.github-copilot-cli","C:\ProgramData\Microsoft\WSL") | ForEach-Object { Remove-MpPreference -ExclusionPath $_ -ErrorAction SilentlyContinue }
```

## Group Policy alternative

If `Set-MpPreference` is overridden by Group Policy, configure via registry:

```powershell
# Disable MAPS
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Value 2 -Type DWord -Force
```

## Pitfalls

1. **Domain-joined machines**: Group Policy may re-enable cloud settings on next gpupdate. Check with `gpresult /r`.
2. **Tamper Protection**: If enabled, you cannot change Defender settings via PowerShell/registry. Disable it first in the Windows Security GUI: Virus & Threat Protection → Manage settings → Tamper Protection → Off.
3. **Microsoft Defender for Endpoint (MDE)**: Enterprise EDR product — separate from Defender AV. If MDE is installed, it has its own telemetry pipeline that these settings do not control.
4. **Don't forget to restore**: Leaving Defender crippled after an engagement is a security risk. Always run the restore commands.
5. **Exclusions are broad**: Only exclude paths actively used for the engagement. Remove them after.

## When to use this skill

- Before any authorized penetration test from a Windows host
- When setting up a pentest VM/workstation
- When Defender is quarantining pentest tools or uploading engagement artifacts
- Paired with `wslc-pentest-workflow` for container-based engagements

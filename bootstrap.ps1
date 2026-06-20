# bootstrap.ps1 — one-shot setup for Windows (PowerShell).
#
# Run from a fresh clone of this repo:
#     git clone https://github.com/sanjaesuresh/claude-code-toolkit.git
#     cd claude-code-toolkit
#     powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
#
# Windows uses COPY MODE only. Symlinks on Windows require admin or Developer
# Mode and are blocked in many corporate environments, so we do not use them.
# The .sh hook scripts run under Git Bash / WSL; native cmd.exe will not run
# them, so install Git for Windows (which Claude Code already expects).

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src     = Join-Path $RepoDir "global"
$Dest    = Join-Path $env:USERPROFILE ".claude"
$Stamp   = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "[bootstrap] toolkit at: $RepoDir"
Write-Host "[bootstrap] dest: $Dest (copy mode)"

if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest | Out-Null }

function Backup-IfExists($target) {
  if (Test-Path $target) {
    $bdir = Join-Path $Dest ".toolkit-backups\$Stamp"
    if (-not (Test-Path $bdir)) { New-Item -ItemType Directory -Path $bdir -Force | Out-Null }
    Copy-Item $target -Destination $bdir -Recurse -Force
    Write-Host "[bootstrap] backed up $(Split-Path $target -Leaf)"
  }
}

# Files
foreach ($f in @("CLAUDE.md","settings.json")) {
  $s = Join-Path $Src $f
  if (Test-Path $s) {
    Backup-IfExists (Join-Path $Dest $f)
    Copy-Item $s -Destination (Join-Path $Dest $f) -Force
    Write-Host "[bootstrap] installed $f"
  }
}

# Directories: skills, agents (from global/), scripts (from repo root)
$dirMap = @{
  "skills"  = (Join-Path $Src "skills")
  "agents"  = (Join-Path $Src "agents")
  "scripts" = (Join-Path $RepoDir "scripts")
}
foreach ($name in $dirMap.Keys) {
  $s = $dirMap[$name]
  if (Test-Path $s) {
    $d = Join-Path $Dest $name
    Backup-IfExists $d
    if (Test-Path $d) { Remove-Item $d -Recurse -Force }
    Copy-Item $s -Destination $d -Recurse -Force
    Write-Host "[bootstrap] installed $name"
  }
}

Write-Host ""
Write-Host "[bootstrap] Done. settings.local.json and credentials were left untouched."
Write-Host "[bootstrap] Note: .sh hooks require Git Bash or WSL on Windows."
Write-Host "[bootstrap] Open Claude Code and try:  /office-hours   or   /careful"

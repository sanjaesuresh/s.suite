# bootstrap.ps1 — one-shot setup for Windows (PowerShell).
#
# Run from a fresh clone of this repo:
#     git clone https://github.com/sanjaesuresh/s.suite.git
#     cd s.suite
#     powershell -ExecutionPolicy Bypass -File .\bootstrap.ps1
#
# Windows uses COPY MODE only by default. Symlinks on Windows require admin or
# Developer Mode and are blocked in many corporate environments.
# The .sh hook scripts run under Git Bash / WSL; native cmd.exe will not run
# them, so install Git for Windows (which Claude Code already expects).
#
# Flags are passed through to scripts\install.ps1:
#   -DryRun   Show what would happen without making changes.
#   -Symlink  Attempt symlink mode (requires admin or Developer Mode).

[CmdletBinding()]
param(
    [switch]$Symlink,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallPs1 = Join-Path $RepoDir "scripts\install.ps1"

Write-Host "[bootstrap] toolkit at: $RepoDir"
Write-Host "[bootstrap] installing global config into $env:USERPROFILE\.claude ..."

& $InstallPs1 -Symlink:$Symlink -DryRun:$DryRun

Write-Host ""
Write-Host "[bootstrap] Done. Open Claude Code and try:  /office-hours   or   /careful"

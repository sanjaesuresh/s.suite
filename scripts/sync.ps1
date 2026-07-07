# sync.ps1
#
# Pull the latest toolkit and re-install into $env:USERPROFILE\.claude.
# Windows analog of scripts/sync.sh.
#
#   powershell -File scripts\sync.ps1             # git pull + copy install
#   powershell -File scripts\sync.ps1 -Symlink    # git pull + symlink install
#   powershell -File scripts\sync.ps1 -NoPull     # re-install without pulling
#
# On pull failure, warns and continues with the local copy (non-fatal),
# matching sync.sh behavior.

[CmdletBinding()]
param(
    [switch]$NoPull,
    [switch]$Symlink,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$Repo       = Split-Path -Parent $ScriptDir
$InstallPs1 = Join-Path $ScriptDir "install.ps1"

Set-Location $Repo

if (-not $NoPull) {
    # Check we are inside a git work tree before attempting pull.
    # Both git calls are wrapped in try/catch so that on PS 7.4+, where
    # $PSNativeCommandUseErrorActionPreference defaults to $true, a non-zero
    # exit code throws NativeCommandExitException before $LASTEXITCODE is
    # checked.  Catching guarantees non-fatal behavior on PS 5.1 AND 7.4+,
    # matching sync.sh: `git pull --ff-only || { warn; }`.
    try {
        $isGit = & git rev-parse --is-inside-work-tree 2>$null
    } catch {
        $isGit = $null
    }
    if ($isGit -eq "true") {
        Write-Host "[sync] pulling latest..."
        try {
            & git pull --ff-only
            if ($LASTEXITCODE -ne 0) {
                # non-fatal: warn and continue with local copy, matching sync.sh
                Write-Host "[sync] pull failed (resolve manually), continuing with local copy."
            }
        } catch {
            # PS 7.4+: NativeCommandExitException on non-zero git exit — non-fatal
            Write-Host "[sync] pull failed (resolve manually), continuing with local copy."
        }
    }
}

Write-Host "[sync] installing..."
& $InstallPs1 -Symlink:$Symlink -DryRun:$DryRun
Write-Host "[sync] done."

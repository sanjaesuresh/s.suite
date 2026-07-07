# install.ps1
#
# Installs the global toolkit (CLAUDE.md, settings.json, skills, agents,
# scripts, LESSONS.md) from this repo into $env:USERPROFILE\.claude.
# Windows analog of scripts/install.sh.
#
# Defaults to COPY mode. Pass -Symlink to attempt symlinks (requires
# admin or Developer Mode on Windows; falls back to copy on failure).
#
#   powershell -File scripts\install.ps1           # copy mode (default)
#   powershell -File scripts\install.ps1 -Symlink  # symlink mode
#   powershell -File scripts\install.ps1 -DryRun   # show what would happen
#
# Behavior:
#   - Never deletes files it did not create.
#   - Backs up any existing target before overwriting (timestamped).
#   - Does NOT touch settings.local.json or any credentials.
#   - Deep-merges settings.json: toolkit keys overlay, user-only keys preserved.

[CmdletBinding()]
param(
    [switch]$Symlink,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$Mode = if ($Symlink) { "symlink" } else { "copy" }
$Dry  = $DryRun.IsPresent

# locate repo root (one level up from this script's directory)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Repo      = Split-Path -Parent $ScriptDir
$Src       = Join-Path $Repo "global"
$Dest      = Join-Path $env:USERPROFILE ".claude"
$Stamp     = Get-Date -Format "yyyyMMdd-HHmmss"

function Say($msg) { Write-Host "[install] $msg" }

if (-not (Test-Path $Src)) {
    Write-Error "Missing $Src — run from the repo root."
    exit 1
}

Say "mode=$Mode  source=$Src  dest=$Dest"
if (-not $Dry) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }

function Backup-IfExists($target) {
    if (-not (Test-Path $target -PathType Any)) { return }
    $bdir = Join-Path $Dest ".toolkit-backups\$Stamp"
    if ($Dry) {
        Write-Host "  DRY: Copy '$target' -> '$bdir\'"
    } else {
        New-Item -ItemType Directory -Path $bdir -Force | Out-Null
        # a failed backup must abort before we delete/overwrite the target
        Copy-Item $target -Destination $bdir -Recurse -Force -ErrorAction Stop
        Say "backed up $(Split-Path $target -Leaf) -> $bdir\"
    }
}

function Place-File($relSrc, $relDest) {
    $s = Join-Path $Src $relSrc
    $d = Join-Path $Dest $relDest
    if (-not (Test-Path $s)) { Say "skip $relDest (no source)"; return }
    Backup-IfExists $d
    if ($Dry) {
        Write-Host "  DRY: $Mode '$s' -> '$d'"
        return
    }
    if ($Mode -eq "symlink") {
        try {
            if (Test-Path $d) { Remove-Item $d -Force }
            New-Item -ItemType SymbolicLink -Path $d -Target $s | Out-Null
        } catch {
            # symlinks require admin or Developer Mode; fall back silently
            Say "WARNING: symlink failed for $relDest — falling back to copy"
            Copy-Item $s -Destination $d -Force
        }
    } else {
        Copy-Item $s -Destination $d -Force
    }
    Say "installed $relDest"
}

function Place-Dir($name, $srcPath = $null) {
    $s = if ($srcPath) { $srcPath } else { Join-Path $Src $name }
    $d = Join-Path $Dest $name
    if (-not (Test-Path $s)) { Say "skip $name (no source)"; return }
    Backup-IfExists $d
    if ($Dry) {
        Write-Host "  DRY: $Mode dir '$s' -> '$d'"
        return
    }
    if (Test-Path $d) { Remove-Item $d -Recurse -Force }
    if ($Mode -eq "symlink") {
        try {
            New-Item -ItemType SymbolicLink -Path $d -Target $s | Out-Null
        } catch {
            Say "WARNING: symlink failed for $name — falling back to copy"
            Copy-Item $s -Destination $d -Recurse -Force
        }
    } else {
        Copy-Item $s -Destination $d -Recurse -Force
    }
    Say "installed $name"
}

# Recursive JSON deep-merge: $base is user (preserved), $overlay is toolkit (wins on conflicts).
# Mirrors jq -s '.[0] * .[1]' from install.sh: recurses into nested objects, arrays replaced by
# overlay value (not concatenated). User-only keys (plugins, theme, env, ...) are absent from
# the toolkit overlay so they survive in $result untouched.
function Merge-Json($base, $overlay) {
    if ($null -eq $overlay) { return $base }
    if ($base -isnot [PSCustomObject]) { return $overlay }

    # seed result with all user keys
    $result = [ordered]@{}
    $base.PSObject.Properties | ForEach-Object { $result[$_.Name] = $_.Value }

    # overlay each toolkit key; recurse only when both sides are objects
    $overlay.PSObject.Properties | ForEach-Object {
        $key = $_.Name
        $val = $_.Value
        if ($result.ContainsKey($key) -and
            $result[$key] -is [PSCustomObject] -and
            $val -is [PSCustomObject]) {
            $result[$key] = Merge-Json $result[$key] $val
        } else {
            # toolkit wins for scalars and arrays (same as jq * behavior)
            $result[$key] = $val
        }
    }

    return [PSCustomObject]$result
}

function Merge-Settings {
    $s = Join-Path $Src "settings.json"
    $d = Join-Path $Dest "settings.json"
    if (-not (Test-Path $s)) { Say "skip settings.json (no source)"; return }

    # fresh machine: nothing to preserve, just copy
    if (-not (Test-Path $d)) {
        if (-not $Dry) { Copy-Item $s -Destination $d -Force }
        else { Write-Host "  DRY: Copy '$s' -> '$d' (new)" }
        Say "installed settings.json (new)"
        return
    }

    Backup-IfExists $d

    if ($Dry) {
        Write-Host "  DRY: deep-merge settings.json (preserve user plugins/theme/env)"
        return
    }

    $tmp = "$d.tmp"
    try {
        # Strip a leading BOM (U+FEFF) before parsing — PS 5.1 Set-Content
        # -Encoding UTF8 emits a BOM, which ConvertFrom-Json rejects on 5.1.
        $rawUser     = Get-Content $d -Raw -Encoding UTF8
        $rawUser     = $rawUser.TrimStart([char]0xFEFF)
        $userJson    = $rawUser | ConvertFrom-Json
        $toolkitJson = Get-Content $s -Raw -Encoding UTF8 | ConvertFrom-Json
        $merged      = Merge-Json $userJson $toolkitJson
        # Depth 64: real settings are ~6 deep; 64 is clearly safe insurance.
        # ConvertTo-Json silently truncates anything beyond -Depth — higher is safer.
        $jsonText    = $merged | ConvertTo-Json -Depth 64
        # BOM-free UTF-8 write: PS 5.1 Set-Content -Encoding UTF8 writes a BOM,
        # which breaks ConvertFrom-Json on the next run.  WriteAllText with
        # UTF8Encoding($false) is BOM-free on both PS 5.1 and 7.4+.
        [System.IO.File]::WriteAllText($tmp, $jsonText, (New-Object System.Text.UTF8Encoding($false)))
        Move-Item $tmp $d -Force
        Say "merged settings.json (your plugins/theme/env preserved)"
    } catch {
        # on any failure, leave existing untouched and clean up tmp
        if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
        Say "WARNING: settings.json merge failed — left existing file untouched."
        Say "  Manually merge keys from: $s"
    }
}

function Install-GlobalGitignore {
    $s = Join-Path $Src "gitignore_global"
    if (-not (Test-Path $s)) { Say "skip gitignore_global (no source)"; return }

    # exact same marker strings as install.sh — must stay in sync across platforms
    $marker  = "# >>> claude-code-toolkit global excludes >>>"
    $endmark = "# <<< claude-code-toolkit global excludes <<<"

    # respect an existing excludesfile; otherwise default to ~/.gitignore_global
    # Wrapped in try/catch: on PS 7.4+ $PSNativeCommandUseErrorActionPreference
    # defaults to $true, so a non-zero git exit (key absent) throws before
    # $LASTEXITCODE is checked.  Catch treats "key not set" as $null — non-fatal.
    try {
        $current = & git config --global core.excludesfile 2>$null
        if ($LASTEXITCODE -ne 0) { $current = $null }
    } catch {
        $current = $null
    }
    if ($current) {
        # git on Windows may store POSIX-style ~ paths; expand to full path
        $target = $current -replace '^~', $env:USERPROFILE
    } else {
        $target = Join-Path $env:USERPROFILE ".gitignore_global"
    }

    if ($Dry) {
        Write-Host "  DRY: ensure toolkit excludes block in '$target' and set core.excludesfile"
        return
    }

    $targetDir = Split-Path $target -Parent
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
    if (-not (Test-Path $target))    { New-Item -ItemType File -Path $target -Force | Out-Null }

    # strip any existing managed block (idempotent update — replace block on re-run)
    $existing = Get-Content $target -ErrorAction SilentlyContinue
    if ($null -eq $existing) { $existing = @() }
    $filtered = [System.Collections.ArrayList]@()
    $skip = $false
    foreach ($line in $existing) {
        if ($line -eq $marker)  { $skip = $true;  continue }
        if ($line -eq $endmark) { $skip = $false; continue }
        if (-not $skip) { [void]$filtered.Add($line) }
    }

    # append fresh managed block
    $gitignoreLines = Get-Content $s -ErrorAction SilentlyContinue
    if ($null -eq $gitignoreLines) { $gitignoreLines = @() }
    $block      = @($marker) + @($gitignoreLines) + @($endmark)
    $newContent = @($filtered) + $block
    # BOM-free UTF-8 write (PS 5.1 Set-Content -Encoding UTF8 emits a BOM).
    # WriteAllLines writes each array element as a line with platform newlines.
    [System.IO.File]::WriteAllLines($target, [string[]]$newContent, (New-Object System.Text.UTF8Encoding($false)))

    # set core.excludesfile if not already configured
    if (-not $current) {
        try {
            & git config --global core.excludesfile $target
        } catch {
            Say "WARNING: could not set core.excludesfile — set manually: git config --global core.excludesfile '$target'"
        }
    }

    Say "global gitignore: managed block written to $target"
}

# ---- main install sequence (mirrors install.sh order) ----

Place-File "CLAUDE.md"  "CLAUDE.md"
Place-File "LESSONS.md" "LESSONS.md"
Merge-Settings
Install-GlobalGitignore
Place-Dir "skills"
Place-Dir "agents"

# scripts live at repo root (same source as install.sh's special-case for scripts/)
Place-Dir "scripts" (Join-Path $Repo "scripts")

Write-Host ""
Say "Done. settings.local.json and credentials were left untouched."
Say "Verify with: bash '$Repo\scripts\validate-claude-config.sh'"

# run validator if bash is available (Git for Windows / WSL); otherwise print a note
$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if ($bashCmd) {
    & bash "$Repo/scripts/validate-claude-config.sh"
} else {
    Write-Host ""
    Say "NOTE: bash not found — install Git for Windows (includes Git Bash) or WSL to validate."
    Say "  Then run: bash '$Repo\scripts\validate-claude-config.sh'"
}

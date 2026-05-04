# Copy tracked Claude Code config from this repo into $env:CLAUDE_CONFIG_DIR
# (default $env:USERPROFILE\.claude\), install enabled plugins, and wire up a
# pre-commit hook that syncs edits back. Idempotent — safe to re-run.
#
# Run from PowerShell 5.1+.

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) {
    $env:CLAUDE_CONFIG_DIR
} else {
    Join-Path $env:USERPROFILE '.claude'
}
$Stamp     = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir = Join-Path $ClaudeDir "backups\dotfiles-$Stamp"

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'commands') | Out-Null

function Copy-Tracked {
    param([string]$Src, [string]$Dest)

    if (Test-Path $Dest) {
        $item = Get-Item $Dest -Force
        $isSymlink = $item.LinkType -eq 'SymbolicLink'
        if (-not $isSymlink -and (Get-FileHash $Src).Hash -eq (Get-FileHash $Dest).Hash) {
            Write-Host "  ok   $Dest"
            return
        }
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        Move-Item -Force -Path $Dest -Destination $BackupDir
        Write-Host "  back $Dest -> $BackupDir"
    }

    Copy-Item -Force -Path $Src -Destination $Dest
    Write-Host "  copy $Dest"
}

Write-Host "Copying config into $ClaudeDir ..."
Copy-Tracked (Join-Path $RepoDir 'claude\CLAUDE.md')                (Join-Path $ClaudeDir 'CLAUDE.md')
Copy-Tracked (Join-Path $RepoDir 'claude\settings.json')            (Join-Path $ClaudeDir 'settings.json')
Copy-Tracked (Join-Path $RepoDir 'claude\statusline-command.sh')    (Join-Path $ClaudeDir 'statusline-command.sh')
Copy-Tracked (Join-Path $RepoDir 'claude\commands\init-project.md') (Join-Path $ClaudeDir 'commands\init-project.md')

Write-Host ""
Write-Host "Registering marketplace ..."
& claude plugin marketplace add anthropics/claude-plugins-official 2>$null

Write-Host ""
Write-Host "Installing plugins from claude\settings.json -> enabledPlugins ..."
$installedJson = & claude plugins list --json 2>$null
$installedIds = @()
if ($installedJson) {
    try {
        $installedIds = ($installedJson | ConvertFrom-Json) | ForEach-Object { $_.id }
    } catch {}
}

$settings = Get-Content (Join-Path $RepoDir 'claude\settings.json') -Raw | ConvertFrom-Json
foreach ($plugin in $settings.enabledPlugins.PSObject.Properties.Name) {
    if ($installedIds -contains $plugin) {
        Write-Host "  reinstall $plugin"
        & claude plugins uninstall $plugin | Out-Null
    } else {
        Write-Host "  install   $plugin"
    }
    & claude plugins install $plugin | Out-Null
}

Write-Host ""
Write-Host "Installing pre-commit hook ..."
$Hook = Join-Path $RepoDir '.git\hooks\pre-commit'
$HookBody = @"
#!/usr/bin/env bash
set -e
"`$(git rev-parse --show-toplevel)/sync-from-home.sh" --quiet
git add claude/
"@
if (-not (Test-Path $Hook) -or -not ((Get-Content $Hook -Raw) -match 'sync-from-home')) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Hook) | Out-Null
    Set-Content -Path $Hook -Value $HookBody -Encoding ASCII -NoNewline
    Write-Host "  hook pre-commit installed"
} else {
    Write-Host "  hook pre-commit ok"
}

Write-Host ""
Write-Host "Done. Edits in $ClaudeDir will be synced back to the repo on git commit"
Write-Host "(via .git/hooks/pre-commit -> sync-from-home.sh; needs Git Bash or WSL)."
Write-Host ""
Write-Host "Note: statusline-command.sh is a bash script. On native Windows the"
Write-Host "status line will only render if Claude Code can invoke bash"
Write-Host "(Git Bash or WSL on PATH). Otherwise it silently no-ops."

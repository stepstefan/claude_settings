# Copy tracked Claude Code config from $env:CLAUDE_CONFIG_DIR
# (default $env:USERPROFILE\.claude\) back into this repo, so edits made by
# Claude Code (or by you) show up as `git status` changes.
#
# Pass -Quiet to suppress per-file output (used by the pre-commit hook).

[CmdletBinding()]
param([switch]$Quiet)

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) {
    $env:CLAUDE_CONFIG_DIR
} else {
    Join-Path $env:USERPROFILE '.claude'
}

function Sync-File {
    param([string]$Src, [string]$Dest)
    if (-not (Test-Path $Src)) { return }
    if ((Test-Path $Dest) -and (Get-FileHash $Src).Hash -eq (Get-FileHash $Dest).Hash) {
        if (-not $Quiet) { Write-Host "  ok   $Dest" }
        return
    }
    Copy-Item -Force -Path $Src -Destination $Dest
    if (-not $Quiet) { Write-Host "  sync $Dest" }
}

Sync-File (Join-Path $ClaudeDir 'CLAUDE.md')                (Join-Path $RepoDir 'claude\CLAUDE.md')
Sync-File (Join-Path $ClaudeDir 'settings.json')            (Join-Path $RepoDir 'claude\settings.json')
Sync-File (Join-Path $ClaudeDir 'statusline-command.sh')    (Join-Path $RepoDir 'claude\statusline-command.sh')
Sync-File (Join-Path $ClaudeDir 'commands\init-project.md') (Join-Path $RepoDir 'claude\commands\init-project.md')

# Symlink tracked Claude Code config from this repo into $env:USERPROFILE\.claude\
# Idempotent. Run from PowerShell 5.1+.
#
# Symlink creation on Windows requires either:
#   - Developer Mode enabled (Settings > Privacy & security > For developers), or
#   - an elevated (Run as Administrator) PowerShell session.
# If neither is available the script falls back to copying files (you lose the
# auto-sync benefit; edits in ~/.claude won't flow back to git).

#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$RepoDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE '.claude'
$Stamp     = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir = Join-Path $ClaudeDir "backups\dotfiles-$Stamp"

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'commands') | Out-Null

function Link-File {
    param([string]$Src, [string]$Dest)

    if (Test-Path $Dest) {
        $item = Get-Item $Dest -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Src) {
            Write-Host "  ok   $Dest"
            return
        }
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        Move-Item -Force -Path $Dest -Destination $BackupDir
        Write-Host "  back $Dest -> $BackupDir"
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Dest -Target $Src -ErrorAction Stop | Out-Null
        Write-Host "  link $Dest"
    } catch {
        Write-Warning "Symlink failed ($($_.Exception.Message.Trim())). Copying instead."
        Write-Warning "Enable Developer Mode or run as Administrator for symlinks."
        Copy-Item -Force -Path $Src -Destination $Dest
        Write-Host "  copy $Dest"
    }
}

Write-Host "Linking config into $ClaudeDir ..."
Link-File (Join-Path $RepoDir 'claude\CLAUDE.md')                (Join-Path $ClaudeDir 'CLAUDE.md')
Link-File (Join-Path $RepoDir 'claude\settings.json')            (Join-Path $ClaudeDir 'settings.json')
Link-File (Join-Path $RepoDir 'claude\statusline-command.sh')    (Join-Path $ClaudeDir 'statusline-command.sh')
Link-File (Join-Path $RepoDir 'claude\commands\init-project.md') (Join-Path $ClaudeDir 'commands\init-project.md')

Write-Host ""
Write-Host "Symlinks ready. Open Claude Code, then run:"
Write-Host ""
Write-Host "  /plugin marketplace add anthropics/claude-plugins-official"
Get-Content (Join-Path $RepoDir 'plugins.txt') |
    Where-Object { $_ -and $_ -notmatch '^\s*#' } |
    ForEach-Object { Write-Host "  /plugin install $_" }
Write-Host ""
Write-Host "(Marketplace + installed plugins are managed by Claude Code itself —"
Write-Host " known_marketplaces.json and installed_plugins.json are NOT tracked here"
Write-Host " because they contain machine-specific absolute paths.)"
Write-Host ""
Write-Host "Note: statusline-command.sh is a bash script. On native Windows the"
Write-Host "status line will only render if Claude Code can invoke bash"
Write-Host "(Git Bash or WSL on PATH). Otherwise it silently no-ops."

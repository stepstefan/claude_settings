# Claude Code dotfiles

Portable user-level Claude Code configuration. Tracked files are copied into
`$CLAUDE_CONFIG_DIR` (default `~/.claude/`) by `bootstrap.sh`. A pre-commit
hook syncs edits back so changes made by Claude Code (or by you) show up as
unstaged changes in this repo.

## New machine

**Linux / macOS / WSL:**
```bash
git clone <this-repo> ~/Workspace/claude_settings
cd ~/Workspace/claude_settings
./bootstrap.sh
```

**Windows (PowerShell):**
```powershell
git clone <this-repo> $HOME\Workspace\claude_settings
cd $HOME\Workspace\claude_settings
.\bootstrap.ps1
```

`bootstrap.sh` / `bootstrap.ps1` will:
1. Copy tracked files into `$CLAUDE_CONFIG_DIR` (default `~/.claude/`), backing
   up anything pre-existing.
2. Register the `claude-plugins-official` marketplace.
3. Install every plugin listed in `claude/settings.json -> enabledPlugins`. If
   a plugin is already installed it is uninstalled and reinstalled (clears any
   bad install state).
4. Install a `pre-commit` hook in this repo that runs `sync-from-home.sh`
   before each commit.

Requires `jq` and `claude` on `PATH` (Linux/macOS). The Windows script uses
`ConvertFrom-Json` natively — no `jq` needed.

## Daily flow

Tracked files are real copies, not symlinks, so edits made anywhere need to be
synced back before commit. The pre-commit hook handles this for you:

```bash
cd ~/Workspace/claude_settings
git commit -am 'tweak CLAUDE.md'   # hook syncs ~/.claude -> claude/ and stages
git push
# on another machine:
git pull && ./bootstrap.sh         # re-applies copies + ensures plugins match
```

To inspect changes from `~/.claude/` before committing, run
`./sync-from-home.sh` manually first.

## Custom config dir

Both scripts honor `CLAUDE_CONFIG_DIR` if set:

```bash
CLAUDE_CONFIG_DIR=/opt/claude ./bootstrap.sh
CLAUDE_CONFIG_DIR=/opt/claude ./sync-from-home.sh
```

## What's tracked

| File | Purpose |
|---|---|
| `claude/CLAUDE.md` | Global custom instructions (loaded into every session) |
| `claude/settings.json` | model, alwaysThinkingEnabled, statusLine, enabledPlugins (canonical plugin list) |
| `claude/statusline-command.sh` | agnoster-style status line |
| `claude/commands/init-project.md` | `/init-project` user-level slash command |
| `bootstrap.sh` / `bootstrap.ps1` | Idempotent installer (copy + plugins + hook) |
| `sync-from-home.sh` / `sync-from-home.ps1` | Reverse sync from `$CLAUDE_CONFIG_DIR` to repo |

## What's deliberately NOT tracked

- **Credentials, sessions, history, cache, plugin binaries** — machine-local or sensitive
- **`installed_plugins.json` / `known_marketplaces.json`** — contain absolute paths; re-derived per-machine by `bootstrap.sh`
- **`~/.claude.json`** — UI / onboarding state (numStartups, dialog flags, OAuth account)
- **`projects/*/memory/`** — auto-memory; per-machine, intentionally excluded
- **`plans/`** — local design docs, gitignored

## Adding a new plugin

1. Add `<plugin>@<marketplace>: true` to `claude/settings.json -> enabledPlugins`.
2. Re-run `./bootstrap.sh` (it will install the new plugin and reinstall existing ones).
3. Commit + push.

## Adding new tracked files

If you start using something new (e.g. `~/.claude/keybindings.json`):

1. Move it into `claude/` here.
2. Add a `copy …` line in `bootstrap.sh` AND a matching `sync …` line in `sync-from-home.sh` (and the PowerShell equivalents).
3. Re-run `./bootstrap.sh`.
4. Commit + push.

## Notes

- `statusLine.command` uses `~/.claude/statusline-command.sh` — Claude Code expands `~` to `$HOME` (per official docs), so `settings.json` is fully portable.
- MCP connectors (Notion, Gmail, Calendar, Drive) live on the claude.ai account, not on disk — re-auth them once per new machine via `claude.ai`.
- Per-project `CLAUDE.md` and project-scope plugins live with their repos, not here.

#!/usr/bin/env bash
# Symlink tracked Claude Code config from this repo into ~/.claude/
# and register the plugin marketplace. Idempotent — safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date -u +%Y%m%d-%H%M%S)"

mkdir -p "$CLAUDE_DIR/commands"

link() {
    local src="$1" dest="$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        echo "  ok   $dest"
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
        echo "  back $dest -> $BACKUP_DIR/"
    fi
    ln -s "$src" "$dest"
    echo "  link $dest"
}

echo "Linking config into $CLAUDE_DIR ..."
link "$REPO_DIR/claude/CLAUDE.md"                "$CLAUDE_DIR/CLAUDE.md"
link "$REPO_DIR/claude/settings.json"            "$CLAUDE_DIR/settings.json"
link "$REPO_DIR/claude/statusline-command.sh"    "$CLAUDE_DIR/statusline-command.sh"
link "$REPO_DIR/claude/commands/init-project.md" "$CLAUDE_DIR/commands/init-project.md"

echo
echo "Symlinks ready. Open Claude Code, then run:"
echo
echo "  /plugin marketplace add anthropics/claude-plugins-official"
grep -vE '^\s*(#|$)' "$REPO_DIR/plugins.txt" | sed 's|^|  /plugin install |'
echo
echo "(Marketplace + installed plugins are managed by Claude Code itself —"
echo " known_marketplaces.json and installed_plugins.json are NOT tracked here"
echo " because they contain machine-specific absolute paths.)"

#!/usr/bin/env bash
# Copy tracked Claude Code config from $CLAUDE_CONFIG_DIR (default ~/.claude/)
# back into this repo, so edits made by Claude Code (or by you) show up as
# `git status` changes. Run manually before a commit, or rely on the
# pre-commit hook installed by bootstrap.sh.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
QUIET="${1:-}"

sync() {
    local src="$1" dest="$2"
    if [[ ! -e "$src" ]]; then return; fi
    if cmp -s "$src" "$dest" 2>/dev/null; then
        [[ "$QUIET" == "--quiet" ]] || echo "  ok   $dest"
        return
    fi
    cp "$src" "$dest"
    [[ "$QUIET" == "--quiet" ]] || echo "  sync $dest"
}

sync "$CLAUDE_DIR/CLAUDE.md"                "$REPO_DIR/claude/CLAUDE.md"
sync "$CLAUDE_DIR/settings.json"            "$REPO_DIR/claude/settings.json"
sync "$CLAUDE_DIR/statusline-command.sh"    "$REPO_DIR/claude/statusline-command.sh"
sync "$CLAUDE_DIR/commands/init-project.md" "$REPO_DIR/claude/commands/init-project.md"

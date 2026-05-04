#!/usr/bin/env bash
# Copy tracked Claude Code config from this repo into $CLAUDE_CONFIG_DIR
# (default ~/.claude/), install enabled plugins, and wire up a pre-commit
# hook that syncs edits back. Idempotent — safe to re-run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date -u +%Y%m%d-%H%M%S)"

mkdir -p "$CLAUDE_DIR/commands"

copy() {
    local src="$1" dest="$2"
    if [[ -e "$dest" && ! -L "$dest" ]] && cmp -s "$src" "$dest"; then
        echo "  ok   $dest"
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
        echo "  back $dest -> $BACKUP_DIR/"
    fi
    cp "$src" "$dest"
    echo "  copy $dest"
}

echo "Copying config into $CLAUDE_DIR ..."
copy "$REPO_DIR/claude/CLAUDE.md"                "$CLAUDE_DIR/CLAUDE.md"
copy "$REPO_DIR/claude/settings.json"            "$CLAUDE_DIR/settings.json"
copy "$REPO_DIR/claude/statusline-command.sh"    "$CLAUDE_DIR/statusline-command.sh"
copy "$REPO_DIR/claude/commands/init-project.md" "$CLAUDE_DIR/commands/init-project.md"

echo
echo "Registering marketplace ..."
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true

echo
echo "Installing plugins from claude/settings.json -> enabledPlugins ..."
INSTALLED_IDS="$(claude plugins list --json 2>/dev/null | jq -r '.[].id' 2>/dev/null || true)"
jq -r '.enabledPlugins | keys[]' "$REPO_DIR/claude/settings.json" \
    | while read -r plugin; do
        if grep -Fxq "$plugin" <<<"$INSTALLED_IDS"; then
            echo "  reinstall $plugin"
            claude plugins uninstall "$plugin" >/dev/null || true
        else
            echo "  install   $plugin"
        fi
        claude plugins install "$plugin" >/dev/null
    done

echo
echo "Installing pre-commit hook ..."
HOOK="$REPO_DIR/.git/hooks/pre-commit"
if [[ ! -f "$HOOK" ]] || ! grep -q "sync-from-home.sh" "$HOOK"; then
    cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
set -e
"$(git rev-parse --show-toplevel)/sync-from-home.sh" --quiet
git add claude/
EOF
    chmod +x "$HOOK"
    echo "  hook pre-commit installed"
else
    echo "  hook pre-commit ok"
fi

echo
echo "Done. Edits in $CLAUDE_DIR will be synced back to the repo on git commit"
echo "(via .git/hooks/pre-commit -> sync-from-home.sh)."

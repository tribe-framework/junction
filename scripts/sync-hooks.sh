#!/usr/bin/env bash

HOOKS_DIR="$(git rev-parse --show-toplevel)/scripts/.git_hooks"

echo "Installing Git hooks..."
ln -sf "$HOOKS_DIR/pre-push" "$(git rev-parse --git-path hooks)/pre-push"

chmod +x "$(git rev-parse --git-path hooks)/pre-push"
echo "Done."

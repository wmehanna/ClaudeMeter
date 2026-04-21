#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.githooks"

git config core.hooksPath "$HOOKS_DIR"
chmod +x "$HOOKS_DIR"/pre-commit "$HOOKS_DIR"/pre-push

echo "✓ Git hooks installed (core.hooksPath → .githooks)"
echo "  pre-commit : blocks commits to main, runs test suite"
echo "  pre-push   : blocks direct push to main"

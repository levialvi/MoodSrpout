#!/bin/zsh
set -euo pipefail

# Configuration
DEFAULT_BRANCH="main"

# Inputs
COMMIT_MSG=${MSG:-"chore: deploy from Cursor"}
BRANCH=${BRANCH:-$DEFAULT_BRANCH}

echo "🔧 Deploying to branch: $BRANCH"

# Ensure we're in repo root
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR/.."

# Make sure a git repo exists
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository. Aborting."
  exit 1
fi

# Show current status
echo "📦 Staging changes..."
git add -A

if ! git diff --cached --quiet; then
  echo "✅ Committing: $COMMIT_MSG"
  git commit -m "$COMMIT_MSG"
else
  echo "ℹ️  No staged changes to commit."
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
  echo "🚚 Switching to $BRANCH"
  git checkout -B "$BRANCH"
fi

echo "🚀 Pushing to origin/$BRANCH"
git push -u origin "$BRANCH"

echo "🎉 Deploy complete."



#!/bin/bash
set -euo pipefail

# Script to sync Tufte skill from the canonical upstream repository
UPSTREAM_URL="https://github.com/aref-vc/tufte-claude-skill.git"
TEMP_DIR=$(mktemp -d)

echo "Cloning canonical tufte-claude-skill..."
git clone --depth 1 "$UPSTREAM_URL" "$TEMP_DIR"

# Resolve absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Syncing Tufte skill..."
TARGET_DIR="$REPO_DIR/planning-and-design/tufte"

# Ensure target exists
mkdir -p "$TARGET_DIR"

# Sync files (excluding .git or other repository level artifacts)
rsync -av --delete \
  --exclude='.git' \
  "$TEMP_DIR/" \
  "$TARGET_DIR/"

echo "Cleaning up temp files..."
rm -rf "$TEMP_DIR"

echo "Sync complete!"

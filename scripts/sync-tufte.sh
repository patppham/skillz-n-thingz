#!/bin/bash
set -euo pipefail

# Script to sync Tufte skills from the canonical upstream repository
UPSTREAM_URL="https://github.com/gnurio/tufte-vdqi-plugin.git"
TEMP_DIR=$(mktemp -d)

echo "Cloning canonical tufte-vdqi-plugin..."
git clone --depth 1 "$UPSTREAM_URL" "$TEMP_DIR"

# Resolve absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Define skills to sync
SKILLS=("orchestrate-tufte-vdqi" "assess-graphical-excellence" "render-tufte-chart")

echo "Syncing skills..."
for skill in "${SKILLS[@]}"; do
  echo "-> Syncing $skill"
  # Target directory under planning-and-design
  TARGET_DIR="$REPO_DIR/planning-and-design/$skill"
  
  # Ensure target exists
  mkdir -p "$TARGET_DIR"
  
  # Sync files (excluding .git or other repository level artifacts)
  rsync -av --delete \
    "$TEMP_DIR/skills/$skill/" \
    "$TARGET_DIR/"
done

echo "Cleaning up temp files..."
rm -rf "$TEMP_DIR"

echo "Sync complete!"

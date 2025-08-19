#!/bin/bash
set -euo pipefail

# Script to verify that all Omarchy references have been removed

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Checking for remaining Omarchy references..."

# Check for Omarchy references in the main project files
echo "Checking main project files..."
grep -r "omarchy" "$REPO_ROOT" \
  --include="*.sh" --include="*.conf" --include="*.md" --include="*.txt" \
  --exclude-dir=".git" --exclude-dir="hyprland-sddm-config" | grep -v ".git" \
  || echo "No Omarchy references found in main project files"

# Check for Omarchy references in the installation scripts
echo "Checking installation scripts..."
find "$REPO_ROOT/install" -type f -name "*.sh" -exec grep -l "omarchy" {} \; 2>/dev/null \
  || echo "No Omarchy references found in installation scripts"

# Check for Omarchy references in the migrations
echo "Checking migrations..."
find "$REPO_ROOT/migrations" -type f -name "*.sh" -exec grep -l "omarchy" {} \; 2>/dev/null \
  || echo "No Omarchy references found in migrations"

# Check for Omarchy references in the configuration files
echo "Checking configuration files..."
find "$REPO_ROOT/config" -type f -name "*.conf" -exec grep -l "omarchy" {} \; 2>/dev/null \
  || echo "No Omarchy references found in configuration files"

# Check for Omarchy references in the default configuration files
echo "Checking default configuration files..."
find "$REPO_ROOT/default" -type f -name "*.conf" -exec grep -l "omarchy" {} \; 2>/dev/null \
  || echo "No Omarchy references found in default configuration files"

echo "Verification complete!"

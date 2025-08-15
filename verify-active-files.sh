#!/bin/bash

# Script to verify that all Omarchy references have been removed from active files

echo "Checking for remaining Omarchy references in active files..."

# Check for Omarchy references in the main project files
echo "Checking main project files..."
grep -r "omarchy" /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax --include="*.sh" --include="*.conf" --include="*.md" --include="*.txt" --exclude-dir=".git" --exclude-dir="hyprland-sddm-config" --exclude-dir="migrations" --exclude="GEMINI.md" --exclude="QWEN.md" | grep -v ".git" || echo "No Omarchy references found in main project files"

# Check for Omarchy references in the installation scripts
echo "Checking installation scripts..."
find /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/install -type f -name "*.sh" -exec grep -l "omarchy" {} \; 2>/dev/null || echo "No Omarchy references found in installation scripts"

# Check for Omarchy references in the configuration files
echo "Checking configuration files..."
find /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/config -type f -name "*.conf" -exec grep -l "omarchy" {} \; 2>/dev/null || echo "No Omarchy references found in configuration files"

# Check for Omarchy references in the default configuration files
echo "Checking default configuration files..."
find /mnt/c/Users/mriu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/default -type f -name "*.conf" -exec grep -l "omarchy" {} \; 2>/dev/null || echo "No Omarchy references found in default configuration files"

# Check for Omarchy references in the hyprland-sddm-config directory
echo "Checking hyprland-sddm-config directory..."
find /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config -type f -exec grep -l "omarchy" {} \; 2>/dev/null || echo "No Omarchy references found in hyprland-sddm-config directory"

echo "Verification of active files complete!"
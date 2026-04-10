#!/bin/bash
set -euo pipefail

APP_NAME="TaskBar Time Zones"
DMG_NAME="TaskBarTimeZones"
APP_PATH="build/TaskBarTimeZones.app"
DMG_DIR="build/dmg"
DMG_PATH="build/${DMG_NAME}.dmg"

# Build first
./build.sh

# Prepare DMG staging area
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"
cp -R "$APP_PATH" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

# Remove old DMG if it exists
rm -f "$DMG_PATH"

# Create the DMG
hdiutil create -volname "$APP_NAME" \
  -srcfolder "$DMG_DIR" \
  -ov -format UDZO \
  "$DMG_PATH"

# Clean up staging
rm -rf "$DMG_DIR"

echo ""
echo "Created: $DMG_PATH"
echo "Double-click to open, then drag the app to Applications."

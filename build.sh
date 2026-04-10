#!/bin/bash
set -euo pipefail

APP="build/TaskBarTimeZones.app"

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp TaskBarTimeZones/Info.plist "$APP/Contents/"

swiftc -O \
  -target arm64-apple-macos13.0 \
  -sdk "$(xcrun --show-sdk-path)" \
  -framework SwiftUI \
  -framework AppKit \
  -framework ServiceManagement \
  -parse-as-library \
  TaskBarTimeZones/TaskBarTimeZonesApp.swift \
  TaskBarTimeZones/TimeZoneManager.swift \
  TaskBarTimeZones/SettingsView.swift \
  -o "$APP/Contents/MacOS/TaskBarTimeZones"

echo "Built: $APP"
echo ""
echo "To install:"
echo "  cp -R $APP /Applications/"

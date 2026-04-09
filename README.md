# TaskBar Time Zones

A minimal macOS menu bar app that shows multiple time zones inline.

```
SF 07:15  |  SG 22:15  |  STO 16:15
```

## Features

- Multiple city clocks displayed directly in the menu bar
- 24-hour format
- Add, remove, and reorder cities
- Custom short labels (e.g. SF, SG, STO)
- No dock icon, no clutter
- Settings persist across launches

## Build

Requires macOS 13+ and Swift toolchain (Xcode Command Line Tools).

```bash
mkdir -p build/TaskBarTimeZones.app/Contents/MacOS build/TaskBarTimeZones.app/Contents/Resources
cp TaskBarTimeZones/Info.plist build/TaskBarTimeZones.app/Contents/

swiftc \
  -o build/TaskBarTimeZones.app/Contents/MacOS/TaskBarTimeZones \
  -target arm64-apple-macosx13.0 \
  -sdk $(xcrun --show-sdk-path) \
  -framework SwiftUI \
  -framework AppKit \
  -parse-as-library \
  TaskBarTimeZones/TaskBarTimeZonesApp.swift \
  TaskBarTimeZones/TimeZoneManager.swift \
  TaskBarTimeZones/SettingsView.swift
```

Then open the app:

```bash
open build/TaskBarTimeZones.app
```

## Usage

- Click the time display in the menu bar to access **Settings** or **Quit**
- In Settings: add cities, set short labels, pick time zones, reorder or remove entries
- Default cities: San Francisco (SF), Singapore (SG), Stockholm (STO)

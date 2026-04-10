# TaskBar Time Zones

A minimal macOS menu bar app that shows multiple time zones inline.

```
SF 07:15  |  SG 22:15  |  STO 16:15
```

## Install

### Homebrew

```bash
brew install meadow-kun/tap/taskbartimezones
```

### Download

Grab the DMG from the [latest release](https://github.com/meadow-kun/taskbartimezones/releases/latest), open it, and drag the app to Applications.

## Features

- Multiple city clocks displayed directly in the menu bar
- 24-hour format
- Add, remove, and reorder cities
- Custom short labels (e.g. SF, SG, STO)
- Launch at Login support
- No dock icon, no clutter
- Settings persist across launches

## Usage

- Click the time display in the menu bar to access **Settings** or **Quit**
- In Settings: add cities, set short labels, pick time zones, reorder or remove entries
- Toggle **Launch at Login** to start automatically when you log in
- Default cities: San Francisco (SF), Singapore (SG), Stockholm (STO)

## Build from source

Requires macOS 13+ and Xcode Command Line Tools.

```bash
./build.sh
open build/TaskBarTimeZones.app
```

To create a DMG installer:

```bash
./create-dmg.sh
```

## Author

Philip Nordenfelt — [LinkedIn](https://www.linkedin.com/in/philipnordenfelt) · [GitHub](https://github.com/meadow-kun)

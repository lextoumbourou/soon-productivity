# Soon - Build Instructions

## Prerequisites

- macOS 14.0+
- Xcode 15.0+
- XcodeGen (for generating the Xcode project)

## Generate Xcode Project

Install XcodeGen if you haven't:

```bash
brew install xcodegen
```

Generate the project:

```bash
cd Soon
xcodegen generate
```

This creates `Soon.xcodeproj`.

## Build & Run

1. Open `Soon.xcodeproj` in Xcode
2. Select the "Soon" target
3. Press Cmd+R to build and run

The app will appear in your menu bar with a clock icon.

## Project Structure

```
Soon/
├── Sources/
│   ├── App/
│   │   └── SoonApp.swift          # App entry point, menu bar setup
│   ├── Models/
│   │   ├── FocusSession.swift     # SwiftData model
│   │   └── SessionState.swift     # State machine enum
│   ├── Services/
│   │   ├── SessionManager.swift   # Core business logic
│   │   ├── NotificationService.swift
│   │   └── OverlayWindowController.swift
│   └── Views/
│       ├── MenuBarView.swift      # Main popover container
│       ├── ScheduleFocusView.swift
│       ├── ScheduledView.swift
│       ├── ActiveSessionView.swift
│       ├── ReflectionView.swift
│       ├── HistoryView.swift
│       └── SettingsView.swift
├── Resources/
│   ├── Info.plist
│   └── Soon.entitlements
└── project.yml                    # XcodeGen config
```

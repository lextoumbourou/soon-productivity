# Soon Productivity App

Soon is a productivity app, designed as a time-tracker and motivational coach in one.

Designed to totally eliminate procrastination while you're at your computer.

The idea is to explicity decide on what you're going to use your computer for, and for how long. All other functionality it locked.

Unlock apps and websites as needed, but explain to your future self why you're doing it. Include browser use details

Syncs perfectly with Obsidian, OpenClaw (or any of the claws), or self-contained.

Totally offline and secure by default. Integrates with all your favorite AI providers.

Elegant MacOSX native (2026) design.

## How It Works

Soon Productivity Icon lives in the OSX status bar.

Think offline RescueTime with an AI-first design.

Set your intention for now, or for later.

Soon will start tracking your time against that intention.

Have fun now, but schedule tasks in the future - make your productivity about future you.

No cloud required. Log computer activity and sync to markdown files - Obsidian-vault friendly. Data is stored in a single SQlite table.

## MVP

Click on status menu bar and it shows a screen similar to RescueTime.

Choose to Focus Now | Focus Later

See your list of to tasks.

Select the task and Start Focus Session.

--- Old README below. Need to decide what to do with it. ---

Hotkey or menu bar:

> “In 10 minutes, I will work on: ______”

> Presets: 5 / 10 / 20 (plus maybe “Custom” later)

2. Lock-in

Show a single confirmation: “Locked. Starts at 8:42am. Duration: 25 min.”

Optional: allow “edit until start” but not after it begins.

3. At start time

Full-screen or menubar takeover: “Go time: _____”

Immediately enforce:

Website block list (MVP)

Optional: app blocking later

4. During focus

Minimal UI: countdown + goal + “break glass” (with friction)

5. At end

“Done?” → quick reflection (1 tap):

✅ made progress / ⚠️ started late / ❌ skipped

This is your retention engine + data flywheel.

---

## Build Instructions

### Prerequisites

- macOS 14.0+
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

### Setup

1. Install XcodeGen:

```bash
brew install xcodegen
```

2. Generate the Xcode project:

```bash
cd Soon
xcodegen generate
```

3. Open and run:

```bash
open Soon.xcodeproj
```

Then press `Cmd+R` to build and run. The app will appear in your menu bar with a clock icon.

### Project Structure

```
Soon/
├── Sources/
│   ├── App/           # App entry point, menu bar setup
│   ├── Models/        # SwiftData models, state machine
│   ├── Services/      # SessionManager, notifications, overlays
│   └── Views/         # SwiftUI views for each state
├── Resources/         # Info.plist, entitlements
└── project.yml        # XcodeGen configuration
```

---

## Future Ideas

* Integrate with Obsidan daily notes.
* Capture what you did in the study break to assess how productive the user was.

## Development Goals

Aim for at least one-iteration on this per day. Use it, and try to describe how I can make it better.

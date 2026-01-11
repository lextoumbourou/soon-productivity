# Soon Productivity App

This is a well-integrated native OSX app to help combate productivity and focus you.

It's based on George Ainsle's principles of future reward discounting:

> Humans systematically undervalue future rewards compared to immediate rewards, and the closer a reward gets to the present, the more its subjective value spikes.

The idea is that you want to do something that requires focus, like working for 30 minutes, or studying, but all you want to do now is scroll TikTok or play games. So you set a focus time for 5 minutes in the future, for how long and you can even say what you want to do.

## MVP

1. One-field capture:

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

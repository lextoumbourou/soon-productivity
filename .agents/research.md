# Soon Productivity App - Research & Analysis

## Overview

**Soon** is a macOS menu bar productivity app designed to eliminate procrastination through a unique psychological approach: "commit now, start soon." Rather than demanding immediate action, it lets users schedule focus sessions 5-20 minutes in the future, leveraging hyperbolic discounting to make commitment easy while enforcement is automatic.

The core insight: humans undervalue future rewards, but as they approach, subjective value spikes. Soon makes the commitment painless (it's in the future) and the enforcement automatic (present-you has no choice).

---

## Current Implementation Status

### Sprint 1: Core Scheduling - COMPLETE

The app has completed Sprint 1 and is a functional focus scheduler. All core features work:

| Feature | Status | File(s) |
|---------|--------|---------|
| Menu bar app (no dock) | Done | `SoonApp.swift:38` |
| SwiftData persistence | Done | `SoonApp.swift:8-19`, `FocusSession.swift` |
| Session state machine | Done | `SessionState.swift`, `SessionManager.swift` |
| Schedule focus UI | Done | `ScheduleFocusView.swift` |
| Countdown/scheduled view | Done | `ScheduledView.swift` |
| Active session view | Done | `ActiveSessionView.swift` |
| Start overlay | Done | `OverlayWindowController.swift` |
| Reflection flow | Done | `ReflectionView.swift` |
| Session history | Done | `HistoryView.swift` |
| Notifications | Done | `NotificationService.swift` |
| Settings | Done | `SettingsView.swift` |
| "Guilt-free" messaging | Done | `SessionManager.swift:152-163` |

### Sprint 2: Website Blocking - NOT STARTED

No Network Extension or blocking functionality implemented yet.

### Sprint 3: Polish - PARTIAL

- Settings with launch at login: Done
- Default delay/duration preferences: Done
- Templates/presets: Not started
- Statistics/streaks: Basic stats only (weekly count, completion rate)
- Global hotkey: Not started
- Distribution prep: Not started

---

## Architecture Deep Dive

### Application Structure

```
Soon/
├── Sources/
│   ├── App/
│   │   └── SoonApp.swift          # Entry point + AppDelegate
│   ├── Models/
│   │   ├── FocusSession.swift     # SwiftData model
│   │   └── SessionState.swift     # State enum
│   ├── Services/
│   │   ├── SessionManager.swift   # Core business logic
│   │   ├── NotificationService.swift
│   │   └── OverlayWindowController.swift
│   └── Views/
│       ├── MenuBarView.swift      # Main container
│       ├── ScheduleFocusView.swift
│       ├── ScheduledView.swift
│       ├── ActiveSessionView.swift
│       ├── ReflectionView.swift
│       ├── HistoryView.swift
│       └── SettingsView.swift
├── Resources/
│   ├── Info.plist
│   └── Soon.entitlements
└── project.yml                    # XcodeGen config (inside Soon/)
```

### State Machine

The app uses a clear state machine pattern:

```
.idle → .scheduled → .countdown → .active → .reflection → .idle
         (session)    (session)   (session)   (session)
```

Each state carries the associated session UUID. States defined in `SessionState.swift:3-46`.

### Data Model

**FocusSession** (`FocusSession.swift`):
- `id: UUID` - Unique identifier
- `task: String` - What the user committed to
- `delayMinutes: Int` - Time before start (0/5/10/20)
- `durationMinutes: Int` - Focus duration (10/25/50)
- `scheduledStart: Date` - When focus begins
- `actualStart: Date?` - When it actually started
- `endTime: Date?` - When session ended
- `status: SessionStatus` - scheduled/active/completed/skipped
- `reflection: Reflection?` - User's self-assessment
- `createdAt: Date` - For history sorting

**SessionStatus enum**: `scheduled`, `active`, `completed`, `skipped`

**Reflection enum**: `madeProgress`, `startedLate`, `skipped` (with emoji/label computed properties)

### Key Components

#### SessionManager (`SessionManager.swift`)

The central orchestrator. Responsibilities:
- Session lifecycle (schedule, start, end, complete, skip, cancel)
- Timer management (1-second tick)
- State transitions
- Menu bar icon updates
- History queries
- "Guilt-free" message generation

Uses `@MainActor` for UI safety, publishes state via `@Published`.

#### NotificationService (`NotificationService.swift`)

Handles macOS notifications:
- 2-minute warning before session start
- "Go time" notification at start
- Completion notification
- Session-logged confirmation

Uses `UNUserNotificationCenter` with calendar triggers.

#### OverlayWindowController (`OverlayWindowController.swift`)

Shows a floating "Go time!" window when session starts:
- Borderless, transparent window
- `.ultraThickMaterial` background
- Auto-dismisses after 8 seconds
- Clickable to dismiss
- Animated fade in/out

### UI Components

#### MenuBarView (`MenuBarView.swift`)
- Header with title + tab picker (Focus/History)
- Content area switches based on session state
- Footer with quit button and settings access

#### ScheduleFocusView (`ScheduleFocusView.swift`)
- "In X minutes, I will work on:" prompt
- Delay picker: 0/5/10/20 minutes (circular buttons) - includes "start now" option
- Task text field
- Duration picker: 10/25/50 minutes (capsule buttons)
- "Lock it in" button (disabled if no task)

#### ScheduledView (`ScheduledView.swift`)
- Status badge ("Locked in" or "Starting soon!")
- Large countdown timer
- "Starts at X:XXam" subtitle
- Task display
- Guilt-free message
- Cancel button

#### ActiveSessionView (`ActiveSessionView.swift`)
- Pulsing "Focus mode" indicator
- Large time remaining display
- Progress ring
- Task reminder
- "End early" with confirmation dialog

#### ReflectionView (`ReflectionView.swift`)
- Completion checkmark
- "Session complete!" message
- "How did it go?" prompt
- Three reflection buttons (progress/late/skipped)

#### HistoryView (`HistoryView.swift`)
- Stats header: sessions this week, completion %, total minutes
- Scrollable session list with reflection emoji, task, date, duration

#### SettingsView (`SettingsView.swift`)
- General tab: launch at login, warning notification toggle
- Defaults tab: default delay/duration pickers
- Uses `SMAppService` for login item management

---

## Tech Stack

- **SwiftUI** - All UI components
- **AppKit** - Menu bar integration, window management
- **SwiftData** - Persistence (SQLite-backed)
- **UserDefaults** - Settings via `@AppStorage`
- **UserNotifications** - Local notifications
- **ServiceManagement** - Launch at login

### Build System

Uses **XcodeGen** (`project.yml`) to generate Xcode project:
- macOS 14.0+ deployment target
- Xcode 15.0+
- Swift 5.9
- Hardened runtime enabled
- LSUIElement = true (menu bar app, no dock icon)

---

## What's Missing for MVP

Based on code review, here's what remains:

### High Priority (Core UX)

1. **Default values from settings aren't used** ⚠️ STILL OPEN
   - `ScheduleFocusView` hardcodes `selectedDelay = 10`, `selectedDuration = 25`
   - Should read from `@AppStorage("defaultDelay")` and `@AppStorage("defaultDuration")`
   - Settings exist in `SettingsView.swift:6-7` but aren't wired to schedule view

2. **Warning notification doesn't respect setting** ⚠️ STILL OPEN
   - `showWarningNotification` setting exists in `SettingsView.swift:8`
   - `NotificationService.scheduleSessionStart()` always schedules warning at line 19-38
   - Should check `UserDefaults.standard.bool(forKey: "showWarningNotification")`

3. **Session recovery edge cases**
   - App crashes during active session need testing
   - Timer expiry while app was closed

### Medium Priority (Polish)

4. **Statistics improvements**
   - Streak counter not implemented
   - No charts/visualization
   - Export not available

5. **Templates/presets**
   - User-created session templates
   - One-click start from template

6. **Global hotkey**
   - Quick-access keyboard shortcut

### Lower Priority (Future Sprints)

7. **Website blocking** (Sprint 2)
   - Network Extension
   - Block list management
   - Break glass feature

8. **App blocking** (Phase 4)
   - Monitor active app
   - Overlay blocked apps

9. **Integrations** (Phase 5)
   - Obsidian daily notes
   - Calendar blocking

---

## Roadmap Summary

```
DONE: Sprint 1 - Core Scheduling
├── Menu bar app
├── Session scheduling (0/5/10/20 min delay)
├── Timer with countdown states
├── Start overlay notification
├── Reflection flow
├── History view with basic stats
└── Settings (launch at login, defaults)

TODO: Sprint 2 - Website Blocking
├── Network Extension research
├── Block list management UI
├── Content filter implementation
├── Integration with session state
└── Break glass emergency override

TODO: Sprint 3 - Polish & Retention
├── Templates/presets
├── Enhanced statistics & streaks
├── Global hotkey
├── Onboarding flow
└── Distribution preparation

FUTURE: Advanced Features
├── App blocking (Accessibility API)
├── Obsidian integration
├── Calendar sync
└── Detailed analytics
```

---

## Design Philosophy

### Core Principles

1. **Commit future, enforce present** - Easy to commit when it's "not now"
2. **Guilt-free countdown** - No shame in the delay period
3. **Minimal friction to start** - One tap from template or quick text entry
4. **Friction to break** - Emergency override requires effort
5. **Simple reflection** - Single tap to log session outcome

### UX Flow

```
1. User clicks menu bar icon
2. Enters task, selects delay (0/5/10/20 min) and duration (10/25/50 min)
3. Clicks "Lock it in"
4. Popover closes, icon changes to "scheduled"
5. User enjoys guilt-free time ("You've got X:XX to chill")
6. At T-2min: Warning notification
7. At T-30s: Icon changes, UI shows "Starting soon!"
8. At T-0: "Go time!" overlay appears
9. Icon changes to flame, countdown timer shows time remaining
10. At end: "Session complete!" reflection prompt
11. User taps emoji (✅/⚠️/❌), session logged
12. Back to idle state
```

### Visual Design

- Orange as accent color (warmth, energy)
- Green for success states ("Locked in", completion)
- Clean, minimal interface
- Large typography for countdowns
- Progress ring visualization
- Pulse animation for active indicator

---

## Known Issues / Technical Debt

1. **Duplicate ModelContainer creation** - Both `SoonApp.sharedModelContainer` (line 8-19) and `AppDelegate.modelContainer` (line 41-48) exist; should consolidate to a single source

2. **Timer resilience** - Uses basic `Timer.scheduledTimer` in `SessionManager.swift:117`; could benefit from `DispatchSourceTimer` for better background behavior

3. **Entitlements empty** - `Soon.entitlements` is an empty dict; will need entries for:
   - Network Extension (Sprint 2)
   - App Sandbox (if App Store distribution)
   - Hardened runtime exceptions

4. **No error handling UI** - SwiftData operations use `try?` silently throughout `SessionManager.swift`

5. **Settings-to-view wiring incomplete** - Default delay/duration settings exist but `ScheduleFocusView` doesn't read them

6. **Delay options mismatch** - `ScheduleFocusView` offers [0, 5, 10, 20] but `SettingsView` offers [5, 10, 20, 30] for defaults

---

## Files Quick Reference

| File | Lines | Purpose |
|------|-------|---------|
| `SoonApp.swift` | 127 | App entry, AppDelegate, menu bar setup |
| `FocusSession.swift` | 96 | SwiftData model, SessionStatus, Reflection enums |
| `SessionState.swift` | 46 | State machine enum |
| `SessionManager.swift` | 266 | Core business logic |
| `NotificationService.swift` | 107 | Notification scheduling |
| `OverlayWindowController.swift` | 107 | Start overlay window |
| `MenuBarView.swift` | 89 | Main container view |
| `ScheduleFocusView.swift` | 159 | Session scheduling UI |
| `ScheduledView.swift` | 104 | Countdown view |
| `ActiveSessionView.swift` | 132 | Active session UI |
| `ReflectionView.swift` | 109 | Post-session reflection |
| `HistoryView.swift` | 170 | Session history + stats |
| `SettingsView.swift` | 88 | App preferences |
| `project.yml` | 33 | XcodeGen configuration (Soon/project.yml) |

**Total implementation**: ~1,600 lines of Swift code

---

## Recent Changes (Last Updated: 2026-03-01)

- Added `0` minute delay option ("start now") to `ScheduleFocusView`
- Menu bar now shows timer in title during scheduled/active states
- Minor stability fixes for focus removal edge cases

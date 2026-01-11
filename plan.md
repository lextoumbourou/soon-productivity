# Soon - Development Plan

## Core Concept

**"Future Me Mode"** - Commit now, start soon.

Most productivity blockers assume you're motivated *right now*. Soon's twist: commit to starting in 5/10/20 minutes. Present-you can keep scrolling guilt-free until the timer hits, then the environment flips automatically.

Based on George Ainslie's hyperbolic discounting: humans undervalue future rewards, but as they approach, subjective value spikes. We leverage this by making the commitment easy (future) and the enforcement automatic (present).

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Menu Bar App                         │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ Session     │  │ Timer       │  │ Block           │  │
│  │ Manager     │──│ Service     │──│ Service         │  │
│  │             │  │             │  │ (Network Ext)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
│         │                │                  │           │
│         ▼                ▼                  ▼           │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Local Persistence                   │    │
│  │         (SwiftData / UserDefaults)              │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

**Tech Stack:**
- SwiftUI + AppKit (menu bar integration)
- SwiftData for session history
- Network Extension for website blocking (Safari/Chrome)
- Background timer with notification scheduling

---

## Sprint 1: Core Scheduling (No Blocking)

**Goal:** Shippable "focus scheduler" that feels complete without blocking.

### 1.1 Project Setup
- [ ] Create macOS app project with SwiftUI
- [ ] Configure menu bar app (no dock icon)
- [ ] Set up app lifecycle and launch at login option
- [ ] Create basic SwiftData models

### 1.2 Session Model & State Machine
- [ ] Define `FocusSession` model:
  - `id: UUID`
  - `task: String`
  - `delayMinutes: Int` (5/10/20)
  - `durationMinutes: Int` (10/25/50)
  - `scheduledStart: Date`
  - `actualStart: Date?`
  - `endTime: Date?`
  - `status: SessionStatus` (scheduled/active/completed/skipped)
  - `reflection: Reflection?` (progress/startedLate/skipped)
- [ ] Implement session state machine:
  - `.idle` → `.scheduled` → `.countdown` → `.active` → `.reflection` → `.idle`

### 1.3 Menu Bar UI
- [ ] Menu bar icon (changes based on state)
- [ ] Dropdown panel with:
  - "Schedule Focus" button
  - Delay presets: 5 / 10 / 20 min
  - Duration presets: 10 / 25 / 50 min
  - Task input field (single line)
  - "Lock it in" confirmation button
- [ ] Scheduled state view:
  - "Starts at 8:42am" countdown
  - "Working on: [task]"
  - "Cancel" option (before start only)
- [ ] Active state view:
  - Large countdown timer
  - Task reminder
  - "End early" with friction

### 1.4 Timer Service
- [ ] Background timer that survives app backgrounding
- [ ] Local notifications:
  - "2 minutes until focus starts"
  - "Go time: [task]"
  - "Focus session complete"
- [ ] Handle system sleep/wake correctly

### 1.5 Start Overlay
- [ ] Full-screen or floating window at session start
- [ ] Shows: "Go time: [task]"
- [ ] Auto-dismiss after 5 seconds or click
- [ ] Brings app to foreground attention

### 1.6 End & Reflection
- [ ] End notification with action buttons
- [ ] Quick reflection UI (3 options):
  - ✅ Made progress
  - ⚠️ Started late
  - ❌ Skipped
- [ ] Save to session history

### 1.7 Session History
- [ ] Simple list view of past sessions
- [ ] Basic stats: sessions this week, completion rate
- [ ] Accessible from menu bar dropdown

---

## Sprint 2: Website Blocking

**Goal:** Enforce focus with reliable website blocking.

### 2.1 Blocking Strategy Research
- [ ] Evaluate options:
  - Network Extension (Content Filter)
  - Screen Time API (FamilyControls)
  - DNS proxy approach
- [ ] Document limitations and requirements
- [ ] Choose approach for MVP

### 2.2 Block List Management
- [ ] Default block list (social, news, video):
  - twitter.com, x.com
  - facebook.com, instagram.com
  - reddit.com
  - youtube.com
  - tiktok.com
  - news sites (configurable)
- [ ] User-defined additions
- [ ] Block list presets: "Social" / "All Distractions" / "Custom"

### 2.3 Network Extension Implementation
- [ ] Create Network Extension target
- [ ] Implement content filter provider
- [ ] Handle extension lifecycle
- [ ] System extension approval flow

### 2.4 Integration with Session State
- [ ] Auto-enable blocking when session starts
- [ ] Auto-disable when session ends
- [ ] Handle edge cases (app crash, system restart)
- [ ] "Blocked" page/notification when user hits blocked site

### 2.5 Break Glass Feature
- [ ] Emergency override with friction:
  - Type the task you committed to
  - 20-second wait timer
  - "1 override per day" setting
- [ ] Log overrides in session data

---

## Sprint 3: Polish & Retention

**Goal:** Make it sticky and ready for distribution.

### 3.1 Templates / Presets
- [ ] Saved session templates:
  - "Deep Work" (20 min delay, 50 min duration, all distractions blocked)
  - "Quick Task" (5 min delay, 10 min duration)
  - "Study" (10 min delay, 25 min duration)
- [ ] User-created templates
- [ ] One-click start from template

### 3.2 "Guilt-Free Zone" UI
- [ ] During countdown to start, show:
  - "You've got 9:58 to chill"
  - "When this hits zero, we go"
- [ ] Transform vibe from shame → permission → action

### 3.3 Statistics & Streaks
- [ ] Weekly summary view
- [ ] Streak counter (days with completed sessions)
- [ ] Simple charts: focus minutes per day
- [ ] Export data option

### 3.4 Settings & Preferences
- [ ] Launch at login toggle
- [ ] Default delay/duration preferences
- [ ] Block list management UI
- [ ] Break glass friction level
- [ ] Sound/notification preferences

### 3.5 Global Hotkey
- [ ] Configurable keyboard shortcut to open scheduler
- [ ] Quick-schedule with defaults (hotkey → type task → enter)

### 3.6 Distribution Prep
- [ ] App icon and branding
- [ ] Onboarding flow (first launch)
- [ ] Handle sandbox/entitlements for App Store
- [ ] Or: notarization for direct distribution

---

## Future Phases (Post-MVP)

### Phase 4: App Blocking
- [ ] Monitor active application
- [ ] Block/overlay specified apps during focus
- [ ] Accessibility API integration

### Phase 5: Integrations
- [ ] Obsidian daily notes integration
- [ ] Calendar integration (block focus time)
- [ ] Shortcuts/automation support

### Phase 6: Pro Features
- [ ] Multiple block sets
- [ ] Advanced rules ("block until 3 min in Xcode")
- [ ] Commitment queue / calendar view
- [ ] Detailed analytics

---

## Technical Decisions

### Why Menu Bar App?
- Non-intrusive presence
- Quick access without breaking flow
- Mac-native feel
- No dock clutter

### Why Network Extension for Blocking?
- Works across all browsers
- System-level enforcement
- Survives browser changes
- Apple-sanctioned approach

### Data Storage
- SwiftData for session history (queryable, future-proof)
- UserDefaults for preferences
- No cloud sync in MVP (keeps it simple)

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Network Extension complexity | Start without blocking (Sprint 1 is useful alone) |
| App Store rejection | Prepare for direct distribution with notarization |
| Timer unreliability | Use scheduled notifications as backup |
| User bypasses blocking | Accept 80% solution; perfection isn't goal |

---

## Success Metrics

- **Retention:** Users complete 3+ sessions in first week
- **Completion rate:** >70% of scheduled sessions completed
- **Daily active:** Users schedule at least 1 session/day

---

## Todo Summary

### Sprint 1 (Core Scheduling)
- [ ] Project setup (menu bar app, SwiftData)
- [ ] Session model and state machine
- [ ] Menu bar UI (schedule, countdown, active states)
- [ ] Timer service with notifications
- [ ] Start overlay
- [ ] End reflection flow
- [ ] Session history view

### Sprint 2 (Website Blocking)
- [ ] Research and choose blocking approach
- [ ] Implement block list management
- [ ] Network Extension implementation
- [ ] Integrate blocking with session state
- [ ] Break glass feature

### Sprint 3 (Polish)
- [ ] Templates/presets
- [ ] Guilt-free countdown UI
- [ ] Statistics and streaks
- [ ] Settings UI
- [ ] Global hotkey
- [ ] Distribution preparation

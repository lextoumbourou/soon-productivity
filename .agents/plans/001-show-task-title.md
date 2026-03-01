# Plan: Show Task Title in Menu Bar

**Status:** Complete
**Priority:** High
**Complexity:** Low

---

## Goal

Display the current task title in the macOS menu bar during scheduled and active sessions, so users can see what they committed to without opening the popover.

---

## Current State

- Menu bar shows: `[icon] 5:23` (timer only)
- Task is only visible inside popover views (`ScheduledView`, `ActiveSessionView`)
- `SessionManager` already has `currentSession` with `.task` property
- `AppDelegate.updateMenuBarTitle()` sets the button title

---

## Proposed Design

### Option A: Task after timer (Recommended)
```
[flame] 5:23 · Write report
```
- Truncate task to ~20 chars with ellipsis if needed
- Separator (·) between timer and task
- Clean, scannable at a glance

### Option B: Task only (no timer in title)
```
[flame] Write report
```
- Timer still visible in popover
- Cleaner but loses quick time check

### Option C: Task above timer in popover header
- No menu bar change
- Less useful since popover must be opened

**Recommendation:** Option A - users get both time and context at a glance.

---

## Implementation Steps

### 1. Update `SessionManager` to provide task title
Add a computed property or update `updateMenuBarTitle()` to include task.

**File:** `SessionManager.swift`
```swift
private func updateMenuBarTitle(_ interval: TimeInterval) {
    let totalSeconds = max(0, Int(interval))
    let formatted = String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)

    // Add truncated task title
    if let task = currentSession?.task {
        let truncated = task.count > 20 ? String(task.prefix(17)) + "..." : task
        onUpdateMenuBarTitle?("\(formatted) · \(truncated)")
    } else {
        onUpdateMenuBarTitle?(formatted)
    }
}
```

### 2. Verify width handling
Menu bar items have limited space. Test with:
- Short tasks: "Email"
- Medium tasks: "Write weekly report"
- Long tasks: "Finish the quarterly planning document for Q2"

**File:** `SoonApp.swift:125`
- Current: `button.title = title.isEmpty ? "" : " \(title)"`
- May need to cap total length or use `NSStatusItem.variableLength`

### 3. Add user preference (optional)
If users find it too long, add a setting to toggle task display in menu bar.

**File:** `SettingsView.swift`
```swift
@AppStorage("showTaskInMenuBar") private var showTaskInMenuBar = true
```

---

## Files to Modify

| File | Change |
|------|--------|
| `SessionManager.swift:223-227` | Update `updateMenuBarTitle()` to include task |
| `SoonApp.swift:123-126` | Verify title display handles longer strings |
| `SettingsView.swift` | (Optional) Add toggle for menu bar task display |

---

## Testing

1. Schedule a session with short task → verify displays correctly
2. Schedule with long task (40+ chars) → verify truncation
3. Active session → verify task persists in title
4. Session ends → verify title clears
5. Resize menu bar area (many apps open) → verify doesn't break layout

---

## Estimated Scope

- **Lines of code:** ~10-15
- **Files:** 1-2
- **Risk:** Low (additive change, no breaking behavior)

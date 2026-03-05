# Plan: Full Todo List Support

**Status:** Complete
**Priority:** High
**Complexity:** Medium

---

## Goal

Allow users to enter multiple tasks when scheduling a focus session, and check them off during the session. This transforms Soon from a single-task timer into a focused work session with a checklist.

---

## Current State

- `FocusSession.task` is a single `String`
- `ScheduleFocusView` has one text field
- `ActiveSessionView` displays the task as static text
- Menu bar shows: `5:23 · Write report`

---

## Proposed Design

### User Experience

**Scheduling:**
```
In [10] minutes, I will work on:
┌─────────────────────────────┐
│ ☐ Review pull request       │
│ ☐ Write unit tests          │
│ ☐ Update documentation      │
│ + Add task                  │
└─────────────────────────────┘
For [25 min]
        [Lock it in]
```

**Active Session:**
```
        Focus mode
          18:42
         remaining

    ☑ Review pull request
    ☐ Write unit tests  ← current
    ☐ Update documentation

        (End early)
```

**Menu Bar:**
```
[flame] 18:42 · Write unit tests (2/3)
```

---

## Data Model Changes

### Option A: Embedded Array (Recommended)
Store tasks as a `Codable` array in `FocusSession`:

```swift
// New model for individual task items
struct TaskItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
    }
}

// Update FocusSession
@Model
final class FocusSession {
    // ... existing fields ...
    var task: String  // Keep for backward compatibility (first task title)
    var tasks: [TaskItem]  // New: full task list

    var currentTask: TaskItem? {
        tasks.first { !$0.isCompleted }
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }
}
```

**Pros:** Simple, no schema migration headaches, tasks tied to session
**Cons:** Can't query individual tasks across sessions

### Option B: Separate SwiftData Model
Create `TaskItem` as `@Model` with relationship to `FocusSession`.

**Pros:** Queryable, could support global task queue later
**Cons:** More complex, requires relationship management

**Recommendation:** Option A for simplicity. Can migrate to B later if needed.

---

## Implementation Steps

### Phase 1: Data Model (FocusSession.swift)

1. Add `TaskItem` struct (Codable)
2. Add `tasks: [TaskItem]` property to `FocusSession`
3. Add computed properties: `currentTask`, `completedCount`, `totalCount`
4. Update `init` to accept `[String]` and convert to `TaskItem` array
5. Keep `task` property as computed (first task title) for backward compat

### Phase 2: Schedule UI (ScheduleFocusView.swift)

1. Replace single `TextField` with task list editor
2. Add "+" button to add new task
3. Allow reordering (drag handles) - optional v1
4. Allow deletion (swipe or X button)
5. Disable "Lock it in" if no tasks

### Phase 3: Active Session UI (ActiveSessionView.swift)

1. Replace static task text with scrollable checklist
2. Tap task to toggle completion
3. Visual distinction: completed (strikethrough, muted), current (highlighted)
4. Auto-scroll to keep current task visible

### Phase 4: Menu Bar Update (SessionManager.swift)

1. Update `updateMenuBarTitle()` to show current task + progress
2. Format: `18:42 · Write tests (2/3)`
3. When all complete: `18:42 · All done! (3/3)`

### Phase 5: Scheduled/Reflection Views

1. `ScheduledView`: Show task list preview (read-only)
2. `ReflectionView`: Show completion summary

---

## Files to Modify

| File | Changes |
|------|---------|
| `FocusSession.swift` | Add `TaskItem`, `tasks` array, computed properties |
| `ScheduleFocusView.swift` | Multi-task input UI |
| `ActiveSessionView.swift` | Checkable task list |
| `ScheduledView.swift` | Task list preview |
| `ReflectionView.swift` | Completion summary |
| `SessionManager.swift` | Update menu bar title, add `toggleTask()` |
| `HistoryView.swift` | Show tasks completed vs total |

---

## UI Components Needed

```swift
// Reusable task row
struct TaskRow: View {
    let task: TaskItem
    let isEditable: Bool
    var onToggle: (() -> Void)?
    var onDelete: (() -> Void)?
}

// Task list editor for scheduling
struct TaskListEditor: View {
    @Binding var tasks: [String]
}

// Checkable task list for active session
struct ActiveTaskList: View {
    let tasks: [TaskItem]
    var onToggle: (UUID) -> Void
}
```

---

## Migration / Backward Compatibility

- Existing sessions have `task` string but no `tasks` array
- On load, if `tasks` is empty but `task` is not, create single-item array
- `task` property becomes computed: `tasks.first?.title ?? ""`

---

## Edge Cases

1. **Empty task list** → Disable "Lock it in"
2. **All tasks completed mid-session** → Show encouragement, session continues
3. **Very long task list** → ScrollView with reasonable max height
4. **Single task** → Works exactly like today (backward compatible UX)

---

## Testing

1. Schedule with 1 task → behaves like current app
2. Schedule with 3 tasks → shows list, can check off
3. Complete all tasks → menu bar shows "All done!"
4. End early with incomplete tasks → reflection shows X/Y completed
5. View history → shows completion count per session

---

## Estimated Scope

- **Lines of code:** ~150-200
- **Files:** 7
- **Risk:** Medium (data model change, but additive)
- **Time:** 2-3 focused sessions

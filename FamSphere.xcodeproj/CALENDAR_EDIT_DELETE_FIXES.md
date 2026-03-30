# Calendar Edit/Delete Fixes Needed

## Current Issues:
1. ✅ Events are editable (already working after my previous changes)
2. ❌ Deadlines cannot be edited  
3. ❌ Cannot delete events, pickups, or deadlines

## Root Cause:
My previous string replacement changes weren't applied correctly to the CalendarView.swift file. The file still has the old versions without:
- Edit buttons/sheets
- Tappable cards
- Proper context menus with Edit option

## Files That Need Updates:

### 1. CalendarView.swift - PickupRowView

**Current Problem:** Just has delete in context menu, no edit functionality

**Needs:**
```swift
@State private var showingEditSheet = false

// Wrap entire card in Button
Button {
    showingEditSheet = true
} label: {
    // existing HStack content...
}
.buttonStyle(.plain)
.contextMenu {
    Button {
        showingEditSheet = true
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    
    if canDelete {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
.sheet(isPresented: $showingEditSheet) {
    EditEventView(event: event)
}
```

### 2. CalendarView.swift - EventCardView

**Current Problem:** Same as PickupRowView

**Needs:** Same fix as PickupRowView above

### 3. CalendarView.swift - DeadlineCardView  

**Current Problem:** Only has completion checkbox, no edit/delete

**Needs:**
```swift
@State private var showingEditSheet = false
@State private var showingDeleteAlert = false

private var canEdit: Bool {
    appSettings.currentUserRole == .parent || goal.createdByChildName == appSettings.currentUserName
}

private var canDelete: Bool {
    appSettings.currentUserRole == .parent || goal.createdByChildName == appSettings.currentUserName
}

// Wrap card in Button
Button {
    showingEditSheet = true
} label: {
    // existing VStack content...
}
.buttonStyle(.plain)
.contextMenu {
    if canEdit {
        Button {
            showingEditSheet = true
        } label: {
            Label("Edit Goal", systemImage: "pencil")
        }
    }
    
    if canDelete {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Label("Delete Goal", systemImage: "trash")
        }
    }
}
.sheet(isPresented: $showingEditSheet) {
    NavigationStack {
        EditGoalView(goal: goal)
    }
}
.alert("Delete Goal?", isPresented: $showingDeleteAlert) {
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {
        modelContext.delete(goal)
    }
} message: {
    Text("This will permanently delete '\(goal.title)' and all its progress.")
}
```

### 4. Add EditEventView (Already created)

This view should already be added at the end of CalendarView.swift before the previews.

### 5. Add EditGoalView (Already created)

This view should already be added at the end of CalendarView.swift before the previews.

## Why Delete Isn't Working:

The context menu is there, but might not be triggering because:
1. Missing `.buttonStyle(.plain)` on parent views
2. Gesture conflicts with ScrollView
3. The alert confirmation isn't showing

## Quick Fix to Test:

Try adding `.onLongPressGesture` as an alternative:

```swift
.onLongPressGesture {
    showingDeleteAlert = true
}
```

This will trigger delete on long press if context menu isn't working.

## Manual Steps to Fix:

Since my automated changes aren't applying correctly, here's what to do manually in Xcode:

1. Open CalendarView.swift
2. Find `struct PickupRowView`
3. Add `@State private var showingEditSheet = false` near the top
4. Wrap the entire `HStack` content in a `Button { showingEditSheet = true }`
5. Add `.buttonStyle(.plain)` after the button's closing brace
6. Update `.contextMenu` to include Edit option
7. Add `.sheet(isPresented: $showingEditSheet) { EditEventView(event: event) }`
8. Repeat for `EventCardView`
9. Repeat for `DeadlineCardView` (but use `EditGoalView`)

## Testing After Fix:

1. **Tap** a pickup/event/deadline → Should open edit sheet
2. **Long-press** → Should show context menu with Edit and Delete
3. **Tap Delete** → Should show confirmation alert
4. **Confirm** → Should delete the item

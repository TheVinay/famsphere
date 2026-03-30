# FamSphere Enhancement Implementation Plan

## Overview
Four major enhancements to implement based on user feedback.

---

## ✅ COMPLETED: Data Model Updates

### CalendarEvent Model
```swift
@Model
final class CalendarEvent {
    var title: String
    var eventDate: Date
    var endDate: Date?  // ✅ NEW
    var notes: String
    var eventTypeValue: String
    var createdByName: String
    var colorHex: String
    
    // ✅ NEW: Recurrence properties
    var isRecurring: Bool
    var recurrenceDays: [Int]  // 1=Sunday, 2=Monday, etc.
    var recurrenceEndDate: Date?
    var recurrenceGroupId: String?  // Links related recurring events
}
```

### Goal Model
```swift
@Model
final class Goal {
    var createdByParentName: String?  // ✅ NEW: Track if parent created
    
    // ✅ NEW: Computed property for creator type
    var creatorType: GoalCreatorType {
        if createdByParentName != nil {
            return .parent
        } else if status == .pending {
            return .childSuggested
        } else {
            return .child
        }
    }
}
```

### New Enum
```swift
enum GoalCreatorType: String, Codable {
    case child = "Child"
    case childSuggested = "Child Suggested"
    case parent = "Parent"
    
    var badge: String
    var icon: String
    var color: String
}
```

---

## Feature 1: Enhanced Goal Creation

### Requirements
1. ✅ Goal creator types: "Child", "Child Suggested", "Parent"
2. ⏳ Parent-created goals auto-approved
3. ⏳ Parents can edit their own goals anytime
4. ⏳ Parents can adjust points during approval

### Implementation Status

**✅ Models Updated**
- `createdByParentName` field added
- `creatorType` computed property added
- `GoalCreatorType` enum created
- Auto-approval logic in init

**⏳ UI Changes Needed:**

#### AddGoalView (GoalsView.swift)
```swift
// Add for parents:
if appSettings.currentUserRole == .parent {
    Section {
        Picker("Assign To", selection: $selectedChildName) {
            ForEach(children) { child in
                Text(child.name).tag(child.name)
            }
        }
    } header: {
        Text("Assign Goal To")
    } footer: {
        Text("This goal will be auto-approved for the selected child")
    }
}

// On save:
let goal = Goal(
    title: title,
    createdByChildName: isParent ? selectedChildName : appSettings.currentUserName,
    createdByParentName: isParent ? appSettings.currentUserName : nil,
    // ...
)
```

#### GoalCardView - Show Creator Badge
```swift
HStack(spacing: 4) {
    Image(systemName: goal.creatorType.icon)
        .font(.caption2)
    Text(goal.creatorType.badge)
        .font(.caption)
}
.foregroundStyle(colorFor(goal.creatorType.color))
.padding(.horizontal, 6)
.padding(.vertical, 2)
.background(colorFor(goal.creatorType.color).opacity(0.15))
.clipShape(Capsule())
```

#### GoalApprovalSheet - Point Adjustment
```swift
Section {
    Stepper("Points: \(adjustedPoints)", value: $adjustedPoints, in: 1...100, step: 5)
    
    if adjustedPoints != goal.pointValue {
        Text("Child suggested: \(goal.pointValue) pts")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
} header: {
    Text("Reward Points")
} footer: {
    Text("You can adjust the point value before approving")
}

// On approve:
goal.pointValue = adjustedPoints
goal.status = .approved
```

#### Parent Goal Editing
```swift
// In GoalCardView, if parent created:
if goal.createdByParentName == appSettings.currentUserName {
    Button {
        showingEditGoal = true
    } label: {
        Label("Edit Goal", systemImage: "pencil")
    }
}
```

---

## Feature 2: Delete Family Members

### Requirements
1. ⏳ Add delete functionality to Manage Family Members
2. ⏳ Swipe-to-delete
3. ⏳ Confirmation dialog
4. ⏳ Handle orphaned goals (reassign or delete)

### Implementation

#### ManageFamilyView (SettingsView.swift)
```swift
Section {
    ForEach(familyMembers) { member in
        HStack(spacing: 12) {
            // ... existing code
        }
    }
    .onDelete(perform: deleteMembers)  // ✅ Already exists!
}
```

**Already implemented!** Just need to add confirmation dialog:

```swift
@State private var memberToDelete: FamilyMember?
@State private var showingDeleteConfirmation = false

private func deleteMembers(at offsets: IndexSet) {
    guard let index = offsets.first else { return }
    memberToDelete = familyMembers[index]
    showingDeleteConfirmation = true
}

.alert("Delete Family Member", isPresented: $showingDeleteConfirmation) {
    Button("Cancel", role: .cancel) {}
    Button("Delete", role: .destructive) {
        if let member = memberToDelete {
            deleteMember(member)
        }
    }
} message: {
    if let member = memberToDelete {
        Text("Are you sure you want to delete \(member.name)? This will also delete all their goals and data.")
    }
}

private func deleteMember(_ member: FamilyMember) {
    // Delete associated goals
    let goalsToDelete = allGoals.filter { $0.createdByChildName == member.name }
    goalsToDelete.forEach { modelContext.delete($0) }
    
    // Delete member
    modelContext.delete(member)
    
    memberToDelete = nil
}
```

---

## Feature 3: Calendar Event Enhancements

### Requirements
1. ✅ End date and end time
2. ⏳ 15-minute interval picker (00, 15, 30, 45)
3. ⏳ Recurrence options (days of week)
4. ⏳ Recurrence end date
5. ⏳ Show events on all selected dates

### Implementation

#### AddEventView (CalendarView.swift)

```swift
@State private var title = ""
@State private var startDate = Date()
@State private var endDate = Date().addingTimeInterval(3600)  // +1 hour
@State private var notes = ""
@State private var selectedEventType: EventType = .personal

// NEW:
@State private var isRecurring = false
@State private var selectedDays: Set<Int> = []
@State private var recurrenceEndDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!

Form {
    Section {
        TextField("Event Title", text: $title)
        
        // Start Date with 15-min picker
        DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
        
        // End Date with 15-min picker  
        DatePicker("Ends", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
        
        Picker("Type", selection: $selectedEventType) {
            ForEach(EventType.allCases, id: \.self) { type in
                Label(type.rawValue, systemImage: type.icon).tag(type)
            }
        }
    }
    
    Section("Notes") {
        TextField("Optional notes", text: $notes, axis: .vertical)
            .lineLimit(3...6)
    }
    
    // NEW: Recurrence Section
    Section {
        Toggle("Repeat", isOn: $isRecurring)
        
        if isRecurring {
            // Days of week selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Repeat On")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 8) {
                    ForEach(1...7, id: \.self) { day in
                        DayButton(
                            day: day,
                            isSelected: selectedDays.contains(day)
                        ) {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            
            DatePicker("Repeat Until", selection: $recurrenceEndDate, displayedComponents: .date)
        }
    } header: {
        Text("Recurrence")
    } footer: {
        if isRecurring {
            Text("Event will repeat on selected days until \(recurrenceEndDate, style: .date)")
        }
    }
}

// Helper view
struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var dayName: String {
        ["S", "M", "T", "W", "T", "F", "S"][day - 1]
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
```

#### Event Creation Logic

```swift
private func addEvent() {
    if isRecurring && !selectedDays.isEmpty {
        createRecurringEvents()
    } else {
        createSingleEvent()
    }
    dismiss()
}

private func createSingleEvent() {
    let event = CalendarEvent(
        title: title,
        eventDate: startDate,
        endDate: endDate,
        notes: notes,
        eventType: selectedEventType,
        createdByName: appSettings.currentUserName,
        colorHex: colorHex
    )
    modelContext.insert(event)
}

private func createRecurringEvents() {
    let groupId = UUID().uuidString
    var currentDate = Calendar.current.startOfDay(for: startDate)
    let endDay = Calendar.current.startOfDay(for: recurrenceEndDate)
    
    while currentDate <= endDay {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        
        if selectedDays.contains(weekday) {
            // Copy time from startDate to currentDate
            let components = Calendar.current.dateComponents([.hour, .minute], from: startDate)
            if let eventTime = Calendar.current.date(bySettingHour: components.hour ?? 0,
                                                      minute: components.minute ?? 0,
                                                      second: 0,
                                                      of: currentDate) {
                
                // Calculate end time
                let duration = endDate.timeIntervalSince(startDate)
                let eventEndTime = eventTime.addingTimeInterval(duration)
                
                let event = CalendarEvent(
                    title: title,
                    eventDate: eventTime,
                    endDate: eventEndTime,
                    notes: notes,
                    eventType: selectedEventType,
                    createdByName: appSettings.currentUserName,
                    colorHex: colorHex,
                    isRecurring: true,
                    recurrenceDays: Array(selectedDays),
                    recurrenceEndDate: recurrenceEndDate,
                    recurrenceGroupId: groupId
                )
                modelContext.insert(event)
            }
        }
        
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
    }
}
```

#### 15-Minute Interval Picker

For 15-minute intervals, we need to round dates:

```swift
extension Date {
    func roundedToNearest15Minutes() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        let minute = components.minute ?? 0
        let roundedMinute = (minute / 15) * 15
        
        return calendar.date(from: DateComponents(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: roundedMinute
        )) ?? self
    }
}

// Apply when setting initial dates:
@State private var startDate = Date().roundedToNearest15Minutes()
@State private var endDate = Date().addingTimeInterval(3600).roundedToNearest15Minutes()

// And in onChange:
.onChange(of: startDate) { old, new in
    startDate = new.roundedToNearest15Minutes()
}
.onChange(of: endDate) { old, new in
    endDate = new.roundedToNearest15Minutes()
}
```

---

## Feature 4: Recurring Event Management

### Requirements
1. ⏳ Delete single event vs all future events
2. ⏳ Apple Calendar-style deletion
3. ⏳ Don't delete past occurrences

### Implementation

#### EventRowView (CalendarView.swift)

```swift
@State private var showingDeleteOptions = false

.contextMenu {
    if canDelete {
        if event.isRecurring {
            Button(role: .destructive) {
                showingDeleteOptions = true
            } label: {
                Label("Delete Event", systemImage: "trash")
            }
        } else {
            Button(role: .destructive) {
                deleteEvent(event)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
.confirmationDialog("Delete Recurring Event", isPresented: $showingDeleteOptions) {
    Button("Delete This Event Only") {
        deleteEvent(event)
    }
    
    Button("Delete All Future Events", role: .destructive) {
        deleteAllFutureEvents(event)
    }
    
    Button("Cancel", role: .cancel) {}
} message: {
    Text("This is a recurring event")
}

private func deleteEvent(_ event: CalendarEvent) {
    modelContext.delete(event)
}

private func deleteAllFutureEvents(_ event: CalendarEvent) {
    guard let groupId = event.recurrenceGroupId else {
        deleteEvent(event)
        return
    }
    
    // Find all events in the recurrence group that are today or in the future
    let today = Calendar.current.startOfDay(for: Date())
    
    let futureEvents = allEvents.filter {
        $0.recurrenceGroupId == groupId &&
        Calendar.current.startOfDay(for: $0.eventDate) >= today
    }
    
    futureEvents.forEach { modelContext.delete($0) }
}
```

#### Visual Indicator for Recurring Events

```swift
// In EventRowView/EventCardView
if event.isRecurring {
    HStack(spacing: 4) {
        Image(systemName: "repeat")
            .font(.caption2)
        Text("Recurring")
            .font(.caption)
    }
    .foregroundStyle(.secondary)
}
```

---

## Testing Checklist

### Goal Creation
- [ ] Child creates goal → Status: "Child Suggested" badge
- [ ] Child goal approved → Changes to "Child" badge
- [ ] Parent creates goal for child → Status: "Parent" badge, auto-approved
- [ ] Parent can edit their own goals anytime
- [ ] Parent can adjust points during approval
- [ ] Adjusted points shown vs original

### Family Member Deletion
- [ ] Swipe to delete shows delete button
- [ ] Confirmation dialog appears
- [ ] Member deleted successfully
- [ ] Associated goals deleted
- [ ] Cannot delete if currently signed in (optional safety check)

### Calendar Events - Basic
- [ ] Can set start date and time
- [ ] Can set end date and time
- [ ] Times rounded to 15-minute intervals
- [ ] End time defaults to 1 hour after start

### Calendar Events - Recurrence
- [ ] Toggle "Repeat" shows day selector
- [ ] Can select multiple days (Sun-Sat)
- [ ] Can set recurrence end date
- [ ] Events created on all selected days
- [ ] Events show time from original
- [ ] Events linked by recurrenceGroupId

### Recurring Event Deletion
- [ ] Context menu shows "Delete Event" for recurring
- [ ] Dialog shows "This Event Only" and "All Future Events"
- [ ] Single delete removes only that occurrence
- [ ] Future delete removes today + future, keeps past
- [ ] Non-recurring events delete immediately

---

## File Changes Summary

### ✅ Models.swift
- Updated CalendarEvent with endDate, recurrence fields
- Updated Goal with createdByParentName
- Added GoalCreatorType enum

### ⏳ GoalsView.swift (Needs Updates)
- AddGoalView: Add child picker for parents
- GoalCardView: Add creator badge display
- GoalApprovalSheet: Add point adjustment stepper
- Add EditGoalView for parent-created goals

### ⏳ CalendarView.swift (Needs Updates)
- AddEventView: Add endDate, recurrence UI
- AddEventView: Implement 15-min rounding
- AddEventView: Implement recurring event creation
- EventRowView: Add recurring event deletion options
- EventCardView: Show recurring indicator

### ⏳ SettingsView.swift (Needs Updates)
- ManageFamilyView: Add delete confirmation dialog
- ManageFamilyView: Handle goal cleanup on member deletion

---

## Implementation Priority

1. **High Priority:**
   - [ ] Goal creation with parent assignment
   - [ ] Point adjustment during approval
   - [ ] Calendar end date/time

2. **Medium Priority:**
   - [ ] Recurring events creation
   - [ ] Creator badges on goals
   - [ ] Delete family members with confirmation

3. **Nice to Have:**
   - [ ] Edit parent-created goals
   - [ ] Recurring event deletion options
   - [ ] Visual recurring indicators

---

## Migration Notes

**Existing Data:**
- Existing goals: `createdByParentName` will be `nil` → Creator type: "Child"
- Existing events: `endDate` will be `nil` → Defaults to startDate
- No recurrence data → `isRecurring` defaults to `false`

**Backward Compatible:** ✅ All changes are additive, no breaking changes.


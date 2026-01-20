# Calendar Day Tabs - Quick Reference Guide

## Overview

The Calendar Day Tabs feature transforms how families view their daily schedules by organizing items into three focused categories: Pickups, Events, and Deadlines.

## Tab Structure

```
┌─────────────────────────────────────────┐
│   Calendar Grid (Week/Month View)       │
├─────────────────────────────────────────┤
│  [Pickups]  [Events]  [Deadlines]       │  ← Segmented Picker
├─────────────────────────────────────────┤
│                                          │
│         Tab Content Area                 │
│                                          │
└─────────────────────────────────────────┘
```

## Pickups Tab 🚗

### What Gets Classified as a Pickup?

A `CalendarEvent` is shown in the Pickups tab if **ANY** of these conditions are true:

1. `eventType == .school`
2. Title contains (case-insensitive):
   - "pickup"
   - "pick up"
   - "dropoff"
   - "drop off"

### Visual Design

```
┌──────────────────────────────────────────┐
│  🚗   2:30 PM                            │
│       School Pickup                      │
│       👤 Assigned to: Mom                │
│       📍 Elementary School               │
└──────────────────────────────────────────┘
```

**Key Features:**
- ⏰ **Large Time Display:** Title2 font, bold weight
- 🚗 **Blue Gradient Icon:** 56x56pt, rounded rectangle
- 👤 **Assignment:** Shows who created the event
- 📍 **Location:** Pulled from notes field
- 🗑️ **Deletion:** Context menu (permission-based)

### Use Cases

- After-school pickups
- Sports practice dropoffs
- Carpool coordination
- Appointment transportation

### Example Code to Create a Pickup

```swift
let pickup = CalendarEvent(
    title: "School Pickup - Emma",
    eventDate: Date(),
    notes: "Main entrance",
    eventType: .school,
    createdByName: "Mom",
    colorHex: "#4A90E2"
)
```

---

## Events Tab 📅

### What Shows Here?

All `CalendarEvent` items that are **NOT** classified as pickups.

### Visual Design

```
┌──────────────────────────────────────────┐
│  ⚽   Soccer Practice                    │
│       6:00 PM                            │
│       [Sports]  by Dad                   │
│       Bring water bottle and cleats      │
└──────────────────────────────────────────┘
```

**Key Features:**
- 🎨 **Color-Coded Icons:** Based on event type
- 🏷️ **Type Badge:** Capsule with event category
- 👤 **Creator:** Shows who added the event
- 📝 **Notes Preview:** First 2 lines visible

### Event Type Colors

| Type     | Color  | Icon           |
|----------|--------|----------------|
| School   | Blue   | `book.fill`    |
| Sports   | Orange | `figure.run`   |
| Family   | Purple | `heart.fill`   |
| Personal | Green  | `star.fill`    |

### Use Cases

- Family dinners
- Sports games
- Social events
- Appointments
- Birthdays
- Celebrations

### Example Code

```swift
let event = CalendarEvent(
    title: "Family Movie Night",
    eventDate: Date(),
    notes: "Choose movie together",
    eventType: .family,
    createdByName: "Dad",
    colorHex: "#9B59B6"
)
```

---

## Deadlines Tab 🎯

### What Shows Here?

`Goal` items where:
1. `targetDate` matches the selected calendar date
2. `status != .completed`

### Visual Design

```
┌──────────────────────────────────────────┐
│  ⚠️   Finish Reading Assignment         │
│       👤 Emma                            │
│  ─────────────────────────────────────── │
│  📅 Due today!        ⭐ 20 pts         │
│  [Pending]                               │
└──────────────────────────────────────────┘
```

**Key Features:**
- ⚠️ **Urgency Icon:** Dynamic based on deadline proximity
- 🎨 **Color-Coded Border:** Matches urgency level
- 👤 **Owner Display:** Shows which child owns the goal
- 📅 **Smart Countdown:** "Due today!", "Overdue by 3d", etc.
- ⭐ **Points Badge:** Reward value
- 🏷️ **Status Badge:** Shows if pending/rejected

### Urgency Calculation

| Days Until | Color  | Icon                            | Text Example        |
|-----------|--------|----------------------------------|---------------------|
| < 0       | Red    | `exclamationmark.triangle.fill` | "Overdue by 3d"     |
| 0         | Red    | `exclamationmark.circle.fill`   | "Due today!"        |
| 1         | Orange | `clock.badge.exclamationmark`   | "Due tomorrow"      |
| 2         | Red    | `clock.badge.exclamationmark`   | "2 days left"       |
| 3-7       | Orange | `clock`                          | "5 days left"       |
| 8+        | Green  | `clock`                          | "10 days left"      |

### Use Cases

- Homework deadlines
- Project due dates
- Reading goals
- Habit completion targets
- Long-term goal milestones

### Example Code

```swift
let goal = Goal(
    title: "Complete Science Project",
    createdByChildName: "Emma",
    hasHabit: false,
    pointValue: 50,
    targetDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
)
goal.status = .approved
```

---

## Badge Counts

Each tab shows a count in the picker:

```
[Pickups (2)]  [Events (5)]  [Deadlines (1)]
```

**Implementation:**
- Dynamically calculated from filtered arrays
- Updates reactively as data changes
- Only shows if count > 0

---

## Empty States

### Design Philosophy
Empty states are friendly, informative, and use emojis to maintain the app's playful tone.

### Pickups Empty State
```
       🚗
No pickups scheduled for today 🚗
```

### Events Empty State
```
       📅
      No events today
```

### Deadlines Empty State
```
       🎯
   No deadlines today 🎯
```

**Visual Specs:**
- Icon: 50pt system size
- Color: `.secondary`
- Vertical spacing: 12pt
- Top padding: 40pt

---

## Filtering Logic

### Pickups Filter (Pseudocode)

```swift
func isPickup(_ event: CalendarEvent) -> Bool {
    // School events are always pickups
    if event.eventType == .school {
        return true
    }
    
    // Check title for keywords
    let title = event.title.lowercased()
    let keywords = ["pickup", "pick up", "dropoff", "drop off"]
    
    return keywords.contains { title.contains($0) }
}
```

### Events Filter

```swift
func isRegularEvent(_ event: CalendarEvent) -> Bool {
    !isPickup(event)
}
```

### Deadlines Filter

```swift
func hasDeadline(_ goal: Goal, on date: Date) -> Bool {
    guard let targetDate = goal.targetDate else { return false }
    let sameDay = Calendar.current.isDate(targetDate, inSameDayAs: date)
    let notCompleted = goal.status != .completed
    
    return sameDay && notCompleted
}
```

---

## Performance Optimizations

### Data Fetching

```swift
@Query(sort: \CalendarEvent.eventDate, order: .forward)
private var allEvents: [CalendarEvent]

@Query(sort: \Goal.targetDate, order: .forward)
private var allGoals: [Goal]
```

**Benefits:**
- Automatic SwiftData integration
- Reactive updates on data changes
- Sorted at query level (no manual sorting)

### Computed Properties

Filters are implemented as computed properties that only recalculate when dependencies change:

```swift
private var pickupEvents: [CalendarEvent] {
    // Filter logic runs only when allEvents or selectedDate changes
}
```

### Lazy Rendering

```swift
LazyVStack(spacing: 12) {
    // Only visible items are rendered
}
```

---

## Accessibility Considerations

### Dynamic Type
All text uses system fonts that scale with user preferences:
- `.title2`, `.headline`, `.subheadline`, `.caption`

### Color + Text
Never rely on color alone:
- Urgency uses icon + color + text
- Event types have icon + badge + color

### VoiceOver Labels
All interactive elements have descriptive labels:
- Tab picker announces counts
- Cards read full context
- Context menus clearly labeled

### Contrast Ratios
All color combinations meet WCAG AA standards:
- Foreground/background contrasts
- Badge colors with opacity adjustments

---

## Integration with Existing Features

### Goal Completion Flow
When a goal is marked complete:
1. `goal.status = .completed`
2. Goal automatically disappears from Deadlines tab
3. Shows up in Goal Statistics view instead

### Event Creation
When creating a new event:
1. User selects event type in `AddEventView`
2. If type is `.school`, auto-classifies as pickup
3. User can also use pickup keywords in title for manual classification

### Role-Based Permissions
Deletion permissions in context menus:
```swift
private var canDelete: Bool {
    appSettings.currentUserRole == .parent || 
    event.createdByName == appSettings.currentUserName
}
```

---

## Animation Details

### Tab Switching
```swift
Picker("Tab", selection: $selectedTab.animation()) {
    // Content
}
```

**Effect:** Smooth cross-fade when changing tabs

### State Changes
All data updates use implicit animations from SwiftUI's reactive system.

---

## Testing Scenarios

### Scenario 1: Pickup Keywords
**Steps:**
1. Create event with title "Soccer Practice Pickup"
2. Set type to `.sports` (not school)
3. Navigate to calendar
4. Select event date

**Expected:** Event appears in Pickups tab (keyword match)

### Scenario 2: Deadline Urgency
**Steps:**
1. Create goal with deadline tomorrow
2. Navigate to calendar
3. Select tomorrow's date

**Expected:** Shows orange badge with "Due tomorrow"

**Then:**
4. Wait until tomorrow
5. Reload calendar

**Expected:** Shows red badge with "Due today!"

### Scenario 3: Empty States
**Steps:**
1. Navigate to calendar
2. Select a date with no events/goals

**Expected:** All three tabs show appropriate empty states

### Scenario 4: Badge Counts
**Steps:**
1. Create 2 pickups, 3 events, 1 deadline for same day
2. Navigate to calendar
3. Select that date

**Expected:** Tabs show: Pickups (2), Events (3), Deadlines (1)

### Scenario 5: Permission-Based Deletion
**Steps:**
1. Switch to child profile
2. Navigate to calendar
3. Long-press on event created by parent

**Expected:** No delete option (unless parent role)

---

## Code Architecture

### Component Hierarchy

```
CalendarView
└── NavigationStack
    ├── Picker (Week/Month)
    ├── WeekCalendarView / MonthCalendarView
    │   ├── Calendar Grid
    │   └── CalendarDayTabsView ← NEW
    │       ├── Tab Picker
    │       └── ScrollView
    │           ├── PickupRowView[]
    │           ├── EventCardView[]
    │           └── DeadlineCardView[]
    └── Toolbar (Add Event, Today)
```

### State Management

**@Query:** Data fetching
```swift
@Query(sort: \CalendarEvent.eventDate)
private var allEvents: [CalendarEvent]
```

**@State:** Local UI state
```swift
@State private var selectedTab: CalendarDayTab = .pickups
```

**@Environment:** Shared state
```swift
@Environment(AppSettings.self) private var appSettings
@Environment(\.modelContext) private var modelContext
```

### Computed Properties
Used for derived data:
- `pickupEvents`
- `regularEvents`
- `deadlineGoals`
- `pickupCount`, `eventCount`, `deadlineCount`

---

## Customization Tips

### Adding a New Tab

1. **Update Enum:**
```swift
enum CalendarDayTab: String, CaseIterable {
    case pickups = "Pickups"
    case events = "Events"
    case deadlines = "Deadlines"
    case reminders = "Reminders" // NEW
}
```

2. **Add Filtering Logic:**
```swift
private var reminders: [SomeModel] {
    // Filter logic
}
```

3. **Update Content View:**
```swift
case .reminders:
    remindersContent
```

4. **Create Row View:**
```swift
struct ReminderRowView: View {
    // Implementation
}
```

### Changing Pickup Keywords

Modify the filter in `CalendarDayTabsView`:

```swift
private var pickupEvents: [CalendarEvent] {
    allEvents.filter { event in
        Calendar.current.isDate(event.eventDate, inSameDayAs: selectedDate) &&
        (event.eventType == .school ||
         event.title.lowercased().contains("pickup") ||
         event.title.lowercased().contains("carpool") || // NEW
         event.title.lowercased().contains("drive"))     // NEW
    }
}
```

### Adjusting Urgency Thresholds

Modify the `urgencyInfo` computed property in `DeadlineCardView`:

```swift
private var urgencyInfo: (color: Color, icon: String, text: String) {
    guard let daysRemaining = goal.daysUntilDeadline else { ... }
    
    if daysRemaining < 0 { return (.red, ...) }
    else if daysRemaining == 0 { return (.red, ...) }
    else if daysRemaining <= 1 { return (.orange, ...) } // Changed from 2
    else if daysRemaining <= 5 { return (.orange, ...) } // Changed from 7
    else { return (.green, ...) }
}
```

---

## Best Practices

### For Parents

1. **Use School Type:** Set school events to "School" type for automatic pickup classification
2. **Add Location:** Use notes field for pickup locations
3. **Assign Clearly:** Make sure child name is in title or notes
4. **Set Deadlines:** Use goal deadlines instead of just calendar events for accountability

### For Children

1. **Check Deadlines Daily:** Look at tomorrow's date to plan ahead
2. **Review Pickups:** Know when and where to be ready
3. **Mark Complete:** Update goal status when done to clear from deadlines

### For Developers

1. **Keep Filters Simple:** Complex filtering can impact performance
2. **Use Computed Properties:** Let SwiftUI handle reactivity
3. **Limit Queries:** Don't over-fetch data
4. **Test Empty States:** Ensure they're always friendly and clear
5. **Maintain Consistency:** Use FamSphere color/icon system

---

## FAQ

**Q: Why don't completed goals show in deadlines?**  
A: The filter explicitly excludes `status == .completed` to avoid clutter. Completed goals are tracked in Goal Statistics instead.

**Q: Can I have an event show in both Pickups and Events?**  
A: No, the filters are mutually exclusive. Pickups are removed from the Events tab.

**Q: What if a goal has no deadline?**  
A: It won't appear in the Deadlines tab. Only goals with `targetDate != nil` are shown.

**Q: Can children delete parent-created events?**  
A: No, the `canDelete` property checks role permissions. Children can only delete their own events.

**Q: What happens if there are 50+ events in one day?**  
A: `LazyVStack` renders only visible items, so performance remains good. Consider adding pagination or limiting display if this becomes common.

**Q: Can I customize the tab order?**  
A: Currently, tabs are in enum order. To reorder, change the enum case order in `CalendarDayTab`.

---

## Future Enhancements

### Swipe Gestures
Allow swiping between tabs instead of just tapping:

```swift
TabView(selection: $selectedTab) {
    pickupsContent.tag(CalendarDayTab.pickups)
    eventsContent.tag(CalendarDayTab.events)
    deadlinesContent.tag(CalendarDayTab.deadlines)
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

### Quick Actions
Swipe-to-action on cards:

```swift
.swipeActions(edge: .trailing) {
    Button(role: .destructive) {
        delete()
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

### Notifications
Push reminders for urgent items:

```swift
UNUserNotificationCenter.current()
    .add(request) { error in
        // Handle
    }
```

### Map Integration
Show pickup locations on a map:

```swift
import MapKit

Map(coordinateRegion: $region, annotationItems: pickups) { pickup in
    MapMarker(coordinate: pickup.coordinate)
}
```

---

## Conclusion

The Calendar Day Tabs feature is a production-ready, polished enhancement that makes FamSphere more useful for families by organizing daily activities into focused, actionable categories. It follows SwiftUI best practices, maintains the app's design language, and scales well with the existing codebase.

**Key Takeaways:**
- ✅ Three focused tabs (Pickups, Events, Deadlines)
- ✅ Smart filtering with keyword matching
- ✅ Urgency-based visual design
- ✅ Role-based permissions
- ✅ Performance-optimized
- ✅ Fully accessible
- ✅ Production-ready


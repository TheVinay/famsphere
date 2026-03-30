# Responsibility Timeline - Quick Reference Card

## 🎯 Core Concept
**Calendar → Responsibility Timeline**: Emphasizes WHO owns items, WHAT'S at stake, and WHAT happens if missed.

---

## 📋 Quick Visual Guide

### Pickups Tab 🚗
```
┌─────────────────────────────────────┐
│ [🚙]  3:00 PM                       │
│       School Pickup                 │
│       ✓ Handled by Dad (BLUE)      │
│       📍 Main entrance              │
└─────────────────────────────────────┘
```

**Missed Pickup:**
```
┌─────────────────────────────────────┐ ← RED BORDER
│ [🚗] ⚠️ MISSED                      │ ← RED ICON
│       3:00 PM (RED)                 │
│       School Pickup                 │
│       ✓ Handled by Dad (BLUE)      │
└─────────────────────────────────────┘
```

### Events Tab 📅
```
┌─────────────────────────────────────┐
│ [⚽] Soccer Practice                │
│      5:00 PM                        │
│      [Sports] 👤 Added by Mom      │
│      Bring water bottle             │
└─────────────────────────────────────┘
```

### Deadlines Tab 🎯
```
┌─────────────────────────────────────┐
│ [⚠️] Complete Homework              │
│       ✓ Owned by Emma (BLUE)       │
│                                     │
│  📅 2 days left  |  ⭐ 20 pts      │
│                                     │
│  ⚠️ Streak at risk                 │ ← CONSEQUENCE
│  💡 Keep your streak alive         │ ← MOTIVATIONAL HINT
└─────────────────────────────────────┘
```

---

## 🔑 Key Code Patterns

### Ownership Display
```swift
// Pickups
HStack(spacing: 4) {
    Image(systemName: "person.fill.checkmark")
    Text("Handled by \(event.createdByName)")
}
.foregroundStyle(.blue)
.fontWeight(.medium)

// Events
HStack(spacing: 3) {
    Image(systemName: "person.circle.fill")
    Text("Added by \(event.createdByName)")
}
.foregroundStyle(.secondary)

// Deadlines
HStack(spacing: 4) {
    Image(systemName: "person.fill.checkmark")
    Text("Owned by \(goal.createdByChildName)")
}
.foregroundStyle(.blue)
.fontWeight(.medium)
```

### Missed Pickup Detection
```swift
private var isMissed: Bool {
    event.eventDate < Date()
}

// Icon gradient
LinearGradient(
    colors: isMissed ? [.red, .red.opacity(0.7)] : [.blue, .blue.opacity(0.7)]
)

// Red border overlay
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(isMissed ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2)
)
```

### Consequence Logic
```swift
private var consequenceText: String? {
    guard let daysRemaining = goal.daysUntilDeadline else { return nil }
    
    if daysRemaining < 0 {
        return "Overdue – progress impacted"
    } else if daysRemaining <= 2 && goal.currentStreak > 0 {
        return "Streak at risk"
    } else if daysRemaining <= 7 && goal.pointValue > 0 {
        return "Points on the line: ⭐ \(goal.pointValue)"
    }
    
    return nil
}
```

### Role-Aware Messaging
```swift
private var motivationalHint: String? {
    guard let daysRemaining = goal.daysUntilDeadline,
          daysRemaining >= 0, daysRemaining <= 7 else { return nil }
    
    if isSingleChild {
        // Self-progress focus
        return goal.currentStreak > 0 ? 
            "Chance to extend your streak" : 
            "Finish strong today"
    } else {
        // Team support focus
        return goal.currentStreak > 0 ? 
            "Keep your streak alive" : 
            "Stay on track"
    }
}
```

### Parameter Passing Chain
```swift
CalendarView
    ↓ isSingleChild: Bool
WeekCalendarView / MonthCalendarView
    ↓ isSingleChild: Bool
CalendarDayTabsView
    ↓ isSingleChild: Bool
DeadlineCardView
```

---

## 🎨 Visual Elements

### Icons
| Element | Icon | Color |
|---------|------|-------|
| Pickup owner | `person.fill.checkmark` | Blue |
| Event owner | `person.circle.fill` | Secondary |
| Deadline owner | `person.fill.checkmark` | Blue |
| Missed pickup | `exclamationmark.triangle.fill` | White on red |
| Consequence | `exclamationmark.triangle.fill` | White on red/orange |
| Motivational hint | `lightbulb.fill` | Orange |

### Badge Styles
```swift
// Ownership (Pickups/Deadlines)
.foregroundStyle(.blue)
.fontWeight(.medium)

// Missed Badge
.foregroundStyle(.white)
.background(Color.red)
.clipShape(Capsule())

// Consequence Badge
.foregroundStyle(.white)
.background(urgencyInfo.color) // red/orange
.clipShape(Capsule())

// Motivational Hint Badge
.foregroundStyle(.orange)
.background(Color.orange.opacity(0.15))
.clipShape(Capsule())
```

---

## 📊 Consequence Matrix

| Days Remaining | Streak? | Points? | Consequence Text | Color |
|---------------|---------|---------|------------------|-------|
| < 0 | - | - | "Overdue – progress impacted" | Red |
| 0-2 | Yes | - | "Streak at risk" | Red |
| 0-7 | - | Yes | "Points on the line: ⭐ X" | Orange/Red |
| > 7 | - | - | None | - |

---

## 🧪 Quick Test Commands

```swift
// Test missed pickup
let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
let pickup = CalendarEvent(
    title: "School Pickup",
    eventDate: pastDate,
    eventType: .school,
    createdByName: "Dad",
    colorHex: "#4A90E2"
)

// Test overdue deadline
let goal = Goal(
    title: "Homework",
    createdByChildName: "Emma",
    targetDate: Date().addingTimeInterval(-86400) // 1 day ago
)

// Test single-child detection
let children = familyMembers.filter { $0.role == .child }
let isSingleChild = children.count == 1
```

---

## 🚫 What NOT to Change

❌ **DO NOT modify:**
- Data models (CalendarEvent, Goal)
- Business logic (streak calculations, points)
- Filtering algorithms
- Tab structure
- Navigation flow
- Add/delete event logic

✅ **ONLY modify:**
- Display text and labels
- Visual styling (colors, badges, icons)
- Conditional display logic
- UI hierarchy within row views

---

## 📝 Common Tasks

### Add a new consequence type
```swift
// In DeadlineCardView
private var consequenceText: String? {
    // ... existing logic ...
    
    // Add new condition
    else if daysRemaining <= 5 && goal.milestones.isEmpty {
        return "No milestones set"
    }
    
    return nil
}
```

### Change ownership styling
```swift
// In PickupRowView/DeadlineCardView
HStack(spacing: 4) {
    Image(systemName: "person.fill.checkmark")
    Text("Handled by \(event.createdByName)")
}
.foregroundStyle(.blue) // Change color here
.fontWeight(.medium)    // Change weight here
```

### Add motivational hint variant
```swift
// In DeadlineCardView
private var motivationalHint: String? {
    // ... existing logic ...
    
    // Add new variant
    if isSingleChild && goal.completedDates.count >= 10 {
        return "You're on a roll!"
    }
    
    return nil
}
```

---

## 🐛 Common Issues

### Issue: isSingleChild not working
**Fix:** Ensure parameter is passed through entire chain:
```swift
CalendarView → WeekCalendarView → CalendarDayTabsView → DeadlineCardView
```

### Issue: Missed pickup not showing red
**Fix:** Check time comparison:
```swift
private var isMissed: Bool {
    event.eventDate < Date() // Must be less than NOW
}
```

### Issue: Consequence not showing
**Fix:** Check conditions:
```swift
// Must have targetDate
guard let daysRemaining = goal.daysUntilDeadline else { return nil }

// Must be within range
if daysRemaining < 0 || daysRemaining <= 7 { ... }
```

### Issue: Preview not loading
**Fix:** Update preview with required parameter:
```swift
#Preview {
    CalendarDayTabsView(
        selectedDate: Date(),
        selectedTab: .constant(.events),
        isSingleChild: false // ADD THIS
    )
}
```

---

## 📚 Related Files

- `CalendarView.swift` - Main implementation
- `RESPONSIBILITY_TIMELINE_REFACTOR.md` - Full technical docs
- `TESTING_RESPONSIBILITY_TIMELINE.md` - Test guide
- `IMPLEMENTATION_COMPLETE.md` - Summary
- `README.md` - Updated project overview

---

## 🎓 Philosophy Reminder

> "This shows what matters today — who owns it, and what it affects."  
> **NOT:** "Just what's on the schedule."

**Ownership First. Consequences Clear. Context-Aware.**

---

## ✅ Checklist for New Features

Before adding anything to the Responsibility Timeline:

- [ ] Does it emphasize ownership?
- [ ] Does it show consequences or impact?
- [ ] Is it context-aware (single vs multi-child)?
- [ ] Is it display logic only (no data model changes)?
- [ ] Does it differentiate from Apple/Google calendars?
- [ ] Is it lightweight and focused?
- [ ] Does it preserve existing functionality?

If all yes → proceed. If any no → reconsider approach.

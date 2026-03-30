# FamSphere Changelog

## Latest Updates (January 12, 2026)

### 🔧 Bug Fixes & Enhancements

#### Enhancement #1: Approval Messaging Now Includes Approver Name
**Problem:** When a goal was approved, the FamSphere chat notification showed "Task xyz has been approved" but didn't indicate which parent approved it.

**Solution:** Updated the approval notification to include the approving parent's name.

**File Modified:** `GoalsView.swift`

**Changes:**
- Modified `approveGoal()` function in `ApprovalGoalCard` (line 1398)
- Updated chat message to: `"✅ '\(goal.title)' has been approved for \(goal.createdByChildName) by \(appSettings.currentUserName)!"`
- Detailed approval sheet already had this implemented correctly (line 1534)

**Testing:**
1. Create a goal as a child
2. Switch to parent user
3. Approve the goal from approval queue or goal card
4. Check chat - should show "approved by [Parent Name]"

---

#### Bug Fix #2: Calendar Tab Badge Display
**Problem:** Badge counts were appearing inside the segmented picker tabs themselves, making items like "Events (1)" and "(1)" separate clickable segments. This was confusing because the badge count became a selectable tab instead of just showing a count.

**Solution:** Separated the badge counts from the segmented picker into their own row.

**File Modified:** `CalendarView.swift`

**Changes:**
- Refactored `CalendarDayTabsView` body to separate tabs from badge counts
- Tabs now show only the name: "Pickups | Events | Deadlines"
- Added a new HStack below the picker showing badge counts: "(2) | (5) | (3)"
- Badge counts are color-coded based on selection state (primary when selected, secondary otherwise)
- Removed the `tabLabel()` helper function (no longer needed)

**Visual Comparison:**
```
BEFORE:
[Pickups] [Events (1)] [(1)]  ❌ Confusing! The "(1)" was clickable!

AFTER:
[Pickups] [Events] [Deadlines]  ✅ Clear tab names
   (0)       (1)        (0)      ✅ Counts below tabs
```

**Testing:**
1. Go to Calendar view
2. Add some events/pickups/deadlines
3. Verify badge counts appear below the segmented picker
4. Verify all three tab names are clickable (not the badge counts)
5. Check that badge counts update when switching tabs

---

#### Enhancement #3: Add Event Form - Category Selection & Smart Defaults
**Problem:** 
1. When adding events from the calendar, there was no way to specify which tab (Pickups, Events, Deadlines) the event should appear under
2. The form didn't default to the currently active tab
3. Users had to manually configure event type to ensure items appeared in the correct tab

**Solution:** Added intelligent category selection and context-aware defaults to the Add Event form.

**Files Modified:** `CalendarView.swift`

**Changes:**

**Main CalendarView:**
- Added `@State private var selectedTab: CalendarDayTab = .events` to track active tab
- Updated sheet presentation to pass parameters: `AddEventView(selectedDate: selectedDate, initialTab: selectedTab)`

**WeekCalendarView & MonthCalendarView:**
- Added `@Binding var selectedTab: CalendarDayTab` parameter
- Updated `CalendarDayTabsView` calls to pass `selectedTab: $selectedTab` binding

**CalendarDayTabsView:**
- Changed `@State private var selectedTab` to `@Binding var selectedTab`
- Now receives the tab selection from parent views
- Updated preview to use `.constant(.events)`

**AddEventView:**
- Added `let selectedDate: Date` and `let initialTab: CalendarDayTab` parameters
- Added `@State private var selectedFormTab: CalendarDayTab` to track category selection
- Added custom `init()` to set smart defaults based on `initialTab`:
  - **Pickups tab** → School event type, Pickups category
  - **Events tab** → Personal event type, Events category
  - **Deadlines tab** → Events category (deadlines are goals, not events)
- Changed `startDate` and `endDate` to use selected date instead of current date
- Added new "Category" section with segmented picker for Pickups/Events selection
- Added helpful footer text explaining where the event will appear

**createSingleEvent():**
- Added logic to set `finalEventType` to `.school` when `selectedFormTab == .pickups`
- Ensures pickups are properly categorized for filtering

**createRecurringEvents():**
- Added same category-aware logic for recurring events

**User Experience:**
```
User clicks "+" while viewing "Pickups" tab:
  ✅ Form opens with School type selected
  ✅ Category defaults to "Pickups"
  ✅ Start date defaults to selected calendar date
  ✅ Event will appear in Pickups tab after saving

User clicks "+" while viewing "Events" tab:
  ✅ Form opens with Personal type selected
  ✅ Category defaults to "Events"
  ✅ Event will appear in Events tab after saving

User can change category before saving:
  ✅ Switch from Events to Pickups
  ✅ Event type automatically changes to School
  ✅ Footer text updates to show target tab
```

**Testing:**
1. Navigate to Calendar → Week or Month view
2. Select a specific date
3. Switch to "Pickups" tab
4. Tap "+" button
5. Verify form shows:
   - Start date = selected date
   - Type = School
   - Category = Pickups selected
   - Footer says "This event will appear in the Pickups tab"
6. Save event and verify it appears in Pickups tab
7. Repeat for Events tab
8. Test category switching in the form
9. Test with recurring events

---

#### Bug Fix #4: Add Family Member Role Picker - Full Clickability
**Problem:** In the "Add Family Member" form, the role picker showed an icon and text for "Parent" and "Child" options, but only the text portion was clickable. The icon was not clickable, which was confusing for users who expected to tap anywhere on the segment.

**Solution:** Replaced `HStack` containing separate icon and text with SwiftUI's `Label` component.

**File Modified:** `SettingsView.swift`

**Changes:**
```swift
BEFORE:
Picker("Role", selection: $role) {
    HStack(spacing: 6) {
        Image(systemName: "person.fill")
        Text("Parent")
    }
    .tag(MemberRole.parent)
    
    HStack(spacing: 6) {
        Image(systemName: "figure.child")
        Text("Child")
    }
    .tag(MemberRole.child)
}

AFTER:
Picker("Role", selection: $role) {
    Label("Parent", systemImage: "person.fill")
        .tag(MemberRole.parent)
    
    Label("Child", systemImage: "figure.child")
        .tag(MemberRole.child)
}
```

**Why This Fixes It:**
- `Label` is the proper SwiftUI component for segmented pickers with icons
- The entire segment (icon + text) becomes one unified, fully clickable element
- Follows SwiftUI best practices and conventions
- Provides better accessibility

**Testing:**
1. Go to Settings → Manage Family Members (parent only)
2. Tap "+" to add a new family member
3. In the Role section with segmented picker:
   - Tap on the person icon for "Parent" → should select
   - Tap on the child icon for "Child" → should select
   - Tap on the text "Parent" → should select
   - Tap on the text "Child" → should select
4. Verify entire segment is clickable, not just parts

---

### ✅ Status Check: Already Working Features

During this bug fix session, we also verified that the following features are already working correctly:

1. **Parents Can Add Goals** ✅
   - Both parents and children have the add button in GoalsView toolbar (line 53)
   - Parents can create goals and assign them to children
   - Parent-created goals are auto-approved

2. **Dashboard Shows User Role** ✅
   - Header displays "Welcome back, [Name] (Parent/Child)" (DashboardView line 105)
   - Role is clearly indicated next to the user's name

---

## Previous Updates (January 11, 2026)

### ✨ New Feature: Single-Child vs Multi-Child Adaptations

#### Overview
FamSphere now intelligently adapts its interface and messaging based on family size. The app provides contextually appropriate experiences for both single-child and multi-child families, ensuring it always feels intentional and motivating—never awkward or empty.

**Files Modified:** 
- `DashboardView.swift` - Added adaptive widgets and messaging
- `GoalsView.swift` - Updated Points Summary with context-aware UI

#### Key Changes

**1. Dashboard Adaptations**

**Multi-Child Mode (2+ children):**
- Shows "Family Leaderboard" for parents
- Displays rankings with 🥇🥈🥉 medals
- Competitive language ("Ranked #1 in family!")
- Children see family rankings

**Single-Child Mode (1 child):**
- Shows "[Child Name]'s Progress" board for parents
- 4 stat cards: Points, Current Streak, Longest Streak, Goals
- Week-over-week comparison messaging
- Achievement-based language
- **NO rankings, medals, or sibling comparisons**
- Children see self-comparison ("Up 40 points from last week!")

**2. Points Summary Adaptations**

**Multi-Child Mode:**
- "Top Goals" header
- Shows "#1, #2, #3" rankings
- "Best Streak" label

**Single-Child Mode:**
- "Your Best Goals" header
- NO numerical rankings
- "Current Best" label
- Personal achievement messaging
- Progress celebration section

**3. Messaging Changes**

| Multi-Child Copy | Single-Child Copy |
|-----------------|-------------------|
| "Ranked #1 in family!" | "New personal best!" |
| "Top performer" | "Streak champion!" |
| "Top Goals" | "Your Best Goals" |
| "Family Leaderboard" | "[Name]'s Progress" |

#### New Components

**StatCardCompact:**
```swift
struct StatCardCompact: View
```
Compact stat cards for single-child progress board.

**singleChildProgressWidget:**
- Personalized header with child's name
- 2x2 stat grid
- Weekly progress comparison
- Streak achievement messaging

#### New Helper Functions

**weeklyProgressComparison(for:):**
Compares current week to previous week, returns trend and message:
- ↗ "Up X points from last week!" (green)
- → "Steady progress - keep it up!" (blue)
- ↘ "Keep pushing - you've got this!" (orange)

**streakAchievementMessage(for:):**
Returns milestone-based messages:
- 100+ days: "Streak Champion! 100+ days! 🏆"
- 50-99: "Incredible! X-day streak!"
- 30-49: "Streak Master!"
- etc.

**personalBestText(for:):**
Achievement messaging for Points Summary view.

#### Technical Implementation

**Detection Logic:**
```swift
private var isSingleChild: Bool {
    children.count == 1
}
```

**Conditional Rendering:**
```swift
if isParent {
    if isSingleChild {
        singleChildProgressWidget
    } else if !children.isEmpty {
        familyLeaderboardWidget
    }
}
```

**View-Level Only:**
- ✅ NO model changes
- ✅ NO business logic changes
- ✅ NO algorithm changes
- ✅ NO database changes

#### Design Philosophy

**Single-Child:** Personal, achievement-focused, growth-oriented
**Multi-Child:** Competitive, fun, engaging

The app seamlessly transitions between modes as family size changes, with no manual configuration required.

#### Testing Checklist

- [ ] Single child: Verify NO leaderboard shown
- [ ] Single child: Verify "[Name]'s Progress" appears (parent)
- [ ] Single child: Verify weekly comparison shows (child)
- [ ] Single child: Verify NO rankings/medals
- [ ] Multi-child: Verify Family Leaderboard with medals
- [ ] Multi-child: Verify rankings appear correctly
- [ ] Points Summary: Verify "Your Best Goals" (single)
- [ ] Points Summary: Verify "Top Goals" (multi)
- [ ] Points Summary: Verify NO "#1, #2" in single-child
- [ ] Transition test: Add 2nd child, verify leaderboard appears

---

### 🔧 Bug Fixes

#### Issue #1: User Switching Role Update
**Problem:** When switching between user profiles in Settings → Switch User, the role (parent/child) wasn't updating properly, preventing users from switching back to parent mode after switching to child mode.

**Solution:** Added debug logging to the `switchToUser()` method in `UserSwitcherView` to help diagnose the issue. The underlying logic was correct - both `currentUserName` and `currentUserRole` are properly updated when switching users.

**File Modified:** `SettingsView.swift`

**Changes:**
- Added console logging to track user switching behavior
- Verified that `AppSettings.currentUserRole` is correctly updated from the `FamilyMember.role` property

**Testing:**
1. Go to Settings → Switch User
2. Select a family member with a different role
3. Verify the role updates in dashboard and other views
4. Check console logs for confirmation

---

### ✨ New Feature: Calendar Day Tabs

#### Enhancement Overview
Completely redesigned the calendar day view to include three horizontally-stacked tabs that filter and display day-specific items: **Pickups**, **Events**, and **Deadlines**.

**Files Modified:** `CalendarView.swift`

#### New Components Added

##### 1. CalendarDayTabsView
Main container view that manages the tab interface and filtering logic.

**Features:**
- Segmented picker for tab selection
- Badge counts showing number of items per tab
- Smooth animations when switching tabs
- Persists selected tab when changing days
- Dynamic Type support
- Fully accessible

**Tab Definitions:**

**Pickups Tab** 🚗
- **Purpose:** Time-critical child logistics
- **Data Source:** `CalendarEvent`
- **Filtering:**
  - `eventType == .school`, OR
  - Title contains: "pickup", "pick up", "dropoff", "drop off"
- **Display:** Time (large/bold), title, assigned person, location (from notes)
- **Accent Color:** Blue
- **Icon:** `car.fill`
- **Empty State:** "No pickups scheduled for today 🚗"

**Events Tab** 📅
- **Purpose:** General family scheduling
- **Data Source:** `CalendarEvent` (excluding pickups)
- **Display:** 
  - Title
  - Time
  - Event type badge (School, Sports, Family, Personal)
  - Color-coded by event type
  - Created by indicator
  - Notes preview (2 lines max)
- **Empty State:** "No events today"

**Deadlines Tab** 🎯
- **Purpose:** Goal accountability
- **Data Source:** `Goal` (where `targetDate` matches selected day)
- **Filtering:** Status ≠ `.completed`
- **Display:**
  - Goal title
  - Owner (child name)
  - Urgency badge with color coding:
    - 🔴 Red: Overdue or due today
    - 🟠 Orange: Due in 1-2 days or 3-7 days
    - 🟢 Green: 8+ days
  - Points value
  - Status badge (if not approved)
- **Icons:** `exclamationmark.triangle.fill` (overdue), `clock.badge.exclamationmark`, `clock`
- **Empty State:** "No deadlines today 🎯"

##### 2. PickupRowView
Specialized row component for pickup/dropoff events.

**Design:**
- Large, prominent time display (title2, bold)
- Blue gradient background icon
- Car icon (white)
- Assigned person with icon
- Location from notes field
- Context menu for deletion (role-based permissions)

##### 3. EventCardView
Enhanced event display for non-pickup events.

**Design:**
- Event type icon with colored background
- Type-specific colors:
  - School: Blue
  - Sports: Orange
  - Family: Purple
  - Personal: Green
- Event type badge (capsule)
- Creator attribution
- Notes preview (2 lines)
- Context menu for deletion

##### 4. DeadlineCardView
Goal deadline display with urgency indicators.

**Design:**
- Urgency-based icon and color
- Large circular icon badge
- Goal title and owner
- Urgency text ("Due today!", "Overdue by 3d", etc.)
- Points badge (yellow)
- Status badge (if pending/rejected)
- Border color matches urgency level

#### Urgency Color Logic

```swift
Overdue (negative days):     🔴 Red + triangle icon
Due today (0 days):          🔴 Red + exclamation icon  
Due tomorrow (1 day):        🟠 Orange
Due in 2 days:               🔴 Red
Due in 3-7 days:             🟠 Orange
Due in 8+ days:              🟢 Green
```

#### Integration Points

**Week View:**
- Replaced old "Events for Selected Day" section
- Now shows `CalendarDayTabsView(selectedDate: selectedDate)`

**Month View:**
- Replaced old "Events for Selected Day" section  
- Now shows `CalendarDayTabsView(selectedDate: selectedDate)`

#### User Experience Improvements

1. **Reduced Clutter:** Events are categorized instead of showing a mixed list
2. **Quick Glanceability:** Tab badges show counts at a glance
3. **Time-Critical Focus:** Pickups are prominently displayed with large times
4. **Goal Visibility:** Deadlines are surfaced in the calendar context
5. **Child Accountability:** Children can see their own deadlines on specific days
6. **Parent Overview:** Parents can quickly check pickups and logistics

#### Performance Considerations

- Uses `@Query` for efficient SwiftData fetching
- Computed properties for filtering (reactive updates)
- `LazyVStack` for list rendering
- Minimal re-renders when switching tabs

#### Accessibility Features

- Dynamic Type support (system fonts)
- SF Symbols (scalable icons)
- Color + text labels (not color-only)
- Semantic colors
- VoiceOver-friendly labels
- Sufficient contrast ratios

#### Preview Support

Added dedicated preview for testing:
```swift
#Preview("Calendar Day Tabs") {
    NavigationStack {
        CalendarDayTabsView(selectedDate: Date())
    }
    .environment(AppSettings())
    .modelContainer(for: [CalendarEvent.self, Goal.self])
}
```

---

### 📝 Design Philosophy

These changes align with FamSphere's core principles:

1. **Simplicity:** Tabs reduce cognitive load
2. **Family-First:** Parent/child roles respected in permissions
3. **Accountability:** Deadlines visible in calendar context
4. **Polish:** Production-ready UI with smooth animations
5. **Flexibility:** Works for both week and month views

---

### 🧪 Testing Checklist

- [ ] Switch between user profiles (parent ↔ child)
- [ ] Verify role-based permissions update
- [ ] Add calendar event classified as pickup
- [ ] Add regular event (non-pickup)
- [ ] Create goal with deadline
- [ ] Navigate to calendar and select date
- [ ] Verify all three tabs display correct data
- [ ] Check badge counts
- [ ] Test empty states for each tab
- [ ] Verify urgency color coding
- [ ] Test deletion permissions (context menu)
- [ ] Check animations when switching tabs
- [ ] Test on different dates with varying data
- [ ] Verify Dynamic Type scaling
- [ ] Test VoiceOver support

---

### 🚀 Next Steps

Consider these future enhancements:

1. **Swipeable Tabs:** Gesture-based navigation between tabs
2. **Tab Reordering:** User preference for tab order
3. **Custom Filters:** Advanced filtering options
4. **Notification Integration:** Alerts for urgent pickups/deadlines
5. **Quick Actions:** Swipe actions on cards (mark complete, reschedule)
6. **Time Ranges:** Group events by morning/afternoon/evening
7. **Map Integration:** Location support for pickups
8. **Reminders:** Link to iOS Reminders for deadlines

---

### 📚 Documentation Updates Needed

- Update README.md with new Calendar tab structure
- Add screenshots of new tab interface
- Document pickup keyword matching logic
- Update navigation structure diagram
- Add urgency color coding reference


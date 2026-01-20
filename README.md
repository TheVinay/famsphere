# FamSphere - Family Organization & Engagement App

## 🆕 Quick Reference - Latest Features

### Searchable Family Chat Record (Jan 13, 2026) 💬
**What:** Chat enhanced as a searchable family record for decisions and memories

**Tagline:** *"Chat, decisions, and memories — searchable in one place"*

**Three Core Features:**

1. **Chat Search** 🔍
   - Full-text search with `.searchable()`
   - Matches: Messages, author names, system notifications, goal titles
   - Live filtering with yellow highlighting
   - Empty state: "No messages match 'food'"

2. **System vs Family Distinction** 🔵
   - System messages (FamSphere) centered with blue styling
   - Family messages (users) left/right with standard bubbles
   - Filter picker: All | System | Family
   - Keeps them in same stream

3. **Pin Important Messages** 📌
   - Long-press to pin/unpin
   - Pinned section at top
   - Persists across sessions
   - Use for: Rules, reminders, instructions, decisions

**Key Philosophy:**
- NOT another chat app
- A family memory and accountability log
- Purposeful, retrievable communication
- NO reactions, stickers, or typing indicators

**See:** `CHAT_ENHANCEMENTS.md` for complete documentation

---

### Responsibility Timeline (Jan 13, 2026) 🎯
**What:** Calendar transformed into an accountability-focused timeline

**Navigation:** "Responsibility Timeline" (was "Family Calendar")

**Three Tabs:** Pickups 🚗 | Events 📅 | Deadlines 🎯

**Ownership-First:**
- Pickups: "Handled by [Parent]" + missed detection (red if past)
- Events: "Added by [Name]"
- Deadlines: "Owned by [Child]" + consequences + role-aware hints

**Consequences (Deadlines only):**
- "Streak at risk" (≤2 days, has streak)
- "Points on the line: ⭐ X" (≤7 days, has points)
- "Overdue – progress impacted" (past due)

**Role-Aware Hints:**
- Single-child: "Finish strong today"
- Multi-child: "Stay on track"

**Key:** Focus on WHO owns it, WHAT's at stake, and WHAT happens if missed

### Calendar Day Tabs with Smart Category Selection
**Three Tabs:** Pickups 🚗 | Events 📅 | Deadlines 🎯

**Smart Filtering:**
- Pickups: School events + keyword matching ("pickup", "dropoff")
- Events: All non-pickup calendar events
- Deadlines: Goals with targetDate matching selected day

**Add Event Form:** Category selector defaults to your active tab

**Key Components:**
- `CalendarDayTabsView` - Tab container with separated badge counts
- `AddEventView` - Accepts `initialTab` parameter for smart defaults
- `PickupRowView`, `EventCardView`, `DeadlineCardView` - Row displays

### Single-Child vs Multi-Child Adaptations
**Detection:** `isSingleChild: Bool { children.count == 1 }`

**Multi-Child (2+):** Leaderboard, rankings, medals, competitive language
**Single-Child (1):** Personal progress board, weekly comparison, achievement messaging

**Key Components:**
- `singleChildProgressWidget` - New parent widget for solo child
- `weeklyProgressComparison(for:)` - Week-over-week trend calculator
- `streakAchievementMessage(for:)` - Milestone-based messaging

### Recent Bug Fixes & Updates
- ✅ **Jan 13, 2026:** Calendar refined as Responsibility Timeline (ownership & accountability focus)
- ✅ **Jan 12, 2026:** Approval messages now include approver name
- ✅ **Jan 12, 2026:** Calendar tab badges display correctly below tabs (not inside them)
- ✅ **Jan 12, 2026:** Add Event form defaults to active tab category
- ✅ **Jan 12, 2026:** Add Family Member role picker fully clickable (icon + text)

---

## Previous Updates (January 12, 2026)

### 🔧 Bug Fixes & Enhancements

#### 1. Approval Messaging Enhancement
**Issue:** When a goal was approved, the chat notification didn't include who approved it.

**Fix:** Updated approval notifications to include the parent's name who approved the goal.
- **Before:** "✅ '[Goal Title]' has been approved for [Child Name]!"
- **After:** "✅ '[Goal Title]' has been approved for [Child Name] by [Parent Name]!"

**Files Modified:** `GoalsView.swift` (Line 1398)

#### 2. Calendar Tab Badge Display Fix
**Issue:** Badge counts were appearing inside the segmented picker tabs, making "Events (1)" a single clickable item instead of just "Events" being clickable.

**Fix:** Separated badge counts from the segmented picker.
- Tabs now show clean labels: "Pickups | Events | Deadlines"
- Badge counts appear in a separate row below: "(2) | (5) | (3)"
- Badges are color-coded based on tab selection

**Files Modified:** `CalendarView.swift` (CalendarDayTabsView body)

**Visual Before/After:**
```
Before: [Pickups] [Events (1)] [(1)]  ❌ Confusing!
After:  [Pickups] [Events] [Deadlines]  ✅ Clear!
             (0)      (1)        (0)
```

#### 3. Add Event Form - Category Selection
**Issue:** When adding events from the calendar, there was no way to specify which tab the event should appear under, and the form didn't default to the currently active tab.

**Fix:** Added intelligent category selection to the Add Event form.
- Form now accepts `selectedDate` and `initialTab` parameters
- Automatically defaults to the tab you were viewing
- New "Category" section with Pickups/Events picker
- Smart defaults based on context:
  - **Pickups tab** → School event type, Pickups category
  - **Events tab** → Personal event type, Events category
  - **Deadlines tab** → Events category (deadlines are goals)
- When selecting "Pickups" category, automatically sets event type to `.school`
- Helpful footer text explains where the event will appear

**Files Modified:** `CalendarView.swift`
- Added `selectedTab` state to main `CalendarView`
- Updated `WeekCalendarView` and `MonthCalendarView` to accept `selectedTab` binding
- Refactored `AddEventView` with new initialization logic
- Updated `createSingleEvent()` and `createRecurringEvents()` to respect category selection

**User Experience:**
- Click add button while on "Pickups" tab → form opens with School type and Pickups category selected
- Click add button while on "Events" tab → form opens with Personal type and Events category selected
- Can change category in the form before saving
- Event appears in the correct tab after creation

#### 4. Add Family Member Role Picker Fix
**Issue:** In the "Add Family Member" form, the role picker showed icon + text for "Parent" and "Child", but only the text was clickable, not the icon. This was confusing for users.

**Fix:** Changed from `HStack` with separate icon and text to using SwiftUI's `Label` component.
- **Before:** `HStack { Image(...) Text("Parent") }` - only text clickable
- **After:** `Label("Parent", systemImage: "person.fill")` - entire segment clickable
- Both icon and text are now part of a single, fully clickable segment
- Consistent with SwiftUI best practices for segmented pickers

**Files Modified:** `SettingsView.swift` (AddFamilyMemberView, Role Section)

---

## Latest Updates (January 13, 2026)

### 🎯 Calendar → Responsibility Timeline Refactor

**Vision:** Transformed the calendar from a generic scheduling tool into an accountability-focused **Responsibility Timeline** that emphasizes ownership, consequences, and context.

**Core Reframe:** The calendar now answers: *"Who is responsible, what's at stake, and what happens if this is missed?"*

#### Changes Overview

**1. Navigation Title**
- Changed from "Family Calendar" to "Responsibility Timeline"
- Sets the tone: this is about accountability, not just scheduling

**2. Ownership-First Presentation (All Tabs)**

**Pickups Tab:**
- Now shows "Handled by [Parent Name]" with checkmark icon (`person.fill.checkmark`)
- Blue color, medium weight, prominent placement
- **Missed pickup detection:**
  - Red gradient icon (instead of blue)
  - "Missed" badge with triangle icon
  - Red time text + red border
  - Visual flag for `eventDate < now`

**Events Tab:**
- Now shows "Added by [Name]" with `person.circle.fill` icon
- Clear attribution for who created each event
- No consequences shown (keeps noise low)

**Deadlines Tab:**
- Now shows "Owned by [Child Name]" with checkmark icon
- Blue color, prominent ownership context
- **Consequence awareness** - Smart hints based on urgency:
  - **Overdue:** "Overdue – progress impacted"
  - **≤2 days + has streak:** "Streak at risk"
  - **≤7 days + has points:** "Points on the line: ⭐ X"

**3. Role-Aware Motivational Messaging**

Adapts based on family size (reuses `isSingleChild` detection):

**Single-Child Families:**
- "Chance to extend your streak"
- "Finish strong today"
- Focus: Personal growth

**Multi-Child Families:**
- "Keep your streak alive"
- "Stay on track"
- Focus: Team support

**4. What Was NOT Added (Intentionally)**

Calendar remains lightweight and focused:
- ❌ No invites/RSVP
- ❌ No external calendar sync
- ❌ No full-day grid complexity
- ❌ No push notifications
- Stays: Day-focused, contextual, family-oriented

#### Technical Implementation

**Display Logic Only:**
- No data model changes
- No business logic changes
- ~150 lines modified in row views
- Reuses existing `isSingleChild` detection from Dashboard

**Files Modified:**
- `CalendarView.swift` - All enhancements in row views (PickupRowView, EventCardView, DeadlineCardView)

**Key Principle:**
*"This shows what matters today — who owns it, and what it affects."*  
**NOT:** *"Just what's on the schedule."*

**See also:** `RESPONSIBILITY_TIMELINE_REFACTOR.md`, `TESTING_RESPONSIBILITY_TIMELINE.md`, `VISUAL_DESIGN_SPEC.md`

---

## Previous Updates (January 12, 2026)

### ✨ Single-Child vs Multi-Child Adaptations
FamSphere now intelligently adapts its interface based on family size. Single-child families see **personal progress tracking** with self-comparison, while multi-child families see **competitive leaderboards** with rankings and medals. The app seamlessly transitions between modes with no configuration needed.

### ✨ Calendar Day Tabs
Calendar now features three horizontally-stacked tabs: **Pickups** 🚗 (time-critical logistics), **Events** 📅 (general scheduling), and **Deadlines** 🎯 (goal accountability). Smart filtering with keyword matching and urgency-based color coding.

### 🔧 Bug Fix: User Profile Switching
Fixed role updating when switching between family member profiles in Settings.

---

## Project Overview

FamSphere is a comprehensive family organization and engagement app built with SwiftUI and SwiftData. It helps families stay connected through goals tracking, messaging, calendar events, and gamification features. The app supports both parent and child user roles with different permissions and views.

**Key Differentiator:** Intelligently adapts interface for single-child vs multi-child families, ensuring motivating experiences regardless of family size.

## Core Architecture

### Data Models (`Models.swift`)

#### 1. **FamilyMember**
- Properties: `name`, `role` (parent/child), `colorHex`
- Used for user management within families

#### 2. **ChatMessage**
- Properties: `content`, `timestamp`, `authorName`, `isImportant`
- Supports family messaging with important message flagging

#### 3. **CalendarEvent**
- Properties: `title`, `eventDate`, `notes`, `eventType`, `createdByName`, `colorHex`
- Event types: School, Sports, Family, Personal
- Color-coded events with custom icons

#### 4. **Goal** (Main Focus)
Comprehensive goal tracking with multiple features:

**Basic Properties:**
- `title`: Goal name
- `createdByChildName`: Goal creator
- `hasHabit`: Whether it's a recurring habit
- `habitFrequency`: Daily or Weekly
- `completedDates`: Array of completion timestamps
- `shareCompletionToChat`: Auto-share completions
- `createdDate`: Creation timestamp

**Feature 1: Rewards/Points System**
- `pointValue`: Points awarded per completion (1-100)
- `totalPointsEarned`: Accumulated points

**Feature 2: Approval Workflow**
- `status`: Pending, Approved, Rejected, Completed
- `parentNote`: Rejection reason/feedback

**Feature 3: Streak Tracking**
- `currentStreak`: Consecutive completion days
- `longestStreak`: Best streak ever
- `lastCompletedDate`: Last completion timestamp
- Methods: `updateStreak()`, `recalculateStreak()`

**Feature 6: Deadlines**
- `targetDate`: Optional deadline
- `milestones`: Array of sub-goals
- `daysUntilDeadline`: Computed property

**Feature 8: Statistics**
- `completionRate`: Percentage based on days since creation
- `totalCompletions`: Count of all completions
- `progressPercentage`: Visual progress (based on frequency)

#### 5. **GoalMilestone**
- Properties: `title`, `isCompleted`, `completedDate`, `order`
- Sub-tasks for larger goals

### Enums

- **MemberRole**: parent, child
- **EventType**: school, sports, family, personal
- **HabitFrequency**: daily, weekly
- **GoalStatus**: pending, approved, rejected, completed

## App Settings (`AppSettings.swift`)

Observable class managing app-wide settings:
- `currentUserName`: Active user
- `currentUserRole`: Active role
- `appearanceMode`: Light/Dark/System
- `familyName`: Family identifier

## Main Views

### 1. DashboardView (Tab 1)

**Purpose:** Central hub showing family overview and quick access to all features

**⭐ NEW: Single-Child vs Multi-Child Adaptations**

The dashboard intelligently adapts based on family size:

**Multi-Child Mode (2+ children):**
- Shows "Family Leaderboard" for parents
- Displays rankings with 🥇🥈🥉 medals
- Competitive language ("Ranked #1 in family!")
- Children see family rankings with medals

**Single-Child Mode (1 child):**
- Shows "[Child Name]'s Progress" board for parents
- 4 stat cards: Total Points, Current Streak, Longest Streak, Active Goals
- Week-over-week comparison: "↗ Up 40 points from last week!"
- Achievement messaging: "🏆 You're on fire! 12 days!"
- **NO rankings, medals, or sibling comparisons**
- Children see self-comparison instead of family rankings

**Widgets:**

#### Welcome Header
- Personalized greeting with user's name
- Blue-purple gradient background
- Role-specific subtitle

#### Family Overview Widget
- 4 Quick Stats: Children count, Total goals, Family points, Total completions
- Color-coded cards

#### Family Leaderboard (Parents Only - Multi-Child Mode)
- Ranked list of all children by points
- Shows: 🥇🥈🥉 medals for top 3, goal count, best streak
- Sorted by points (highest first)
- **Only shown when 2+ children exist**

#### Personal Progress Board (Parents Only - Single-Child Mode)
- Shows child's name in header ("[Name]'s Progress")
- 4 stat cards: Points, Current Streak, Longest Streak, Goals
- Week-over-week comparison with trend arrows
- Achievement milestone messaging
- **Replaces leaderboard when only 1 child exists**

#### Personal Progress Widget (Children Only)
- 3 Stats: Total points, Active goals, Best streak
- **Multi-child:** Shows family ranking with medal
- **Single-child:** Shows weekly comparison and personal achievements
- Motivational messaging (context-aware)

#### Recent Activity Feed
- Last 10 activities across family
- Activity types:
  - ✅ Completions (green)
  - 🔥 Milestones (orange)
  - 🔐 Approvals (blue)
  - ❌ Rejections (red)
- Relative timestamps ("5m ago", "2h ago")
- Points earned display

#### Upcoming Deadlines Widget
- Top 5 nearest deadlines
- Color-coded urgency:
  - 🔴 Red: Overdue or ≤2 days
  - 🟠 Orange: 3-7 days
  - 🟢 Green: 8+ days
- Smart countdown text
- Shows goal owner and status

#### Weekly Statistics Widget
- Last 7 days summary
- 3 compact stats: Completions, Points earned, Active streaks
- Color-coded backgrounds

#### Quick Actions Widget
**Parent Actions:**
- Review Approvals (with pending count badge)
- View All Goals

**Child Actions:**
- Add New Goal (opens sheet)
- View My Goals
- Next Deadline (if applicable)

### 2. GoalsView (Tab 4 - formerly Tab 3)

**Purpose:** Create, track, and manage goals with habits

**Role-Based Views:**

#### Children View:
- Points badge in toolbar (yellow star)
- Add goal button (top-right)
- Points summary card at top
- Own goals list with edit capabilities
- Status indicators (Pending/Approved/Rejected)

#### Parents View:
- Approval queue button (orange badge if pending goals)
- Goals grouped by child
- Read-only view of all family goals
- Quick approval buttons on pending goals

**Goal Card Features:**
- Status badge (Pending 🕐, Approved ✅, Rejected ❌)
- Title and metadata badges:
  - Frequency (Daily/Weekly)
  - Current streak (🔥 flame icon)
  - Point value (⭐ star)
  - Deadline countdown (📅 calendar)
- Deadline info banner (color-coded urgency)
- Parent rejection note display
- Progress bar (for habits)
- Best streak display
- Completion button (approved habits only)
- "View Statistics" button (when data exists)

### 3. AddGoalView (Sheet)

**Sections:**

1. **Basic Info**
   - Goal title (required)

2. **Habit Tracking**
   - Toggle: Track as Habit
   - Frequency picker (Daily/Weekly)
   - Share completions to chat toggle

3. **Rewards**
   - Point value stepper (1-100, step 5)
   - Default: 10 points

4. **Deadline**
   - Toggle: Set Target Date
   - Date picker (future dates only)
   - Days countdown preview

**Behavior:**
- Creates goal with status = .pending
- Requires parent approval before tracking starts

### 4. Approval Flows

#### ApprovalQueueView (Parent Sheet)
- List of all pending goals
- Shows: Creator name, point value, frequency, deadline
- Quick approve/reject buttons
- Empty state: "All Caught Up!"

#### GoalApprovalSheet (Parent Detail)
- Full goal details
- Segmented picker: Approve / Reject
- Required rejection note field
- Sends chat notification on decision

#### ApprovalGoalCard
- Quick approval from dashboard or goals list
- Green "Approve" and Red "Reject" buttons
- Inline goal information

### 5. Points & Rewards

#### PointsSummaryView (Child Sheet)
- Large total points display (gradient star)
- 4 Stats Grid:
  - Active goals
  - Total completions
  - Best streak (tappable) - **Label adapts:** "Best Streak" (multi-child) or "Current Best" (single-child)
  - Average completion rate
- **Multi-child mode:**
  - "Top Goals" header
  - Shows "#1, #2, #3" rankings
  - Competitive tone
- **Single-child mode:**
  - "Your Best Goals" header
  - NO numerical rankings
  - Personal achievement message section
  - Progress celebration messaging

#### StreakDetailsView (Sheet from Points Summary)
- Best current streak display (large number)
- 2 Stats: Longest ever, Active streaks count
- Next Milestones section:
  - Progress bars for 3, 7, 14, 30, 50, 100 days
  - Checkmarks for completed milestones
  - Countdown to next milestone
- Top 3 Active Streaks:
  - 🥇🥈🥉 medals
  - Longest streak history
  - Current streak count

### 6. Statistics & Insights

#### GoalStatisticsView (Sheet from Goal Card)
- Goal title and purple chart icon header

**Sections:**

1. **Stats Grid** (4 cards)
   - Total completions
   - Last 30 days completions
   - Longest streak
   - Completion rate

2. **Weekly Pattern**
   - Bar chart by weekday (Mon-Sun)
   - Highlights best day in orange
   - Insight: "You complete this goal most often on [Day]s!"

3. **Timeline**
   - Created date
   - First completion date
   - Last completion ("X days ago")
   - Target deadline (if set)

4. **Recent Completions**
   - Last 10 completions
   - Formatted dates with relative time
   - Green checkmarks

5. **Rewards Summary**
   - Points per completion
   - Total points earned from this goal
   - Gradient yellow/orange card

### 7. Supporting Views

#### ChatView (Tab 2) - Searchable Family Record

**Purpose:** More than just chatting — a searchable family record for everyday communication and important decisions

**Tagline:** "Chat, decisions, and memories — searchable in one place"

**Core Features:**

1. **Full-Text Search** 🔍
   - Native `.searchable()` with live filtering
   - Search matches:
     - Normal chat messages ("food" finds "Josh come to eat food")
     - System messages (approvals, streaks, deadlines)
     - Author names
     - Embedded goal titles
   - Yellow highlighting on matched terms
   - Empty state: "No messages match 'food'"

2. **System vs Family Message Distinction** 🔵
   - **System messages** (from "FamSphere"):
     - Centered alignment with blue badge
     - Light blue background with border
     - Automatic notifications for approvals, streaks, completions
   - **Family messages** (from users):
     - Left/right alignment by sender
     - Standard blue/gray bubble styling
   - **Optional filter picker:**
     - All (default)
     - System (FamSphere only)
     - Family (user messages only)
   - Keeps both types in same stream for context

3. **Pin Important Messages** 📌
   - Long-press any message → "Pin Message"
   - Pinned messages appear at top in dedicated section
   - Orange pin icon and "PINNED MESSAGES" header
   - Persists across app restarts
   - Use cases: Family rules, reminders, instructions, decisions

**What's NOT Included (Intentionally):**
- ❌ Reactions (thumbs up, emojis)
- ❌ Stickers / GIFs
- ❌ Typing indicators
- ❌ Read receipts
- **Reason:** Keeps chat calm, purposeful, and retrievable — not another iMessage clone

**Key Differentiator:** Makes chat more useful than iMessage for families by prioritizing **retrievability** over real-time engagement

**See:** `CHAT_ENHANCEMENTS.md` for complete documentation

#### CalendarView (Tab 3) - Responsibility Timeline
- **Renamed from "Family Calendar" to "Responsibility Timeline"** - Emphasizes accountability
- Family calendar events with week/month views
- **Ownership-First Presentation:**
  - **Pickups Tab** 🚗: Shows "Handled by [Parent Name]" with checkmark icon
    - Missed pickup detection (red gradient, "Missed" badge, red border)
    - Time-critical child logistics (school events + pickup keywords)
  - **Events Tab** 📅: Shows "Added by [Name]" with person icon
    - General family scheduling (all non-pickup events)
    - Clean presentation without consequence noise
  - **Deadlines Tab** 🎯: Shows "Owned by [Child Name]" with checkmark icon
    - Goal accountability (goals with matching target dates)
    - **Consequence awareness**: "Streak at risk", "Points on the line: ⭐ X", "Overdue – progress impacted"
    - **Role-aware messaging**: Adapts hints for single-child vs multi-child families
- Smart filtering with keyword matching
- Urgency-based color coding for deadlines (red/orange/green borders)
- Badge counts on tabs
- Role-based deletion permissions
- **See:** `RESPONSIBILITY_TIMELINE_REFACTOR.md` for complete documentation

#### SettingsView (Tab 5)
- User management
- Appearance settings
- Family settings

## Single-Child vs Multi-Child Adaptations (NEW)

### Overview
FamSphere intelligently adapts its interface and messaging based on whether there's a single child or multiple children in the family. This ensures the app feels intentional, personal, and motivating regardless of family size—never awkward or empty.

### Detection Logic
```swift
private var isSingleChild: Bool {
    children.count == 1
}
```

### Implementation Scope
**View-level only** - NO changes to:
- ✅ Data models
- ✅ Business logic
- ✅ Streak algorithms
- ✅ Points calculations

### Dashboard Adaptations

#### Parent View

**Multi-Child Mode (2+ children):**
```
🏆 Family Leaderboard

🥇  Emma                        ⭐ 250
    🎯 5  🔥 12

🥈  Jake                        ⭐ 180
    🎯 3  🔥 7
```

**Single-Child Mode (1 child):**
```
📊 Emma's Progress

⭐ 250         🔥 12
Total Points   Current Streak

🏆 15          🎯 5
Longest Streak Active Goals

↗ Up 40 points from last week!

🏆 You're on fire! 12 days!
```

#### Child View

**Multi-Child Mode:**
- Shows family ranking with medal
- "🥇 Ranked #1 in family!"

**Single-Child Mode:**
- Shows weekly comparison
- "↗ Up 40 points from last week!"
- Achievement messaging
- NO family rankings

### Points Summary Adaptations

**Multi-Child Mode:**
- "Top Goals" header
- Shows "#1, #2, #3" rankings
- Competitive language

**Single-Child Mode:**
- "Your Best Goals" header
- NO numerical rankings
- Personal achievement section
- "🏆 Incredible dedication! 12-day streak!"

### Messaging Changes

| Multi-Child Copy | Single-Child Copy |
|-----------------|-------------------|
| "Ranked #1 in family!" | "New personal best!" |
| "Top Goals" | "Your Best Goals" |
| "Best Streak" | "Current Best" |
| Medal emojis 🥇🥈🥉 | Trophy/star 🏆⭐ |

### New Components

#### StatCardCompact
Compact stat cards for single-child progress board.

#### singleChildProgressWidget
Complete progress board for parents with one child:
- Personalized header with child's name
- 2x2 stat grid
- Weekly comparison card
- Achievement milestone card

### Helper Functions

#### weeklyProgressComparison(for:)
Compares current week to previous week:
- Returns trend (.up, .down, .stable)
- Returns contextual message
- Powers weekly comparison cards

```swift
↗ "Up 40 points from last week!" (green)
→ "Steady progress - keep it up!" (blue)
↘ "Keep pushing - you've got this!" (orange)
```

#### streakAchievementMessage(for:)
Returns milestone-based messages:
- 100+ days: "Streak Champion! 100+ days! 🏆"
- 50-99: "Incredible! X-day streak!"
- 30-49: "Streak Master!"
- 14-29: "Two weeks strong!"
- 7-13: "One week streak! Keep going!"

#### personalBestText(for:)
Achievement messaging for Points Summary view.

### Design Philosophy

**Single-Child:** Personal, achievement-focused, growth-oriented
**Multi-Child:** Competitive, fun, engaging

The app seamlessly transitions between modes as family size changes, with no manual configuration required.

## Key Features Implementation

### Feature 1: Rewards/Points System ⭐

**Implementation:**
- Point value selector (1-100, increments of 5)
- Automatic points awarding on completion
- Total points tracking per goal
- Family-wide points aggregation

**UI Elements:**
- Yellow star badges throughout
- Points summary card on dashboard
- Toolbar badge showing total points
- Points summary view with leaderboard
- "+X pts" indicators on completions

### Feature 2: Goal Approval Workflow ✅

**States:**
- Pending (🕐): Awaiting parent review
- Approved (✅): Ready for tracking
- Rejected (❌): Needs revision with parent note
- Completed (🏆): Goal achieved

**Flow:**
1. Child creates goal → Status: Pending
2. Parent receives notification badge
3. Parent approves/rejects in queue or on card
4. Rejection requires note explaining why
5. Chat notification sent on decision

**UI Elements:**
- Status badges on goal cards
- Orange approval queue button (parents)
- Pending count badge
- Parent note display for rejections
- "Waiting for parent approval" message (children)

### Feature 3: Streak Tracking 🔥

**Calculation:**
- Increments on consecutive day completions
- Resets if day skipped
- Tracks longest streak separately
- Recalculates on unchecking completion

**Milestones:**
- 3, 7, 14, 30, 50, 100 days
- Alert dialog on achievement
- Important chat message to family
- Added to activity feed

**UI Elements:**
- Orange flame badges with streak count
- "Best: X 🔥" in progress section
- Streak included in chat messages
- Dedicated streak details view
- Progress bars to next milestone

### Feature 6: Deadlines & Targets 📅

**Features:**
- Optional target date picker
- Days remaining calculator
- Overdue detection
- Urgency indicators
- **NEW: Calendar integration** - Deadlines show in calendar day view

**Color Coding:**
- 🟢 Green: 8+ days (plenty of time)
- 🟠 Orange: 3-7 days (approaching) or 1 day
- 🔴 Red: 0-2 days (urgent) or overdue

**UI Elements:**
- Deadline badge on goal cards
- Info banner with countdown
- Dedicated deadlines widget on dashboard
- **NEW: Deadlines tab in calendar** with urgency borders
- Special icons for urgency (⚠️ triangle for overdue)
- "Due today!", "Due tomorrow", "Overdue by Xd" messages

**Calendar Integration:**
- Deadlines appear on target date in calendar
- Filtered by selected day
- Excludes completed goals
- Shows urgency with colored borders and icons
- Displays points value and status

### Feature 8: Statistics & Insights 📊

**Metrics:**
- Total completions (all-time)
- Last 30 days activity
- Completion rate (daily percentage since creation)
- Progress percentage (based on frequency window)
- Weekly pattern analysis

**Visualizations:**
- Horizontal bar chart by weekday
- Progress bars for habit tracking
- Stat cards with icons
- Timeline with colored icons
- Recent completions list

**Insights:**
- Best day of week identification
- Streak analysis
- Points breakdown
- Activity patterns

## Data Flow

### Goal Completion Flow:
1. Child taps "Mark Complete" on approved goal
2. `goal.markCompleted()` called
3. Date added to `completedDates` array
4. `updateStreak()` calculates new streak
5. Points added to `totalPointsEarned`
6. Check for milestone achievements
7. If `shareCompletionToChat` enabled:
   - Create ChatMessage with streak info
   - Insert into context
8. Check milestone array for celebrations
9. Show alert if milestone reached
10. Post milestone to chat as important

### Approval Flow:
1. Goal created with status = .pending
2. Parent sees badge on toolbar
3. Opens approval queue or taps seal icon
4. Reviews goal details
5. Approves or rejects:
   - Approve: status = .approved, can track
   - Reject: status = .rejected, requires note
6. ChatMessage posted (important)
7. Child sees status update immediately

### Statistics Calculation:
1. Queries run on view appear
2. Aggregations:
   - Sum points across goals
   - Count completions in date ranges
   - Calculate streaks from sorted dates
   - Determine weekday frequencies
3. Cached in computed properties
4. UI updates reactively

## Design Patterns

### Color Coding System:
- 🟢 Green: Completions, success, approved
- 🔴 Red: Overdue, rejected, urgent
- 🟠 Orange: Warnings, streaks, approaching deadlines
- 🟡 Yellow: Points, rewards
- 🔵 Blue: Information, navigation
- 🟣 Purple: Statistics, analytics

### Icon System:
- ⭐ `star.fill`: Points
- 🔥 `flame.fill`: Streaks
- ✅ `checkmark.circle.fill`: Completions
- 🎯 `target`: Goals
- 📅 `calendar.badge.clock`: Deadlines
- 🕐 `clock`: Pending
- 🏆 `trophy.fill`: Achievements
- 📊 `chart.bar.fill`: Statistics

### Status Badges:
- Capsule shape with icon + text
- Colored background (opacity 0.2)
- Matching foreground color
- 6pt horizontal, 3pt vertical padding

### Cards & Widgets:
- `RoundedRectangle(cornerRadius: 12-16)`
- `secondarySystemGroupedBackground`
- Consistent padding (16pt)
- Dividers between list items

## Component Reusability

### Reusable Components:

1. **QuickStatCard**
   - Used in: Dashboard family overview
   - Props: icon, value, label, color

2. **StatCard**
   - Used in: Points summary, Streak details, Statistics
   - Props: icon, value, label, color

3. **LeaderboardRow**
   - Used in: Family leaderboard
   - Props: rank, childName, points, goalCount, bestStreak

4. **ActivityRowView**
   - Used in: Recent activity feed
   - Props: activity (ActivityItem)

5. **DeadlineRowView**
   - Used in: Upcoming deadlines widget
   - Props: goal

6. **WeeklyStatCard**
   - Used in: Weekly statistics widget
   - Props: icon, value, label, color

7. **QuickActionButton/Content**
   - Used in: Quick actions widget
   - Props: icon, title, subtitle, color, action

8. **GoalCardView**
   - Used in: Goals list
   - Props: goal, canEdit

9. **MilestoneProgressCard**
   - Used in: Streak details
   - Props: milestone, currentStreak

10. **WeekdayBar**
    - Used in: Statistics weekly pattern
    - Props: weekday, count, maxCount, isBest

11. **CalendarDayTabsView**
    - Used in: Calendar week/month views
    - Props: selectedDate
    - Features: Tab filtering, badge counts, empty states

12. **PickupRowView**
    - Used in: Calendar Pickups tab
    - Props: event
    - Features: Large time display, blue gradient, car icon

13. **EventCardView**
    - Used in: Calendar Events tab
    - Props: event
    - Features: Type badges, color coding, notes preview

14. **DeadlineCardView**
    - Used in: Calendar Deadlines tab
    - Props: goal
    - Features: Urgency indicators, countdown text, colored borders

15. **StatCardCompact** (NEW)
    - Used in: Single-child progress board
    - Props: icon, value, label, color
    - Features: Compact layout for dashboard stats

16. **singleChildProgressWidget** (NEW)
    - Used in: Dashboard (parent view, single-child mode)
    - Features: Child name header, 2x2 stat grid, weekly comparison, achievements

## Navigation Structure

```
MainTabView
├── DashboardView (Tab 1)
│   ├── PointsSummaryView (sheet - children)
│   │   └── StreakDetailsView (sheet)
│   ├── ApprovalQueueView (sheet - parents)
│   │   └── GoalApprovalSheet (sheet)
│   └── AddGoalView (sheet - children)
├── ChatView (Tab 2)
├── CalendarView (Tab 3)
├── GoalsView (Tab 4)
│   ├── AddGoalView (sheet)
│   ├── PointsSummaryView (sheet)
│   │   └── StreakDetailsView (sheet)
│   ├── ApprovalQueueView (sheet)
│   │   └── GoalApprovalSheet (sheet)
│   └── GoalStatisticsView (sheet)
└── SettingsView (Tab 5)
```

## State Management

### @Environment
- `AppSettings`: User preferences and current user
- `modelContext`: SwiftData context for CRUD operations

### @Query
- Automatic data fetching with sorting
- Reactive updates on data changes
- Used for: goals, family members, messages

### @State
- Sheet presentation flags
- Local UI state
- Alert triggers

## Performance Considerations

### Computed Properties
- Lazy evaluation
- Recalculated only when dependencies change
- Used for filtered lists and aggregations

### LazyVStack
- Renders only visible items
- Used in scrollable lists
- Improves performance with large datasets

### Prefix Limiting
- Top 5 deadlines
- Last 10 activities
- Top 5 goals
- Prevents excessive rendering

## Testing Considerations

### Preview Providers
- All major views have #Preview
- Mock data through ModelContainer
- Environment setup with AppSettings

### Key Test Scenarios:
1. Goal creation and approval workflow
2. Streak calculation on consecutive completions
3. Points accumulation
4. Deadline urgency color changes
5. Weekly statistics calculations
6. Activity feed parsing
7. Leaderboard sorting
8. Milestone detection

## Future Enhancement Ideas

**Completed Features:**
- ✅ Points system with rewards
- ✅ Streak tracking with milestones
- ✅ Goal approval workflow
- ✅ Deadlines with urgency
- ✅ Comprehensive statistics
- ✅ Family dashboard
- ✅ Calendar day tabs (Pickups, Events, Deadlines)
- ✅ Single-child vs multi-child adaptations
- ✅ Responsibility Timeline (ownership & accountability focus)

**Potential Additions:**
- Photo evidence for completions
- Goal templates library
- Collaborative family goals
- Rewards redemption system
- Push notifications for deadlines
- Weekly/monthly reports
- Export data/statistics
- Goal categories/tags
- Custom milestone values
- Animations and celebrations
- Widgets for home screen
- Apple Watch companion app

## Code Organization

### File Structure:
```
FamSphere/
├── FamSphereApp.swift          # App entry point
├── Models.swift                # All data models
├── AppSettings.swift           # App-wide settings
├── MainTabView.swift           # Tab navigation
├── DashboardView.swift         # Family dashboard (NEW)
├── GoalsView.swift             # Goals management
├── ChatView.swift              # Family chat
├── CalendarView.swift          # Family calendar
├── SettingsView.swift          # App settings
├── OnboardingView.swift        # First-time setup
└── ContentView.swift           # Root view
```

### View Hierarchy Best Practices:
- Use MARK comments for organization
- Separate widgets into computed properties
- Extract reusable components
- Keep view bodies concise
- Use ViewBuilder for conditional views

## Key Algorithms

### Streak Calculation:
```swift
private func updateStreak(for date: Date) {
    if let lastDate = lastCompletedDate {
        let daysSince = calendar.dateComponents([.day], from: lastDate, to: date).day ?? 0
        
        if daysSince == 1 {
            currentStreak += 1  // Consecutive day
        } else if daysSince > 1 {
            currentStreak = 1   // Streak broken
        }
        // Same day: no change
    } else {
        currentStreak = 1  // First completion
    }
    
    lastCompletedDate = date
    longestStreak = max(longestStreak, currentStreak)
}
```

### Deadline Color Logic:
```swift
private func deadlineColor(for daysRemaining: Int) -> Color {
    if daysRemaining < 0 {
        return .red     // Overdue
    } else if daysRemaining <= 2 {
        return .red     // Urgent (0-2 days)
    } else if daysRemaining <= 7 {
        return .orange  // Soon (3-7 days)
    } else {
        return .green   // Plenty of time (8+ days)
    }
}
```

### Progress Percentage (Habit):
```swift
var progressPercentage: Double {
    let calendar = Calendar.current
    let now = Date()
    
    switch frequency {
    case .daily:
        // Last 7 days window
        let last7Days = (0..<7).compactMap { 
            calendar.date(byAdding: .day, value: -$0, to: now) 
        }
        let completed = completedDates.filter { date in
            last7Days.contains(where: { calendar.isDate($0, inSameDayAs: date) })
        }
        return Double(completed.count) / 7.0
        
    case .weekly:
        // Last 4 weeks window
        let last4Weeks = (0..<4).compactMap { 
            calendar.date(byAdding: .weekOfYear, value: -$0, to: now) 
        }
        let completed = completedDates.filter { date in
            last4Weeks.contains(where: { 
                calendar.isDate($0, equalTo: date, toGranularity: .weekOfYear) 
            })
        }
        return Double(completed.count) / 4.0
    }
}
```

## SwiftUI Patterns Used

### Environment Injection:
```swift
@Environment(AppSettings.self) private var appSettings
@Environment(\.modelContext) private var modelContext
```

### Query with Sorting:
```swift
@Query(sort: \Goal.createdDate, order: .reverse)
private var allGoals: [Goal]
```

### Conditional Views:
```swift
@ViewBuilder
private var contentView: some View {
    if allGoals.isEmpty {
        emptyStateView
    } else {
        goalsList
    }
}
```

### Sheet Presentation:
```swift
.sheet(isPresented: $showingSheet) {
    DetailView()
}
```

### NavigationLink:
```swift
NavigationLink(destination: GoalsView()) {
    QuickActionButtonContent(...)
}
.buttonStyle(.plain)
```

## Accessibility Considerations

- Dynamic Type support (system fonts)
- SF Symbols for scalable icons
- Color with meaning AND text labels
- Semantic colors (systemGray, etc.)
- VoiceOver-friendly labels
- Sufficient contrast ratios

## Platform Support

- **Target:** iOS 17.0+
- **Frameworks:** SwiftUI, SwiftData
- **Device:** iPhone, iPad (universal)
- **Orientation:** Portrait preferred

## Testing Guide

### Single-Child Adaptation Tests

**Setup:** Create family with 1 child

✅ Parent Dashboard:
- Verify NO "Family Leaderboard" widget
- Verify "[Child Name]'s Progress" shows instead
- Check 4 stat cards display correctly
- Verify weekly comparison appears
- Check achievement messages show

✅ Child Dashboard:
- Verify NO "Ranked #X in family" text
- Verify weekly comparison shows
- Check achievement messaging appears

✅ Points Summary:
- Verify "Your Best Goals" header (not "Top Goals")
- Verify NO "#1, #2, #3" rankings
- Check personal best message section displays

### Multi-Child Tests

**Setup:** Create family with 2+ children

✅ Parent Dashboard:
- Verify "Family Leaderboard" shows
- Check 🥇🥈🥉 medals display
- Verify rankings by points

✅ Child Dashboard:
- Verify "Ranked #X in family!" shows
- Check medal emoji appears

✅ Points Summary:
- Verify "Top Goals" header
- Check "#1, #2, #3" rankings show

### Calendar Tabs Tests

✅ Pickups Tab:
- Add school event → verify shows in Pickups
- Add event with "pickup" in title → verify shows in Pickups
- Check large time display
- Verify car icon

✅ Events Tab:
- Add sports/family/personal event → verify shows in Events
- Verify does NOT show if classified as pickup
- Check type badge and color coding

✅ Deadlines Tab:
- Create goal with deadline on selected date → verify shows
- Check urgency color coding (red/orange/green)
- Verify completed goals excluded
- Check points badge displays

✅ Tab Features:
- Verify badge counts update
- Check smooth tab switching animation
- Test empty states for each tab

### Transition Test

✅ 1 → 2 Children:
- Start with 1 child
- Add 2nd child via Settings
- Return to Dashboard
- Verify automatic switch to leaderboard mode
- Check medals and rankings appear

## Summary

FamSphere is a production-ready family engagement app with:
- 9 major feature implementations (including Responsibility Timeline)
- 16 reusable components
- Role-based access control
- Comprehensive data modeling
- Rich statistics and insights
- Gamification elements
- Intuitive navigation
- Polished UI/UX
- Performance optimizations
- **Intelligent adaptation for single-child vs multi-child families**
- **Responsibility Timeline: Ownership & accountability-focused calendar**

The app successfully balances complexity with usability, making family goal tracking fun and engaging for both parents and children. It adapts seamlessly to family size, providing competitive experiences for multi-child families and personal, achievement-focused experiences for single-child families. The calendar emphasizes **who is responsible, what's at stake, and what happens if missed** — transforming scheduling into accountability.

## Recent Changes (January 13, 2026)

### 💬 Chat → Searchable Family Record

**What Changed:**
- Chat enhanced with full-text search using `.searchable()`
- Added visual distinction between system and family messages
- Implemented pin/unpin functionality for important messages
- Added filter picker (All/System/Family)
- System messages now centered with blue styling
- Search highlights matched terms with yellow background
- Pinned messages appear in dedicated section at top

**New Features:**
1. **Chat Search:**
   - Searches message content, author names, and goal titles
   - Live filtering as user types
   - Yellow highlighting on matches
   - Empty state: "No messages match 'search term'"

2. **System vs Family Distinction:**
   - System messages from "FamSphere" centered with blue badge
   - Family messages left/right aligned by sender
   - Filter picker to show All/System/Family
   - Visual clarity without separating streams

3. **Pin Important Messages:**
   - Long-press to pin/unpin any message
   - Pinned section at top with orange pin icon
   - Persists across sessions
   - Perfect for rules, reminders, instructions

**Files Modified:**
- `Models.swift` - Added `isPinned` and `isSystemMessage` to ChatMessage
- `ChatView.swift` - Complete rewrite with search, filters, and pinning (~450 lines)

**Impact:**
- Chat is now a **searchable family record**, not just ephemeral conversation
- Parents can find past decisions and instructions instantly
- System notifications don't clutter family chat (filter them separately)
- Important information stays visible (pinned at top)
- Differentiates FamSphere from generic chat apps

**Design Philosophy:**
*"This isn't another chat app — it's a family memory and accountability log that happens to include chat."*

**NO reactions, stickers, or typing indicators** — keeps chat calm, purposeful, and retrievable

**Documentation:** See `CHAT_ENHANCEMENTS.md` for complete details

---

### 🎯 Calendar → Responsibility Timeline Refactor

**What Changed:**
- Calendar navigation title changed to "Responsibility Timeline"
- All tabs now emphasize ownership with visual prominence
- Pickups show "Handled by [Name]" with checkmark icon (blue)
- Events show "Added by [Name]" with person icon
- Deadlines show "Owned by [Child Name]" with checkmark icon (blue)
- Missed pickup detection with red visual indicators (gradient, badge, border, red time)
- Consequence awareness on deadlines:
  - "Streak at risk" (≤2 days with active streak)
  - "Points on the line: ⭐ X" (≤7 days with points)
  - "Overdue – progress impacted" (past deadline)
- Role-aware motivational messaging:
  - Single-child: "Chance to extend your streak" / "Finish strong today"
  - Multi-child: "Keep your streak alive" / "Stay on track"

**Files Modified:**
- `CalendarView.swift` - Enhanced row views (PickupRowView, EventCardView, DeadlineCardView)

**Impact:**
- Calendar differentiates from Apple/Google by focusing on accountability
- Parents immediately see who's responsible and what's missed
- Children understand stakes and receive personalized encouragement
- No regression to existing functionality
- Display logic only - no data model or business logic changes

**Design Philosophy:**
*"This shows what matters today — who owns it, and what it affects."*  
**NOT:** *"Just what's on the schedule."*

**Documentation:** See `RESPONSIBILITY_TIMELINE_REFACTOR.md`, `TESTING_RESPONSIBILITY_TIMELINE.md`, `VISUAL_DESIGN_SPEC.md`

---

## Previous Changes (January 12, 2026)

### 🔧 Bug Fixes & Enhancements

#### Approval Messaging Enhancement
**What Changed:**
- Approval notifications now include the parent's name who approved the goal
- **Before:** "✅ '[Goal Title]' has been approved for [Child Name]!"
- **After:** "✅ '[Goal Title]' has been approved for [Child Name] by [Parent Name]!"

**Files Modified:**
- `GoalsView.swift` - Updated `approveGoal()` function

**Impact:**
- Better transparency for children
- Clear accountability for parents
- More informative family chat messages

#### Calendar Tab Badge Display Fix
**What Changed:**
- Badge counts are now displayed in a separate row below the segmented picker
- Tabs show clean labels: "Pickups | Events | Deadlines"
- Badge counts appear below: "(2) | (5) | (3)"
- Badges are color-coded based on tab selection

**Files Modified:**
- `CalendarView.swift` - Refactored `CalendarDayTabsView` body

**Impact:**
- All tab segments are now properly clickable
- Visual clarity improved
- No more confusing "(1)" appearing as a clickable tab

#### Add Event Form - Category Selection
**What Changed:**
- Add Event form now accepts `selectedDate` and `initialTab` parameters
- Automatically defaults to the tab you were viewing when you tapped add
- New "Category" section lets you choose Pickups or Events
- Smart defaults based on active tab:
  - Pickups tab → School type, Pickups category
  - Events tab → Personal type, Events category
  - Deadlines tab → Events category
- When selecting "Pickups" category, automatically sets event type to `.school`

**Files Modified:**
- `CalendarView.swift`:
  - Added `selectedTab` state to main `CalendarView`
  - Updated `WeekCalendarView` and `MonthCalendarView` to accept `selectedTab` binding
  - Refactored `AddEventView` with new initialization logic
  - Updated `createSingleEvent()` and `createRecurringEvents()`

**Impact:**
- Intuitive workflow - form defaults to your context
- Less manual configuration needed
- Events automatically appear in the correct tab
- Improved user experience for busy parents

#### Add Family Member Role Picker Fix
**What Changed:**
- Role picker now uses SwiftUI's `Label` component instead of `HStack`
- **Before:** Only text was clickable, icon was visual-only
- **After:** Entire segment (icon + text) is clickable

**Files Modified:**
- `SettingsView.swift` - AddFamilyMemberView role section

**Impact:**
- Better UX - clicking anywhere on the segment works
- Follows SwiftUI best practices
- Eliminates user confusion

---

## Previous Changes (January 11, 2026)

### ✨ Single-Child vs Multi-Child Adaptations

**What Changed:**
- Dashboard shows "Family Leaderboard" for 2+ children, "[Name]'s Progress" for 1 child
- Points Summary adapts labels and removes rankings in single-child mode
- Children see self-comparison instead of family rankings when solo
- Weekly progress comparison added for single-child families
- Achievement messaging replaces competitive language

**Files Modified:**
- `DashboardView.swift` - Added adaptive widgets and helpers
- `GoalsView.swift` - Updated Points Summary with context-aware UI

**Impact:**
- App feels intentional for all family sizes
- NO awkward empty leaderboards
- Personal growth focus for single children
- Competitive fun for multi-child families

### ✨ Calendar Day Tabs

**What Changed:**
- Calendar day view now has 3 tabs: Pickups, Events, Deadlines
- Smart filtering with keyword matching for pickups
- Urgency-based color coding for deadlines
- Badge counts on tabs
- Empty states for each tab

**Files Modified:**
- `CalendarView.swift` - Added CalendarDayTabsView and 3 row components

**New Components:**
- `CalendarDayTabsView` - Main tab container
- `PickupRowView` - Time-critical logistics display
- `EventCardView` - General event display
- `DeadlineCardView` - Goal deadline with urgency

**Impact:**
- Reduced calendar clutter
- Time-critical items instantly visible
- Goal deadlines surface in calendar context
- Better organization for parents

### 🔧 Bug Fix: User Profile Switching

**What Changed:**
- Added debug logging to user switching in Settings

**Files Modified:**
- `SettingsView.swift`

**Impact:**
- Easier to diagnose role update issues
- Confirmed switching logic works correctly


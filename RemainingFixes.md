# Remaining Bug Fixes & Enhancements

## Issues to Fix

### 1. ✅ COMPILE ERRORS FIXED
- Fixed extension scope errors in CalendarView.swift
- Extensions now at file level (not nested)
- `searchResultsView` properly scoped

### 2. ⏳ Approval Message Enhancement
**Current:** "✅ 'Task xyz' has been approved for Emma!"
**Needed:** "✅ 'Task xyz' has been approved for Emma by Mom!"

**File:** `GoalsView.swift` → `GoalApprovalSheet`
**Fix:**
```swift
// Line ~1520 in submitDecision()
let message = ChatMessage(
    content: "✅ '\(goal.title)' has been approved for \(goal.createdByChildName) by \(appSettings.currentUserName)!",
    authorName: "FamSphere",
    isImportant: true
)
```

### 3. ⏳ Parent Cannot Add Goals
**Issue:** Parent's "+" button not working or missing child picker

**Check:**
- AddGoalView should show child picker for parents
- Already implemented in code
- May need to test if FamilyMembers query working

**Debug:**
```swift
// In AddGoalView onAppear
.onAppear {
    print("👤 Parent mode: \(isParent)")
    print("👦 Children count: \(children.count)")
    if isParent && !children.isEmpty && selectedChildName.isEmpty {
        selectedChildName = children[0].name
    }
}
```

### 4. ⏳ Dashboard - Show Role Next to Name
**Current:** "Emma"
**Needed:** "Emma (Child)" or "Mom (Parent)"

**File:** `DashboardView.swift`
**Location:** Welcome Header section

**Fix:**
```swift
// Change from:
Text(appSettings.currentUserName)
    .font(.largeTitle)
    .fontWeight(.bold)

// To:
HStack(spacing: 8) {
    Text(appSettings.currentUserName)
        .font(.largeTitle)
        .fontWeight(.bold)
    
    Text("(\(appSettings.currentUserRole == .parent ? "Parent" : "Child"))")
        .font(.title2)
        .foregroundStyle(.secondary)
}
```

### 5. ⏳ Calendar Tab Badge Bug
**Issue:** Shows "Events (1)" instead of "Events" with badge

**File:** `CalendarView.swift` → `CalendarDayTabsView`
**Current (broken):**
```swift
Text("Tab (\(count))")  // Wrong!
```

**Should be:**
```swift
HStack(spacing: 4) {
    Text(tab.rawValue)
    if count(for: tab) > 0 {
        Text("(\(count(for: tab)))")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}
```

**The issue:** Badge is part of selectable text. Need to check how picker text is structured.

### 6. ⏳ Add Family Member Role Picker
**Issue:** Only "Parent" text clickable, not "Child" text

**File:** `SettingsView.swift` → `AddFamilyMemberView`
**Current (broken):**
```swift
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
```

**Fix (text only in picker):**
```swift
Picker("Role", selection: $role) {
    Text("Parent").tag(MemberRole.parent)
    Text("Child").tag(MemberRole.child)
}
.pickerStyle(.segmented)

// Add role icons separately OUTSIDE picker
HStack {
    Image(systemName: role == .parent ? "person.fill" : "figure.child")
        .foregroundStyle(.blue)
    Text(role == .parent ? "Parent" : "Child")
        .font(.subheadline)
}
```

## Quick Implementation Order

1. ✅ Compile errors (DONE)
2. Approval message (1 line change)
3. Dashboard role display (5 lines)
4. Calendar tab badge (find and fix picker text)
5. Family member role picker (restructure section)
6. Debug parent goal creation (test + add logging)

## Estimated Time
- Fixes #2-5: ~30 minutes
- Debug #6: Depends on root cause

All fixes are small, targeted changes!


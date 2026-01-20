# Switch User Testing Utility - Complete Guide

## Overview

The Switch User screen is now a comprehensive testing utility that allows developers and testers to quickly switch between family members, add new users, and test different role-based views without complex setup.

## Features

### ✅ All Requirements Implemented

1. **View all existing family members** ✓
2. **Switch to any existing user** ✓
3. **Add new users directly** ✓
4. **Empty state handling** ✓
5. **Production-ready UX** ✓

---

## User Interface

### Empty State

**When:** No family members exist in the database

**Display:**
```
        👥 (person.3.fill icon)
        
    No Family Members Yet
    
    Add your first parent or child
    to get started with FamSphere.
    
    [➕ Add First User] (blue button)
```

**Actions:**
- Tap "Add First User" button → Opens AddFamilyMemberView sheet

---

### Main View (With Users)

**Layout:** Grouped List style

#### Section 1: Testing Mode Banner
```
🔧 Testing Mode
   Quickly switch between family members to test
   different views and permissions.
```

#### Section 2: Current User Indicator
```
👤 Currently Signed In
   Emma
   Parent
                              ✓ (green checkmark seal)
```

**Shows:**
- User avatar (circle with initial)
- Name in headline font
- Role (Parent/Child)
- Green checkmark seal on right

#### Section 3: Parents
```
👤 Parents

[Avatar] Mom                      Current ✓
         Parent                        >

[Avatar] Dad
         Parent                        >
```

**Shows:**
- Section header with "Parents" label and person.fill icon
- Each parent as a selectable row
- Current user has "Current" badge and green checkmark on avatar

#### Section 4: Children
```
👥 Children

[Avatar] Emma                     Current ✓
         Child                         >

[Avatar] Jake
         Child                         >
```

**Shows:**
- Section header with "Children" label and figure.2.and.child.holdinghands icon
- Each child as a selectable row
- Current user highlighted

#### Section 5: Quick Add
```
➕ Add New Family Member
```

**Action:** Opens AddFamilyMemberView sheet

#### Section 6: Info
```
ℹ️ How It Works

Tap any family member to instantly switch to
their account. All views will update to show
their role and permissions.

This is a testing utility to help you explore
how FamSphere works for different family members.
```

---

## User Row Design

### Visual Components

```
┌──────────────────────────────────────────┐
│ [C] Emma               Current ✓         │
│     👤 Child                       >     │
└──────────────────────────────────────────┘
```

**Elements:**

1. **Avatar Circle (44x44pt)**
   - Background: User's assigned color
   - Content: First letter of name (uppercase, white)
   - Overlay: Green checkmark badge (if current user)

2. **User Info**
   - Name: Headline font
   - "Current" badge: Green capsule (only if current)
   - Role icon + text: Secondary color, caption font

3. **Action Indicator**
   - Chevron right: Only shown if not current user
   - Hidden for current user (since can't switch to self)

### Role Icons

| Role   | Icon              | Color  |
|--------|-------------------|--------|
| Parent | `person.fill`     | Blue   |
| Child  | `figure.child`    | Orange |

---

## Add Family Member Sheet

### Visual Layout

```
┌────────────────────────────────────────┐
│ ✕                Add Family Member  Add│
├────────────────────────────────────────┤
│                                        │
│            [Large Circle Avatar]       │
│                  Emma                  │
│               👤 Child                 │
│                                        │
├────────────────────────────────────────┤
│ Name                                   │
│ ┌────────────────────────────────────┐ │
│ │ Emma                               │ │
│ └────────────────────────────────────┘ │
│ Enter the family member's first name   │
│                                        │
├────────────────────────────────────────┤
│ Role                                   │
│ ┌─────────────┬──────────────────────┐ │
│ │   Parent    │       Child ✓        │ │
│ └─────────────┴──────────────────────┘ │
│ Children can create goals and track    │
│ their progress                         │
│                                        │
├────────────────────────────────────────┤
│ Profile Color                          │
│ ┌────────────────────────────────────┐ │
│ │ ⭕ ⭕ ✨⭕ ⭕ ⭕ ⭕ ⭕              │ │
│ │ ⭕ ⭕ ⭕ ⭕                         │ │
│ └────────────────────────────────────┘ │
│ ✨ Auto-selected color (tap to        │
│    customize)                          │
└────────────────────────────────────────┘
```

### Fields

#### 1. Preview Section
- Large circular avatar (80x80pt)
- Shows first letter of name (if entered) or role icon
- Name display (or "New User" if empty)
- Role icon + text

#### 2. Name Field
- Text input with placeholder "Name"
- Auto-focused on appear
- Validation:
  - ✅ Required (cannot be empty)
  - ✅ Must be unique (case-insensitive check)
  - ❌ Shows error if duplicate: "A family member with this name already exists"

#### 3. Role Selector
- Segmented control
- Options:
  - 👤 Parent
  - 🧒 Child
- Footer text updates based on selection:
  - Parent: "Parents can approve goals and manage the family"
  - Child: "Children can create goals and track their progress"

#### 4. Profile Color
- Grid of 12 color circles (55x55pt each)
- Auto-selection logic:
  - Suggests first unused color
  - Shows ✨ sparkle icon on suggested color
  - If all colors used, cycles through

**Color Selection States:**
- **Auto (default):** Sparkle icon on suggested color
- **Selected:** Large checkmark, white border, scaled up
- **Used by another member:** Dimmed border
- **Available:** Standard appearance

**Interaction:**
- Tap color → Select it
- Tap selected color → Deselect (return to auto)

**Available Colors:**
```swift
"#F5A623", "#E74C3C", "#3498DB", "#2ECC71", 
"#9B59B6", "#1ABC9C", "#E67E22", "#34495E",
"#F39C12", "#16A085", "#8E44AD", "#C0392B"
```

### Validation Rules

| Field | Validation | Error Message |
|-------|------------|---------------|
| Name  | Not empty | "Add" button disabled |
| Name  | Unique | ⚠️ "A family member with this name already exists" |
| Role  | Required | Always selected (default: Child) |
| Color | Auto-assigned | Always valid |

### Actions

**Cancel:**
- Dismisses sheet
- No changes saved

**Add:**
- Creates new FamilyMember
- Inserts into modelContext
- Automatically appears in Switch User list
- Does NOT auto-switch (user must manually tap to switch)
- Dismisses sheet
- Console log: "✅ Added new family member: [Name] ([Role]) - Color: [Hex]"

---

## User Switching Flow

### Step-by-Step

1. **User opens Settings**
2. **Taps "Switch User"**
3. **Views list of all family members**
4. **Taps desired user**
5. **App updates immediately:**
   - `AppSettings.currentUserName` → Selected name
   - `AppSettings.currentUserRole` → Selected role
   - Console logs switch action
6. **Sheet dismisses**
7. **All role-based UI updates reactively:**
   - Dashboard adapts (leaderboard vs progress)
   - Goals view changes (parent vs child view)
   - Toolbar icons update
   - Navigation options change

**No confirmation dialog** - Instant switching (Testing Mode only)

---

## Console Logging

### User Switch
```
🔄 Switching to user: Emma, role: child
✅ Updated settings - Name: Emma, Role: child
```

### Add User
```
✅ Added new family member: Jake (parent) - Color: #3498DB
```

---

## Technical Implementation

### Components

#### 1. UserSwitcherView
**Purpose:** Main testing utility screen

**State:**
- `@Environment(AppSettings.self)` - App settings
- `@Environment(\.modelContext)` - SwiftData context
- `@Query` - Family members list
- `@State showingAddMember` - Sheet presentation

**Computed Properties:**
- `parents: [FamilyMember]` - Filtered parent list
- `children: [FamilyMember]` - Filtered child list

**Methods:**
- `switchToUser(_ member:)` - Updates app settings and dismisses

#### 2. UserRowView
**Purpose:** Individual user row component

**Properties:**
- `member: FamilyMember` - The family member
- `isCurrent: Bool` - Whether this is the active user
- `action: () -> Void` - Switch action

**Computed Properties:**
- `roleIcon: String` - Icon name based on role
- `roleColor: Color` - Color based on role

#### 3. AddFamilyMemberView
**Purpose:** Add new family member sheet

**State:**
- `@State name` - User name input
- `@State role` - Selected role (default: .child)
- `@State selectedColorHex` - Optional custom color
- `@FocusState nameFieldFocused` - Auto-focus name field
- `@Query existingMembers` - For validation

**Computed Properties:**
- `usedColors: Set<String>` - Colors already in use
- `suggestedColor: String` - Auto-selected color
- `finalColorHex: String` - Selected or suggested
- `isNameValid: Bool` - Name not empty
- `nameAlreadyExists: Bool` - Duplicate check
- `canSave: Bool` - All validations pass

**Methods:**
- `addMember()` - Creates and saves new member

#### 4. ColorSelectionButton
**Purpose:** Reusable color picker button

**Properties:**
- `colorHex: String` - The color value
- `isSelected: Bool` - Currently selected
- `isUsed: Bool` - Used by another member
- `isSuggested: Bool` - Auto-suggested
- `action: () -> Void` - Selection action

**Features:**
- Animated selection (spring animation)
- Visual indicators (checkmark, sparkle, border)
- Accessible tap target (55x55pt)

---

## Accessibility

### Dynamic Type Support
- All text uses system fonts
- Scales with user preferences
- Maintains readable hierarchies

### VoiceOver
- All buttons properly labeled
- Role icons have text alternatives
- Current user state announced
- Color selection accessible

### Touch Targets
- All buttons ≥44pt minimum
- Adequate spacing between elements
- Full-width tap areas on rows

---

## Edge Cases Handled

### Empty Database
✅ Shows friendly empty state
✅ "Add First User" button prominent
✅ Clear call-to-action

### Single User
✅ Shows "Current" badge
✅ No chevron (can't switch to self)
✅ Add button still available

### Duplicate Names
✅ Case-insensitive check
✅ Real-time validation
✅ Clear error message
✅ Prevents submission

### All Colors Used
✅ Cycles back to beginning
✅ Still suggests least-recently-used
✅ Can override with manual selection

### No Selection (Auto)
✅ Sparkle icon on suggested
✅ Footer explains auto-selection
✅ Can tap to customize

---

## Use Cases

### Testing Role-Based Views
1. Add one parent and one child
2. Switch to child → See child dashboard
3. Create a goal → See pending status
4. Switch to parent → See approval queue
5. Approve goal → See badge disappear
6. Switch back to child → See approved goal

### Testing Single vs Multi-Child
1. Add one child → See personal progress
2. Add second child → See leaderboard appear
3. Switch between children → See rankings
4. Delete one child (via Manage Family) → Return to personal progress

### Testing Family Features
1. Add multiple family members
2. Create goals for each child
3. Switch to each child → View their goals
4. Switch to parent → See all family goals
5. Test approval workflows from both sides

---

## Best Practices

### For Developers
- Use this during development to test all views
- Add realistic test data (multiple children)
- Test edge cases (empty, single, many)
- Verify reactive updates work correctly

### For Testers
- Document user flows with specific profiles
- Test all role combinations
- Verify permissions enforcement
- Check UI adaptation (single/multi-child)

### For Demos
- Pre-populate with sample family
- Use realistic names and roles
- Show switching between roles
- Demonstrate reactive updates

---

## Future Enhancements

### Potential Additions
1. **Delete User** - Swipe-to-delete in Switch User list
2. **Edit User** - Tap row in Manage Family to edit
3. **Favorite/Pin** - Pin frequently-used test accounts
4. **Quick Switch Widget** - iOS widget for faster testing
5. **Preset Families** - One-tap setup for common scenarios
6. **Export/Import** - Share test family data
7. **Auto-Generate** - Create random family for testing

### Not Planned (Out of Scope)
- ❌ Authentication
- ❌ Cloud sync of user preferences
- ❌ Multi-device switching
- ❌ Password protection
- ❌ Family invitations

---

## Summary

The Switch User testing utility provides:
- ✅ **Quick user switching** - One tap to change roles
- ✅ **Easy user creation** - Add new family members inline
- ✅ **Visual feedback** - Clear current user indication
- ✅ **Smart color selection** - Auto-assignment with customization
- ✅ **Validation** - Prevents duplicates and errors
- ✅ **Empty state handling** - Helpful first-run experience
- ✅ **Production-ready UX** - Polished, accessible, intuitive
- ✅ **Zero configuration** - No external setup required

Perfect for development, testing, and demos!


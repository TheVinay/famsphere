# Responsibility Timeline - Visual Design Spec

## Navigation Title

```
┌────────────────────────────────────────┐
│ ◀ Today    Responsibility Timeline  ⊕ │
└────────────────────────────────────────┘
```

**Change:** "Family Calendar" → "Responsibility Timeline"

---

## Pickups Tab 🚗

### Normal Pickup (On Time / Future)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌────────┐                                     │
│  │        │                                     │
│  │   🚙   │   3:00 PM  ← Large, bold           │
│  │  BLUE  │   School Pickup                    │
│  │        │   ✓ Handled by Dad  ← Blue, medium │
│  └────────┘   📍 Main entrance                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Missed Pickup
```
┌─────────────────────────────────────────────────┐ ← RED BORDER (2pt, 50%)
│                                                 │
│  ┌────────┐   ⚠️ MISSED ← Red capsule          │
│  │        │                                     │
│  │   🚗   │   3:00 PM  ← RED TEXT              │
│  │  RED   │   School Pickup                    │
│  │        │   ✓ Handled by Dad  ← Blue, medium │
│  └────────┘   📍 Main entrance                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Key Changes:**
- Ownership: "Assigned to" → "Handled by" (blue, checkmark icon)
- Missed detection: Red gradient, "Missed" badge, red time, red border
- Icon: `person.fill` → `person.fill.checkmark`

---

## Events Tab 📅

### Regular Event
```
┌─────────────────────────────────────────────────┐
│                                                 │
│   ┌──┐                                          │
│   │⚽│   Soccer Practice                        │
│   └──┘   5:00 PM                                │
│                                                 │
│          [Sports] 👤 Added by Mom ← Icon added │
│          Bring water bottle                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Key Changes:**
- Ownership: "by Name" → "Added by Name" (person.circle icon added)
- No consequences shown (intentional)

---

## Deadlines Tab 🎯

### Deadline - Normal (8+ days)
```
┌─────────────────────────────────────────────────┐
│                                                 │
│   ┌──┐   Complete Homework                     │
│   │⏰│   ✓ Owned by Emma  ← Blue, checkmark    │
│   └──┘                                          │
│   ────────────────────────────────────          │
│                                                 │
│   📅 10 days left              ⭐ 20 pts       │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Deadline - Urgent (2 days, with streak)
```
┌─────────────────────────────────────────────────┐ ← ORANGE BORDER
│                                                 │
│   ┌──┐   Complete Homework                     │
│   │⚠️│   ✓ Owned by Emma  ← Blue, checkmark    │
│   └──┘                                          │
│   ────────────────────────────────────          │
│                                                 │
│   📅 2 days left               ⭐ 20 pts       │
│                                                 │
│   ⚠️ Streak at risk  ← Red capsule (CONSEQUENCE)│
│                                                 │
│   💡 Keep your streak alive  ← Orange capsule   │
│      (MOTIVATIONAL HINT)                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Deadline - Overdue
```
┌─────────────────────────────────────────────────┐ ← RED BORDER
│                                                 │
│   ┌──┐   Complete Homework                     │
│   │❌│   ✓ Owned by Emma  ← Blue, checkmark    │
│   └──┘                                          │
│   ────────────────────────────────────          │
│                                                 │
│   📅 Overdue by 2d             ⭐ 20 pts       │
│                                                 │
│   ⚠️ Overdue – progress impacted ← Red (CONSEQUENCE)│
│                                                 │
└─────────────────────────────────────────────────┘
```

**Key Changes:**
- Ownership: Plain name → "Owned by Name" (blue, checkmark icon)
- Consequence badges added (conditional)
- Motivational hints added (conditional, role-aware)
- Border color matches urgency

---

## Badge Anatomy

### Ownership Badge (Pickups/Deadlines)
```
┌────────────────────────┐
│ ✓ Handled by Dad       │  ← Blue (#007AFF)
└────────────────────────┘    Medium weight
    Icon + Text
```

### Ownership Badge (Events)
```
┌────────────────────────┐
│ 👤 Added by Mom        │  ← Gray/Secondary
└────────────────────────┘    Regular weight
    Icon + Text
```

### Missed Badge
```
┌──────────────┐
│ ⚠️ MISSED    │  ← White text on red
└──────────────┘    Capsule shape
```

### Consequence Badge
```
┌────────────────────────────────┐
│ ⚠️ Streak at risk              │  ← White text on red/orange
└────────────────────────────────┘    Capsule shape
```

### Motivational Hint Badge
```
┌────────────────────────────────┐
│ 💡 Keep your streak alive      │  ← Orange text on light orange bg
└────────────────────────────────┘    Capsule shape
```

### Points Badge
```
┌───────────┐
│ ⭐ 20 pts │  ← Yellow text on light yellow bg
└───────────┘    Capsule shape
```

---

## Color Palette

### Primary Colors
| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Ownership emphasis | Blue | #007AFF | "Handled by", "Owned by" text |
| Missed indicator | Red | #FF3B30 | Missed badge, border, time |
| Consequence | Red/Orange | #FF3B30 / #FF9500 | Consequence badges |
| Motivational hint | Orange | #FF9500 | Hint badges |
| Points | Yellow | #FFCC00 | Points badges |

### Urgency Colors (Deadlines)
| Days Remaining | Border Color | Icon Background |
|----------------|--------------|-----------------|
| < 0 (overdue) | Red | Red |
| 0-2 days | Red | Red |
| 3-7 days | Orange | Orange |
| 8+ days | Green | Green |

---

## Typography

### Pickups Tab
```
Time:       Title2, Bold         (3:00 PM)
Title:      Headline            (School Pickup)
Ownership:  Caption, Medium     (Handled by Dad)
Location:   Caption, Regular    (Main entrance)
```

### Events Tab
```
Title:      Headline            (Soccer Practice)
Time:       Subheadline         (5:00 PM)
Type:       Caption, Medium     ([Sports])
Ownership:  Caption, Regular    (Added by Mom)
Notes:      Caption, Regular    (Bring water bottle)
```

### Deadlines Tab
```
Title:      Headline            (Complete Homework)
Ownership:  Subheadline, Medium (Owned by Emma)
Urgency:    Caption, Semibold   (2 days left)
Points:     Caption, Medium     (20 pts)
Consequence: Caption, Medium    (Streak at risk)
Hint:       Caption, Medium     (Keep your streak alive)
```

---

## Icon Reference

### System Icons Used
```swift
// Ownership
"person.fill.checkmark"      // Pickups, Deadlines
"person.circle.fill"         // Events

// Status
"car.fill"                   // Pickup icon
"exclamationmark.triangle.fill"  // Missed/Urgent
"exclamationmark.circle.fill"    // Due today
"clock.badge.exclamationmark"    // Approaching deadline
"clock"                      // Normal deadline

// Badges
"calendar"                   // Urgency badge icon
"star.fill"                  // Points badge icon
"lightbulb.fill"             // Motivational hint icon
"location.fill"              // Location icon
```

---

## Layout Specifications

### Pickup Row
```
┌─────────────────────────────────┐
│ [Spacing: 16pt]                 │
│ ┌────────┐ [Spacing: 16pt]      │
│ │ 56x56  │ VStack [Spacing: 6]  │
│ │  Icon  │   - Badge (if missed)│
│ │        │   - Time (Title2)    │
│ └────────┘   - Title (Headline) │
│              - Owner (Caption)  │
│              - Location (Caption)│
│ [Spacing: 16pt]                 │
└─────────────────────────────────┘
Padding: 16pt all sides
Corner radius: 12pt
```

### Event Card
```
┌─────────────────────────────────┐
│ [Spacing: 12pt]                 │
│ ┌────┐ [Spacing: 12pt]          │
│ │ 44 │ VStack [Spacing: 6]      │
│ │ x  │   - Title (Headline)     │
│ │ 44 │   - Time (Subheadline)   │
│ └────┘   - HStack [Type + Owner]│
│            - Notes (Caption)    │
│ [Spacing: 12pt]                 │
└─────────────────────────────────┘
Padding: 16pt all sides
Corner radius: 12pt
```

### Deadline Card
```
┌─────────────────────────────────┐
│ [Spacing: 12pt]                 │
│ VStack [Spacing: 12]            │
│   - HStack [Icon + Title/Owner] │
│   - Divider                     │
│   - HStack [Urgency + Points]   │
│   - Consequence badge (if any)  │
│   - Motivational hint (if any)  │
│   - Status badge (if pending)   │
│ [Spacing: 12pt]                 │
└─────────────────────────────────┘
Padding: 16pt all sides
Corner radius: 12pt
Border: 2pt, urgency color, 30% opacity
```

---

## Spacing Guidelines

### Card Spacing
- Padding: 16pt all sides
- Corner radius: 12pt
- Cards spacing: 12pt vertical

### Icon Sizing
- Pickup icon: 56x56pt
- Event icon: 44x44pt
- Deadline icon: 48x48pt
- Badge icons: Caption2 / Caption font size

### Badge Spacing
- Horizontal padding: 8-10pt
- Vertical padding: 3-6pt
- Gap between badges: 8-12pt

---

## Animation & Transitions

### Missed Pickup State
```swift
// Gradient transition
.animation(.easeInOut(duration: 0.3), value: isMissed)

// Border appearance
.animation(.spring(), value: isMissed)
```

### Tab Switching
```swift
.animation(.easeInOut(duration: 0.2), value: selectedTab)
```

### Badge Appearance
```swift
// Fade in with slight scale
.transition(.scale.combined(with: .opacity))
.animation(.spring(response: 0.3), value: showBadge)
```

---

## Accessibility

### VoiceOver Labels

**Pickup (Normal):**
```
"School Pickup at 3:00 PM. Handled by Dad. Main entrance."
```

**Pickup (Missed):**
```
"Missed. School Pickup at 3:00 PM. Handled by Dad. Main entrance."
```

**Event:**
```
"Soccer Practice at 5:00 PM. Sports event. Added by Mom. Bring water bottle."
```

**Deadline:**
```
"Complete Homework. Owned by Emma. 2 days left. 20 points. Streak at risk. Keep your streak alive."
```

### Dynamic Type Support
- All text uses system fonts
- Scales with user's text size preference
- Badges remain readable at all sizes

### Color Contrast
- Blue ownership text: Sufficient contrast on light/dark backgrounds
- Red missed indicators: High contrast (AAA compliant)
- Badge text: White on color ensures readability

---

## Dark Mode Adaptations

### Color Adjustments
| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Card background | secondarySystemGroupedBackground | Automatically adapts |
| Blue ownership | #007AFF | Slightly lighter blue |
| Red missed | #FF3B30 | Slightly lighter red |
| Orange hints | #FF9500 | Slightly lighter orange |

### Icon Visibility
- All icons use system colors that adapt automatically
- Gradients maintain visual hierarchy in both modes

---

## Responsive Layout

### iPhone Portrait
- Standard card layout
- Full width minus horizontal padding (16pt each side)

### iPhone Landscape
- Same card layout (maintains readability)
- More cards visible vertically

### iPad
- Cards maintain max width for readability
- Additional horizontal padding in larger screens

---

## Testing Visuals

### Visual Regression Checklist
- [ ] Ownership labels are blue and medium weight
- [ ] Icons are correct (checkmark variants)
- [ ] Missed pickups have red gradient + badge + border
- [ ] Consequence badges show appropriate colors
- [ ] Motivational hints show orange lightbulb
- [ ] Badges have proper spacing and padding
- [ ] Cards have correct corner radius (12pt)
- [ ] Text hierarchy is maintained
- [ ] Dark mode looks appropriate

### Animation Checklist
- [ ] Tab switching is smooth
- [ ] Missed state transitions smoothly
- [ ] Badges fade in appropriately
- [ ] No layout jumping or flashing

---

## Design Tokens (Reference)

```swift
// Spacing
let cardPadding: CGFloat = 16
let cardSpacing: CGFloat = 12
let iconSpacing: CGFloat = 12
let badgeHorizontalPadding: CGFloat = 10
let badgeVerticalPadding: CGFloat = 6

// Corner Radius
let cardCornerRadius: CGFloat = 12
let iconCornerRadius: CGFloat = 12
let badgeCornerRadius: CGFloat = .infinity // Capsule

// Border
let missedBorderWidth: CGFloat = 2
let missedBorderOpacity: CGFloat = 0.5
let urgencyBorderWidth: CGFloat = 2
let urgencyBorderOpacity: CGFloat = 0.3

// Icon Sizes
let pickupIconSize: CGFloat = 56
let eventIconSize: CGFloat = 44
let deadlineIconSize: CGFloat = 48

// Colors (using system colors)
let ownershipColor = Color.blue
let missedColor = Color.red
let consequenceColor = Color.red // or .orange
let hintColor = Color.orange
let pointsColor = Color.yellow
```

---

## Before/After Comparison

### Pickups Tab
**Before:**
```
🚙 3:00 PM
   School Pickup
   Assigned to: Dad (gray)
   Main entrance
```

**After:**
```
🚙 3:00 PM (bold)
   School Pickup
   ✓ Handled by Dad (blue, prominent)
   📍 Main entrance
```

### Events Tab
**Before:**
```
⚽ Soccer Practice
   5:00 PM
   [Sports] by Mom (gray)
   Bring water bottle
```

**After:**
```
⚽ Soccer Practice
   5:00 PM
   [Sports] 👤 Added by Mom (with icon)
   Bring water bottle
```

### Deadlines Tab
**Before:**
```
⏰ Complete Homework
   Emma (gray)
   2 days left • ⭐ 20 pts
```

**After:**
```
⚠️ Complete Homework
   ✓ Owned by Emma (blue, prominent)
   
   📅 2 days left  |  ⭐ 20 pts
   
   ⚠️ Streak at risk
   💡 Keep your streak alive
```

---

This visual design spec ensures consistent implementation and provides a reference for designers, developers, and QA testers.

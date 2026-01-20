# Testing the Responsibility Timeline

## Quick Test Guide

### Setup
1. Ensure you have at least one parent and one child in the family
2. Create some calendar events and goals with deadlines
3. Navigate to the Calendar tab (Tab 3)

---

## Test 1: Navigation Title
**Expected:** Title should read "Responsibility Timeline" (not "Family Calendar")

**Steps:**
1. Open Calendar tab
2. Look at navigation bar title

✅ **Pass:** Title says "Responsibility Timeline"  
❌ **Fail:** Title says "Family Calendar" or something else

---

## Test 2: Pickups Tab - Ownership Display

**Expected:** Pickups show "Handled by [Parent Name]" in blue with checkmark icon

**Steps:**
1. Go to Pickups tab
2. Create a pickup event (school event or event with "pickup" in title)
3. Check owner display

✅ **Pass:** Shows "Handled by [Name]" in blue with `person.fill.checkmark` icon  
❌ **Fail:** Shows "Assigned to [Name]" in gray or different styling

---

## Test 3: Missed Pickup Detection

**Expected:** Past pickups show red gradient, "Missed" badge, red time, red border

**Steps:**
1. Create a pickup event with time in the past (e.g., 1 hour ago)
2. View pickup in Pickups tab
3. Check visual indicators

✅ **Pass:** Car icon is red gradient, shows "Missed" badge, time is red, card has red border  
❌ **Fail:** Pickup looks the same as future pickups (blue gradient)

**Bonus Test:** Create future pickup and verify it's still blue (not red)

---

## Test 4: Events Tab - Ownership Display

**Expected:** Events show "Added by [Name]" with person.circle icon

**Steps:**
1. Go to Events tab
2. Create any event (sports, family, personal)
3. Check owner display

✅ **Pass:** Shows "Added by [Name]" with `person.circle.fill` icon  
❌ **Fail:** Shows "by [Name]" or different styling

---

## Test 5: Deadlines Tab - Ownership Display

**Expected:** Deadlines show "Owned by [Child Name]" in blue with checkmark icon

**Steps:**
1. Create a goal with a deadline (from Goals tab)
2. Go to Calendar → Deadlines tab on that deadline date
3. Check owner display

✅ **Pass:** Shows "Owned by [Child Name]" in blue with `person.fill.checkmark` icon  
❌ **Fail:** Shows plain name in gray or different styling

---

## Test 6: Consequence Awareness - Overdue

**Expected:** Overdue deadlines show "Overdue – progress impacted" in red capsule

**Steps:**
1. Create a goal with deadline in the past
2. Go to Calendar → Deadlines tab on that date
3. Look for consequence badge

✅ **Pass:** Shows red capsule with "Overdue – progress impacted"  
❌ **Fail:** No consequence text or wrong message

---

## Test 7: Consequence Awareness - Streak at Risk

**Expected:** Deadlines ≤2 days with active streak show "Streak at risk"

**Steps:**
1. Create a goal with a deadline 1-2 days away
2. Complete the goal once to start a streak
3. Go to Calendar → Deadlines tab on the deadline date
4. Look for consequence badge

✅ **Pass:** Shows red capsule with "Streak at risk"  
❌ **Fail:** No consequence text or wrong message

---

## Test 8: Consequence Awareness - Points on the Line

**Expected:** Deadlines ≤7 days with points show "Points on the line: ⭐ X"

**Steps:**
1. Create a goal with deadline 3-7 days away and point value (e.g., 20 pts)
2. Go to Calendar → Deadlines tab on the deadline date
3. Look for consequence badge

✅ **Pass:** Shows orange/red capsule with "Points on the line: ⭐ 20" (or your point value)  
❌ **Fail:** No consequence text or wrong message

---

## Test 9: Role-Aware Messaging - Single Child

**Expected:** Deadlines show personalized messaging focused on self-progress

**Setup:**
1. Ensure family has exactly 1 child
2. Create a goal with deadline 1-7 days away

**Steps:**
1. Go to Calendar → Deadlines tab on deadline date
2. Look for motivational hint (orange capsule with lightbulb icon)

✅ **Pass (with streak):** Shows "Chance to extend your streak"  
✅ **Pass (no streak):** Shows "Finish strong today"  
❌ **Fail:** Shows competitive language or wrong message

---

## Test 10: Role-Aware Messaging - Multiple Children

**Expected:** Deadlines show team-oriented messaging

**Setup:**
1. Ensure family has 2+ children
2. Create a goal with deadline 1-7 days away

**Steps:**
1. Go to Calendar → Deadlines tab on deadline date
2. Look for motivational hint (orange capsule with lightbulb icon)

✅ **Pass (with streak):** Shows "Keep your streak alive"  
✅ **Pass (no streak):** Shows "Stay on track"  
❌ **Fail:** Shows single-child messaging or wrong message

---

## Test 11: No Hints for Distant Deadlines

**Expected:** Deadlines >7 days away show NO motivational hints

**Steps:**
1. Create a goal with deadline 10+ days away
2. Go to Calendar → Deadlines tab on that date
3. Check for motivational hint

✅ **Pass:** NO orange lightbulb badge visible  
❌ **Fail:** Shows motivational hint (should only show for 0-7 days)

---

## Test 12: Events Tab - No Consequences

**Expected:** Events tab shows NO consequence badges

**Steps:**
1. Create any event (sports, family, personal)
2. Go to Calendar → Events tab
3. Look for consequence badges

✅ **Pass:** NO consequence badges on any events  
❌ **Fail:** Consequence badges appear (they should only be on Deadlines)

---

## Test 13: Existing Functionality Preserved

**Expected:** All existing calendar features still work

**Steps:**
1. Test Add Event button → form should open
2. Test week/month view toggle → should switch views
3. Test tab switching → badges should update
4. Test event deletion → context menu should work
5. Test search → should find events
6. Test "Today" button → should jump to today

✅ **Pass:** All features work as before  
❌ **Fail:** Any feature broken or changed unexpectedly

---

## Visual Checklist

### Pickups Tab
- [ ] "Handled by [Name]" in blue with checkmark icon
- [ ] Missed pickups have red gradient car icon
- [ ] Missed pickups show "Missed" badge
- [ ] Missed pickups have red time text
- [ ] Missed pickups have red border

### Events Tab
- [ ] "Added by [Name]" with person.circle icon
- [ ] No consequence badges
- [ ] Clean, minimal design

### Deadlines Tab
- [ ] "Owned by [Child Name]" in blue with checkmark icon
- [ ] Consequence badges appear conditionally
- [ ] Motivational hints adapt to family size
- [ ] Overdue deadlines clearly marked
- [ ] Points badge always visible
- [ ] Urgency color coding (red/orange/green)

---

## Edge Cases to Test

1. **Pickup at exactly current time** → Should be blue (not missed)
2. **Deadline exactly 0 days (due today)** → Should show "Due today!" and consequences
3. **Deadline exactly 1 day (due tomorrow)** → Should show "Due tomorrow" and hints
4. **Goal with no target date** → Should NOT appear in Deadlines tab
5. **Completed goal with deadline** → Should NOT appear in Deadlines tab
6. **Event with empty notes** → Should display correctly without notes section
7. **Multiple pickups on same day** → All should show ownership context
8. **Switching from 1 to 2 children** → Deadline messaging should update

---

## Performance Check

- [ ] Tab switching is smooth (no lag)
- [ ] Scrolling is smooth with many items
- [ ] Badge counts update instantly
- [ ] No console errors or warnings
- [ ] Memory usage stable

---

## Accessibility Check

- [ ] All badges have readable text (not just icons)
- [ ] Color is not the only indicator (icons + text)
- [ ] VoiceOver can read all elements
- [ ] Text is readable at various Dynamic Type sizes

---

## Success Criteria

✅ **All tests pass**  
✅ **No regressions to existing features**  
✅ **Calendar feels like a responsibility timeline, not just a schedule**  
✅ **Ownership is prominent and clear**  
✅ **Consequences are visible but not overwhelming**  
✅ **Messaging adapts to family context**

---

## Quick Bug Report Template

If you find an issue:

```
**Test:** [Test number/name]
**Expected:** [What should happen]
**Actual:** [What actually happened]
**Steps to reproduce:**
1. 
2. 
3. 

**Environment:**
- Family size: [1 child / 2+ children]
- Tab: [Pickups / Events / Deadlines]
- Device/Simulator: 
```

---

## Notes

- Consequence hints are **display logic only** — no changes to data models
- Ownership context is **visual only** — no changes to business logic
- Role-aware messaging reuses existing `isSingleChild` detection from Dashboard
- All existing calendar features remain unchanged

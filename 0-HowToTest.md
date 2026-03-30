# 🧪 How to Test FamSphere (Single Device Guide)

## Overview

This guide shows you how to fully test FamSphere with just one Apple device and account. You'll use the built-in **User Switcher** to switch between different family members.

---

## 📱 Initial Setup (One Time)

### Step 1: Run the App
1. Build and run the app in Xcode or on your device
2. Complete the onboarding flow

### Step 2: Create Your Test Family
Create a family with at least one parent and 2-3 children:

**Example Family:**
- **Mom** - Parent (you)
- **Alex** - Child
- **Sam** - Child
- **Jordan** - Child (optional, for better leaderboard testing)

💡 **Tip:** Use simple, distinct names so you can quickly identify who you're testing as.

---

## 🔄 How to Switch Users

### Using the User Switcher:

1. **Go to Settings Tab** (Tab 5 - gear icon)
2. **Tap "Switch User"** in the "Current User" section
3. **Select any family member** from the list
4. **Done!** The app immediately updates to show that user's view

### Quick Reference:
```
Settings → Switch User → Select Member → Auto-updates
```

---

## 📋 Core Test Scenarios

### Scenario 1: Child Creates a Goal ✅

**As Child (Alex):**
1. Switch to "Alex" (child)
2. Go to **Dashboard** tab
3. Tap **"Add New Goal"** button
4. Fill in:
   - Title: "Read 30 minutes daily"
   - Toggle ON: "Track as Habit"
   - Frequency: Daily
   - Point Value: 10 points
   - Toggle ON: "Share completions to chat" (optional)
5. Tap **"Add"**

**Expected Results:**
- ✅ Goal appears in Goals tab
- ✅ Status badge shows "Pending" (orange)
- ✅ Cannot mark it complete yet
- ✅ Message: "Waiting for parent approval"

---

### Scenario 2: Parent Approves Goal ✅

**As Parent (Mom):**
1. Switch to "Mom" (parent)
2. Go to **Dashboard** tab
3. **See orange notification badge** on toolbar
4. Tap the **approval queue button**
5. Review the goal "Read 30 minutes daily"
6. Tap **"Approve"** (green button)

**Expected Results:**
- ✅ Goal status changes to "Approved"
- ✅ Chat message posted: "✅ 'Read 30 minutes daily' has been approved for Alex!"
- ✅ Badge disappears from toolbar
- ✅ Goal now appears in family goals list

**Alternative: Test Rejection:**
1. Instead of Approve, tap **"Reject"**
2. Enter reason: "Please make it 15 minutes instead"
3. See rejection note appear on goal card
4. Chat message: "⚠️ 'Goal' needs revision..."

---

### Scenario 3: Child Completes Goal ✅

**As Child (Alex):**
1. Switch back to "Alex"
2. Go to **Goals** tab
3. Find your approved goal
4. Tap **"Mark Complete"** button

**Expected Results:**
- ✅ Button changes to "Completed Today" (green)
- ✅ Points added: "+10" appears
- ✅ Streak starts: 🔥 1 badge appears
- ✅ Progress bar updates
- ✅ If sharing enabled: Chat message posted
- ✅ Dashboard points badge updates
- ✅ Activity feed shows completion

**Test Unchecking:**
- Tap "Completed Today" again
- ✅ Completion removed
- ✅ Points subtracted
- ✅ Streak recalculated

---

### Scenario 4: Build a Streak 🔥

**Method 1: Manual Date Changing (iOS Settings)**
1. As "Alex", mark goal complete today
2. **Close the app**
3. Go to **iOS Settings → General → Date & Time**
4. Toggle OFF "Set Automatically"
5. Set date to **tomorrow**
6. **Open app again**
7. Mark goal complete
8. Repeat for day 3, 4, etc.
9. ⚠️ **Important:** Re-enable "Set Automatically" when done

**Method 2: Xcode Simulator Time**
1. In Xcode: **Debug → Simulate Location/Time**
2. Set custom date/time
3. Mark goals complete
4. Advance date
5. Repeat

**Expected Results:**
- ✅ Streak increments each consecutive day: 🔥 1, 🔥 2, 🔥 3...
- ✅ At day 3: Milestone alert appears! "You've reached a 3-day streak!"
- ✅ At day 7: Another milestone! "You've reached a 7-day streak!"
- ✅ Milestone posted to chat as important message
- ✅ "Best: X 🔥" updates in goal card

**Breaking a Streak:**
- Skip a day (don't mark complete)
- ✅ Streak resets to 0
- ✅ Longest streak preserved

---

### Scenario 5: Test Family Leaderboard 🏆

**Setup (as different children):**

1. Switch to "Alex" - Create 2 goals, complete 5 times = 50 points
2. Switch to "Sam" - Create 3 goals, complete 7 times = 70 points
3. Switch to "Jordan" - Create 1 goal, complete 10 times = 100 points

**As Parent (Mom):**
1. Switch to "Mom"
2. Go to **Dashboard**
3. Scroll to **"Family Leaderboard"** widget

**Expected Results:**
- ✅ Jordan shows 🥇 (100 points)
- ✅ Sam shows 🥈 (70 points)
- ✅ Alex shows 🥉 (50 points)
- ✅ Each row shows: goals count, best streak
- ✅ Sorted by points (highest first)

**As Child:**
- Switch to any child
- Dashboard shows **"Your Progress"** widget
- ✅ Displays rank: "You're ranked #X in the family!"
- ✅ Color-coded: Gold (#1), Silver (#2), Bronze (#3)

---

### Scenario 6: Test Deadlines 📅

**As Child (Alex):**
1. Create new goal: "Finish science project"
2. Toggle ON: "Set Target Date"
3. Pick date **3 days from now**
4. Set point value: 50
5. Tap "Add"

**As Parent (Mom):**
1. Switch to Mom
2. Approve the goal

**Back as Child (Alex):**
1. Go to **Dashboard**
2. Scroll to **"Upcoming Deadlines"** widget

**Expected Results:**
- ✅ Goal appears with countdown: "In 3 days"
- ✅ Color: Orange (3-7 days warning)
- ✅ Shows target date
- ✅ Shows your name as creator

**Test Urgency Colors:**
- 8+ days: 🟢 Green (plenty of time)
- 3-7 days: 🟠 Orange (approaching)
- 0-2 days: 🔴 Red (urgent!)
- Set goal to tomorrow → See red "Due tomorrow"
- Set goal to today → See red "Due today!"
- Set goal to yesterday → See red "Overdue by 1d" with ⚠️ icon

---

### Scenario 7: Test Statistics 📊

**Prerequisites:**
- Need at least 5-10 completions on a goal
- Complete on different days of the week

**As Child with Data:**
1. Go to **Goals** tab
2. Find goal with completions
3. Tap **"View Statistics"** (purple link)

**Expected Results:**

**Stats Grid:**
- ✅ Total Completions count
- ✅ Last 30 Days count
- ✅ Longest Streak number
- ✅ Completion Rate percentage

**Weekly Pattern:**
- ✅ Bar chart shows days (Mon-Sun)
- ✅ Tallest bar highlighted orange
- ✅ Insight: "You complete this goal most often on [Day]s!"

**Timeline:**
- ✅ Created date
- ✅ First completion date
- ✅ Last completion: "X days ago"
- ✅ Target date (if set)

**Recent Completions:**
- ✅ Last 10 dates listed
- ✅ Shows "Today" for same-day
- ✅ Shows "Xd ago" for others

**Rewards:**
- ✅ Points per completion
- ✅ Total points earned from this goal

---

### Scenario 8: Test Points Summary 💰

**As Child:**
1. Go to **Dashboard**
2. Tap the **yellow points badge** (top-left)
   OR
3. Tap **"Details"** on points summary card

**Expected Results:**

**Header:**
- ✅ Large total points number
- ✅ Gradient star icon

**Stats Grid:**
- ✅ Active Goals
- ✅ Total Completions
- ✅ Best Streak (tappable!)
- ✅ Avg Completion %

**Top Goals Leaderboard:**
- ✅ #1, #2, #3... ranked by points earned
- ✅ Shows completions count
- ✅ Points earned per goal

**Tap "Best Streak":**
- ✅ Opens Streak Details view
- ✅ Shows next milestones (3d, 7d, 14d, 30d, 50d, 100d)
- ✅ Progress bars to milestones
- ✅ Checkmarks on completed milestones
- ✅ Top 3 active streaks with medals

---

## 🎯 Complete Feature Checklist

### Core Features:
- [ ] Child can create goals
- [ ] Goals show "Pending" status
- [ ] Parent sees approval notification badge
- [ ] Parent can approve goals
- [ ] Parent can reject goals with notes
- [ ] Rejection note appears on goal card
- [ ] Approved goals can be completed
- [ ] Pending/rejected goals cannot be completed
- [ ] Points accumulate correctly
- [ ] Points badge updates in real-time

### Streaks:
- [ ] Streak starts at 1 on first completion
- [ ] Streak increments on consecutive days
- [ ] Streak resets when day is skipped
- [ ] Longest streak is preserved
- [ ] Milestone alerts appear (3, 7, 14, 30, 50, 100)
- [ ] Milestone posted to chat
- [ ] Flame badge shows on goal card
- [ ] "Best: X 🔥" displays in progress section

### Deadlines:
- [ ] Can set target date when creating goal
- [ ] Countdown shows correctly
- [ ] Colors change based on urgency (green/orange/red)
- [ ] "Due today" message for today
- [ ] "Due tomorrow" for tomorrow
- [ ] "Overdue by Xd" for past deadlines
- [ ] Warning icon (⚠️) for overdue
- [ ] Deadlines appear in dashboard widget
- [ ] Sorted by urgency (nearest first)

### Dashboard Widgets:
- [ ] Welcome header shows current user name
- [ ] Family Overview shows correct counts
- [ ] Leaderboard (parents) shows medals 🥇🥈🥉
- [ ] Personal Progress (children) shows rank
- [ ] Recent Activity shows last 10 items
- [ ] Activity has correct icons/colors
- [ ] Upcoming Deadlines shows top 5
- [ ] Weekly Stats calculate correctly
- [ ] Quick Actions show role-appropriate buttons

### Statistics:
- [ ] Statistics button appears after completions
- [ ] Total completions count is accurate
- [ ] Last 30 days filters correctly
- [ ] Completion rate calculates properly
- [ ] Weekly pattern chart displays
- [ ] Best day insight is correct
- [ ] Timeline shows all dates
- [ ] Recent completions list (10 max)
- [ ] Rewards summary displays correctly

### Chat Integration:
- [ ] Completions post to chat (if enabled)
- [ ] Streak info included in completion message
- [ ] Milestone achievements post to chat (important)
- [ ] Approval/rejection posts to chat (important)
- [ ] Messages show correct author
- [ ] Important messages marked with flag

### User Switching:
- [ ] Can switch to any family member
- [ ] View updates immediately
- [ ] Data persists across switches
- [ ] Role-specific features show/hide correctly
- [ ] Toolbar updates for role

---

## 💡 Advanced Testing Tips

### Test Edge Cases:

**Empty States:**
- [ ] No goals created yet → Shows empty state message
- [ ] No completions yet → "View Statistics" button hidden
- [ ] No deadlines set → Deadlines widget hidden
- [ ] No pending approvals → "All caught up!" message
- [ ] No activity yet → Activity feed shows empty state

**Multiple Completions:**
- [ ] Complete same goal twice in one day → Only counts once
- [ ] Complete multiple goals same day → All appear in activity
- [ ] Uncheck completion → Points subtracted, streak recalculated
- [ ] Delete goal with completions → All data removed

**Approval Edge Cases:**
- [ ] Reject without note → Error, note is required
- [ ] Approve already approved → No duplicate message
- [ ] Delete pending goal → Approval badge updates
- [ ] Create 5+ pending goals → Counter shows correct number

**Deadline Edge Cases:**
- [ ] No deadline set → No badge, no deadline banner
- [ ] Deadline in past → Shows as overdue with red
- [ ] Complete overdue goal → Still counts, points awarded
- [ ] Change device time → Countdown updates
- [ ] Deadline today but not complete → Shows urgent red

**Streak Edge Cases:**
- [ ] Complete on day 1 only → Streak = 1
- [ ] Skip day 2, complete day 3 → Streak resets to 1
- [ ] Complete days 1-6, skip 7, complete 8 → Streak = 1, longest = 6
- [ ] Uncheck today's completion → Streak may reset
- [ ] Complete multiple goals same day → Each has own streak

### Performance Testing:

**Create Many Items:**
1. Create 20+ goals
2. Complete 100+ times
3. Test scrolling performance
4. Check leaderboard with many children
5. Verify statistics with large datasets

**Rapid Actions:**
1. Quickly toggle completions
2. Rapidly switch users
3. Create/delete goals in succession
4. Check for crashes or lag

### Visual Testing:

**Dark Mode:**
1. Go to Settings → Appearance → Dark
2. Verify all widgets readable
3. Check contrast on badges
4. Ensure gradients look good

**Different Text Sizes:**
1. iOS Settings → Display & Brightness → Text Size
2. Increase to max
3. Check for text truncation
4. Verify layouts don't break

**Landscape Orientation (iPad):**
1. Rotate device
2. Check responsive layouts
3. Verify widgets stack properly

---

## 🐛 Troubleshooting Common Issues

### Issue: Leaderboard is empty
**Solution:** Create goals for at least 2 different children and complete them to earn points.

### Issue: No streak appearing after completion
**Solution:** Make sure you're completing on consecutive days. Use date simulation to test faster.

### Issue: Approval badge doesn't show
**Solution:** 
1. Make sure you created goal as a child
2. Switch to parent account
3. Badge appears only if pending goals exist

### Issue: Statistics button not visible
**Solution:** Complete the goal at least once. Button only appears when there's data.

### Issue: User switch doesn't update view
**Solution:**
1. Navigate away from current tab
2. Come back to see updates
3. Or force-close and reopen app

### Issue: Points don't match expected total
**Solution:**
1. Check each goal's point value
2. Count actual completions
3. Math: completions × point value per goal
4. Verify in Points Summary view

### Issue: Streak reset unexpectedly
**Solution:**
1. Check if you skipped a day
2. Verify completion dates in Statistics
3. Recalculate manually: consecutive days only

### Issue: Deadline shows wrong color
**Solution:**
1. Verify current date vs. target date
2. Check calculation logic:
   - Green: 8+ days
   - Orange: 3-7 days
   - Red: 0-2 days or overdue

---

## ⚡ Quick 2-Minute Smoke Test

Run this flow to validate core functionality:

1. **Switch to Child** (e.g., Alex)
2. **Create goal** → "Test Goal", Daily, 10 points
3. **Switch to Parent** (e.g., Mom)
4. **See badge** → Open approval queue
5. **Approve goal** → Verify chat message
6. **Switch to Child**
7. **Complete goal** → See points added
8. **Check Dashboard** → Verify all widgets updated
9. **Switch to Parent**
10. **Check Leaderboard** → See child ranked

✅ **If all steps work, core loop is healthy!**

---

## 🎨 Visual Checklist

### Colors (Light Mode):
- [ ] Green for completions/success
- [ ] Red for urgent/overdue/rejected
- [ ] Orange for warnings/streaks/pending
- [ ] Yellow for points/rewards
- [ ] Blue for info/navigation
- [ ] Purple for statistics

### Icons:
- [ ] ⭐ Stars for points
- [ ] 🔥 Flames for streaks
- [ ] ✅ Checkmarks for completions
- [ ] 🎯 Targets for goals
- [ ] 📅 Calendars for deadlines
- [ ] 🏆 Trophies for achievements
- [ ] 🥇🥈🥉 Medals for rankings

### Badges:
- [ ] Rounded capsule shapes
- [ ] Icon + text or just number
- [ ] Consistent padding
- [ ] Background opacity ~20%
- [ ] Foreground matches color theme

### Cards:
- [ ] Rounded corners (12-16pt radius)
- [ ] Secondary background color
- [ ] Consistent padding (16pt)
- [ ] Dividers between list items
- [ ] Shadow/elevation on tap (if button)

---

## 📊 Testing Metrics

Track these during testing:

**Goal Creation:**
- Time to create: < 30 seconds
- Approval time: < 10 seconds
- Completion time: < 5 seconds

**Navigation:**
- Tab switches: Instant
- User switches: < 1 second
- Sheet presentations: Smooth animation
- Dismissals: Smooth animation

**Data Updates:**
- Points badge: Immediate
- Leaderboard: On next view
- Activity feed: On next view
- Statistics: On sheet open

---

## 🎉 Testing Complete!

Once you've run through all scenarios, you've validated:

✅ Complete approval workflow  
✅ Points and rewards system  
✅ Streak tracking with milestones  
✅ Deadline management with urgency  
✅ Comprehensive statistics  
✅ Family dashboard with 6 widgets  
✅ Role-based permissions  
✅ Chat integration  
✅ User switching for testing  

**Your FamSphere app is production-ready!** 🚀

---

## 📝 Notes for Future Testing

### After Code Changes:
- [ ] Run smoke test (2-minute flow)
- [ ] Test affected feature specifically
- [ ] Verify no regressions in related features

### Before Release:
- [ ] Test on physical device
- [ ] Test with real family members
- [ ] Verify iCloud sync (if multiple devices)
- [ ] Test with different iOS versions
- [ ] Check App Store screenshots match reality

### User Feedback Testing:
- [ ] Have real users try the app
- [ ] Observe without helping
- [ ] Note confusion points
- [ ] Record feature requests
- [ ] Track any crashes/bugs

---

**Happy Testing! 🧪**

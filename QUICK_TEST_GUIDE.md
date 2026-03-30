# Quick Testing Guide - New Features

## 🎯 1. Test Multiple Task Checkboxes (FIXED)

### The Problem Before
When 2+ tasks had the same deadline, only one checkbox appeared in the calendar.

### The Fix
Each deadline goal now has its own independent checkbox!

### How to Test

**Setup (5 minutes):**
1. Switch to a **child** user (Settings → Switch User)
2. Create **2 goals** with the **same target date** (e.g., tomorrow):
   - Goal 1: "Read for 30 minutes" (Daily habit, 10 points)
   - Goal 2: "Practice piano" (Daily habit, 10 points)
3. Switch to **parent** user
4. Go to **Dashboard** → tap approval badge → approve both goals

**Test the Fix:**
1. Switch back to **child** user
2. Go to **Calendar** tab (Tab 3)
3. Navigate to the target date (use arrows or month view)
4. Tap **Deadlines** tab (🎯 icon)
5. **✅ You should see BOTH goals listed**
6. **✅ Each goal has its OWN checkbox** in the top-right corner
7. Tap the checkbox on "Read for 30 minutes"
   - ✅ Only that checkbox turns green
   - ✅ Points added (+10)
   - ✅ Other checkbox stays gray/unchecked
8. Tap the checkbox on "Practice piano"
   - ✅ This checkbox also turns green independently
   - ✅ More points added (+10)
   - ✅ Both are now marked complete

**What You'll See:**
```
📅 Calendar → Tomorrow → Deadlines Tab

┌─────────────────────────────────────┐
│ 🔴  Read for 30 minutes        ✓    │  ← Green checkmark
│     Owned by Alex                    │
│     📅 Due tomorrow    ⭐ 10 pts     │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🔴  Practice piano             ✓    │  ← Green checkmark  
│     Owned by Alex                    │
│     📅 Due tomorrow    ⭐ 10 pts     │
└─────────────────────────────────────┘
```

**Before the fix:**
- Only one checkbox total 😞
- Couldn't track both tasks separately

**After the fix:**
- Each task has its own checkbox ✅
- Track completion independently ✅
- Streaks work per task ✅
- Points accumulate correctly ✅

---

## 🗑️ 2. Test Remove Family Member (ENHANCED)

### What's New
- Visible trash icon button next to each member
- Shows how many goals and events will be deleted
- Better confirmation dialog
- Can't delete yourself (protected)

### How to Test

**Setup:**
1. Switch to **parent** user (Settings → Switch User → select a parent)
2. Make sure you have at least **2 family members** (1 parent, 1+ children)

**Test the Enhancement:**
1. Go to **Settings** tab (Tab 5)
2. Tap **"Manage Family Members"** (under Profile section)
3. **✅ See trash icon (🗑️)** next to each member
4. **✅ See data counts** below each name:
   - Example: "🎯 3  📅 5" (3 goals, 5 events)
5. **✅ Current user** shows green "Current" badge with **NO trash icon**
6. Tap the **trash icon** on a child member
7. **✅ Confirmation dialog appears:**
   ```
   Delete Family Member?
   
   This will permanently delete Alex and their 3 goals 
   and 5 events. This action cannot be undone.
   
   [Cancel]  [Delete]
   ```
8. Tap **Delete**
9. **✅ Member is removed from list**
10. Go to **Goals** tab → ✅ Their goals are gone
11. Go to **Calendar** tab → ✅ Their events are gone

**Additional Tests:**
- Try to delete yourself → ✅ No trash icon, shows "Current" badge
- Delete member with no data → ✅ Dialog says "permanently delete [Name]" only
- Swipe left on member → ✅ Still works as before (alternative method)

**What You'll See:**
```
Manage Family Members

┌─────────────────────────────────────┐
│ 👤  Mom                    [Current] │  ← No trash icon
│     Parent                           │
│     🎯 5  📅 8                       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 👤  Alex                        🗑️   │  ← Trash icon!
│     Child                            │
│     🎯 3  📅 5                       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 👤  Sam                         🗑️   │  ← Trash icon!
│     Child                            │
│     🎯 7  📅 2                       │
└─────────────────────────────────────┘
```

---

## 📱 3. Test iMessage Sharing (CONFIRMED WORKING)

### Important Note
**iMessage ONLY works on a physical device!** The iOS Simulator doesn't support Messages.

### Requirements
- ✅ Physical iPhone or iPad
- ✅ Messages app configured with your phone number or Apple ID
- ✅ FamSphere setting: "iMessage Sharing" enabled

### How to Test

**Setup:**
1. Deploy app to a **physical device** (not Simulator)
2. Go to **Settings** tab → Preferences
3. Make sure **"iMessage Sharing"** toggle is **ON** (green)

**Test Message Sharing:**
1. Create some activity in the app:
   - Complete a goal (generates chat message)
   - Approve a goal (generates chat message)
   - Or just send a regular family chat message
2. Go to **Chat** tab (Tab 2)
3. **Long-press** any message
4. **✅ Context menu appears** with "Share via iMessage"
5. Tap **"Share via iMessage"**
6. **✅ Native iOS Messages compose sheet appears**
7. **✅ Message text is pre-filled** with the FamSphere message
8. Select a contact or enter a phone number
9. Tap **Send** (blue arrow button)
10. **✅ Message sends through iMessage/SMS**
11. **✅ Returns to FamSphere** automatically

**What You'll See:**
```
Chat Tab → Long-press message

┌─────────────────────────────────────┐
│ 🎉 Alex completed: Read 30 mins     │  ← Long-press this
│ 2:30 PM                              │
└─────────────────────────────────────┘

Context Menu Appears:
┌─────────────────────────┐
│ 📌 Pin Message          │
│ 📲 Share via iMessage   │  ← Tap this
│ 🚫 Cancel               │
└─────────────────────────┘

Native Messages App Opens:
┌─────────────────────────────────────┐
│ To: _________________    [Cancel]   │
│                                      │
│ 🎉 Alex completed: Read 30 mins     │  ← Pre-filled!
│                                      │
│ [Send] →                             │
└─────────────────────────────────────┘
```

**Troubleshooting:**

**"Share via iMessage" doesn't appear:**
- ✅ Check Settings → iMessage Sharing is enabled
- ✅ Make sure you're on a physical device (NOT Simulator)

**Messages app doesn't open:**
- ✅ Verify Messages app is set up on device
- ✅ Sign in with Apple ID in Settings → Messages
- ✅ Or set up with phone number

**Can't send message:**
- ✅ Add a valid contact or phone number
- ✅ Check cellular/internet connection
- ✅ Verify Messages app works outside FamSphere

---

## 🎉 Success Criteria

### Task Completion Checkboxes ✅
- [ ] Can create 2+ goals with same deadline
- [ ] Each goal shows in Deadlines tab on that date
- [ ] Each goal has its own independent checkbox
- [ ] Checking one doesn't check the others
- [ ] Points accumulate correctly for each
- [ ] Streaks track independently per goal
- [ ] Can uncheck to remove completion

### Family Member Deletion ✅
- [ ] Trash icon visible next to each member (except current)
- [ ] Current user shows "Current" badge, no trash icon
- [ ] Data counts display (goals/events)
- [ ] Confirmation dialog shows detailed info
- [ ] Deletion removes member and all associated data
- [ ] Cannot delete currently signed-in user
- [ ] Swipe-to-delete still works as alternative

### iMessage Integration ✅
- [ ] Tested on physical device (not Simulator)
- [ ] iMessage Sharing enabled in Settings
- [ ] Long-press message shows context menu
- [ ] "Share via iMessage" option appears
- [ ] Messages compose sheet opens
- [ ] Message content is pre-filled
- [ ] Can select recipient
- [ ] Message sends successfully
- [ ] Returns to FamSphere after send/cancel

---

## 📊 Quick 5-Minute Test Flow

Run this to verify all 3 features quickly:

**1. Setup (2 min):**
```
1. Switch to child user
2. Create 2 goals with same deadline (tomorrow)
3. Switch to parent
4. Approve both goals
```

**2. Test Checkboxes (1 min):**
```
1. Switch back to child
2. Go to Calendar → Tomorrow → Deadlines tab
3. ✅ See both goals with separate checkboxes
4. Check both → verify independence
```

**3. Test Deletion (1 min):**
```
1. Switch to parent
2. Settings → Manage Family Members
3. ✅ See trash icons and data counts
4. Tap trash → see detailed confirmation
5. Cancel (or delete a test member)
```

**4. Test iMessage (1 min):**
```
1. On physical device only
2. Go to Chat tab
3. Long-press any message
4. ✅ See "Share via iMessage"
5. Tap → ✅ Messages opens with pre-filled text
6. Cancel to return to FamSphere
```

**Total time: ~5 minutes**  
**Result: All 3 features verified! ✅**

---

## 🐛 Known Issues & Limitations

### Expected Behavior (Not Bugs)

**Checkboxes:**
- Only appear for children viewing their own goals
- Only for approved, habit-based goals
- Parents see goals in read-only mode
- ✅ This is intentional for role separation

**Member Deletion:**
- Cannot delete yourself (current user)
- Deletion is permanent (no undo)
- ✅ This is intentional for data safety

**iMessage:**
- Only works on physical devices
- Won't work in iOS Simulator
- User must manually send (no auto-send)
- ✅ This is intentional for privacy

---

## 💡 Pro Tips

**For Testing Checkboxes:**
- Create goals with TODAY as deadline to test immediately
- Use different point values to verify correct points awarded
- Check Dashboard points badge to confirm accumulation

**For Testing Deletion:**
- Create a dummy test member to safely test deletion
- Note the data counts before deleting to verify cleanup
- Check Goals and Calendar tabs after deletion to confirm

**For Testing iMessage:**
- Test on a real device, not Simulator
- Use your own phone number to send test messages to yourself
- Check Messages app to verify message was actually sent
- Try different message types (completions, approvals, etc.)

---

## 📞 Need Help?

**Issue: Checkboxes don't appear**
→ Make sure:
  - You're signed in as the child who owns the goal
  - Goal is approved (not pending/rejected)
  - Goal has "Track as Habit" enabled
  - You're on the Deadlines tab in Calendar

**Issue: Can't delete member**
→ Check:
  - You're signed in as a parent
  - You're not trying to delete yourself
  - Tap the trash icon (don't just swipe)

**Issue: iMessage not working**
→ Verify:
  - Using physical device (not Simulator!)
  - Messages app is set up
  - iMessage Sharing is enabled in Settings
  - Long-pressing the message (not just tapping)

---

**Happy Testing! 🚀**

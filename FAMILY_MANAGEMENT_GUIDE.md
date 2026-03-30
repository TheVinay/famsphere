# Family Management Guide

## Two Systems Explained

Your app currently has **two different ways** to manage family members:

### 1. 🧪 Local Testing Mode (Debug Only)
**Location:** Settings → Switch User (only visible in DEBUG builds)

**How it works:**
- Manually add family members on a single device
- Switch between different user profiles locally
- All data stored in local SwiftData database
- **No real multi-device support**

**When to use:**
- Testing the app during development
- Trying out different user perspectives
- Demos on a single device

**Note:** This is why your "first user" seems to disappear - they're just another local profile that can be selected via "Switch User"

### 2. ✅ CloudKit Family Sharing (Production)
**Location:** Settings → Family Sharing

**How it works:**
1. **Parent creates family group:**
   - Open Settings → Family Sharing
   - Tap "Create Family Group"
   
2. **Parent invites family members:**
   - Tap "Invite Family Member"
   - App generates a unique invitation URL
   - Share via Messages, Email, AirDrop, etc.
   
3. **Family members accept invitation:**
   - Click the invitation link on their device
   - Opens FamSphere app
   - Signs in with their Apple ID
   - Automatically gets access to shared data

**Benefits:**
- ✅ Real multi-device support
- ✅ Each person uses their own device
- ✅ Secure Apple ID authentication
- ✅ Automatic iCloud sync across all family members
- ✅ Family Sharing permissions (owner can remove members)
- ✅ Built on Apple's CloudKit framework

## Recommended Setup

### For Development/Testing:
1. Use **Local Testing Mode** (Settings → Switch User)
2. Add multiple family members manually
3. Switch between them to test different views
4. Keep in DEBUG builds only

### For Production/Real Use:
1. Use **CloudKit Family Sharing** (Settings → Family Sharing)
2. Parent creates the family group
3. Parent invites each family member via URL
4. Each family member installs app and accepts invite
5. Everyone sees shared data automatically

## Common Issues

### Issue: "My first user disappeared when I added another member"
**Cause:** You're using Local Testing Mode, which treats all users equally. The "first user" didn't disappear - they're just in the list with everyone else.

**Solution:** 
- Go to Settings → Switch User
- Select your first user from the list
- All users are saved - just select the one you want

### Issue: "How do I really add family members?"
**For Production:**
- Use Settings → Family Sharing → Create Family Group
- Then invite members via the generated URL

**For Testing:**
- Use Settings → Switch User (DEBUG only)
- Add members manually for local testing

## Data Sync Explained

### Local Testing Mode:
- All data stored on one device only
- No actual multi-user sync
- Just simulates different user views

### CloudKit Family Sharing:
- Data stored in iCloud
- Automatically syncs across all family members' devices
- Each person sees updates in real-time
- Requires iCloud account and internet connection

## Migration Path

If you've been using Local Testing Mode and want to switch to CloudKit:

1. **On Parent's Device:**
   - Go to Settings → Family Sharing
   - Tap "Create Family Group"

2. **Invite Real Family Members:**
   - Tap "Invite Family Member"
   - Send invitation URL to each family member
   
3. **Each Family Member:**
   - Installs FamSphere app
   - Opens invitation URL
   - Signs in with their Apple ID
   - Completes onboarding

4. **Optional - Clean Up Local Data:**
   - Remove local test users from "Manage Local Members"
   - Keep using CloudKit Family Sharing going forward

## Debug vs. Release Builds

The Local Testing Mode is wrapped in `#if DEBUG`:
- **DEBUG builds:** Shows "Switch User" option
- **RELEASE builds:** Only shows CloudKit Family Sharing

This ensures users in production only see the real family sharing system.

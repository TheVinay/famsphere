# 🔧 Apple ID Invitation Troubleshooting Checklist

## Issue: Unable to Invite Members via Apple ID in Debug Mode

When running your app on a physical device in debug mode, family invitations via Apple ID may not work. Here's a comprehensive checklist to fix this issue.

---

## ✅ Code Fixes (COMPLETED)

### 1. Fixed CloudKitSharingManager.swift
- ✅ Removed `@MainActor` from class declaration
- ✅ Added proper `MainActor.run` blocks for @Published property updates
- ✅ Fixed thread safety issues with CloudKit async operations

**Result:** CloudKit operations should now work correctly without thread-related crashes.

---

## 🔍 Xcode Project Settings (CHECK THESE)

### 2. Verify iCloud Capability

1. Open your project in Xcode
2. Select your app target (`FamSphere`)
3. Go to **Signing & Capabilities** tab
4. Look for **iCloud** capability

**If iCloud is NOT present:**
- Click **+ Capability** button
- Add **iCloud**
- Check the following boxes:
  - ☑️ **CloudKit**
  - ☑️ **CloudKit Database** (Private Database should be selected)

**If iCloud IS present:**
- Verify container ID matches: `iCloud.VinPersonal.FamSphere`
- Ensure "CloudKit" checkbox is checked

---

### 3. Check Signing & Provisioning

**Development Signing:**
1. Go to **Signing & Capabilities**
2. Verify **Team** is selected (not "None")
3. Check **Signing Certificate** is valid
4. Verify **Provisioning Profile** includes iCloud entitlement

**Common Issues:**
- ❌ Using "Automatically manage signing" but not signed into Xcode with Apple ID
- ❌ Provisioning profile doesn't include CloudKit entitlement
- ❌ Different team ID than container ID

**Fix:**
- Sign into Xcode: **Xcode → Settings → Accounts**
- Add your Apple ID if not present
- Download provisioning profiles

---

### 4. Verify Bundle Identifier

**Check these match:**

1. **Xcode Target:**
   - Go to **General** tab
   - Look at **Bundle Identifier**: Should be something like `com.VinPersonal.FamSphere`

2. **CloudKit Container:**
   - Go to **Signing & Capabilities** → **iCloud**
   - Container should be: `iCloud.VinPersonal.FamSphere`
   - These should match (without the `iCloud.` prefix)

---

### 5. Check Entitlements File

1. In Xcode, find `FamSphere.entitlements` file (or similar)
2. Open it and verify it contains:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.VinPersonal.FamSphere</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)$(CFBundleIdentifier)</string>
</dict>
</plist>
```

**If file doesn't exist or is missing keys:**
- Delete the iCloud capability
- Re-add it (Xcode will regenerate the entitlements file)

---

## 📱 Device Settings (CHECK THESE)

### 6. Verify iCloud Sign-In

**On your test iPhone:**

1. Open **Settings** app
2. Tap your name at the top
3. Verify you're signed in with an Apple ID
4. Tap **iCloud**
5. Scroll down and verify **iCloud Drive** is ON

**If iCloud Drive is OFF:**
- Turn it ON
- Wait a few minutes for sync to initialize
- Restart your app

---

### 7. Check App-Specific iCloud Settings

**On your test iPhone:**

1. Go to **Settings** → **[Your Name]** → **iCloud**
2. Scroll down to **Apps Using iCloud**
3. Find **FamSphere** in the list
4. Make sure it's toggled ON

**If FamSphere is not listed:**
- This is normal for development builds
- It will appear after first launch
- Launch the app, then check again

---

## 🌐 Network & Connectivity

### 8. Verify Internet Connection

CloudKit requires a working internet connection:

- ✅ Connected to Wi-Fi or Cellular
- ✅ Not in Airplane Mode
- ✅ No VPN that might block iCloud services
- ✅ Firewall settings allow iCloud connections

**Test:**
- Open Safari and visit iCloud.com
- If you can access it, internet is working

---

## 🔐 CloudKit Dashboard

### 9. Check CloudKit Container

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard/)
2. Sign in with your Apple ID (same one in Xcode)
3. Select your container: **iCloud.VinPersonal.FamSphere**

**What to verify:**
- ✅ Container exists
- ✅ You have access to it
- ✅ Schema shows your record types (FamilyMember, ChatMessage, etc.)

**If container doesn't exist:**
- Xcode should create it automatically on first build
- Try running the app once, then check dashboard again

**If schema is missing:**
- This is normal for SwiftData (auto-generated)
- Schema appears after first data operation
- Run the app and create some test data

---

### 10. Check Development vs Production Environment

CloudKit has two environments:

- **Development:** Used during testing (default for debug builds)
- **Production:** Used for App Store builds

**Current Setup:**
Your debug builds use **Development** environment automatically.

**Common Issue:**
If you previously deployed schema to Production but now testing in Development, they might be out of sync.

**Fix:**
- For now, stay in Development
- Don't deploy to Production until ready for App Store
- Development environment is reset when you delete app

---

## 🧪 Testing Procedure

### 11. Test with Two Devices

**Requirements:**
- ✅ Two physical devices (iPhone/iPad)
- ✅ Two **different** Apple IDs
- ✅ Both devices signed into iCloud
- ✅ Both devices have internet connection
- ✅ FamSphere installed on both

**Test Steps:**

**Device A (Family Creator):**
1. Launch FamSphere
2. Complete onboarding
3. Go to **Settings** → **Family Sharing**
4. Tap **"Create Family Group"**
5. Wait for success message
6. Tap **"Invite Family Member"**
7. Wait for invitation link to generate
8. Tap **Share** button
9. Send via Messages/Email to Device B

**Device B (Family Member):**
1. Receive invitation link
2. Tap the link
3. Should open FamSphere (or App Store if not installed)
4. Accept invitation when prompted
5. Complete onboarding

**Expected Results:**
- ✅ Invitation link generated successfully on Device A
- ✅ Device B can open the link
- ✅ Device B sees "Join Family" prompt
- ✅ After accepting, Device B sees family data

---

## 🐛 Common Errors & Solutions

### Error: "Not authenticated to CloudKit"

**Cause:** Not signed into iCloud  
**Fix:**
1. Settings → [Your Name]
2. Sign in with Apple ID
3. Enable iCloud Drive
4. Force quit and restart FamSphere

---

### Error: "Container identifier not found"

**Cause:** Container ID mismatch  
**Fix:**
1. Check `CloudKitSharingManager.swift` line 27:
   ```swift
   private static let containerIdentifier = "iCloud.VinPersonal.FamSphere"
   ```
2. Verify it matches Xcode → Signing & Capabilities → iCloud → Containers
3. If different, update the code to match
4. Clean build folder (Cmd+Shift+K) and rebuild

---

### Error: "Operation couldn't be completed" (CloudKit error)

**Possible Causes & Fixes:**

**1. iCloud Drive disabled:**
- Enable in Settings → [Your Name] → iCloud → iCloud Drive

**2. Network connectivity:**
- Check internet connection
- Try switching between Wi-Fi and Cellular

**3. CloudKit quota exceeded:**
- Unlikely in development
- Check CloudKit Dashboard → Telemetry

**4. Entitlements mismatch:**
- Verify entitlements file (see #5 above)
- Delete app, clean build, reinstall

**5. Development environment issue:**
- Delete app from device
- Clean build folder (Cmd+Shift+K)
- Rebuild and reinstall

---

### Error: "Share URL is nil" or "Could not generate share link"

**Cause:** CKShare not created properly  
**Fix:**
1. Add logging to `CloudKitSharingManager.swift`:
   ```swift
   func generateInvitationLink() async throws -> URL {
       let share: CKShare

       if let existing = currentFamilyShare {
           print("✅ Using existing share")
           share = existing
       } else {
           print("🔵 Creating new family share...")
           share = try await createFamilyShare()
           print("✅ Family share created: \(share)")
       }

       guard let url = share.url else {
           print("❌ Share URL is nil!")
           print("   Share: \(share)")
           print("   Share owner: \(share.owner)")
           throw FamSphereCloudKitError.noShareURL
       }

       print("✅ Generated invitation URL: \(url)")
       return url
   }
   ```
2. Run app and check Xcode console for detailed output
3. Look for any errors in the creation process

---

### Error: Invitation link doesn't open the app

**This is NORMAL in development.**

**Why:**
- Associated domains require App Store distribution
- In development, the link opens Safari/Messages
- User must manually open FamSphere app

**Workarounds:**

**Option A: Manual Process (Development)**
1. Device B receives link
2. Tap link → Opens in browser (expected)
3. Copy the URL
4. Manually open FamSphere app
5. Create logic to detect clipboard contains FamSphere link
6. Auto-prompt to accept share

**Option B: Add Associated Domains (Advanced)**
1. Go to Signing & Capabilities
2. Add **Associated Domains** capability
3. Add domain: `applinks:yourdomain.com`
4. Configure apple-app-site-association file on your web server
5. This only works with real domain ownership

**For now, use Option A.** Option B is for production release.

---

## 📊 Debugging Workflow

### Step-by-Step Debug Process

**1. Enable Verbose Logging:**

Add this to `CloudKitSharingManager.swift`:

```swift
private func log(_ message: String) {
    #if DEBUG
    print("☁️ CloudKit: \(message)")
    #endif
}
```

Then add `log()` calls throughout:

```swift
func createFamilyShare() async throws -> CKShare {
    log("Creating family share...")
    
    let zoneID = CKRecordZone.ID(zoneName: "FamilyZone")
    log("Zone ID: \(zoneID)")
    
    // ... rest of code
}
```

**2. Check Console Output:**

After running app, look for:
- ✅ "ModelContainer initialized with CloudKit Private Database"
- ✅ "Creating family share..."
- ✅ "Generated invitation URL"

**3. Test Account Status:**

Add this to `FamilyManagementView`:

```swift
.task {
    do {
        let status = try await cloudKitManager.checkAccountStatus()
        print("☁️ CloudKit Account Status: \(status)")
        
        switch status {
        case .available:
            print("✅ CloudKit available")
        case .noAccount:
            print("❌ Not signed into iCloud")
        case .restricted:
            print("⚠️ iCloud access restricted")
        case .couldNotDetermine:
            print("⚠️ Could not determine iCloud status")
        case .temporarilyUnavailable:
            print("⚠️ iCloud temporarily unavailable")
        @unknown default:
            print("⚠️ Unknown CloudKit status")
        }
    } catch {
        print("❌ Error checking account status: \(error)")
    }
}
```

**4. Monitor CloudKit Dashboard:**

- Go to Telemetry section
- Watch for API calls in real-time
- Look for errors or failed requests

---

## 🎯 Quick Diagnostic Checklist

Use this to quickly identify the issue:

| Check | Status | Fix |
|-------|--------|-----|
| Signed into iCloud on device? | ☐ | Settings → [Your Name] |
| iCloud Drive enabled? | ☐ | Settings → iCloud → iCloud Drive |
| iCloud capability in Xcode? | ☐ | Signing & Capabilities → Add iCloud |
| Container ID matches code? | ☐ | Verify in both places |
| Valid signing certificate? | ☐ | Signing & Capabilities → Team |
| Internet connection working? | ☐ | Test in Safari |
| CloudKit Dashboard accessible? | ☐ | icloud.developer.apple.com |
| FamSphere.entitlements exists? | ☐ | Check project navigator |
| App has iCloud permissions? | ☐ | Settings → Privacy → iCloud |
| Using two DIFFERENT Apple IDs? | ☐ | Must be different accounts |
| Both devices have latest code? | ☐ | Rebuild and reinstall both |

---

## 🚀 If Nothing Works...

### Nuclear Option: Complete Reset

**1. Delete CloudKit Data:**
```swift
// Add this to FamSphereApp.swift debug section
#if DEBUG
private static func resetCloudKit() {
    Task {
        let container = CKContainer(identifier: "iCloud.VinPersonal.FamSphere")
        let database = container.privateCloudDatabase
        
        // Query all records
        let query = CKQuery(recordType: "FamilyZone", predicate: NSPredicate(value: true))
        
        do {
            let (results, _) = try await database.records(matching: query)
            
            for (recordID, _) in results {
                try? await database.deleteRecord(withID: recordID)
                print("🗑️ Deleted CloudKit record: \(recordID)")
            }
            
            print("✅ CloudKit reset complete")
        } catch {
            print("❌ CloudKit reset failed: \(error)")
        }
    }
}
#endif
```

**2. Complete Clean:**
1. Delete app from BOTH devices
2. In Xcode: Product → Clean Build Folder (Cmd+Shift+K)
3. Quit Xcode
4. Delete DerivedData:
   ```
   ~/Library/Developer/Xcode/DerivedData/FamSphere-*
   ```
5. Restart Mac (optional but helpful)
6. Open Xcode
7. Rebuild project
8. Install on both devices
9. Test again

**3. Verify Basics:**
- Both devices can access iCloud.com in Safari
- Both devices can use other iCloud features (Photos, Notes, etc.)
- Both devices show storage in Settings → [Your Name] → iCloud → Manage Storage

---

## 📞 Still Having Issues?

### Gather Diagnostic Info

Before asking for help, collect this info:

```
1. Xcode Version: _______
2. iOS Version (both devices): _______
3. Same Apple ID or different? _______
4. iCloud Drive enabled? Yes / No
5. Internet connection type: Wi-Fi / Cellular
6. Error message (exact text): _______
7. Console output when tapping "Invite": _______
8. CloudKit Dashboard shows container? Yes / No
9. Entitlements file exists? Yes / No
10. Container ID in code: _______
11. Container ID in Xcode: _______
```

### Check Apple System Status

Sometimes iCloud services have outages:
- Visit: [apple.com/support/systemstatus](https://www.apple.com/support/systemstatus/)
- Look for "iCloud" and "CloudKit" services
- If red or yellow, wait for Apple to fix

---

## ✅ Success Criteria

You'll know it's working when:

1. ✅ Device A can tap "Create Family Group" without errors
2. ✅ Device A can tap "Invite Family Member" and see share sheet
3. ✅ Device A can send invitation via Messages/Email
4. ✅ Device B receives the link
5. ✅ Device B's FamSphere shows "Join Family" prompt (after opening app)
6. ✅ Device B can accept and see family data
7. ✅ Changes on Device A appear on Device B within 30 seconds
8. ✅ Both devices show correct participant count in Settings

---

## 📝 Notes

### Expected Behaviors (Not Bugs)

**1. Link doesn't auto-open app:**
- Normal in development
- Will work in production with Associated Domains

**2. Sync takes 10-30 seconds:**
- CloudKit sync is not instant
- This is normal and expected

**3. Participant names show as "Family Member":**
- This happens if contact card permissions not granted
- Normal behavior for privacy

**4. First time slow:**
- Initial CloudKit setup takes longer
- Subsequent operations are faster

### Development vs Production Differences

| Feature | Development | Production |
|---------|-------------|------------|
| Schema changes | Allowed | Locked |
| Universal links | Don't work | Work |
| Data persistence | Can be reset | Permanent |
| Sync speed | Can be slower | Optimized |
| Quota limits | Lower | Higher |

---

## 🎉 Final Checklist

Before considering it "done":

- [ ] Two devices can create/join family successfully
- [ ] Invitation link generates without errors
- [ ] Share sheet appears and works
- [ ] Second device can accept invitation
- [ ] Data syncs between devices
- [ ] Can remove participants (if owner)
- [ ] Can leave family (if member)
- [ ] Error messages are user-friendly
- [ ] No crashes when offline
- [ ] No crashes when switching between profiles

---

**Last Updated:** January 25, 2026  
**FamSphere Version:** Development Build  
**Minimum iOS Version:** 17.0+

---

## Quick Reference Commands

**Clean build:**
```
Cmd + Shift + K (in Xcode)
```

**Delete DerivedData:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/FamSphere-*
```

**View CloudKit logs (in Terminal):**
```bash
log stream --predicate 'subsystem == "com.apple.cloudkit"' --level debug
```

**Check iCloud status (in Terminal):**
```bash
brctl log --wait --shorten
```

---

Good luck! 🍀

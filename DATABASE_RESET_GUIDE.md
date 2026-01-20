# How to Reset Your SwiftData Database

## Quick Reset Options

### Option 1: Use the Automatic Database Cleanup (Already Added)
The code now automatically deletes the database in DEBUG mode. Just:
1. **Clean Build Folder** (Shift+⌘+K)
2. **Delete the app** from simulator/device
3. **Rebuild and run**

The `deleteExistingDatabase()` function will run automatically in debug builds.

### Option 2: Manual Simulator Reset
If you're testing on the iOS Simulator:
1. **Device → Erase All Content and Settings...**
2. Or from Terminal: `xcrun simctl erase all`

### Option 3: Manual Device Reset
If testing on a real device:
1. **Delete the app** (long press → Remove App → Delete App)
2. In **Settings → General → iPhone Storage** → find "FamSphere" → Delete App
3. Reinstall from Xcode

### Option 4: Find and Delete Database Files Manually
SwiftData stores files in:
```
~/Library/Developer/CoreSimulator/Devices/[DEVICE-ID]/data/Containers/Data/Application/[APP-ID]/Library/Application Support/
```

Look for files like:
- `default.store`
- `default.store-shm`
- `default.store-wal`

Delete these and relaunch.

### Option 5: Use Custom Database URL (Advanced)
You can specify a custom database location and version it:

```swift
let modelConfiguration = ModelConfiguration(
    url: URL.documentsDirectory.appending(path: "FamSphere-v2.store"),
    schema: schema,
    cloudKitDatabase: .private(containerIdentifier)
)
```

When you change the schema significantly, increment the version number (v3, v4, etc.) to force a fresh database.

## What the Auto-Delete Does

The new `deleteExistingDatabase()` function:
1. ✅ Only runs in DEBUG builds (safe for production)
2. ✅ Scans Application Support directory
3. ✅ Deletes all `.store`, `.store-shm`, `.store-wal` files
4. ✅ Gives you a completely fresh start

## After Reset

Once the database is deleted, SwiftData will:
1. Create a new database with the current schema
2. No migration errors
3. No schema conflicts
4. Fresh start!

## CloudKit Considerations

If you're using CloudKit:
- Deleting the local database doesn't delete CloudKit data
- On first sync, CloudKit data will download again
- To completely reset CloudKit too, you need to:
  - Go to CloudKit Dashboard (developer.apple.com)
  - Delete the development schema
  - Reset development environment

## Recommendation

**Right now, do this:**
1. ✅ The auto-delete code is already in place
2. ✅ Clean Build Folder (Shift+⌘+K)
3. ✅ Delete the app completely
4. ✅ Rebuild and run
5. ✅ Watch the console - you should see "🗑️ Deleted: ..." messages

This should fix the `loadIssueModelContainer` error!

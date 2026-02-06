# TidyVibes - Quick Setup Guide

## Prerequisites

- macOS with Xcode 15.0+ installed
- iOS device or simulator running iOS 17.0+
- OpenAI API key (get one at https://platform.openai.com)

## Quick Start (5 minutes)

### Step 1: Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Select "iOS" → "App"
4. Configure:
   - Product Name: **TidyVibes**
   - Team: Select your team
   - Organization Identifier: com.yourdomain.tidyvibes
   - Interface: **SwiftUI**
   - Life Cycle: **SwiftUI App**
   - Language: **Swift**
   - Storage: Check **Use SwiftData**
   - Include Tests: Yes
5. Choose location and click "Create"

### Step 2: Add Source Files

1. In Finder, navigate to the `TidyVibes/TidyVibes/` directory from this repository
2. In Xcode, delete the default files Xcode created:
   - ContentView.swift
   - Item.swift (the default SwiftData model)
3. Drag and drop all folders from the repository into your Xcode project:
   - Models/
   - Services/
   - Views/
   - Utilities/
   - Resources/
   - Secrets/
4. When prompted, select:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to target: TidyVibes
5. Replace the existing `TidyVibesApp.swift` with the one from the repository

### Step 3: Configure Info.plist

1. In Xcode, open `Info.plist`
2. Add these keys (or copy from the repository's Info.plist):

```xml
<key>NSCameraUsageDescription</key>
<string>TidyVibes needs camera access to photograph your items</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>TidyVibes can import photos from your library</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>TidyVibes uses speech recognition for voice capture</string>
<key>NSMicrophoneUsageDescription</key>
<string>TidyVibes needs microphone access for voice input</string>
```

### Step 4: Set OpenAI API Key

**Option A: Environment Variable (Recommended)**

1. In Xcode: Product → Scheme → Edit Scheme
2. Select "Run" on the left
3. Go to "Arguments" tab
4. Under "Environment Variables", click "+"
5. Add:
   - Name: `OPENAI_API_KEY`
   - Value: `your-actual-api-key-here`

**Option B: Edit APIKeys.swift (Not recommended for git)**

Edit `TidyVibes/Secrets/APIKeys.swift` and hardcode your key (but don't commit it!):
```swift
static var openAI: String {
    return "your-actual-api-key-here"
}
```

### Step 5: Verify ikea_products.json

1. In Xcode's Project Navigator, find `Resources/ikea_products.json`
2. Click on it
3. In the File Inspector (right panel), verify:
   - ✅ Target Membership: TidyVibes is checked

### Step 6: Build & Run

1. Select a simulator (iPhone 15 Pro recommended) or real device
2. Press **Cmd+R** or click the Play button
3. First launch will show onboarding screens
4. Grant permissions when prompted:
   - Camera access
   - Microphone access
   - Speech recognition

## Testing the App

### Test Photo Capture
1. Complete onboarding
2. Tap "Add your first drawer"
3. Choose "Take a Photo"
4. Use a sample image or take a photo
5. AI will detect items (requires API key)
6. Review and save

### Test Voice Capture
1. Tap "Add your first drawer"
2. Choose "Speak Your Items"
3. Say: "scissors, five pens, tape, passport"
4. AI will parse the items
5. Review and save

### Test Search
1. After adding items, tap the search bar
2. Type an item name
3. See it highlighted in the spatial view

## Troubleshooting

### Build Errors

**Error: "Cannot find type 'StorageSpace' in scope"**
- Make sure all Models/ files are added to the target
- Clean build folder: Shift+Cmd+K
- Rebuild: Cmd+B

**Error: "Bundle.main.url(forResource:) returns nil"**
- Verify ikea_products.json has Target Membership checked
- Clean and rebuild

### Runtime Errors

**Camera not working**
- Check Info.plist has NSCameraUsageDescription
- Run on real device or simulator with camera support

**AI detection fails**
- Verify OpenAI API key is set correctly
- Check internet connection
- Check API key has credits

**Items not saving**
- SwiftData container may need reset
- Delete app and reinstall

## Project Structure Verification

Your Xcode project should look like:

```
TidyVibes
├── TidyVibes (folder - blue)
│   ├── TidyVibesApp.swift
│   ├── Models/
│   │   ├── StorageSpace.swift
│   │   ├── Item.swift
│   │   ├── IKEAProduct.swift
│   │   └── Enums.swift
│   ├── Services/
│   │   ├── VisionAPIProtocol.swift
│   │   ├── APIProviderManager.swift
│   │   ├── GeminiVisionService.swift
│   │   ├── GrokVisionService.swift
│   │   ├── IKEADataService.swift
│   │   ├── SpeechService.swift
│   │   ├── SearchService.swift
│   │   └── LayoutEngine.swift
│   ├── Views/
│   │   ├── Home/
│   │   ├── Capture/
│   │   ├── SpatialBookmark/
│   │   ├── Layout/
│   │   ├── Search/
│   │   └── Shared/
│   ├── Utilities/
│   │   ├── Constants.swift
│   │   └── Extensions.swift
│   ├── Resources/
│   │   └── ikea_products.json
│   ├── Secrets/
│   │   └── APIKeys.swift
│   └── Info.plist
└── TidyVibesTests/
```

## Next Steps

Once the app is running:

1. ✅ Test photo capture with real items
2. ✅ Test voice capture
3. ✅ Add multiple storage spaces
4. ✅ Test search functionality
5. ✅ Try layout suggestions
6. 📝 Report any bugs or issues

## Need Help?

Check the main README.md for detailed documentation and feature descriptions.

---

Happy organizing! 🪴

# TidyVibes iOS App

**Your spatial memory, externalized** — An iOS app that transforms hidden storage chaos into beautiful, searchable visual maps.

## Overview

TidyVibes helps you remember where everything is by creating living spatial bookmarks of your storage spaces. Photograph items, get AI-powered organization suggestions, and find anything in seconds.

## Features

### Core Features (MVP)
- ✅ Photo capture of items with AI detection (GPT-4V)
- ✅ Voice capture alternative for listing items
- ✅ IKEA storage database with known dimensions
- ✅ Custom storage dimensions support
- ✅ 2D spatial visualization (top-down view)
- ✅ Smart search with fuzzy matching
- ✅ AI-powered layout suggestions
- ✅ Multiple organization styles
- ✅ Onboarding flow

## Requirements

- Xcode 15.0+
- iOS 17.0+
- iPhone (optimized for iPhone 12 and later)
- OpenAI API key for GPT-4V

## Project Structure

```
TidyVibes/
├── TidyVibesApp.swift              # App entry point
├── Models/
│   ├── StorageSpace.swift          # SwiftData model for storage
│   ├── Item.swift                  # SwiftData model for items
│   ├── IKEAProduct.swift           # IKEA product data model
│   └── Enums.swift                 # StorageType, OrganizationStyle
├── Services/
│   ├── GPTService.swift            # OpenAI API integration
│   ├── IKEADataService.swift       # IKEA product database
│   ├── SpeechService.swift         # iOS Speech recognition
│   ├── SearchService.swift         # Fuzzy search logic
│   └── LayoutEngine.swift          # Layout algorithm
├── Views/
│   ├── Home/                       # Home screen & onboarding
│   ├── Capture/                    # Camera & voice capture flow
│   ├── SpatialBookmark/            # 2D visualization
│   ├── Layout/                     # AI suggestions
│   ├── Search/                     # Search interface
│   └── Shared/                     # Reusable components
├── Utilities/
│   ├── Constants.swift             # App colors, spacing
│   └── Extensions.swift            # Swift extensions
└── Resources/
    └── ikea_products.json          # IKEA dimension database
```

## Setup Instructions

### 1. Open in Xcode

1. Open Xcode 15.0 or later
2. Create a new iOS App project:
   - Product Name: `TidyVibes`
   - Organization Identifier: `com.yourdomain.tidyvibes`
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App
   - Language: Swift
   - Include Tests: Yes
   - Deployment Target: iOS 17.0

### 2. Add Files to Project

1. Copy all Swift files to your Xcode project
2. Ensure `ikea_products.json` is added to the project with "Target Membership" checked
3. Add `Info.plist` entries for camera, microphone, and speech recognition permissions

### 3. Configure API Key

Set your OpenAI API key as an environment variable:

```bash
export OPENAI_API_KEY="your-openai-api-key-here"
```

Or add it to your Xcode scheme:
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add `OPENAI_API_KEY` with your key

### 4. Build and Run

1. Select your target device (iPhone 12 or later recommended)
2. Press Cmd+R to build and run
3. Grant camera, microphone, and speech recognition permissions when prompted

## Usage

### First Run
1. Complete the 3-step onboarding
2. Tap "Add your first drawer"
3. Choose photo or voice capture

### Photo Capture Flow
1. Lay out items on a flat surface
2. Take a photo from above
3. AI detects and labels items
4. Review and correct any mistakes
5. Select IKEA storage or enter custom dimensions
6. Items are saved with spatial positions

### Voice Capture Flow
1. Tap microphone icon
2. List your items (e.g., "scissors, five pens, tape")
3. AI parses the list
4. Review and correct
5. Select storage and save

### Finding Items
1. Use the search bar on home screen
2. Type item name
3. See highlighted position in storage space

### Layout Suggestions
1. Open any storage space
2. Tap "Suggest Layout"
3. Review AI-organized arrangement
4. Choose organization style
5. Apply with one tap

## Technical Details

### Architecture
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **AI Services**: OpenAI GPT-4V
- **Pattern**: MVVM (Model-View-ViewModel)

### Key Technologies
- Apple Vision Framework (planned for future)
- iOS Speech Recognition Framework
- SwiftData for local persistence
- Async/await for API calls

### Layout Algorithm
- Semantic grouping via GPT-4
- Custom bin packing algorithm
- Multiple organization strategies:
  - Smart (AI-decided)
  - By Category
  - By Frequency
  - By Size
  - By Workflow

## Development Roadmap

### Phase 1: Foundation ✅
- SwiftData models
- Camera & voice capture
- GPT-4V integration
- IKEA database

### Phase 2: Visualization ✅
- 2D spatial view
- Search functionality
- Item management

### Phase 3: Intelligence ✅
- AI layout suggestions
- Organization styles
- Before/after comparison

### Phase 4: Polish (In Progress)
- Onboarding flow
- Voice updates
- Drag-to-rearrange
- Reference object sizing

## Known Limitations

- Requires internet for AI features (detection, grouping, layout suggestions)
- Currently supports inches for dimensions
- IKEA database limited to popular products
- Layout algorithm optimized for small-to-medium storage spaces

## Future Enhancements

- Apple Vision Framework for on-device detection
- AR visualization mode
- Shared household spaces
- Web dashboard
- Automatic change detection
- Barcode/QR scanning
- Fine-tuned semantic grouping model

## Testing

To test the app without real AI calls:
1. Mock GPTService responses in debug mode
2. Use sample IKEA products from JSON
3. Test with voice transcription disabled

## Contributing

This is an MVP for personal/beta testing. For feature requests or bug reports, please contact the maintainer.

## License

Proprietary - All rights reserved

---

**Built with ❤️ for people who lose things**

*"The joy is seeing your items present, beautifully arranged."*

# TidyVibes iOS App

**Your spatial memory, externalized** — An iOS app that transforms hidden storage chaos into beautiful, searchable visual maps.

## Overview

TidyVibes helps you remember where everything is by creating living spatial bookmarks of your storage spaces. Photograph items, get AI-powered organization suggestions, and find anything in seconds.

## Features

### Core Features
- Photo capture of items with AI detection (Gemini / Grok vision)
- Voice capture alternative for listing items
- Manual item entry
- IKEA storage database with known dimensions
- Custom storage dimensions support
- House / Room / Location / StorageSpace hierarchy
- 2D spatial visualization (top-down view)
- Interactive mind-map with drag reorder
- Smart search with fuzzy matching
- AI-powered layout suggestions with before/after comparison
- Multiple organization styles
- Multi-provider AI with automatic fallback
- Onboarding flow

## Requirements

- Xcode 15.0+
- iOS 17.0+
- iPhone (optimized for iPhone 12 and later)
- Google Gemini API key (primary AI provider)
- xAI Grok API key (backup AI provider)

## Project Structure

```
TidyVibes/
├── TidyVibesApp.swift              # App entry point
├── Models/
│   ├── House.swift                 # House (top-level hierarchy)
│   ├── Room.swift                  # Room within a house
│   ├── Location.swift              # Location within a room
│   ├── StorageSpace.swift          # SwiftData model for storage
│   ├── Item.swift                  # SwiftData model for items
│   ├── DetectedItem.swift          # AI detection result types
│   ├── IKEAProduct.swift           # IKEA product data model
│   └── Enums.swift                 # StorageType, OrganizationStyle
├── Services/
│   ├── VisionAPIProtocol.swift     # Provider-agnostic AI protocol
│   ├── APIProviderManager.swift    # Provider selection & fallback
│   ├── GeminiVisionService.swift   # Google Gemini (primary)
│   ├── GrokVisionService.swift     # xAI Grok (backup)
│   ├── LayoutImagePipeline.swift   # Multi-step layout image generation
│   ├── IKEADataService.swift       # IKEA product database
│   ├── SpeechService.swift         # iOS Speech recognition
│   ├── SearchService.swift         # Fuzzy search logic
│   └── LayoutEngine.swift          # Bin packing layout algorithm
├── Views/
│   ├── Home/                       # Home screen, mind map, hierarchy sections
│   ├── Capture/                    # Camera, voice & manual capture flows
│   ├── SpatialBookmark/            # 2D visualization
│   ├── Layout/                     # AI layout suggestions
│   ├── Search/                     # Search interface
│   ├── Hierarchy/                  # House/Room/Location CRUD
│   ├── Items/                      # Item management
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

### 3. Configure API Keys

Set your API keys as environment variables:

```bash
export GEMINI_API_KEY="your-gemini-api-key-here"
export GROK_API_KEY="your-grok-api-key-here"
```

Or add them to your Xcode scheme:
1. Product > Scheme > Edit Scheme
2. Run > Arguments > Environment Variables
3. Add `GEMINI_API_KEY` and `GROK_API_KEY` with your keys

### 4. Build and Run

1. Select your target device (iPhone 12 or later recommended)
2. Press Cmd+R to build and run
3. Grant camera, microphone, and speech recognition permissions when prompted

## Usage

### First Run
1. Complete the 3-step onboarding
2. Add a house, room, and location
3. Tap "Add Items" to start cataloging

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
2. Type item name (fuzzy matching supports typos)
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
- **AI Services**: Google Gemini 2.0 Flash (primary), xAI Grok-2 (backup)
- **Provider Abstraction**: Protocol-based with automatic failover
- **Pattern**: MVVM (Model-View-ViewModel)

### Key Technologies
- iOS Speech Recognition Framework
- SwiftData for local persistence
- Async/await for API calls
- MapKit for location-based mind map

### Layout Algorithm
- Semantic grouping via AI
- Custom bin packing algorithm
- Multiple organization strategies:
  - Smart (AI-decided)
  - By Category
  - By Frequency
  - By Size
  - By Workflow

### Layout Image Pipeline
1. Grok generates a text-based arrangement plan
2. Gemini generates a visualization image from the plan
3. Bounding box labels and styling are composited on top

## Development Roadmap

### Phase 1: Foundation
- SwiftData models
- Camera & voice capture
- AI vision integration
- IKEA database

### Phase 2: Visualization
- 2D spatial view
- Search functionality
- Item management

### Phase 3: Intelligence
- AI layout suggestions
- Organization styles
- Before/after comparison

### Phase 4: Polish
- Onboarding flow
- Voice updates
- Drag-to-rearrange items
- Reference object sizing

### Phase 5: Multi-Provider & Hierarchy (Current)
- Gemini + Grok API abstraction with fallback
- House / Room / Location hierarchy
- Manual item entry
- Layout image pipeline (Grok plans, Gemini renders)
- Mind-map with drag reorder
- Removed legacy OpenAI/GPT integration

## Known Limitations

- Requires internet for AI features (detection, grouping, layout suggestions)
- Currently supports inches for dimensions
- IKEA database limited to popular drawer units and boxes
- Layout algorithm optimized for small-to-medium storage spaces

## Future Enhancements

- Apple Vision Framework for on-device detection
- AR visualization mode
- Shared household spaces
- Web dashboard
- Automatic change detection
- Barcode/QR scanning
- Data migration for existing users (default room assignment)
- Expanded IKEA product catalog

## Testing

To test the app without real AI calls:
1. Mock VisionAPIProtocol responses in debug mode
2. Use sample IKEA products from JSON
3. Test with voice transcription disabled

## Contributing

This is an MVP for personal/beta testing. For feature requests or bug reports, please contact the maintainer.

## License

Proprietary - All rights reserved

---

**Built with care for people who lose things**

*"The joy is seeing your items present, beautifully arranged."*

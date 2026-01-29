# TidyVibes — Product Requirements Document v2 (MVP)

**Version:** 3.0
**Date:** January 29, 2026
**Author:** InfoRemix
**Status:** Phase 1-4 Complete (MVP) — Phase 5 In Planning

---

## Executive Summary

TidyVibes is a **spatial bookmark system for your belongings**—an iOS app that transforms hidden storage chaos into beautiful, searchable visual maps. By photographing items and storage spaces, users create living spatial bookmarks that help them remember where everything lives.

This isn't an inventory app. It's **external spatial memory** for brains that forget where things are.

**Core insight:** The problem isn't organization—it's *remembering where things are*. TidyVibes solves spatial recall and makes the journey of getting organized feel satisfying through instant visual feedback.

**Key differentiators:**
- Spatial visualization (see exactly where items are positioned)
- AI-powered layout suggestions (trained semantic grouping + algorithmic placement)
- ADHD-first design (fast capture, visual feedback, minimal friction)
- IKEA storage integration (known dimensions = accurate layouts)
- Multi-provider AI (Gemini primary, Grok backup — switchable)
- Room/Location hierarchy with FigJam-style mind map navigation
- AI-generated layout imagery via custom LLM + image generation pipeline

---

## The Problem

**"Where did I put that?"**

This question costs the average person 10 minutes per day searching for lost items. For ADHD individuals, it's exponentially worse—the frustration compounds into anxiety, the anxiety into avoidance, and the avoidance into clutter.

Existing solutions fail because they:
- Require tedious manual entry (Sortly, Chestly)
- Focus on inventory lists, not spatial memory (home insurance apps)
- Treat organization as a chore, not a satisfying experience
- Don't show you *where in the drawer* something is
- Can't suggest better arrangements

**The opportunity:** Create the first app that provides **instant visual gratification**—see your items beautifully arranged with AI-suggested layouts, and find anything in seconds with spatial precision.

---

## Target User

### Primary: Adults with ADHD (25-45)

**Behavioral profile:**
- Frequently loses items in their own home
- Has tried and abandoned organization systems
- Responds well to visual systems over text lists
- Needs immediate gratification, not delayed rewards
- Often has "junk drawers" that defeat them
- Gets dopamine from "before/after" transformations
- Likely owns IKEA storage (KALLAX, ALEX, MALM, etc.)

**Pain points:**
- "I know I have scissors somewhere..."
- "I organized this drawer last month and now I can't find anything"
- "Every organization app requires too much work upfront"
- "I start organizing, get overwhelmed, and quit"
- "Apps just give me a list—I need to SEE where things are"

**Why ADHD first:**
- Highest pain = highest motivation to adopt
- Underserved by existing solutions
- Word-of-mouth strong in ADHD communities
- If it works for ADHD, it works for everyone

### Secondary: IKEA storage owners seeking optimization

IKEA's standardized dimensions create a perfect MVP constraint—known drawer/shelf sizes mean accurate layout suggestions without complex dimension estimation.

---

## Product Vision

### The Magic Moment

User can't find their passport. They open TidyVibes, type "passport," and instantly see:
1. **Which drawer** it's in (bedroom ALEX, top drawer)
2. **Exactly where** in the drawer (back left corner, highlighted)
3. **Visual context** showing the item's position relative to other items

**Time from "where is it?" to "found it":** Under 5 seconds.

### The Joy Moment

User captures items from a messy drawer. TidyVibes instantly shows:
1. **Current state** visualized as a spatial map
2. **AI-suggested layout** with items grouped intelligently
3. **Before/after comparison** with satisfying visual transformation

The joy is seeing your chaos transformed into visual order—even before you physically reorganize.

### The Satisfying Loop

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│   CAPTURE ───→ SEE ───→ SUGGEST ───→ FIND ───→ UPDATE       │
│      │          │          │           │          │         │
│      │          │          │           │          │         │
│   "That was   "My items   "This      "Found     "Just      │
│    easy!"     look nice"  is smart"   it!"      moved      │
│                                                  it"        │
│   ◆ Quick     ◆ Visual    ◆ Helpful  ◆ Relief  ◆ Trust    │
│               Gratification                                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

Each step provides intrinsic satisfaction. No points. No streaks. Just the genuine pleasure of visual order and instant recall.

---

## MVP Scope

### What We're Building (6-8 weeks)

**Core features (P0 — Must have):**

| Feature | Description |
|---------|-------------|
| Photo capture (items) | Photograph items laid out on flat surface; AI detects and lists them |
| Voice fallback capture | When photo isn't practical, speak item list for AI to parse |
| IKEA storage selection | Choose from database of IKEA storage with known dimensions |
| Manual storage option | Custom dimensions for non-IKEA storage |
| Spatial bookmark view | 2D top-down visualization of items in their positions |
| Item search | "Where is X?" → visual result with highlighted position |
| Multiple storage spaces | Support for multiple drawers/cabinets/shelves |

**Intelligence features (P1 — Should have):**

| Feature | Description |
|---------|-------------|
| AI layout suggestions | Semantic grouping + algorithmic placement |
| Multiple organization styles | By category, frequency, size, workflow |
| Before/after comparison | Side-by-side current vs. suggested layout |
| Apply suggestion | One-tap to accept AI recommendation |

**Polish features (P2 — Nice to have):**

| Feature | Description |
|---------|-------------|
| Drag-to-rearrange | Manually adjust item positions |
| Voice updates | "I moved the scissors to the kitchen drawer" |
| Reference object dimensions | Credit card in frame for size estimation |
| Onboarding flow | Guided first-run experience |

**What we're NOT building (yet):**
- Social features / sharing
- Barcode/QR scanning
- Family/household accounts
- Web dashboard
- AR visualization
- Automatic change detection
- Non-IKEA furniture database

---

## Feature Details

### 1. Capture Flow

**Primary method: Flat surface photo**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Step 1: "Lay out your items on a flat surface"            │
│          (floor, table, bed — good lighting, spread apart)  │
│                                                             │
│  Step 2: Take photo from above                              │
│          ┌────────────────┐                                 │
│          │   📷 Camera    │                                 │
│          │                │                                 │
│          │  [items laid   │                                 │
│          │   out below]   │                                 │
│          │                │                                 │
│          └────────────────┘                                 │
│                                                             │
│  Step 3: AI processes, shows detected items                 │
│          ┌────────────────┐                                 │
│          │ ✓ Scissors     │                                 │
│          │ ✓ Tape (2)     │                                 │
│          │ ✓ Pens (5)     │                                 │
│          │ ? [unknown]    │  ← tap to name                  │
│          └────────────────┘                                 │
│                                                             │
│  Step 4: User confirms/corrects                             │
│          - Tap item to rename                               │
│          - Swipe to delete false positive                   │
│          - "Add item" for missed items                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Fallback method: Voice listing**

For situations where laying out items isn't practical:

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  [Can't lay out items? Tap to speak instead]                │
│                                                             │
│  User: "Scissors, two rolls of tape, about five pens,       │
│         my passport, some rubber bands, and batteries"      │
│                                                             │
│  AI parses to:                                              │
│  ┌────────────────┐                                         │
│  │ ✓ Scissors (1) │                                         │
│  │ ✓ Tape (2)     │                                         │
│  │ ✓ Pens (5)     │                                         │
│  │ ✓ Passport (1) │                                         │
│  │ ✓ Rubber bands │                                         │
│  │ ✓ Batteries    │                                         │
│  └────────────────┘                                         │
│                                                             │
│  Note: Voice capture won't have position data until         │
│  user arranges items in the spatial view                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Storage Selection

**IKEA-first approach (MVP focus):**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  What kind of storage is this?                              │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🔍 Search IKEA products...                          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Popular IKEA storage:                                      │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ ALEX         │  │ KALLAX      │  │ MALM          │      │
│  │ Drawer unit  │  │ Shelf unit  │  │ Chest         │      │
│  │ 14⅛×27½"     │  │ 13×13" cube │  │ Various       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ SKUBB        │  │ KUGGIS      │  │ TJENA         │      │
│  │ Box/insert   │  │ Box w/lid   │  │ Storage box   │      │
│  │ Various      │  │ 7×10×3"     │  │ Various       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                             │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  [Not IKEA? Enter custom dimensions]                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Custom storage (non-IKEA):**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Custom Storage Dimensions                                  │
│                                                             │
│  Name: [Kitchen junk drawer________________]                │
│                                                             │
│  Type: [Drawer ▼]                                          │
│         Drawer / Cabinet / Bin / Shelf / Other              │
│                                                             │
│  Dimensions (optional but helps with layout suggestions):   │
│                                                             │
│  Width:  [12  ] inches                                      │
│  Depth:  [18  ] inches                                      │
│  Height: [4   ] inches                                      │
│                                                             │
│  💡 Tip: Place a credit card in your photo for             │
│     automatic size estimation (coming soon)                 │
│                                                             │
│  [Skip dimensions for now]     [Continue]                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Spatial Bookmark Visualization

**Style:** Clean minimalist, 2D top-down view

```
        ┌─────────────────────────────────────────┐
        │     Kitchen Junk Drawer                 │
        │     ALEX drawer  •  12 items            │
        ├─────────────────────────────────────────┤
        │                                         │
        │  ┌───────┐  ┌─────┐  ┌──────────────┐  │
        │  │       │  │     │  │              │  │
        │  │ 🔧    │  │ ✂️  │  │  📦 tape     │  │
        │  │ tools │  │     │  │              │  │
        │  └───────┘  └─────┘  └──────────────┘  │
        │                                         │
        │  ┌──────────────┐  ┌────────┐          │
        │  │              │  │        │          │
        │  │   🔑 keys    │  │ 🔋     │          │
        │  │              │  │ batts  │          │
        │  └──────────────┘  └────────┘          │
        │                                         │
        │  ┌──────┐  ┌──────┐  ┌──────┐         │
        │  │ pens │  │rubber│  │ clips│          │
        │  │  (5) │  │bands │  │      │          │
        │  └──────┘  └──────┘  └──────┘         │
        │                                         │
        └─────────────────────────────────────────┘
        
        [🔍 Search]  [✨ Suggest layout]  [+ Add item]
```

**Visual specifications:**
- White/light cream background
- Subtle rounded rectangles for items
- Soft shadows for depth perception
- Item names + optional icons/emojis
- Quantity badges where applicable
- Storage boundary clearly defined
- Tap item → highlight + details panel

**Interaction:**
- Tap item → highlight + show details (name, quantity, date added)
- Long press → drag to rearrange (P2)
- Pinch to zoom
- Pan to scroll large storage spaces

### 4. AI Layout Suggestions

**The hybrid approach:**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  STEP 1: Semantic Grouping (Trained Model)                  │
│  ─────────────────────────────────────────                  │
│  Input: List of items                                       │
│  Output: Logical groups                                     │
│                                                             │
│  Items: scissors, tape, pens, keys, batteries, passport,    │
│         rubber bands, paper clips, screwdriver, charger     │
│                                                             │
│  Model identifies:                                          │
│  • Office supplies: pens, paper clips, rubber bands         │
│  • Tools: scissors, screwdriver, tape                       │
│  • Electronics: batteries, charger                          │
│  • Important docs: passport, keys                           │
│                                                             │
│  STEP 2: Algorithmic Placement (Bin Packing + Heuristics)   │
│  ─────────────────────────────────────────────────────────  │
│  Input: Groups + storage dimensions + organization style    │
│  Output: (x, y) positions for each item                     │
│                                                             │
│  Heuristics by style:                                       │
│  • By frequency: Daily items front, rare items back         │
│  • By category: Groups clustered together                   │
│  • By size: Large items edges, small items center           │
│  • By workflow: Related items adjacent                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Organization styles (user selects):**

| Style | Logic | Best for |
|-------|-------|----------|
| **Smart** (default) | AI decides based on item types | Most users |
| **By category** | Similar items grouped together | "Where are all my cables?" |
| **By frequency** | Daily items accessible, rare items back | Efficiency seekers |
| **By size** | Tetris-style space optimization | Small/crowded spaces |
| **By workflow** | Items used together stored together | Task-oriented users |

**Suggestion UI:**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ✨ Here's a smarter way to organize this:                  │
│                                                             │
│  ┌──────────────────┐     ┌──────────────────┐             │
│  │     CURRENT      │     │    SUGGESTED     │             │
│  │   [messy view]   │  →  │  [organized]     │             │
│  └──────────────────┘     └──────────────────┘             │
│                                                             │
│  💡 "Grouped your office supplies together and moved        │
│      frequently-used items to the front"                    │
│                                                             │
│  Style: [Smart ▼]                                          │
│                                                             │
│  [Apply this layout]     [Show different style]             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5. Search & Recall

**"Where is my X?"**

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ 🔍  passport                                    🎤  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ───────────────────────────────────────────────────────   │
│                                                             │
│  Found in: Bedroom ALEX (top drawer)                        │
│                                                             │
│      ┌─────────────────────────────────────┐               │
│      │                                     │               │
│      │      ┌─────────┐                    │               │
│      │      │ ★       │                    │               │
│      │      │PASSPORT │ ← HERE             │               │
│      │      └─────────┘                    │               │
│      │                                     │               │
│      │   [other items faded]               │               │
│      │                                     │               │
│      └─────────────────────────────────────┘               │
│                                                             │
│  [I found it!]    [It's not there → update location]       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Fuzzy matching:**
- Exact substring match (highest priority)
- Common synonyms: scissors↔shears, charger↔cable
- Typo tolerance: "scisorrs" → "scissors"
- Category search: "office supplies" → shows all matching items

### 6. Voice Updates (P2)

**Quick update flow:**

```
User taps microphone → "I moved the passport to my backpack"

App confirms: 
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Got it! Moving passport...                                 │
│                                                             │
│  From: Bedroom ALEX (top drawer)                            │
│  To:   Backpack                                             │
│                                                             │
│  ⚠️ "Backpack" is a new location. Create it?               │
│                                                             │
│  [Yes, create "Backpack"]    [Cancel]                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Supported voice commands (MVP):**
- "I moved [item] to [location]"
- "Add [item] to [location]"
- "[Item] is now in [location]"
- "Remove [item]" (for discarded items)

---

## Technical Architecture

### Constraints
- Solo developer
- 6-8 week timeline
- <$300 budget
- iOS first (iPhone 12+, iOS 17+)

### Stack

| Layer | Technology | Rationale |
|-------|------------|-----------|
| **Frontend** | SwiftUI | Native iOS, modern, fast iteration |
| **Local storage** | SwiftData | Modern Swift-native persistence, less boilerplate |
| **Vision AI (Primary)** | Google Gemini API | Multimodal vision + text, image generation capable |
| **Vision AI (Backup)** | xAI Grok API (grok-2-vision) | Fallback provider, switchable via protocol |
| **Semantic grouping** | Gemini / Grok with caching | LLM-based grouping, provider-agnostic |
| **Layout image generation** | Custom pipeline: Grok (plan) + Gemini (generate) | LLM plans arrangement, image API renders it |
| **Layout algorithm** | Custom bin packing | Constraint-based placement (local, no API) |
| **Voice** | iOS Speech framework | Free, built-in, accurate |
| **IKEA data** | Static JSON database | Scraped/compiled dimensions |
| **Visualization** | SwiftUI Canvas | Native, performant |

#### API Provider Strategy

TidyVibes uses a **protocol-based abstraction** (`VisionAPIProtocol`) that allows swapping AI providers without changing any view or business logic code.

```
┌─────────────────────────────────────────────────────────────┐
│                    VisionAPIProtocol                         │
│  ─────────────────────────────────────────────────────────  │
│  detectItems(in: UIImage) → [DetectedItem]                  │
│  parseVoiceInput(_ transcript: String) → [DetectedItem]     │
│  groupItems(_ items: [String]) → [ItemGroup]                │
│  generateLayoutImage(items:, storage:, plan:) → UIImage     │
└────────────────┬───────────────────────────┬────────────────┘
                 │                           │
    ┌────────────▼────────────┐  ┌───────────▼────────────┐
    │  GeminiVisionService    │  │  GrokVisionService     │
    │  (PRIMARY)              │  │  (BACKUP)              │
    │                         │  │                         │
    │  • Gemini 2.0 Flash     │  │  • grok-2-vision       │
    │  • Image generation     │  │  • Text-only fallback  │
    │  • Multi-turn context   │  │  • Fast inference      │
    └─────────────────────────┘  └─────────────────────────┘
```

**Provider selection** is controlled via `APIProviderConfig`:
- Default: Gemini (primary)
- Automatic fallback: If Gemini fails, retry with Grok
- Manual override: User can switch in app settings (dev mode)
- Environment variables: `GEMINI_API_KEY`, `GROK_API_KEY`

### IKEA Storage Database

Pre-compiled JSON with IKEA product dimensions:

```json
{
  "ikea_products": [
    {
      "id": "alex_drawer_unit",
      "name": "ALEX Drawer Unit",
      "product_id": "004.735.56",
      "type": "drawer_unit",
      "drawers": [
        {
          "position": 1,
          "width_inches": 12.625,
          "depth_inches": 16.875,
          "height_inches": 2.75
        },
        {
          "position": 2,
          "width_inches": 12.625,
          "depth_inches": 16.875,
          "height_inches": 5.5
        }
      ]
    },
    {
      "id": "kallax_insert",
      "name": "KALLAX Insert with 2 drawers",
      "product_id": "702.866.45",
      "type": "drawer_insert",
      "drawers": [
        {
          "width_inches": 13,
          "depth_inches": 13,
          "height_inches": 5.875
        }
      ]
    }
  ]
}
```

MVP includes: ALEX, KALLAX, MALM, HEMNES, NORDLI, KULLEN, BRIMNES drawer units + SKUBB, KUGGIS, TJENA boxes.

### AI Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  CAPTURE (via VisionAPIProtocol)                            │
│  ───────                                                    │
│  Photo → Gemini 2.0 Flash (vision + bounding boxes)         │
│       → [fallback: Grok-2-Vision]                           │
│       → User corrections                                    │
│       → Final item list with positions                      │
│                                                             │
│  VOICE + MANUAL ENTRY                                       │
│  ────────────────────                                       │
│  Speech → iOS Speech Framework (transcription)              │
│        → Gemini (parse to structured item list)             │
│        → [fallback: Grok]                                   │
│        → User corrections                                   │
│        → Final item list (no positions)                     │
│                                                             │
│  Manual → Comma-separated text input                        │
│        → Gemini (parse quantities + normalize names)        │
│        → User corrections                                   │
│        → Final item list (no positions)                     │
│                                                             │
│  LAYOUT SUGGESTION                                          │
│  ─────────────────                                          │
│  Items → Semantic Grouping (Gemini/Grok)                    │
│       → Groups + storage dimensions                         │
│       → Bin Packing Algorithm (local)                       │
│       → Style heuristics applied                            │
│       → Suggested (x, y) positions                          │
│                                                             │
│  LAYOUT IMAGE GENERATION (Custom Pipeline)                  │
│  ─────────────────────────────────────────                  │
│  Step 1: LLM Planning (Grok)                               │
│       → Input: item list + storage dimensions               │
│       → Output: arrangement plan with bounding boxes        │
│         e.g. "Place scissors top-left (0.1, 0.1, 0.2, 0.1)"│
│                                                             │
│  Step 2: Image Generation (Gemini)                          │
│       → Input: arrangement plan + item descriptions         │
│       → Output: rendered composite image of organized       │
│         storage with items placed per the plan              │
│                                                             │
│  Step 3: Composite & Present                                │
│       → Overlay bounding boxes on generated image           │
│       → Show to user as "what it could look like"           │
│       → Option to apply the arrangement                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Semantic Grouping Model

**Training approach:**

1. **Dataset creation:**
   - Compile list of common household items (1000+)
   - Label with categories: office, tools, electronics, documents, crafts, etc.
   - Include synonyms and variations

2. **Model options (in order of preference):**
   - **Option A:** Fine-tune a small classifier (e.g., DistilBERT) on item→category
   - **Option B:** Use GPT-4 with structured prompting + caching
   - **Option C:** Rule-based with keyword matching (fallback)

3. **Grouping output:**
   ```json
   {
     "groups": [
       {
         "category": "office_supplies",
         "items": ["pens", "paper clips", "rubber bands", "stapler"]
       },
       {
         "category": "tools",
         "items": ["scissors", "screwdriver", "tape"]
       }
     ]
   }
   ```

### Layout Algorithm

**Bin packing with style heuristics:**

```swift
func generateLayout(
    items: [Item],
    groups: [ItemGroup],
    storage: StorageDimensions,
    style: OrganizationStyle
) -> [ItemPosition] {
    
    // 1. Calculate item sizes (estimate from category if no photo)
    let sizedItems = estimateItemSizes(items)
    
    // 2. Apply style-specific ordering
    let orderedGroups = applyStyleOrdering(groups, style: style)
    
    // 3. Bin pack within storage constraints
    let positions = binPack(
        items: orderedGroups.flatMap { $0.items },
        container: storage,
        groupClustering: true
    )
    
    // 4. Apply style-specific positioning rules
    return applyStylePositioning(positions, style: style, storage: storage)
}

// Style heuristics
enum OrganizationStyle {
    case smart      // AI decides best approach
    case category   // Cluster by group, even spacing
    case frequency  // Front-to-back by usage (requires user input)
    case size       // Large items perimeter, small items center
    case workflow   // Related items adjacent (requires relationship data)
}
```

### Cost Estimate

| Service | Estimated monthly cost |
|---------|------------------------|
| Apple Developer Program | $99/year (~$8/mo) |
| Google Gemini API (vision + image gen) | ~$20-40/mo during dev |
| xAI Grok API (backup + layout planning) | ~$10-20/mo during dev |
| **Total** | ~$40-70/mo during development |

**Cost optimization:**
- Cache semantic grouping results (items don't change categories)
- Batch API calls where possible
- Gemini 2.0 Flash is significantly cheaper than GPT-4V for vision tasks
- Layout algorithm is entirely local (no API cost)
- Grok used only for layout planning text (cheap text-only calls)
- Auto-fallback means backup provider only used when primary fails

---

## Data Model

### Hierarchy: Room → Location → StorageSpace → Items

```
┌─────────────────────┐
│        Room         │
├─────────────────────┤
│ id: UUID            │
│ name: String        │  e.g. "Bedroom", "Kitchen", "Garage"
│ icon: String?       │  SF Symbol name
│ color: String?      │  Hex color for visual grouping
│ sortOrder: Int      │
│ isCollapsed: Bool   │  For mind map collapse state
│ createdAt: Date     │
│ locations: [Loc]    │  ◄── has many Locations
└────────┬────────────┘
         │
         │ 1:N
         ▼
┌─────────────────────┐
│      Location       │
├─────────────────────┤
│ id: UUID            │
│ name: String        │  e.g. "Closet", "Under desk", "Wall shelf"
│ sortOrder: Int      │
│ room: Room          │  ◄── belongs to Room
│ storageSpaces: [SS] │  ◄── has many StorageSpaces
└────────┬────────────┘
         │
         │ 1:N
         ▼
┌─────────────────────┐       ┌─────────────────────┐
│    StorageSpace     │       │        Item         │
├─────────────────────┤       ├─────────────────────┤
│ id: UUID            │       │ id: UUID            │
│ name: String        │       │ name: String        │
│ type: StorageType   │       │ category: String?   │
│ ikeaProductId: Str? │       │ quantity: Int       │
│ widthInches: Double │       │ positionX: Double   │
│ depthInches: Double │◄──────│ positionY: Double   │
│ heightInches: Double│       │ photo: Data?        │
│ photo: Data?        │       │ storageSpace: Ref   │
│ generatedImage: Data│       │ createdAt: Date     │
│ location: Location  │       │ lastMoved: Date?    │
│ createdAt: Date     │       └─────────────────────┘
│ updatedAt: Date     │
│ items: [Item]       │
└─────────────────────┘

┌─────────────────────┐
│   IKEAProduct       │
├─────────────────────┤
│ id: String          │
│ name: String        │
│ productId: String   │  (Static JSON, not SwiftData)
│ type: String        │
│ dimensions: [Dim]   │
└─────────────────────┘
```

### Home Screen: FigJam-Style Mind Map

The home screen displays rooms as **collapsible sections** in a fluid, mind-map-like hierarchy:

```
┌─────────────────────────────────────────────────────────────┐
│  TidyVibes                                          [+] [🔍]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ▼ 🛏️ Bedroom                                              │
│  │                                                          │
│  ├── 📍 Closet                                              │
│  │   ├── [ALEX Drawer Unit]  12 items                       │
│  │   └── [SKUBB Box]        4 items                         │
│  │                                                          │
│  ├── 📍 Nightstand                                          │
│  │   └── [Top Drawer]       6 items                         │
│  │                                                          │
│  └── 📍 Under Bed                                           │
│      └── [KUGGIS Box]       3 items                         │
│                                                             │
│  ▶ 🍳 Kitchen  (3 locations, 24 items)                      │
│                                                             │
│  ▶ 🏠 Living Room  (2 locations, 15 items)                  │
│                                                             │
│  ▼ 📦 Unsorted                                              │
│  │   └── [My Drawer]  5 items                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Interactions:**
- Tap room header → collapse/expand (like FigJam sections)
- Long press room/location/storage → drag to reorder or move between groups
- Swipe storage card → quick actions (edit, delete, move)
- Tap storage card → navigate to spatial bookmark detail
- Tap [+] → add Room, Location, or Storage (contextual)
- "Unsorted" section for storage spaces not yet assigned to a room

---

## UX Principles

### For ADHD Brains

1. **Immediate visual gratification** — See your items beautifully arranged instantly
2. **Two capture paths** — Photo when possible, voice when not (zero friction)
3. **Visual over verbal** — Show, don't tell; spatial maps over lists
4. **Forgiveness** — Easy to fix mistakes, nothing permanent
5. **One thing at a time** — Never overwhelm with choices
6. **Satisfying feedback** — Smooth animations, visual transformations
7. **Low commitment** — Can stop anytime, pick up later

### Design Language

| Element | Specification |
|---------|---------------|
| Typography | SF Pro (system), clean hierarchy |
| Colors | Warm neutrals (cream #FDF6E9, soft gray #F5F5F5) + teal accent (#2DD4BF) |
| Items | Rounded rectangles with subtle shadows |
| Animation | Smooth 0.3s transitions, satisfying snap-to-place |
| Spacing | Generous white space, 8pt grid |
| Icons | SF Symbols, consistent weight |

### Empty States

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│                        🪴                                   │
│                                                             │
│              Your spaces are waiting                        │
│                                                             │
│         Start with your messiest drawer.                    │
│         The one that defeats you every time.                │
│                                                             │
│              [+ Add your first drawer]                      │
│                                                             │
│         ─────────────────────────────────────               │
│         Takes about 2 minutes                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Success Metrics

### Primary (validates core hypothesis)

| Metric | Target | Why it matters |
|--------|--------|----------------|
| First storage completion rate | >60% | Can users get through capture? |
| Layout suggestion view rate | >70% | Are they seeing the magic? |
| Day 7 retention | >30% | Do they come back? |
| Search usage | >3 searches in first week | Are they using it to find things? |

### Secondary (informs iteration)

| Metric | Target | Why it matters |
|--------|--------|----------------|
| AI detection accuracy (accepted) | >70% | Is the AI good enough? |
| Layout suggestion acceptance | >40% | Are suggestions valuable? |
| Voice capture usage | >10% of captures | Is voice fallback needed? |
| IKEA vs custom storage | Track ratio | Is IKEA focus correct? |

---

## Competitive Moat

### Why spatial visualization + AI suggestions wins:

1. **Vorby** has AI detection but no spatial visualization—it's a list, not a map
2. **ShelfLily** has bulk scanning but no layout intelligence—it's inventory, not organization
3. **Nicher** has AR but requires manual entry—no AI detection
4. **None** have trained semantic grouping models for layout optimization

**TidyVibes's unique position:** The only app that creates a **visual spatial map** of your storage AND provides **intelligent layout suggestions** based on trained semantic understanding of item relationships.

### Defensibility:

- **Semantic grouping model** trained on household item relationships (hard to replicate quickly)
- **IKEA dimension database** (time investment, not technically hard)
- **ADHD-specific UX patterns** learned through iteration (institutional knowledge)
- **Layout algorithm** combining bin packing with organization heuristics

---

## Open Questions for Development

1. **Semantic grouping model approach?**
   - Fine-tuned classifier vs. prompted GPT-4 with caching
   - Need to test accuracy and latency tradeoffs

2. **Item size estimation without photo dimensions?**
   - Use category-based defaults (scissors ~6", pen ~5", etc.)
   - Or require photo capture for accurate layouts

3. **How to handle "frequency" organization style?**
   - Requires user input on which items are used daily
   - Could track search frequency as proxy over time

4. **What if AI detection is wrong and user doesn't correct?**
   - Accept gracefully—search still works on user's terms
   - Track correction rate to improve prompts

5. **Voice capture positioning?**
   - Place items in default grid until user arranges
   - Or prompt user to position each item after capture

---

## Phase 5: API Migration, Room Hierarchy, Item Lists & Layout Image Generation

### Overview

Phase 5 transforms TidyVibes from a flat-list MVP into a hierarchical, multi-provider, visually intelligent organizer. This phase introduces:

1. **API abstraction** — Replace OpenAI with Gemini (primary) + Grok (backup)
2. **Room/Location hierarchy** — Rooms contain Locations contain StorageSpaces
3. **Improved item entry** — Voice capture + comma-separated manual entry with results page
4. **FigJam-style home screen** — Collapsible mind map navigation
5. **AI layout image generation** — Custom pipeline producing visual layout previews

### 5.1 Multi-Provider API with Gemini + Grok

**Goal:** Decouple all AI calls from a single provider. Gemini becomes primary (vision + image generation), Grok becomes backup (vision + layout planning text).

**What changes:**
- `GPTService.swift` → deprecated, replaced by `VisionAPIProtocol`
- New `GeminiVisionService.swift` — primary provider
- New `GrokVisionService.swift` — backup provider
- New `APIProviderManager.swift` — handles provider selection + automatic fallback
- All existing views call through the protocol, no direct API references

**Comparison criteria for ongoing evaluation:**

| Criteria | Gemini | Grok | Notes |
|----------|--------|------|-------|
| Vision accuracy | TBD | TBD | Side-by-side item detection tests |
| Latency (photo) | TBD | TBD | Time from image send to parsed result |
| Latency (text) | TBD | TBD | Voice/manual parsing speed |
| Cost per call | TBD | TBD | Track in dev dashboard |
| Image generation | Yes (native) | No | Gemini-only capability |
| Bounding box quality | TBD | TBD | Accuracy of item positions |

### 5.2 Room → Location → StorageSpace Hierarchy

**Goal:** Users organize their storage spaces into a meaningful physical hierarchy that mirrors their real home.

**New models:**
- `Room` — top-level grouping (Bedroom, Kitchen, Garage, etc.)
- `Location` — mid-level grouping within a room (Closet, Under desk, Pantry shelf)
- `StorageSpace` gains a `location` relationship

**User flow for creating hierarchy:**
```
[+] Add Room → "Bedroom" (pick icon + color)
    [+] Add Location → "Closet"
        [+] Add Storage → ALEX Drawer Unit (existing flow)
```

**Migration:** Existing storage spaces move to an "Unsorted" pseudo-room until the user assigns them.

### 5.3 Item Entry: Voice + Manual Comma-Separated List

**Goal:** Two fast paths to create an item list for any storage space.

**Path A — Voice capture (existing, improved):**
- Tap microphone → speak items naturally
- Real-time transcript display
- AI parses transcript into structured item list
- Results page shows parsed items with edit/delete/add

**Path B — Manual comma-separated entry (new):**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Enter items (comma-separated):                             │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ scissors, tape x2, pens x5, passport, batteries     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [Process Items]                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

AI parses quantities (e.g., "tape x2" → tape, quantity 2), normalizes names, and presents the same review/results page.

**Results page (shared by both paths):**
```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Items detected (6):                                       │
│                                                             │
│  ☑ Scissors ............... qty 1    [Edit] [✕]             │
│  ☑ Tape .................. qty 2    [Edit] [✕]             │
│  ☑ Pens .................. qty 5    [Edit] [✕]             │
│  ☑ Passport .............. qty 1    [Edit] [✕]             │
│  ☑ Batteries ............. qty 1    [Edit] [✕]             │
│  ☑ Rubber bands .......... qty 1    [Edit] [✕]             │
│                                                             │
│  [+ Add another item]                                       │
│                                                             │
│  Saving to: Bedroom > Closet > ALEX Drawer Unit             │
│  ───────────────────────────────────────────────             │
│                                                             │
│  [Save Items]                                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

The "Saving to" line shows the full hierarchy path, tappable to change destination.

### 5.4 FigJam-Style Collapsible Home Screen

**Goal:** Replace the flat storage list with an interactive, collapsible mind-map-like tree view.

**Key behaviors:**
- Rooms are top-level collapsible sections with icons and item counts
- Collapsed rooms show summary: "3 locations, 24 items"
- Locations are sub-sections within rooms, also collapsible
- Storage spaces are leaf nodes, tappable to open detail view
- Long-press drag to reorder rooms, locations, or move storage between locations
- Smooth expand/collapse animations
- "Unsorted" section always at the bottom for unassigned storage

### 5.5 AI Layout Image Generation (Custom Pipeline)

**Goal:** When a user enters storage dimensions + items, generate a **visual preview** of what the organized storage could look like.

**The pipeline:**

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  INPUT                                                       │
│  ─────                                                       │
│  Items: ["scissors", "tape x2", "pens x5", "passport"]      │
│  Storage: ALEX Drawer (12.6" × 16.9" × 2.75")              │
│  Style: By Category                                          │
│                                                              │
│  STEP 1: LLM Arrangement Planning (Grok)                    │
│  ────────────────────────────────────────                    │
│  Prompt: "Given these items and this drawer size,            │
│  plan an organized arrangement. Output bounding boxes."      │
│                                                              │
│  Output:                                                     │
│  {                                                           │
│    "plan": "Group office supplies left, personal right",     │
│    "placements": [                                           │
│      {"item": "scissors", "region": "top-left",             │
│       "bbox": [0.05, 0.05, 0.25, 0.15]},                   │
│      {"item": "pens x5", "region": "left-center",           │
│       "bbox": [0.05, 0.25, 0.25, 0.20]},                   │
│      {"item": "tape x2", "region": "center",                │
│       "bbox": [0.35, 0.05, 0.30, 0.20]},                   │
│      {"item": "passport", "region": "top-right",            │
│       "bbox": [0.70, 0.05, 0.25, 0.15]}                    │
│    ]                                                         │
│  }                                                           │
│                                                              │
│  STEP 2: Image Generation (Gemini)                          │
│  ─────────────────────────────────                           │
│  Prompt: "Generate a top-down photo of an organized          │
│  drawer (12.6×16.9 inches) containing: scissors top-left,   │
│  5 pens left-center, 2 rolls of tape center, passport       │
│  top-right. Clean, well-lit, realistic."                    │
│                                                              │
│  Output: Generated image (stored as generatedImage on        │
│  StorageSpace)                                               │
│                                                              │
│  STEP 3: Composite & Present                                │
│  ─────────────────────────────                               │
│  Overlay labeled bounding boxes on the generated image       │
│  Show side-by-side: current state vs. generated preview      │
│  User can tap "Apply this arrangement" to update positions   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**User-facing flow:**
1. User opens a storage space → taps "Visualize organized layout"
2. Loading state: "Planning arrangement..." → "Generating preview..."
3. Result: Beautiful generated image of their storage, organized
4. Options: "Apply layout", "Try different style", "Regenerate"

---

## Next Steps (Phase 5 Implementation)

1. **Create `VisionAPIProtocol`** and `GeminiVisionService` — swap out OpenAI
2. **Create `GrokVisionService`** as backup provider
3. **Add `Room` and `Location` SwiftData models** with relationships
4. **Build collapsible mind-map home screen** with Room/Location/Storage tree
5. **Add comma-separated manual item entry** with shared results page
6. **Improve voice capture flow** with same results page
7. **Build layout image generation pipeline** (Grok planning + Gemini generation)
8. **Migrate existing data** — assign existing storage spaces to "Unsorted" room
9. **Test and iterate** — compare Gemini vs Grok detection quality

---

*"The joy is seeing your items present, beautifully arranged."*

Let's build spatial memory.

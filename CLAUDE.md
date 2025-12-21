# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

Always use iPhone 17 simulator for builds.

```bash
# Build for iOS Simulator
xcodebuild -project WhatThePuck.xcodeproj -scheme WhatThePuck -destination 'platform=iOS Simulator,name=iPhone 17' build

# Build for device (requires signing)
xcodebuild -project WhatThePuck.xcodeproj -scheme WhatThePuck -destination generic/platform=iOS build
```

## Architecture

WhatThePuck is an iOS espresso shot tracking app built with SwiftUI and SwiftData.

### Project Structure

```
WhatThePuck/
├── App/                    # App entry point and configuration
│   ├── WhatThePuckApp.swift
│   └── AppearanceConfiguration.swift
├── Features/               # Feature-based modules
│   ├── Shots/             # Shot tracking and history
│   ├── Beans/             # Coffee bean management
│   ├── Timer/             # Shot timing
│   └── Terminal/          # Typewriter-style messaging
├── Models/                 # SwiftData models
│   ├── Bean.swift
│   └── Shot.swift
└── Navigation/             # Tab navigation
    └── MainTabView.swift
```

### Data Layer
- **SwiftData** for persistence with `@Model` macro
- Two models: `Bean` (name, roaster, roastLevel, roastDate) and `Shot` (dose, yield, time, grind, notes)
- `Shot` has a required relationship to `Bean` with cascade delete
- Model container injected at app entry point via `.modelContainer(for: [Shot.self, Bean.self])`
- Views fetch data reactively using `@Query` property wrapper

### View Layer
- **TabView** navigation with three tabs: Shots, Timer, Beans
- `ShotListView` displays shots grouped by date
- `TimerView` runs a stopwatch and passes elapsed time to `ShotFormView`
- `BeanListView` manages coffee beans
- `TerminalView` provides typewriter-style onboarding and context messages
- All data mutations use `@Environment(\.modelContext)` for insert/delete operations

### Key Patterns
- Time stored as tenths of seconds (`Int`) for precision
- Computed properties on models for display formatting
- Sheet presentation for forms with `@Environment(\.dismiss)` for closing
- Feature-based modularization for code organization

## Requirements

- iOS 26+ (uses SwiftData, ContentUnavailableView)
- Swift 6
- Xcode 26

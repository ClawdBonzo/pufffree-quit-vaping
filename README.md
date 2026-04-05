# PuffFree - Quit Vaping & Nicotine Freedom Tracker

A beautiful, privacy-first iOS app to help users quit vaping and nicotine products. Built entirely with SwiftUI, SwiftData, and Swift 6 for iOS 18+.

**All data stays 100% on-device. No servers. No tracking. No accounts.**

## Features

### Core Tracking
- **Live Quit Timer** - Real-time countdown showing days, hours, minutes, and seconds since quitting
- **Money Saved Calculator** - See exactly how much you've saved based on your usage patterns
- **Puffs Avoided Counter** - Track how many puffs/cigarettes you've avoided
- **Life Regained Timer** - Estimated time added back to your life

### Health Recovery Timeline
- 12 science-backed health milestones from 1 hour to 5 years
- Visual progress indicators for each milestone
- Detailed descriptions of what's healing in your body

### Craving Tracker
- Log cravings with intensity, triggers, and coping strategies
- Track your resist rate and identify top triggers
- Weekly craving trends and analytics
- Quick-log for fast craving recording

### Journal & Daily Check-Ins
- Mood tracking (Great, Good, Okay, Struggling, Terrible)
- Daily check-in with craving level, energy, sleep quality
- Exercise and hydration tracking
- Gratitude and proud moments journal
- Tag system for organizing entries

### Milestones & Achievements
- 14 time-based milestones from 1 hour to 1 year
- Animated celebration screens with confetti
- Achievement grid with unlock dates

### Savings Projections
- Daily, weekly, monthly, and yearly projections
- Reward ideas based on money saved
- Visual progress toward spending goals

### Widgets
- Home screen widgets (small + medium)
- Lock screen widgets (circular, rectangular, inline)
- Real-time quit timer and stats at a glance

### Personalization
- Multi-step onboarding flow
- Support for multiple nicotine types (vape, cigarette, pouches, gum, etc.)
- Customizable usage patterns and costs
- Motivation selection and daily quotes

### Notifications
- Milestone celebration alerts
- Daily check-in reminders
- Motivational message rotation

## Onboarding Flow

1. **Welcome** - Name input and app introduction
2. **Nicotine Type** - Select primary nicotine product
3. **Usage Pattern** - Daily usage, cost, and nicotine strength
4. **Quit Date** - Set when you quit (or plan to)
5. **Motivation** - Select why you're quitting
6. **Notifications** - Enable milestone and motivation alerts

## Tech Stack

- **Language:** Swift 6
- **UI Framework:** SwiftUI (iOS 18+)
- **Persistence:** SwiftData (100% local, no CloudKit)
- **Architecture:** MVVM with @Observable
- **Widgets:** WidgetKit (Home + Lock Screen)
- **Notifications:** UserNotifications
- **Haptics:** UIImpactFeedbackGenerator

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0+

## Build Instructions

1. Clone the repository
2. Open `PuffFree.xcodeproj` in Xcode 16+
3. Select your development team in Signing & Capabilities
4. Add the App Group capability (`group.com.pufffree.app`) for widget data sharing
5. Build and run on a simulator or device

### Widget Setup
1. Add a Widget Extension target if not already present
2. Set the App Group to `group.com.pufffree.app` on both the main app and widget targets
3. Build and add widgets from the iOS home screen or lock screen

## Project Structure

```
PuffFree/
  App/           - App entry point and main ContentView
  Models/        - SwiftData models (UserProfile, CravingLog, etc.)
  ViewModels/    - @Observable view models
  Views/
    Onboarding/  - 6-step onboarding flow
    Dashboard/   - Main timer, stats, and motivation
    Health/      - Health recovery timeline
    Cravings/    - Craving tracker and history
    Journal/     - Journal entries and daily check-ins
    Milestones/  - Achievement grid and celebrations
    Savings/     - Money saved and projections
    Settings/    - Profile editing and app settings
    Components/  - Reusable UI components
  Managers/      - Notification and haptic managers
  Utilities/     - Constants and helpers
  Extensions/    - Date and Color extensions
  Theme/         - App-wide design system
  Resources/     - Asset catalogs

PuffFreeWidgets/ - Home screen and lock screen widgets
```

## Privacy

PuffFree is built with privacy as a core principle:
- **Zero data collection** - No analytics, no tracking
- **No accounts required** - No sign-up, no login
- **No network requests** - The app never connects to the internet
- **All data on-device** - SwiftData with local storage only
- **No third-party SDKs** - Pure Apple frameworks

## Screenshots

> Screenshots coming soon

## License

Private repository. All rights reserved.

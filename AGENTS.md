# Agent Rules

This is a SwiftUI iOS app.

## New Concepts

Put each new concept here:

```text
wallet/wallet/<ConceptName>/
  Assets/
  Components/
  Config/
  Helpers/
  Models/
  Pages/
```

Use the folders like this:

- `Assets/`: Concept-only images, icons, and other visual files.
- `Components/`: Small reusable SwiftUI views used inside the concept.
- `Config/`: Constants and tweakable values for layout, sizing, timing, and styling.
- `Helpers/`: Focused utility code that supports the concept's views.
- `Models/`: Data types, state enums, and layout structs for the concept.
- `Pages/`: Full-screen SwiftUI views that can be shown from the app entry point.

Current concept:

```text
wallet/wallet/Digilocker/
  Assets/
  Components/
  Config/
  Helpers/
  Models/
  Pages/
```

## App Start

The app starts from:

```text
wallet/wallet/iosconceptsApp.swift
```

To show a concept first, change the `WindowGroup` view:

```swift
WindowGroup {
    DigilockerMainPage()
}
```

## Before Finishing

- Check edited Swift files for Xcode issues.
- Build when practical.
- Do not change unrelated concepts.

## Global Rules

- Don't over-engineer — no abstractions or patterns beyond what's asked
- Styling and positioning live in the component file, not the parent
- Add short inline comments only where a value is meant to be tweaked
- Keep responses short and direct

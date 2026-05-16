# Agent Rules

This is a SwiftUI iOS app.

## New Concepts

Put each new concept here:

```text
wallet/wallet/<ConceptName>/
  Assets/
  Components/
  Pages/
```

Use the folders like this:

- `Assets`: files used only by this concept.
- `Components`: small reusable SwiftUI views.
- `Pages`: full screen views.

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

# iosconcepts

SwiftUI iOS app. A sandbox for polished UI concepts. Each concept is self-contained under `wallet/wallet/<ConceptName>/`.

## Active concept: Digilocker

A digital wallet UI — stacked cards, tap to expand, swipe to flip, gyroscope tilt.

### Key files

| File | Purpose |
|---|---|
| `wallet/iosconceptsApp.swift` | App entry — change `Main()` here to swap concepts |
| `wallet/Digilocker/Pages/Main.swift` | Root view; owns `FaceIDUnlockState`, passes card names to `Wallet` |
| `wallet/Digilocker/Components/Wallet.swift` | Card stack, expand/collapse, select, flip logic |
| `wallet/Digilocker/Components/Card.swift` | Individual card view; flip 3D, gyro tilt, shader sweep, animated stroke |
| `wallet/Digilocker/Config/WalletConfig.swift` | All tweakable constants (sizes, timings, colors, image names) |
| `wallet/Digilocker/Helpers/WalletLayoutCalculator.swift` | Pure math helpers (offsets, scales, animation delays) |
| `wallet/Digilocker/Models/WalletCardLayout.swift` | Layout struct per card slot |

### Concept folder structure

```
wallet/wallet/<ConceptName>/
  Assets/       images and icons
  Components/   reusable SwiftUI views
  Config/       constants and tweakable values
  Helpers/      focused utility code
  Models/       data types and state enums
  Pages/        full-screen views
```

## Rules

- Don't touch unrelated concepts
- All styling and positioning live in the component file, not the parent
- No abstractions beyond what's asked
- Short inline comments only where a value is meant to be tweaked
- Delete removed code fully — no stubs or commented-out blocks

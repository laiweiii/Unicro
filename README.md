# Unicro

Unicro is a layered SwiftUI interaction library organized around a single execution pipeline:

`Intent -> Resolver -> Interaction Pattern -> Gesture / Motion -> Layout / Animation -> Feedback -> UI`

## Layer Map

### Layer 1. Intent DSL

`InteractionKit/IKIntent.swift`

Defines product intent in a stable form:

- `verb`
- `target`
- `context`

Example:

```swift
let intent = IKIntent(
    verb: .open,
    target: .card
)
```

### Layer 2. Interaction Pattern

`InteractionKit/IKResolver.swift`
`InteractionKit/IKInteraction.swift`

This layer decides which interaction pattern fulfills an intent.

Example:

```swift
let resolved = IKResolver().resolve(
    IKIntent(verb: .open, target: .card)
)
```

### Layer 3. Interaction Primitives

`IntentKit`

Gesture input primitives live here:

- tap
- long press
- drag
- swipe
- pinch
- rotate

### Layer 4. Motion / Layout

`FluidKit`
`MoveKit`

These modules own motion and spatial behavior:

- expand layout
- sheet layout
- draggable grid
- fluid transitions

### Layer 5. Feedback

`StateKit`

Feedback and async state live here:

- loading
- shimmer
- state transitions

## Repo Structure

```text
Sources/Unicro
├── InteractionKit
│   ├── IKIntent.swift
│   ├── IKInteraction.swift
│   └── IKResolver.swift
├── IntentKit
├── MoveKit
├── FluidKit
├── StateKit
└── Extensions
```

## Current Positioning

- `IntentKit`: gesture input
- `InteractionKit`: behavior orchestration
- `MoveKit`: spatial motion
- `FluidKit`: animation / layout
- `StateKit`: feedback

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/laiweiii/Unicro.git", from: "1.0.0")
]
```

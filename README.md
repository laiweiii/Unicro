# Unicro

Unicro is a layered SwiftUI interaction library currently focused on traffic UX:

`Intent -> Resolver -> Interaction Pattern -> Gesture / Motion -> Layout / Animation -> Feedback -> UI`

## Layer Map

### Layer 1. Intent DSL

`InteractionKit/Core/IKIntent.swift`

Defines product intent in a stable form:

- `goal`
- `domain`
- `entity`
- `stage`
- `context`

Example:

```swift
let intent = IKIntent(
    goal: .inspect,
    domain: .traffic,
    entity: .incident,
    stage: .evaluation
)
```

### Layer 2. Interaction Pattern

`InteractionKit/Core/IKResolver.swift`
`InteractionKit/Core/IKInteraction.swift`
`InteractionKit/Core/IKInteractionBinder.swift`
`InteractionKit/Traffic/TrafficIntentMapping.swift`

This layer decides which interaction pattern fulfills an intent.

Example:

```swift
let resolved = IKResolver().resolve(
    IKIntent(
        goal: .manage,
        domain: .traffic,
        entity: .route,
        stage: .activeNavigation
    )
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

These modules own motion and spatial behavior used by traffic patterns:

- expand layout
- sheet layout
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
│   ├── Core
│   │   ├── IKIntent.swift
│   │   ├── IKInteraction.swift
│   │   ├── IKInteractionBinder.swift
│   │   ├── IKResolverProtocol.swift
│   │   └── IKResolver.swift
│   └── Traffic
│       └── TrafficIntentMapping.swift
├── IntentKit
│   └── GesturePrimitives
├── MoveKit
├── FluidKit
├── StateKit
└── Extensions
```

## Current Positioning

- `IntentKit`: gesture input
- `InteractionKit`: traffic intent orchestration
- `MoveKit`: spatial motion
- `FluidKit`: animation / layout
- `StateKit`: feedback

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/laiweiii/Unicro.git", from: "1.0.0")
]
```

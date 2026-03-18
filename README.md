# Unicro

Unicro is a layered SwiftUI interaction library currently focused on traffic UX:

`Intent -> Resolver -> Recipe -> Transformer -> Primitive / Motion / Feedback -> Existing View`

## Positioning

Unicro sits after static page structure and before final interaction code.

- Product teams still define screen structure, content, and business flows.
- Unicro turns interaction intent into a microinteraction recipe: pattern, transformer, motion, feedback, and capability.
- The output is not a business component like an incident sheet or booking form. It is the interaction logic that tells an existing view how to open, reveal, expand, or focus.

In practice, this means a developer can start from an existing SwiftUI page, describe what a part of the page should do, and use Unicro to get a consistent implementation direction for that microinteraction.

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
    domain: TrafficVocabulary.domain,
    entity: TrafficVocabulary.Entity.event,
    stage: .evaluation,
    context: .init(
        domainEntity: TrafficVocabulary.DomainEntity.incident
    )
)
```

### Layer 2. Interaction Pattern

`InteractionKit/Core/IKResolver.swift`
`InteractionKit/Core/IKInteraction.swift`
`InteractionKit/Core/IKInteractionBinder.swift`
`InteractionKit/Core/IKRuleEngine.swift`
`InteractionKit/Domain/Traffic/TrafficIntentMapping.swift`

This layer decides which interaction pattern and transformer fulfill an intent.

Example:

```swift
let resolved = IKResolver().resolve(
    IKIntent(
        goal: .manage,
        domain: TrafficVocabulary.domain,
        entity: TrafficVocabulary.Entity.journey,
        stage: .execution,
        context: .init(
            domainEntity: TrafficVocabulary.DomainEntity.route,
            domainState: TrafficVocabulary.DomainState.activeNavigation
        )
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
│   │   ├── IKRuleEngine.swift
│   │   ├── IKResolverProtocol.swift
│   │   └── IKResolver.swift
│   └── Domain
│       └── Traffic
│           ├── TrafficVocabulary.swift
│           └── TrafficIntentMapping.swift
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

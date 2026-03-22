# Unicro

Unicro is a SwiftUI microinteraction library focused on how existing pages move and behave consistently:

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

Defines interaction intent in a stable form:

- `goal`
- `domain`
- `entity`
- `stage`
- `context`

`domain` is now optional metadata. The motion and transformer pipeline does not depend on it.

Example:

```swift
let intent = IKIntent(
    goal: .inspect,
    entity: IKTransformerMapping.item,
    stage: .discovery
)
```

### Layer 2. Interaction Pattern

`InteractionKit/Core/IKResolver.swift`
`InteractionKit/Core/IKInteraction.swift`
`InteractionKit/Core/IKInteractionBinder.swift`
`InteractionKit/Core/IKRuleEngine.swift`
`InteractionKit/Core/IKTransformerMapping.swift`

This layer decides which transformer and interaction pattern fulfill an intent.

Example:

```swift
let resolved = IKResolver().resolve(
    IKIntent(
        goal: .manage,
        entity: IKTransformerMapping.item,
        stage: .execution,
        context: .init(
            isAsync: true,
            capability: .task(.manage)
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

These modules own motion and spatial behavior used by interaction transformers:

- expand layout
- sheet layout
- fluid transitions

### Layer 5. Feedback

`StateKit`

Feedback and async state live here:

- loading
- shimmer
- state transitions

## Core Structure

```text
Sources/Unicro
├── InteractionKit
│   ├── Core
│   │   ├── IKIntent.swift
│   │   ├── IKInteraction.swift
│   │   ├── IKInteractionBinder.swift
│   │   ├── IKInteractionExecutor.swift
│   │   ├── IKRuleEngine.swift
│   │   ├── IKResolverProtocol.swift
│   │   ├── IKResolver.swift
│   │   ├── IKTransformerMapping.swift
│   │   └── IKTransformerMotion.swift
├── IntentKit
│   └── GesturePrimitives
├── MoveKit
├── FluidKit
├── StateKit
└── Extensions
```

## Example Domains

Domain-specific mappings can still live under `InteractionKit/Domain`, but they are examples rather than part of the core motion pipeline.

Current example set:

```text
Sources/Unicro/InteractionKit/Domain
└── Traffic
    ├── TrafficVocabulary.swift
    └── TrafficIntentMapping.swift
```

## Current Positioning

- `IntentKit`: gesture input
- `InteractionKit`: transformer orchestration
- `MoveKit`: spatial motion
- `FluidKit`: animation / layout
- `StateKit`: feedback

`Domain/Traffic` is an example mapping layer, not a required part of the main architecture.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/laiweiii/Unicro.git", from: "1.0.0")
]
```

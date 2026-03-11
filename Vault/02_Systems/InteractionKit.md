---
tags: architecture/system
---
# InteractionKit

InteractionKit is the orchestration layer between intent and concrete UI behavior.

Responsibilities:

- define the public intent DSL
- resolve intent into an interaction pattern
- host capability mapping and binding helpers
- bridge high-level intent to existing kit capabilities

Core files:

- `Sources/Unicro/InteractionKit/IKIntent.swift`
- `Sources/Unicro/InteractionKit/IKUXIntent.swift`
- `Sources/Unicro/InteractionKit/IKResolver.swift`
- `Sources/Unicro/InteractionKit/IKInteraction.swift`
- `Sources/Unicro/InteractionKit/IKInteractionBinder.swift`

`IKUXIntent.swift` is kept only as a compatibility shim. `IKIntent` is the single source of truth.

Pipeline position:

[[Intent_Model]]
-> interaction resolver
-> interaction pattern
-> [[IntentKit]]
-> [[FluidKit]]
-> [[StateKit]]

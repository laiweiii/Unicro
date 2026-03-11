---
tags: architecture/system
---
# InteractionKit

InteractionKit is the orchestration layer between intent and concrete UI behavior.

Responsibilities:

- define the public intent DSL
- resolve intent into an interaction pattern
- bridge high-level intent to existing kit capabilities

Core files:

- `Sources/Unicro/InteractionKit/IKIntent.swift`
- `Sources/Unicro/InteractionKit/IKResolver.swift`
- `Sources/Unicro/InteractionKit/IKInteraction.swift`

Pipeline position:

[[Intent_Model]]
-> interaction resolver
-> interaction pattern
-> [[IntentKit]]
-> [[FluidKit]]
-> [[StateKit]]

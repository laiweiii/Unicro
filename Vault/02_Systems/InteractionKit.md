---
tags: architecture/system
---
# InteractionKit

InteractionKit is the orchestration layer for traffic intent and concrete UI behavior.

Responsibilities:

- define the public intent DSL
- resolve traffic intent into an interaction pattern
- host capability mapping and binding helpers
- bridge high-level intent to existing kit capabilities

Core files:

- `Sources/Unicro/InteractionKit/Core/IKIntent.swift`
- `Sources/Unicro/InteractionKit/Domain/Traffic/TrafficIntentMapping.swift`
- `Sources/Unicro/InteractionKit/Core/IKResolverProtocol.swift`
- `Sources/Unicro/InteractionKit/Core/IKResolver.swift`
- `Sources/Unicro/InteractionKit/Core/IKInteraction.swift`
- `Sources/Unicro/InteractionKit/Core/IKInteractionBinder.swift`

Pipeline position:

[[Intent_Model]]
-> interaction resolver
-> interaction pattern
-> [[IntentKit]]
-> [[FluidKit]]
-> [[StateKit]]

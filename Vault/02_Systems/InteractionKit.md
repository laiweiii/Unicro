---
tags: architecture/system
---
# InteractionKit

InteractionKit is the orchestration layer for transformer selection and microinteraction behavior.

Responsibilities:

- define the public intent DSL
- resolve interaction intent into an interaction pattern and transformer
- host capability mapping and binding helpers
- bridge high-level intent to existing kit capabilities

`domain` can still exist as metadata, but it is no longer a core decision axis for the main motion pipeline.

Core files:

- `Sources/Unicro/InteractionKit/Core/IKIntent.swift`
- `Sources/Unicro/InteractionKit/Core/IKRuleEngine.swift`
- `Sources/Unicro/InteractionKit/Core/IKTransformerMapping.swift`
- `Sources/Unicro/InteractionKit/Core/IKTransformerMotion.swift`
- `Sources/Unicro/InteractionKit/Core/IKResolverProtocol.swift`
- `Sources/Unicro/InteractionKit/Core/IKResolver.swift`
- `Sources/Unicro/InteractionKit/Core/IKInteraction.swift`
- `Sources/Unicro/InteractionKit/Core/IKInteractionBinder.swift`

Example domain files:

- `Sources/Unicro/InteractionKit/Domain/Traffic/TrafficVocabulary.swift`
- `Sources/Unicro/InteractionKit/Domain/Traffic/TrafficIntentMapping.swift`

These are examples, not part of the required core path.

Pipeline position:

[[Intent_Model]]
-> interaction resolver
-> interaction pattern
-> [[IntentKit]]
-> [[FluidKit]]
-> [[StateKit]]

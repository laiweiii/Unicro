---
tags: architecture/system  
---
# IntentKit

IntentKit is responsible for gesture input primitives.

Responsibilities:

- tap
- long press
- drag
- swipe
- pinch
- rotate

IntentKit is not the orchestration layer anymore. That role now lives in [[InteractionKit]].

Current code is organized under `Sources/Unicro/IntentKit/GesturePrimitives`.

Related modules:

[[InteractionKit]]
[[Execution_Pipeline]]

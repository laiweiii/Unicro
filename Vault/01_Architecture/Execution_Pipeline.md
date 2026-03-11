# Execution Pipeline

Unicro processes all interactions through a deterministic pipeline.

System pipeline:

[[Intent_Model]]
-> [[InteractionKit]]
-> interaction pattern
-> gesture and motion primitives
-> fluid layout
-> [[Feedback_Model]]

## Steps

1. User action generates [[Intent_Model]]
2. [[InteractionKit]] resolves intent into an interaction pattern
3. [[IntentKit]] and [[MoveKit]] provide gesture and motion primitives
4. [[FluidKit]] composes layout and animation
5. [[StateKit]] drives loading and feedback
6. UI renders the resulting state

This architecture ensures behavior is predictable and testable.

Related modules:

[[IntentKit]]
[[InteractionKit]]
[[MoveKit]]
[[StateKit]]
[[FluidKit]]
